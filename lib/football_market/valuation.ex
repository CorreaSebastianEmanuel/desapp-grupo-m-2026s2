defmodule FootballMarket.Valuation.Configurations.Version do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "valuation_configuration_versions" do
    field :strategy_id, :string
    field :formula_version, :string
    field :preset_key, :string, virtual: true
    field :rules, :map
    field :created_at, :utc_datetime_usec, read_after_writes: true
    field :config, :map, virtual: true
    field :references, :map, virtual: true
    field :requirements, :map, virtual: true
    field :position_mapping, {:array, :any}, virtual: true
  end
end

defmodule FootballMarket.Valuation.Configurations.SelectionLock do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :integer, autogenerate: false}

  schema "valuation_selection_locks" do
  end
end

defmodule FootballMarket.Valuation.Configurations.SelectionChange do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:change_order, :integer, autogenerate: false, read_after_writes: true}

  schema "valuation_selection_changes" do
    field :previous_version_id, :binary_id
    field :new_version_id, :binary_id
    field :effective_at, :utc_datetime_usec, read_after_writes: true
  end
end

defmodule FootballMarket.Valuation do
  @moduledoc """
  Player performance valuation formulas, strategy versions, educational presets,
  and active strategy switching.

  Two strategies are supported:
    * `"balanced"` — weighted sum of normalized per-90 overall metrics
    * `"position_aware"` — position-specific weights for GK, DEF, MID, and FWD

  All arithmetic uses standard `Decimal` (no floating-point drift) rounded to
  6 decimal places. Strategy versions and selection changes are append-only in
  PostgreSQL.
  """

  alias FootballMarket.Statistics
  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.Version

  @metrics ~w(
    goals assists shots_on_target tackles interceptions
    saves goals_conceded yellow_cards red_cards
  )a

  @groups [:goalkeeper, :defender, :midfielder, :forward]

  def metrics, do: @metrics
  def groups, do: @groups

  @doc """
  Evaluates a player's performances inside a `[week_start, week_end]` window
  using either the `:active` strategy or a specific `{:version, version_id}`.

  Returns `{:ok, %{score: Decimal.t(), version: Version.t(), performance_ids: [binary()]}}`
  or `{:error, reason}`.
  """
  def evaluate_player(player_id, %{week_start: _, week_end: _} = window, selector \\ :active) do
    with {:ok, version} <- resolve_version(selector),
         {:ok, performances} <- load_window_performances(player_id, window) do
      score_performances(performances, version)
    end
  end

  @doc "Computes a player's 6-decimal valuation score from a list of performances and a strategy version."
  def score_performances([], _version), do: {:error, :no_performances}

  def score_performances(performances, %Version{} = version) do
    Decimal.Context.with(%Decimal.Context{precision: 50}, fn ->
      with :ok <- verify_positive_minutes(performances),
           {:ok, raw_score} <- compute_strategy_score(performances, version) do
        {:ok,
         %{
           score: Decimal.round(raw_score, 6, :half_up),
           version: version,
           performance_ids: Enum.map(performances, & &1.id)
         }}
      end
    end)
  end

  # --- Scoring Implementation ---

  defp compute_strategy_score(performances, %Version{strategy_id: "balanced"} = version) do
    weights = version.config.weights
    references = version.references
    total_minutes = Enum.reduce(performances, 0, fn p, acc -> acc + (p.minutes_played || 0) end)

    with {:ok, features} <-
           normalized_metrics(performances, Map.keys(weights), references, total_minutes) do
      {:ok, weighted_sum(features, weights)}
    end
  end

  defp compute_strategy_score(performances, %Version{strategy_id: "position_aware"} = version) do
    mapping = Map.new(version.position_mapping)
    references = version.references

    grouped =
      Enum.reduce_while(performances, {:ok, %{}}, fn perf, {:ok, acc} ->
        case Map.get(mapping, perf.position_id) do
          nil -> {:halt, {:error, :unmapped_position}}
          group -> {:cont, {:ok, Map.update(acc, group, [perf], &[perf | &1])}}
        end
      end)

    with {:ok, by_group} <- grouped do
      total_minutes = Enum.reduce(performances, 0, fn p, acc -> acc + (p.minutes_played || 0) end)

      Enum.reduce_while(by_group, {:ok, Decimal.new(0)}, fn {group, group_perfs}, {:ok, acc} ->
        accumulate_group_score(group, group_perfs, version, references, total_minutes, acc)
      end)
    end
  end

  defp compute_strategy_score(_performances, _version), do: {:error, :unsupported_strategy}

  defp accumulate_group_score(group, group_perfs, version, references, total_minutes, acc) do
    group_weights = Map.fetch!(version.config.weights, group)
    group_minutes = Enum.reduce(group_perfs, 0, fn p, m -> m + (p.minutes_played || 0) end)
    share = Decimal.div(Decimal.new(group_minutes), Decimal.new(total_minutes))

    case normalized_metrics(group_perfs, Map.keys(group_weights), references, group_minutes) do
      {:ok, features} ->
        group_score = weighted_sum(features, group_weights)
        {:cont, {:ok, Decimal.add(acc, Decimal.mult(group_score, share))}}

      error ->
        {:halt, error}
    end
  end

  defp normalized_metrics(performances, required_metrics, references, total_minutes) do
    ninety = Decimal.new(90)
    mins = Decimal.new(total_minutes)

    Enum.reduce_while(required_metrics, {:ok, %{}}, fn metric, {:ok, acc} ->
      values = Enum.map(performances, &Map.get(&1, metric))

      if Enum.all?(values, &is_integer/1) do
        per_90 = Decimal.div(Decimal.mult(Decimal.new(Enum.sum(values)), ninety), mins)
        ref = to_decimal(Map.fetch!(references, metric))
        {:cont, {:ok, Map.put(acc, metric, Decimal.div(per_90, ref))}}
      else
        {:halt, {:error, {:missing_metric, metric}}}
      end
    end)
  end

  defp weighted_sum(features, weights) do
    Enum.reduce(weights, Decimal.new(0), fn {metric, weight}, acc ->
      feature = Map.fetch!(features, metric)
      Decimal.add(acc, Decimal.mult(feature, to_decimal(weight)))
    end)
  end

  defp verify_positive_minutes(performances) do
    total = Enum.reduce(performances, 0, fn p, acc -> acc + (p.minutes_played || 0) end)
    if total > 0, do: :ok, else: {:error, :zero_minutes}
  end

  defp load_window_performances(player_id, %{week_start: from_dt, week_end: to_dt} = window) do
    opts = [from: from_dt, to: to_dt]
    opts = if window[:season_id], do: Keyword.put(opts, :season_id, window.season_id), else: opts
    Statistics.list_player_history(player_id, opts)
  end

  defp resolve_version(:active), do: Configurations.active()
  defp resolve_version({:version, id}), do: Configurations.get(id)
  defp resolve_version(%Version{} = version), do: {:ok, version}
  defp resolve_version(_), do: {:error, :invalid_selector}

  defp to_decimal(%Decimal{} = d), do: d
  defp to_decimal(n) when is_integer(n), do: Decimal.new(n)
end

# --- Strategy Configuration Store, Presets & Administrator Facade ---

defmodule FootballMarket.Valuation.Configurations do
  @moduledoc """
  Manages immutable valuation strategy versions, educational presets, and
  active strategy selection (with PostgreSQL optimistic concurrency checks).
  """

  import Ecto.Query

  alias FootballMarket.Accounts
  alias FootballMarket.Catalog.Position
  alias FootballMarket.Repo
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.Configurations.{SelectionChange, SelectionLock, Version}

  @preset_roles %{
    "GK" => :goalkeeper,
    "DEF" => :defender,
    "MID" => :midfielder,
    "FWD" => :forward
  }
  @preset_families ["balanced", "position_aware"]

  # --- Administrator Facade ---

  def inspect_for(actor) do
    if Accounts.administrator?(actor) do
      with {:ok, presets} <- ensure_presets(),
           {:ok, data} <- list() do
        {:ok, %{data | versions: presets}}
      end
    else
      {:error, :forbidden}
    end
  end

  def activate_for(actor, target_id, expected_version_id) do
    if Accounts.administrator?(actor),
      do: activate_preset(target_id, expected_version_id),
      else: {:error, :forbidden}
  end

  defp activate_preset(target_id, expected_version_id) do
    with {:ok, presets} <- ensure_presets() do
      if Enum.any?(presets, &(&1.id == target_id)),
        do: activate(target_id, expected_version_id),
        else: {:error, :unsupported_configuration}
    end
  end

  # --- Persistence API ---

  @doc "Creates a new immutable strategy version."
  def create(rules) when is_map(rules) do
    with :ok <- validate_rules(rules) do
      encoded = encode_rules(rules)

      row =
        Repo.insert!(%Version{
          id: Ecto.UUID.generate(),
          strategy_id: rules.strategy_id,
          formula_version: rules.formula_version,
          rules: encoded
        })

      {:ok, hydrate(row)}
    end
  rescue
    _ -> {:error, :storage_unavailable}
  end

  def get(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %Version{} = row <- Repo.get(Version, uuid) do
      {:ok, hydrate(row)}
    else
      _ -> {:error, :not_found}
    end
  end

  def list do
    versions =
      Repo.all(from v in Version, order_by: [asc: v.created_at, asc: v.id])
      |> Enum.map(&hydrate/1)

    active_version =
      case active() do
        {:ok, v} -> v
        _ -> nil
      end

    changes =
      Repo.all(from c in SelectionChange, order_by: [asc: c.change_order])

    {:ok,
     %{
       active: active_version,
       active_version_id: active_version && active_version.id,
       versions: versions,
       history: changes
     }}
  end

  def active do
    case Repo.one(from c in SelectionChange, order_by: [desc: c.change_order], limit: 1) do
      nil -> {:error, %{reason: :no_active_configuration}}
      change -> get(change.new_version_id)
    end
  end

  def history do
    {:ok, Repo.all(from c in SelectionChange, order_by: [asc: c.change_order])}
  end

  @doc """
  Activates `target_id` as the active valuation strategy.
  Requires `expected_version_id` to match the current active version ID (or `nil`
  when activating for the first time) to prevent conflicting concurrent updates.
  """
  def activate(target_id, expected_version_id) do
    with {:ok, target_uuid} <- Ecto.UUID.cast(target_id),
         {:ok, target} <- get(target_uuid) do
      Repo.transaction(fn -> activate_locked!(target, target_uuid, expected_version_id) end)
    else
      _ -> {:error, :not_found}
    end
  end

  defp activate_locked!(target, target_uuid, expected_version_id) do
    ensure_selection_lock!()
    current = Repo.one(from c in SelectionChange, order_by: [desc: c.change_order], limit: 1)
    current_id = current && current.new_version_id

    cond do
      current_id != expected_version_id ->
        Repo.rollback(:predecessor_conflict)

      current_id == target_uuid ->
        Repo.rollback(:already_active)

      true ->
        change =
          Repo.insert!(%SelectionChange{
            previous_version_id: current_id,
            new_version_id: target_uuid
          })

        %{change: change, version: target}
    end
  end

  @doc "Ensures the two educational preset strategies (`balanced` and `position_aware`) exist."
  def ensure_presets do
    positions = Repo.all(from p in Position, where: p.code in ^Map.keys(@preset_roles))

    if length(positions) < 4 do
      {:error, :missing_positions}
    else
      mapping =
        positions
        |> Enum.map(fn p -> {p.id, Map.fetch!(@preset_roles, p.code)} end)
        |> Enum.sort()

      versions =
        Enum.map(@preset_families, fn strategy ->
          ensure_preset!(strategy, mapping)
        end)

      {:ok, versions}
    end
  rescue
    _ -> {:error, :storage_unavailable}
  end

  # --- Educational Preset Definitions ---

  def preset_rules(strategy, mapping) do
    common = %{yellow_cards: Decimal.new("-0.5"), red_cards: -2}

    weights =
      case strategy do
        "balanced" ->
          Map.merge(common, %{goals: 4, assists: 3})

        "position_aware" ->
          %{
            goalkeeper: Map.merge(common, %{goals: 4, assists: 3, saves: 4, goals_conceded: -2}),
            defender:
              Map.merge(common, %{
                goals: 4,
                assists: 3,
                shots_on_target: 1,
                tackles: 3,
                interceptions: 3
              }),
            midfielder:
              Map.merge(common, %{
                goals: 4,
                assists: 4,
                shots_on_target: Decimal.new("1.5"),
                tackles: 2,
                interceptions: 2
              }),
            forward: Map.merge(common, %{goals: 5, assists: 3, shots_on_target: 2})
          }
      end

    references = %{
      goals: 2,
      assists: 2,
      shots_on_target: 6,
      tackles: 8,
      interceptions: 6,
      saves: 10,
      goals_conceded: 4,
      yellow_cards: 2,
      red_cards: 1
    }

    required = if strategy == "balanced", do: Map.keys(weights), else: Valuation.metrics()

    %{
      strategy_id: strategy,
      formula_version: "1",
      config: %{weights: weights},
      references: Map.take(references, required),
      position_mapping: Enum.sort(mapping)
    }
  end

  # --- Rule Validation & Clean JSON Encoding ---

  defp validate_rules(%{
         strategy_id: strategy,
         formula_version: "1",
         config: %{weights: weights},
         references: refs,
         position_mapping: mapping
       })
       when strategy in @preset_families and is_map(weights) and is_map(refs) and is_list(mapping) and
              mapping != [] do
    valid_refs? =
      Enum.all?(refs, fn {metric, value} ->
        metric in Valuation.metrics() and positive_number?(value)
      end)

    if valid_refs?, do: :ok, else: {:error, :invalid_rules}
  end

  defp validate_rules(_), do: {:error, :invalid_rules}

  defp positive_number?(n) when is_integer(n), do: n > 0
  defp positive_number?(%Decimal{} = d), do: Decimal.positive?(d)
  defp positive_number?(_), do: false

  defp ensure_preset!(strategy, mapping) do
    digest =
      mapping
      |> Enum.map(fn {id, role} -> [id, Atom.to_string(role)] end)
      |> Jason.encode!()
      |> then(&:crypto.hash(:sha256, &1))
      |> Base.encode16(case: :lower)

    key = "#{strategy}:educational-v1:#{digest}"

    case Repo.query!("SELECT version_id FROM valuation_presets WHERE key = $1", [key]).rows do
      [[raw_id]] ->
        {:ok, version} = get(Ecto.UUID.load!(raw_id))
        %{version | preset_key: key}

      [] ->
        {:ok, version} = create(preset_rules(strategy, mapping))

        Repo.query!(
          "INSERT INTO valuation_presets (key, version_id) VALUES ($1, $2) ON CONFLICT (key) DO NOTHING",
          [key, Ecto.UUID.dump!(version.id)]
        )

        %{version | preset_key: key}
    end
  end

  defp ensure_selection_lock! do
    case Repo.get(SelectionLock, 1) do
      nil -> Repo.insert!(%SelectionLock{id: 1}, on_conflict: :nothing)
      _ -> :ok
    end
  end

  defp encode_rules(rules) do
    %{
      "schema_version" => 1,
      "weights" => encode_weights(rules.config.weights),
      "references" => encode_map(rules.references),
      "position_mapping" =>
        Enum.map(rules.position_mapping, fn {id, group} -> [id, Atom.to_string(group)] end)
    }
  end

  defp encode_weights(weights) do
    if Map.has_key?(weights, :goalkeeper) do
      Map.new(weights, fn {group, m} -> {Atom.to_string(group), encode_map(m)} end)
    else
      encode_map(weights)
    end
  end

  defp encode_map(map) do
    Map.new(map, fn {k, v} -> {Atom.to_string(k), to_string(v)} end)
  end

  defp hydrate(%Version{rules: rules} = row) do
    weights = decode_weights(rules["weights"] || get_in(rules, ["config", "weights"]))
    references = decode_metric_map(rules["references"])

    position_mapping =
      (rules["position_mapping"] || [])
      |> Enum.map(fn [id, group] -> {id, String.to_existing_atom(group)} end)

    %{
      row
      | config: %{weights: weights},
        references: references,
        requirements: derive_requirements(weights),
        position_mapping: position_mapping
    }
  end

  defp decode_weights(weights) when is_map(weights) do
    if Map.has_key?(weights, "goalkeeper") do
      Map.new(weights, fn {group, metrics} ->
        {String.to_existing_atom(group), decode_metric_map(metrics)}
      end)
    else
      decode_metric_map(weights)
    end
  end

  defp decode_weights([[group, _] | _] = list)
       when group in ["goalkeeper", "defender", "midfielder", "forward"] do
    Map.new(list, fn [g, pairs] -> {String.to_existing_atom(g), decode_metric_map(pairs)} end)
  end

  defp decode_weights(list) when is_list(list), do: decode_metric_map(list)

  defp decode_metric_map(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {String.to_existing_atom(k), decode_decimal(v)} end)
  end

  defp decode_metric_map(list) when is_list(list) do
    Map.new(list, fn [k, v] -> {String.to_existing_atom(k), decode_decimal(v)} end)
  end

  defp decode_decimal(v) when is_binary(v), do: Decimal.new(v)
  defp decode_decimal(%{"type" => "integer", "value" => v}), do: Decimal.new(v)

  defp decode_decimal(%{"type" => "decimal", "sign" => s, "coefficient" => c, "exponent" => e}) do
    %Decimal{sign: String.to_integer(s), coef: String.to_integer(c), exp: String.to_integer(e)}
  end

  defp derive_requirements(weights) do
    if Map.has_key?(weights, :goalkeeper) do
      Map.new(weights, fn {group, m} -> {group, Map.keys(m)} end)
    else
      %{overall: Map.keys(weights)}
    end
  end
end

# --- Valuation Ecto Schemas ---

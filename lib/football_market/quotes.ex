defmodule FootballMarket.Quotes.Mapping do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "quote_conversion_mappings" do
    field :name, :string
    field :version, :string
    field :schema_version, :integer, default: 1
    field :scale, :decimal
    field :rounding_rule, :string
    field :inserted_at, :utc_datetime_usec, read_after_writes: true
  end

  def changeset(mapping, attrs) do
    mapping
    |> cast(attrs, [:id, :name, :version, :scale, :rounding_rule])
    |> validate_required([:id, :name, :version, :scale, :rounding_rule])
    |> validate_number(:scale, greater_than: 0)
    |> validate_change(:rounding_rule, fn :rounding_rule, value ->
      if value == "two-half-away-v1", do: [], else: [rounding_rule: "unsupported"]
    end)
    |> unique_constraint([:name, :version], name: :quote_mapping_version_unique)
  end
end

defmodule FootballMarket.Quotes.Calculation do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "quote_calculations" do
    field :player_id, :binary_id
    field :season_id, :binary_id
    field :week_start, :utc_datetime_usec
    field :week_end, :utc_datetime_usec
    field :configuration_version_id, :binary_id
    field :mapping_id, :binary_id
    field :membership, {:array, :binary_id}
    field :canonical_identity, :map
    field :status, :string
    field :reason, :string
    field :score, :decimal
    field :unit_price, :decimal
    field :effective_at, :utc_datetime_usec
    field :evidence, :map
    field :inserted_at, :utc_datetime_usec
  end
end

defmodule FootballMarket.Quotes.CalculationRequest do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "quote_calculation_requests" do
    field :source, :string, default: "import"
    field :admission_key, :string
    field :snapshot_id, :binary_id
    field :intent_id, :binary_id
    field :player_id, :binary_id
    field :season_id, :binary_id
    field :week_start, :utc_datetime_usec
    field :week_end, :utc_datetime_usec
    field :selector, :string
    field :mapping_id, :binary_id
    field :requested_mapping_id, :binary_id
    field :configuration_version_id, :binary_id
    field :calculation_id, :binary_id
    field :explicit_membership, {:array, :binary_id}
    field :explicit_fact_material, :map
    field :state, :string
    field :attempt_count, :integer, default: 0
    field :lease_fence, :integer, default: 0
    field :lease_until, :utc_datetime_usec
    field :next_attempt_at, :utc_datetime_usec
    field :reason, :string
    field :initial_only, :boolean, default: false
    field :admitted_at, :utc_datetime_usec
    field :inserted_at, :utc_datetime_usec
  end
end

defmodule FootballMarket.Quotes.Evaluation do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "quote_evaluation_requests" do
    field :quote_id, :binary_id
    field :calculation_id, :binary_id
    field :player_id, :binary_id
    field :idempotency_key, :string
    field :state, :string, default: "pending"
    field :delivery_attempts, :integer, default: 0
    field :lease_fence, :integer, default: 0
    field :lease_started_at, :utc_datetime_usec
    field :lease_until, :utc_datetime_usec
    field :acknowledged_at, :utc_datetime_usec
    field :consumer_receipt, :string
    field :inserted_at, :utc_datetime_usec
  end
end

defmodule FootballMarket.Quotes do
  @moduledoc """
  Player token quotes: score-to-price conversion mappings, quote calculation
  and atomic publication, historical queries, and nightly market close.

  Everything related to quotes lives in this file:
    * `FootballMarket.Quotes` — mappings, convert, calculate/publish, latest/history/at_date, evaluation handoff
    * `FootballMarket.Quotes.{Mapping, Calculation, CalculationRequest, Evaluation}` — schemas
    * `FootballMarket.Quotes.Closing` — nightly close quote recalculation
  """

  import Ecto.Query

  alias FootballMarket.Catalog.Player
  alias FootballMarket.Market.Quote
  alias FootballMarket.Quotes.{Calculation, Evaluation, Mapping}
  alias FootballMarket.{Repo, Valuation}

  @rounding_rule "two-half-away-v1"

  # --- Conversion Mappings & Exact Cent Rounding ---

  @doc "Creates an immutable score-to-price conversion mapping."
  def save_mapping(name, version, %Decimal{} = scale)
      when is_binary(name) and is_binary(version) do
    if String.trim(name) != "" and String.trim(version) != "" and Decimal.positive?(scale) do
      %Mapping{}
      |> Mapping.changeset(%{
        id: Ecto.UUID.generate(),
        name: name,
        version: version,
        scale: scale,
        rounding_rule: @rounding_rule,
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
      })
      |> Repo.insert()
    else
      {:error, :invalid_mapping}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def save_mapping(_, _, _), do: {:error, :invalid_mapping}

  def get_mapping(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %Mapping{} = mapping <- Repo.get(Mapping, uuid) do
      {:ok, mapping}
    else
      _ -> {:error, :mapping_unavailable}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def rounding_rule, do: @rounding_rule

  @doc """
  Converts a valuation score to a 2-decimal unit price (`score * scale`)
  using exact half-away-from-zero rounding.
  """
  def convert(%Decimal{coef: s_coef} = score, %Decimal{coef: k_coef} = scale)
      when is_integer(s_coef) and is_integer(k_coef) do
    if Decimal.positive?(scale) do
      cents =
        %Decimal{
          sign: score.sign * scale.sign,
          coef: score.coef * scale.coef,
          exp: score.exp + scale.exp
        }
        |> round_to_cents()

      cond do
        cents > 0 ->
          {:ok, %Decimal{sign: 1, coef: cents, exp: -2}}

        Decimal.compare(score, Decimal.new(0)) != :gt ->
          {:no_quote, :nonpositive_score}

        true ->
          {:no_quote, :nonpositive_converted_result}
      end
    else
      {:error, :invalid_scale}
    end
  end

  def convert(_, _), do: {:error, :invalid_decimal}

  # --- Quote Calculation & Atomic Publication ---

  @doc """
  Evaluates a player's performances in `[week_start, week_end]` under `selector`
  (`:active` or `{:version, id}`), converts the score using `mapping_id`, and
  atomically persists the calculation, market quote, and conditional-order
  evaluation event.

  Idempotent: repeating the exact same player/window/strategy/mapping/facts
  returns the previously persisted calculation and quote.
  """
  def calculate_and_publish(subject, selector, mapping_id) when is_map(subject) do
    with {:ok, mapping} <- get_mapping(mapping_id),
         {:ok, eval} <- Valuation.evaluate_player(subject.player_id, subject, selector) do
      persist_calculation(subject, eval, mapping)
    end
  end

  # --- Local Quote Queries ---

  def list_history(player_id) do
    with {:ok, id} <- validate_player_id(player_id) do
      {:ok,
       Repo.all(
         from q in Quote,
           where: q.player_id == ^id,
           order_by: [
             asc: fragment("COALESCE(?, 0)", q.performance_sequence),
             asc: q.inserted_at,
             asc: q.id
           ]
       )}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def latest(player_id), do: select_quote(player_id, nil)

  def at_date(player_id, %Date{calendar: Calendar.ISO} = date) do
    case DateTime.new(date, ~T[23:59:59.999999], "Etc/UTC") do
      {:ok, cutoff} -> select_quote(player_id, cutoff)
      _ -> {:error, :invalid_date}
    end
  end

  def at_date(_, _), do: {:error, :invalid_date}

  # --- Quote Evaluation Event Handoff (Used by Conditional Orders) ---

  def pending_evaluations do
    now = db_now!()

    Repo.all(
      from e in Evaluation,
        where: e.state == "pending" or (e.state == "leased" and e.lease_until <= ^now),
        order_by: [asc: e.inserted_at, asc: e.id],
        limit: 100
    )
  end

  def claim_evaluation(event_id, lease_seconds \\ 300) do
    now = db_now!()
    lease_until = DateTime.add(now, lease_seconds, :second)

    Repo.transaction(fn ->
      event = Repo.one(from e in Evaluation, where: e.id == ^event_id, lock: "FOR UPDATE")

      cond do
        is_nil(event) ->
          Repo.rollback(:not_found)

        event.state == "acknowledged" ->
          Repo.rollback(:already_acknowledged)

        event.state == "leased" and DateTime.compare(event.lease_until, now) == :gt ->
          Repo.rollback(:already_leased)

        true ->
          fence = event.lease_fence + 1

          updated =
            event
            |> Ecto.Changeset.change(
              state: "leased",
              delivery_attempts: event.delivery_attempts + 1,
              lease_fence: fence,
              lease_started_at: now,
              lease_until: lease_until
            )
            |> Repo.update!()

          %{event: updated, fence: fence}
      end
    end)
  end

  def acknowledge_evaluation(event_id, fence, receipt) when is_binary(receipt) do
    now = db_now!()

    Repo.transaction(fn ->
      event = Repo.one(from e in Evaluation, where: e.id == ^event_id, lock: "FOR UPDATE")

      cond do
        is_nil(event) ->
          Repo.rollback(:not_found)

        event.state == "acknowledged" and event.consumer_receipt == receipt ->
          :ok

        event.state != "leased" or event.lease_fence != fence ->
          Repo.rollback(:lease_mismatch)

        true ->
          event
          |> Ecto.Changeset.change(
            state: "acknowledged",
            lease_started_at: nil,
            lease_until: nil,
            acknowledged_at: now,
            consumer_receipt: receipt
          )
          |> Repo.update!()

          :ok
      end
    end)
    |> case do
      {:ok, :ok} -> :ok
      error -> error
    end
  end

  def db_now! do
    [[now]] = Repo.query!("SELECT clock_timestamp() AT TIME ZONE 'UTC'").rows
    DateTime.from_naive!(now, "Etc/UTC")
  end

  # --- Private Helpers ---

  defp persist_calculation(subject, eval, mapping) do
    membership = Enum.sort(eval.performance_ids)
    version = eval.version

    canonical_identity = %{
      "player_id" => subject.player_id,
      "season_id" => subject.season_id,
      "week_start" => DateTime.to_iso8601(subject.week_start),
      "week_end" => DateTime.to_iso8601(subject.week_end),
      "configuration_version_id" => version.id,
      "mapping_id" => mapping.id,
      "membership" => membership
    }

    Repo.transaction(fn ->
      Repo.one!(from p in Player, where: p.id == ^subject.player_id, lock: "FOR UPDATE")

      case Repo.one(from c in Calculation, where: c.canonical_identity == ^canonical_identity) do
        %Calculation{} = existing ->
          quote = Repo.one(from q in Quote, where: q.calculation_id == ^existing.id)
          %{calculation: existing, quote: quote}

        nil ->
          insert_new_calculation!(subject, eval, mapping, membership, canonical_identity)
      end
    end)
  end

  defp insert_new_calculation!(subject, eval, mapping, membership, canonical_identity) do
    now = db_now!()
    version = eval.version
    calc_id = Ecto.UUID.generate()

    evidence = %{
      "strategy_id" => version.strategy_id,
      "formula_version" => version.formula_version,
      "configuration_version_id" => version.id,
      "mapping_id" => mapping.id,
      "mapping_name" => mapping.name,
      "mapping_version" => mapping.version,
      "scale" => Decimal.to_string(mapping.scale),
      "rounding_rule" => mapping.rounding_rule,
      "score" => Decimal.to_string(eval.score),
      "membership" => membership
    }

    case convert(eval.score, mapping.scale) do
      {:ok, unit_price} ->
        calc =
          Repo.insert!(%Calculation{
            id: calc_id,
            player_id: subject.player_id,
            season_id: subject.season_id,
            week_start: subject.week_start,
            week_end: subject.week_end,
            configuration_version_id: version.id,
            mapping_id: mapping.id,
            membership: membership,
            canonical_identity: canonical_identity,
            status: "successful",
            score: eval.score,
            unit_price: unit_price,
            effective_at: now,
            evidence: evidence,
            inserted_at: now
          })

        next_seq =
          (Repo.one(
             from q in Quote,
               where: q.player_id == ^subject.player_id,
               select: max(q.performance_sequence)
           ) || 0) + 1

        quote =
          Repo.insert!(%Quote{
            player_id: subject.player_id,
            unit_price: unit_price,
            effective_at: now,
            inserted_at: now,
            rule_id: version.strategy_id,
            rule_version: version.formula_version,
            calculation_id: calc.id,
            configuration_version_id: version.id,
            mapping_id: mapping.id,
            performance_sequence: next_seq
          })

        Repo.insert!(%Evaluation{
          id: Ecto.UUID.generate(),
          quote_id: quote.id,
          calculation_id: calc.id,
          player_id: subject.player_id,
          idempotency_key: "quote:" <> quote.id,
          state: "pending",
          delivery_attempts: 0,
          lease_fence: 0,
          inserted_at: now
        })

        %{calculation: calc, quote: quote}

      {:no_quote, reason} ->
        calc =
          Repo.insert!(%Calculation{
            id: calc_id,
            player_id: subject.player_id,
            season_id: subject.season_id,
            week_start: subject.week_start,
            week_end: subject.week_end,
            configuration_version_id: version.id,
            mapping_id: mapping.id,
            membership: membership,
            canonical_identity: canonical_identity,
            status: "no_quote",
            reason: Atom.to_string(reason),
            score: eval.score,
            unit_price: nil,
            effective_at: nil,
            evidence: evidence,
            inserted_at: now
          })

        %{calculation: calc, quote: nil}
    end
  end

  defp select_quote(player_id, cutoff) do
    with {:ok, id} <- validate_player_id(player_id) do
      query =
        from q in Quote,
          where: q.player_id == ^id,
          order_by: [
            desc: fragment("COALESCE(?, 0)", q.performance_sequence),
            desc: q.effective_at,
            desc: q.inserted_at,
            desc: q.id
          ],
          limit: 1

      query = if cutoff, do: where(query, [q], q.effective_at <= ^cutoff), else: query

      case Repo.one(query) do
        nil -> {:error, :quote_not_found}
        quote -> {:ok, quote}
      end
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp validate_player_id(value) do
    uuid_pattern = ~r/\A[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\z/

    with true <- is_binary(value) and Regex.match?(uuid_pattern, value),
         {:ok, id} <- Ecto.UUID.cast(value),
         true <- Repo.exists?(from p in Player, where: p.id == ^id) do
      {:ok, id}
    else
      _ -> {:error, :player_not_found}
    end
  end

  defp round_to_cents(%Decimal{sign: sign, coef: coef, exp: exp}) do
    signed = coef * sign
    cent_exp = exp + 2

    if cent_exp >= 0 do
      signed * Integer.pow(10, cent_exp)
    else
      divisor = Integer.pow(10, -cent_exp)
      whole = div(abs(signed), divisor)
      remainder = rem(abs(signed), divisor)
      rounded = if remainder * 2 >= divisor, do: whole + 1, else: whole
      if signed < 0, do: -rounded, else: rounded
    end
  end
end

# --- Quotes Schemas ---

# --- Nightly Market Close ---

defmodule FootballMarket.Quotes.Closing do
  @moduledoc "Recalculates quotes for players with recorded performances at nightly market close."

  import Ecto.Query

  alias FootballMarket.Catalog.Player
  alias FootballMarket.{Quotes, Repo}
  alias FootballMarket.Statistics.{Match, Performance}

  @doc "Recalculates quotes for every player who has performances in the current window."
  def run_close(now \\ DateTime.utc_now()) do
    case Application.get_env(:football_market, :quote_mapping_id) do
      mapping_id when is_binary(mapping_id) ->
        recalculate_all_players(mapping_id, now)

      _ ->
        {:ok, %{calculated: 0, skipped: 0}}
    end
  end

  defp recalculate_all_players(mapping_id, now) do
    week_start = DateTime.add(now, -7 * 86_400, :second) |> DateTime.truncate(:microsecond)
    week_end = DateTime.truncate(now, :microsecond)

    player_rows =
      Repo.all(
        from p in Player,
          join: perf in Performance,
          on: perf.player_id == p.id and perf.season_id == p.season_id,
          join: m in Match,
          on: m.id == perf.match_id,
          where: m.kickoff_at >= ^week_start and m.kickoff_at <= ^week_end,
          distinct: p.id,
          select: %{player_id: p.id, season_id: p.season_id}
      )

    counts =
      Enum.reduce(player_rows, %{calculated: 0, skipped: 0}, fn row, acc ->
        subject = Map.merge(row, %{week_start: week_start, week_end: week_end})

        case Quotes.calculate_and_publish(subject, :active, mapping_id) do
          {:ok, %{quote: %FootballMarket.Market.Quote{}}} ->
            %{acc | calculated: acc.calculated + 1}

          _ ->
            %{acc | skipped: acc.skipped + 1}
        end
      end)

    {:ok, counts}
  end
end

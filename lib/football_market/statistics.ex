defmodule FootballMarket.Statistics.Count do
  @moduledoc false
  use Ecto.Type

  def type, do: :decimal
  def cast(nil), do: {:ok, nil}
  def cast(n) when is_integer(n) and n >= 0, do: {:ok, n}
  def cast(_), do: :error
  def dump(nil), do: {:ok, nil}
  def dump(n) when is_integer(n) and n >= 0, do: {:ok, Decimal.new(n)}
  def dump(_), do: :error
  def load(nil), do: {:ok, nil}

  def load(%Decimal{coef: coef} = value) when is_integer(coef) do
    if Decimal.compare(value, 0) != :lt and Decimal.equal?(value, Decimal.round(value, 0)),
      do: {:ok, Decimal.to_integer(value)},
      else: :error
  end

  def load(_), do: :error
end

defmodule FootballMarket.Statistics.Match do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "matches" do
    field :match_identity, :string
    field :normalized_identity, :string, read_after_writes: true
    field :kickoff_at, :utc_datetime_usec
    field :season_id, :binary_id
    field :home_team_id, :binary_id
    field :away_team_id, :binary_id
    field :season_league_id, :binary_id
    field :season_start_year, :integer
    field :season_end_year, :integer
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(attrs, season) do
    %__MODULE__{}
    |> cast(attrs, [:match_identity, :kickoff_at, :season_id, :home_team_id, :away_team_id])
    |> put_change(:season_league_id, season.league_id)
    |> put_change(:season_start_year, season.start_year)
    |> put_change(:season_end_year, season.end_year)
    |> unique_constraint(:match_identity, name: :matches_season_identity_index)
    |> check_constraint(:match_identity, name: :matches_identity_not_blank)
    |> check_constraint(:away_team_id, name: :matches_distinct_teams)
    |> foreign_key_constraint(:season_id, name: :matches_season_witness_fkey)
    |> foreign_key_constraint(:home_team_id, name: :matches_home_team_id_season_fkey)
    |> foreign_key_constraint(:away_team_id, name: :matches_away_team_id_season_fkey)
  end
end

defmodule FootballMarket.Statistics.Performance do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias FootballMarket.Statistics.Count

  @metrics ~w(
    goals assists shots_on_target tackles interceptions
    saves goals_conceded yellow_cards red_cards
  )a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "player_match_performances" do
    belongs_to :match, FootballMarket.Statistics.Match
    field :player_id, :binary_id
    field :team_id, :binary_id
    field :position_id, :binary_id
    field :position_basis, :string, default: "legacy_direct"
    field :participation, :string
    field :position_reason, :string
    field :position_evidence, :map
    field :season_id, :binary_id
    field :minutes_played, Count
    for metric <- @metrics, do: field(metric, Count)
    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  def changeset(attrs, match) do
    cs =
      %__MODULE__{}
      |> cast(attrs, [:match_id, :player_id, :team_id, :position_id, :minutes_played] ++ @metrics)
      |> put_change(:season_id, match.season_id)
      |> unique_constraint(:player_id, name: :performances_player_match_index)
      |> foreign_key_constraint(:match_id, name: :performances_match_id_season_fkey)
      |> foreign_key_constraint(:player_id, name: :performances_player_id_season_fkey)
      |> foreign_key_constraint(:team_id, name: :performances_team_id_season_fkey)
      |> foreign_key_constraint(:position_id, name: :player_match_performances_position_id_fkey)
      |> check_constraint(:team_id, name: :performances_participation)
      |> check_constraint(:position_id, name: :performances_position_evidence_state)

    Enum.reduce([:minutes_played | @metrics], cs, fn f, acc ->
      check_constraint(acc, f, name: "performances_#{f}_count")
    end)
  end
end

defmodule FootballMarket.Statistics.Enrichment do
  @moduledoc "Overlays additive metric enrichments on top of original performances."
  use Ecto.Schema
  import Ecto.Query
  alias FootballMarket.Repo

  @fields ~w(
    minutes_played goals assists shots_on_target tackles interceptions
    saves goals_conceded yellow_cards red_cards
  )a

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "performance_enrichments" do
    field :performance_id, :binary_id
    field :check_id, :binary_id
    field :values, :map
    field :revision, :integer
  end

  def overlay([]), do: []

  def overlay(rows) do
    ids = Enum.map(rows, & &1.id)

    latest =
      Repo.all(from e in __MODULE__, where: e.performance_id in ^ids, order_by: e.revision)
      |> Map.new(fn row ->
        {row.performance_id, Map.new(@fields, &{&1, row.values[Atom.to_string(&1)]})}
      end)

    Enum.map(rows, fn row -> struct!(row, Map.get(latest, row.id, %{})) end)
  end
end

defmodule FootballMarket.Statistics.ScopeCheck do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Query
  alias FootballMarket.Repo

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "statistics_import_scopes" do
    field :provider, :string
    field :identity_namespace, :string
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :season_id, :binary_id
    field :player_id, :binary_id
    field :last_checked_at, :utc_datetime_usec
    field :last_accepted_check_id, :binary_id
  end

  def find(provider, season_id, nil) do
    Repo.one(
      from s in __MODULE__,
        where: s.provider == ^provider and s.season_id == ^season_id and is_nil(s.player_id),
        order_by: [desc_nulls_last: s.last_checked_at],
        limit: 1
    )
  end

  def find(provider, season_id, player_id) do
    Repo.one(
      from s in __MODULE__,
        where:
          s.provider == ^provider and s.season_id == ^season_id and s.player_id == ^player_id,
        order_by: [desc_nulls_last: s.last_checked_at],
        limit: 1
    )
  end
end

defmodule FootballMarket.Statistics do
  @moduledoc """
  Immutable completed-match statistics, player history, season summaries,
  direct provider import, and freshness/refresh status.

  Everything related to match statistics lives in this file:
    * `FootballMarket.Statistics` — record matches/performances, query history & summaries, import
    * `FootballMarket.Statistics.{Count, Match, Performance, Enrichment, ScopeCheck}` — schemas
    * `FootballMarket.Statistics.Freshness` — TTL freshness check & async refresh admission
  """

  import Ecto.Query

  alias FootballMarket.Catalog.{Player, Position, Season, Team}
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.{Enrichment, Match, Performance, ScopeCheck}

  @metrics ~w(
    goals assists shots_on_target tackles interceptions
    saves goals_conceded yellow_cards red_cards
  )a

  def metrics, do: @metrics

  # --- Recording Matches & Performances ---

  @doc "Records a completed match inside a season-locked transaction."
  def record_match(attrs) when is_map(attrs) do
    transact(fn ->
      with {:ok, clean} <- validate_match_input(attrs),
           :ok <- lock_seasons!([clean.season_id]) do
        insert_match(clean)
      end
    end)
  end

  def record_match(_), do: validation_error(:match, :invalid_shape)

  @doc "Records a single player's performance in an existing match."
  def record_performance(attrs) when is_map(attrs) do
    transact(fn ->
      with {:ok, clean} <- validate_performance_input(attrs),
           {:ok, match} <- fetch_ref(Match, clean.match_id, :match_id),
           :ok <- lock_seasons!([match.season_id]) do
        insert_performance(clean, match)
      end
    end)
  end

  def record_performance(_), do: validation_error(:performance, :invalid_shape)

  @doc """
  Imports normalized matches and performances from an external provider into
  the local database idempotently. Existing matches/performances are reused.
  Returns `{:ok, %{matches_added: n, performances_added: m, changed_player_ids: [...]}}`.
  """
  def import_performances(season_id, envelopes, opts \\ []) when is_list(envelopes) do
    provider = Keyword.get(opts, :provider, "external")
    player_id = Keyword.get(opts, :player_id)
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    Repo.transaction(fn ->
      season = Repo.get!(Season, season_id) |> Repo.preload(:league)
      lock_seasons!([season.id])

      result =
        Enum.reduce(envelopes, %{matches_added: 0, performances_added: 0, player_ids: []}, fn env,
                                                                                              acc ->
          import_envelope!(season, env, acc)
        end)

      upsert_scope_check!(season, provider, player_id, now)

      %{
        matches_added: result.matches_added,
        performances_added: result.performances_added,
        changed_player_ids: Enum.uniq(result.player_ids)
      }
    end)
  end

  defp import_envelope!(season, env, acc) do
    {match, added_match?} = ensure_match!(season, env.match)

    Enum.reduce(
      env.performances,
      bump_match(acc, added_match?),
      &ensure_performance!(match, &1, &2)
    )
  end

  # --- Queries & Immutability Guards ---

  def get_match(id), do: fetch_by_id(Match, id, :match_id)

  def get_match(season_id, identity) do
    with {:ok, sid} <- cast_uuid(season_id, :season_id),
         {:ok, ident} <- validate_identity(identity),
         {:ok, _season} <- fetch_by_id(Season, sid, :season_id) do
      normalized = ident |> String.trim() |> String.downcase()

      case Repo.one(
             from m in Match, where: m.season_id == ^sid and m.normalized_identity == ^normalized
           ) do
        nil -> {:error, :not_found}
        match -> {:ok, match}
      end
    end
  end

  def get_performance(player_id, match_id) do
    with {:ok, pid} <- cast_uuid(player_id, :player_id),
         {:ok, mid} <- cast_uuid(match_id, :match_id),
         {:ok, _} <- fetch_by_id(Player, pid, :player_id),
         {:ok, _} <- fetch_by_id(Match, mid, :match_id) do
      case Repo.one(from p in Performance, where: p.player_id == ^pid and p.match_id == ^mid) do
        nil -> {:error, :absent_performance}
        performance -> {:ok, performance}
      end
    end
  end

  def update_match(id, _attrs), do: immutable(Match, id, :match_id)
  def delete_match(id), do: immutable(Match, id, :match_id)
  def update_performance(id, _attrs), do: immutable(Performance, id, :performance_id)
  def delete_performance(id), do: immutable(Performance, id, :performance_id)

  @doc "Lists a player's completed match performances, optionally filtered by `:from`/`:to`."
  def list_player_history(player_id, opts \\ []) do
    with {:ok, pid} <- cast_uuid(player_id, :player_id),
         {:ok, bounds} <- validate_bounds(opts),
         {:ok, _} <- fetch_by_id(Player, pid, :player_id) do
      query =
        from p in Performance,
          join: m in Match,
          on: m.id == p.match_id,
          where: p.player_id == ^pid,
          order_by: [asc: m.kickoff_at, asc: m.id, asc: p.id],
          preload: [match: m]

      query =
        if bounds.from,
          do: from([p, m] in query, where: m.kickoff_at >= ^bounds.from),
          else: query

      query =
        if bounds.to, do: from([p, m] in query, where: m.kickoff_at <= ^bounds.to), else: query

      query =
        if bounds.season_id,
          do: from([p, _m] in query, where: p.season_id == ^bounds.season_id),
          else: query

      {:ok, Repo.all(query) |> Enrichment.overlay()}
    end
  end

  @doc "Summarizes recorded local season totals for a player (nil for incomplete metrics)."
  def recorded_summary(%{id: id, season_id: season_id}) do
    rows =
      Repo.all(
        from p in Performance,
          join: m in Match,
          on: m.id == p.match_id,
          where: p.player_id == ^id and p.season_id == ^season_id,
          order_by: [asc: m.kickoff_at, asc: m.id, asc: p.id]
      )
      |> Enrichment.overlay()

    totals =
      Map.new([:minutes_played | @metrics], fn metric ->
        values = Enum.map(rows, &Map.fetch!(&1, metric))
        total = if values != [] and Enum.all?(values, &is_integer/1), do: Enum.sum(values)
        {metric, total}
      end)

    coverage =
      Map.new([:minutes_played | @metrics], fn metric ->
        known = Enum.count(rows, &is_integer(Map.get(&1, metric)))

        status =
          cond do
            known == 0 -> "unavailable"
            known == length(rows) -> "complete"
            true -> "partial"
          end

        {metric,
         %{status: status, known_match_count: known, unknown_match_count: length(rows) - known}}
      end)

    {:ok,
     Map.merge(totals, %{
       season_id: season_id,
       recorded_match_count: length(rows),
       coverage: "recorded_local_facts",
       metric_coverage: coverage
     })}
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  # --- Private Helpers ---

  defp ensure_match!(season, attrs) do
    normalized = attrs.match_identity |> String.trim() |> String.downcase()

    case Repo.one(
           from m in Match,
             where: m.season_id == ^season.id and m.normalized_identity == ^normalized
         ) do
      %Match{} = existing ->
        {existing, false}

      nil ->
        {:ok, created} =
          attrs
          |> Map.put(:season_id, season.id)
          |> Match.changeset(season)
          |> Repo.insert()

        {created, true}
    end
  end

  defp ensure_performance!(match, attrs, acc) do
    case Repo.one(
           from p in Performance,
             where: p.player_id == ^attrs.player_id and p.match_id == ^match.id
         ) do
      %Performance{} ->
        acc

      nil ->
        {:ok, _created} =
          attrs
          |> Map.put(:match_id, match.id)
          |> Performance.changeset(match)
          |> Repo.insert()

        %{
          acc
          | performances_added: acc.performances_added + 1,
            player_ids: [attrs.player_id | acc.player_ids]
        }
    end
  end

  defp bump_match(acc, true), do: %{acc | matches_added: acc.matches_added + 1}
  defp bump_match(acc, false), do: acc

  defp upsert_scope_check!(season, provider, player_id, now) do
    existing = ScopeCheck.find(provider, season.id, player_id)

    case existing do
      nil ->
        Repo.insert!(%ScopeCheck{
          id: Ecto.UUID.generate(),
          provider: provider,
          identity_namespace: provider,
          league_code: season.league.code,
          start_year: season.start_year,
          end_year: season.end_year,
          season_id: season.id,
          player_id: player_id,
          last_checked_at: now
        })

      row ->
        row |> Ecto.Changeset.change(last_checked_at: now) |> Repo.update!()
    end
  end

  defp insert_match(attrs) do
    with {:ok, season} <- fetch_ref(Season, attrs.season_id, :season_id),
         {:ok, home} <- fetch_ref(Team, attrs.home_team_id, :home_team_id),
         {:ok, away} <- fetch_ref(Team, attrs.away_team_id, :away_team_id),
         :ok <- same_season(home, season.id, :home_team_id),
         :ok <- same_season(away, season.id, :away_team_id),
         :ok <-
           if(home.id == away.id,
             do: validation_error(:away_team_id, :identical_teams),
             else: :ok
           ) do
      attrs
      |> Map.update!(:match_identity, &String.trim/1)
      |> Match.changeset(season)
      |> Repo.insert()
      |> format_insert_result()
    end
  end

  defp insert_performance(attrs, match) do
    with {:ok, player} <- fetch_ref(Player, attrs.player_id, :player_id),
         {:ok, team} <- fetch_ref(Team, attrs.team_id, :team_id),
         {:ok, _pos} <- fetch_ref(Position, attrs.position_id, :position_id),
         :ok <- same_season(player, match.season_id, :player_id),
         :ok <- same_season(team, match.season_id, :team_id),
         :ok <-
           if(team.id in [match.home_team_id, match.away_team_id],
             do: :ok,
             else: validation_error(:team_id, :nonparticipant)
           ) do
      attrs |> Performance.changeset(match) |> Repo.insert() |> format_insert_result()
    end
  end

  defp validate_match_input(attrs) do
    with {:ok, sid} <- cast_uuid(get_attr(attrs, :season_id), :season_id),
         {:ok, home} <- cast_uuid(get_attr(attrs, :home_team_id), :home_team_id),
         {:ok, away} <- cast_uuid(get_attr(attrs, :away_team_id), :away_team_id),
         {:ok, identity} <- validate_identity(get_attr(attrs, :match_identity)),
         {:ok, kickoff} <- validate_utc_datetime(get_attr(attrs, :kickoff_at), :kickoff_at) do
      {:ok,
       %{
         season_id: sid,
         home_team_id: home,
         away_team_id: away,
         match_identity: identity,
         kickoff_at: kickoff
       }}
    end
  end

  defp validate_performance_input(attrs) do
    with {:ok, mid} <- cast_uuid(get_attr(attrs, :match_id), :match_id),
         {:ok, pid} <- cast_uuid(get_attr(attrs, :player_id), :player_id),
         {:ok, tid} <- cast_uuid(get_attr(attrs, :team_id), :team_id),
         {:ok, pos_id} <- cast_uuid(get_attr(attrs, :position_id), :position_id),
         {:ok, counts} <- validate_counts(attrs) do
      {:ok,
       Map.merge(counts, %{match_id: mid, player_id: pid, team_id: tid, position_id: pos_id})}
    end
  end

  defp validate_counts(attrs) do
    Enum.reduce_while([:minutes_played | @metrics], {:ok, %{}}, fn field, {:ok, acc} ->
      val = get_attr(attrs, field)

      if is_nil(val) or (is_integer(val) and val >= 0) do
        {:cont, {:ok, Map.put(acc, field, val)}}
      else
        {:halt, validation_error(field, :invalid_count)}
      end
    end)
  end

  defp validate_identity(val) when is_binary(val) do
    if String.valid?(val) and String.trim(val) != "",
      do: {:ok, String.trim(val)},
      else: validation_error(:match_identity, :blank_identity)
  end

  defp validate_identity(_), do: validation_error(:match_identity, :blank_identity)

  defp validate_utc_datetime(%DateTime{utc_offset: 0, std_offset: 0} = dt, _field), do: {:ok, dt}
  defp validate_utc_datetime(_, field), do: validation_error(field, :invalid_timestamp)

  defp validate_bounds(opts) when is_list(opts) do
    from_dt = Keyword.get(opts, :from)
    to_dt = Keyword.get(opts, :to)
    season_id = Keyword.get(opts, :season_id)

    with {:ok, f} <- optional_utc(from_dt, :from),
         {:ok, t} <- optional_utc(to_dt, :to),
         {:ok, s} <- optional_uuid(season_id, :season_id),
         :ok <- check_time_order(f, t) do
      {:ok, %{from: f, to: t, season_id: s}}
    end
  end

  defp validate_bounds(_), do: validation_error(:bounds, :invalid_bounds)

  defp optional_utc(nil, _), do: {:ok, nil}
  defp optional_utc(dt, field), do: validate_utc_datetime(dt, field)

  defp optional_uuid(nil, _), do: {:ok, nil}
  defp optional_uuid(id, field), do: cast_uuid(id, field)

  defp check_time_order(%DateTime{} = from_dt, %DateTime{} = to_dt) do
    if DateTime.compare(from_dt, to_dt) == :gt,
      do: validation_error(:to, :invalid_range),
      else: :ok
  end

  defp check_time_order(_, _), do: :ok

  defp fetch_ref(schema, id, field) do
    case Repo.get(schema, id) do
      nil -> validation_error(field, :missing_reference)
      row -> {:ok, row}
    end
  end

  defp fetch_by_id(schema, id, field) do
    with {:ok, uuid} <- cast_uuid(id, field) do
      case Repo.get(schema, uuid) do
        nil -> {:error, :not_found}
        record -> {:ok, record}
      end
    end
  end

  defp immutable(schema, id, field) do
    with {:ok, _} <- fetch_by_id(schema, id, field), do: {:error, :immutable}
  end

  defp same_season(%{season_id: id}, id, _), do: :ok
  defp same_season(_, _, field), do: validation_error(field, :season_mismatch)

  defp cast_uuid(id, field) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> {:ok, uuid}
      :error -> validation_error(field, :invalid_uuid)
    end
  end

  defp cast_uuid(_, field), do: validation_error(field, :invalid_uuid)

  defp get_attr(map, key), do: Map.get(map, key, Map.get(map, Atom.to_string(key)))

  defp format_insert_result({:ok, record}), do: {:ok, record}

  defp format_insert_result({:error, %Ecto.Changeset{errors: [{field, {_msg, opts}} | _]}}) do
    case opts[:constraint] do
      :unique -> {:error, %{kind: :conflict, field: field, reason: :duplicate, record: nil}}
      :foreign -> validation_error(field, :missing_reference)
      _ -> validation_error(field, :invalid_count)
    end
  end

  defp validation_error(field, reason),
    do: {:error, %{kind: :validation, field: field, reason: reason, record: nil}}

  defp transact(fun) do
    Repo.transaction(fn ->
      case fun.() do
        {:ok, record} -> record
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end

  defp lock_seasons!(ids) do
    ids
    |> Enum.filter(&match?({:ok, _}, Ecto.UUID.cast(&1)))
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.each(fn id ->
      <<key::signed-64, _::binary>> =
        :crypto.hash(:sha256, "statistics-season-v1:" <> to_string(id))

      Ecto.Adapters.SQL.query!(Repo, "SELECT pg_advisory_xact_lock($1)", [key])
    end)

    :ok
  end
end

# --- Statistics Schemas ---

# --- Freshness & Async Refresh ---

defmodule FootballMarket.Statistics.Freshness do
  @moduledoc "Computes player statistics freshness against TTL and enqueues Oban refresh jobs."

  import Ecto.Query

  alias FootballMarket.{Catalog, Repo}
  alias FootballMarket.Market.Quote
  alias FootballMarket.Statistics.ScopeCheck
  alias FootballMarket.Workers.StatisticsImport

  @preload_batch_size 20

  def preload(limit \\ @preload_batch_size) when is_integer(limit) and limit > 0 do
    _ =
      Catalog.list_players_for_statistics()
      |> Enum.reduce_while(0, &preload_player(&1, &2, limit))

    :ok
  end

  defp preload_player(_player, queued, limit) when queued >= limit, do: {:halt, queued}

  defp preload_player(player, queued, _limit) do
    case refresh_if_stale(player, 2) do
      %{state: state} when state in ["queued", "executing"] -> {:cont, queued + 1}
      _ -> {:cont, queued}
    end
  end

  def for_player(player) do
    season = player.team.season
    config = Application.get_env(:football_market, __MODULE__, [])
    ttl = Keyword.get(config, :ttl_seconds, 86_400)
    sources = Keyword.get(config, :refresh_options_by_scope, %{})
    scope_key = {season.league.code, season.start_year, season.end_year}
    base = base_player_status(player, season, ttl)

    case Map.get(sources, scope_key) do
      nil -> base
      options -> configured_player_status(player, base, options, ttl)
    end
  rescue
    _ -> unavailable_player_status(player)
  end

  defp base_player_status(player, season, ttl) do
    latest_quote = latest_quote_for(player.id)

    %{
      scope: %{
        player_id: player.id,
        season_id: player.season_id,
        league_code: season.league.code,
        start_year: season.start_year,
        end_year: season.end_year,
        provider: nil,
        coverage: "player_season"
      },
      source_mode: "unconfigured",
      last_checked_at: nil,
      expires_at: nil,
      ttl_seconds: ttl,
      freshness: "never_checked",
      refresh: %{state: "unconfigured", run_id: nil, reason: nil, next_attempt_at: nil},
      valuation: %{
        state: if(latest_quote, do: "completed", else: "not_requested"),
        calculation_intent_id: nil,
        request_states: %{},
        last_quoted_at: latest_quote && latest_quote.effective_at,
        current_quote:
          latest_quote &&
            latest_quote.unit_price |> Decimal.round(2) |> Decimal.to_string(:normal)
      }
    }
  end

  defp configured_player_status(player, base, options, ttl) do
    source_ref = Keyword.get(options, :source_ref, "fotmob-public-html")
    check = ScopeCheck.find(source_ref, player.season_id, player.id)
    now = DateTime.utc_now()
    last_checked = check && check.last_checked_at

    fresh? =
      last_checked != nil and
        DateTime.compare(now, DateTime.add(last_checked, ttl, :second)) == :lt

    refresh =
      if fresh?,
        do: %{state: "idle", run_id: nil, reason: nil, next_attempt_at: nil},
        else: enqueue_refresh(player, source_ref)

    freshness =
      cond do
        is_nil(last_checked) -> "never_checked"
        fresh? -> "fresh"
        true -> "stale"
      end

    %{
      base
      | scope: Map.put(base.scope, :provider, source_ref),
        source_mode: "live",
        last_checked_at: last_checked,
        expires_at: last_checked && DateTime.add(last_checked, ttl, :second),
        freshness: freshness,
        refresh: refresh
    }
  end

  defp unavailable_player_status(player) do
    %{
      scope: %{player_id: player.id, season_id: player.season_id},
      source_mode: "unconfigured",
      last_checked_at: nil,
      expires_at: nil,
      ttl_seconds: 86_400,
      freshness: "unavailable",
      refresh: %{
        state: "unavailable",
        run_id: nil,
        reason: "temporarily_unavailable",
        next_attempt_at: nil
      },
      valuation: %{
        state: "unavailable",
        calculation_intent_id: nil,
        request_states: %{},
        last_quoted_at: nil,
        current_quote: nil
      }
    }
  end

  defp refresh_if_stale(player, priority) do
    season = player.team.season
    config = Application.get_env(:football_market, __MODULE__, [])
    ttl = Keyword.get(config, :ttl_seconds, 86_400)
    sources = Keyword.get(config, :refresh_options_by_scope, %{})
    scope_key = {season.league.code, season.start_year, season.end_year}

    case Map.get(sources, scope_key) do
      nil ->
        %{
          state: "unconfigured",
          run_id: nil,
          reason: "missing_source_or_player_binding",
          next_attempt_at: nil
        }

      options ->
        source_ref = Keyword.get(options, :source_ref, "fotmob-public-html")
        check = ScopeCheck.find(source_ref, player.season_id, player.id)
        now = DateTime.utc_now()

        fresh? =
          check && check.last_checked_at &&
            DateTime.compare(now, DateTime.add(check.last_checked_at, ttl, :second)) == :lt

        if fresh?,
          do: %{state: "idle", run_id: nil, reason: nil, next_attempt_at: nil},
          else: enqueue_refresh(player, source_ref, priority)
    end
  rescue
    _ ->
      %{
        state: "unavailable",
        run_id: nil,
        reason: "temporarily_unavailable",
        next_attempt_at: nil
      }
  end

  defp enqueue_refresh(player, source_ref, priority \\ 0) do
    oban_name =
      Application.get_env(:football_market, FootballMarket.Synchronization, [])
      |> Keyword.get(:oban_name, Oban)

    args = %{
      "player_id" => player.id,
      "season_id" => player.season_id,
      "source_ref" => source_ref
    }

    case Oban.insert(oban_name, StatisticsImport.new(args, priority: priority)) do
      {:ok, job} ->
        state = if job.state == "executing", do: "executing", else: "queued"
        %{state: state, run_id: to_string(job.id), reason: nil, next_attempt_at: nil}

      _ ->
        %{
          state: "unavailable",
          run_id: nil,
          reason: "temporarily_unavailable",
          next_attempt_at: nil
        }
    end
  end

  defp latest_quote_for(player_id) do
    Repo.one(
      from q in Quote,
        where: q.player_id == ^player_id,
        order_by: [desc: q.effective_at],
        select: %{unit_price: q.unit_price, effective_at: q.effective_at},
        limit: 1
    )
  end
end

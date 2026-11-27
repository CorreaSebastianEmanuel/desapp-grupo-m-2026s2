defmodule FootballMarket.Sync do
  @moduledoc """
  Coordinates catalog sync, player statistics refresh, scouting execution, and
  the local development operations snapshot (`/__local/ops`).
  """

  import Ecto.Query

  alias FootballMarket.{Catalog, Quotes, Repo, Statistics}
  alias FootballMarket.Catalog.{League, Player, ScoutRun, Scouting, Season, SourceBinding, Team}
  alias FootballMarket.Providers.{FootballDataOrg, Scraping}
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.Workers.{CatalogSync, ConditionalOrderRecovery, QuoteClose, QuoteRecovery}

  @supported_leagues ["PL", "BL1", "PD", "SA", "FL1"]
  @fotmob_providers ["fotmob-public-html", "fotmob-public-html-v1"]
  @known_queues ["catalog_sync", "statistics_import", "quote_calculation", "conditional_orders"]
  @hidden_queues ["catalog_scout"]

  # --- Catalog & Statistics Sync ---

  @doc "Fetches a league/season catalog from Football-Data.org and imports it idempotently."
  def sync_catalog(league_code, start_year, end_year, opts \\ []) do
    with {:ok, snapshot} <- FootballDataOrg.fetch_catalog(league_code, start_year, end_year, opts) do
      Catalog.import_catalog(snapshot, provider: FootballDataOrg.provider_label())
    end
  end

  @doc "Enqueues catalog sync Oban jobs for all 5 supported European leagues."
  def enqueue_all_catalogs do
    year = current_season_year()

    Enum.map(@supported_leagues, fn code ->
      Oban.insert(
        Oban,
        CatalogSync.new(%{
          "league_code" => code,
          "start_year" => year,
          "end_year" => year + 1
        })
      )
    end)
  end

  @doc "Executes a queued catalog scout search against configured sources."
  def run_scout(scout_id) do
    case Scouting.get(scout_id) do
      nil -> {:error, :not_found}
      %ScoutRun{} = scout -> execute_scout(scout)
    end
  end

  defp execute_scout(scout) do
    case Catalog.search_local_players(scout.display_name) do
      {:ok, [_ | _]} -> Scouting.finish(scout, "found")
      _ -> scout_external(scout)
    end
  end

  defp scout_external(scout) do
    case Scraping.search_player(scout.display_name) do
      {:ok, _matches} -> Scouting.finish(scout, "not_found")
      {:error, reason} -> Scouting.finish(scout, "provider_failure", to_string(reason))
    end
  end

  @doc "Refreshes statistics for a player from the configured provider and updates freshness."
  def sync_player_statistics(player_id, season_id, source_ref, opts \\ []) do
    case load_sync_player(player_id, season_id) do
      nil ->
        {:error, :not_found}

      player when source_ref in @fotmob_providers ->
        sync_fotmob_player(player, source_ref, opts)

      player ->
        Statistics.import_performances(player.season_id, [],
          provider: source_ref,
          player_id: player.id
        )
    end
  end

  defp load_sync_player(player_id, season_id) do
    case Repo.get(Player, player_id) do
      %Player{season_id: ^season_id} = player ->
        Repo.preload(player, [:team, :position, season: :league])

      _ ->
        nil
    end
  end

  defp sync_fotmob_player(player, source_ref, opts) do
    with {:ok, resolved} <- resolve_fotmob_player_id(player, opts) do
      import_fotmob_player(player, resolved, source_ref, opts)
    end
  end

  defp import_fotmob_player(player, :unmatched, source_ref, _opts) do
    Statistics.import_performances(player.season_id, [],
      provider: source_ref,
      player_id: player.id
    )
  end

  defp import_fotmob_player(player, fotmob_id, source_ref, opts) do
    case Scraping.fetch_player_profile(fotmob_id, opts) do
      {:ok, profile} ->
        envelopes = build_fotmob_envelopes(player, profile.matches)

        with {:ok, summary} <-
               Statistics.import_performances(player.season_id, envelopes,
                 provider: source_ref,
                 player_id: player.id
               ) do
          maybe_calculate_initial_quote(player, envelopes, summary)
          {:ok, summary}
        end

      {:error, :not_found} ->
        Statistics.import_performances(player.season_id, [],
          provider: source_ref,
          player_id: player.id
        )

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp resolve_fotmob_player_id(player, opts) do
    case find_fotmob_player_binding(player.id) do
      source_id when is_binary(source_id) ->
        {:ok, source_id}

      nil ->
        discover_fotmob_player_id(player, opts)
    end
  end

  defp find_fotmob_player_binding(player_id) do
    Repo.one(
      from b in SourceBinding,
        where:
          b.player_id == ^player_id and b.kind == "player" and b.provider in ^@fotmob_providers,
        order_by: [asc: b.provider, asc: b.source_id],
        select: b.source_id,
        limit: 1
    )
  end

  defp discover_fotmob_player_id(player, opts) do
    with {:ok, candidates} <- Scraping.search_player(player.display_name, opts) do
      case pick_fotmob_candidate(candidates, player) do
        nil ->
          {:ok, :unmatched}

        source_id ->
          persist_fotmob_player_binding(player, source_id)
          {:ok, source_id}
      end
    end
  end

  defp pick_fotmob_candidate(candidates, player) do
    league_code = player.season.league.code
    target_name = Scraping.normalize_name(player.display_name)
    target_team = Scraping.normalize_team_name(player.team.name, league_code)

    exact_team =
      Enum.find(candidates, fn c ->
        Scraping.normalize_name(c.name) == target_name and
          team_matches?(Scraping.normalize_team_name(c.team_name, league_code), target_team)
      end)

    fuzzy_team =
      Enum.find(candidates, fn c ->
        name_matches?(Scraping.normalize_name(c.name), target_name) and
          team_matches?(Scraping.normalize_team_name(c.team_name, league_code), target_team)
      end)

    unique_exact =
      case Enum.filter(candidates, &(Scraping.normalize_name(&1.name) == target_name)) do
        [single] -> single
        _ -> nil
      end

    case exact_team || fuzzy_team || unique_exact do
      %{source_id: id} -> id
      nil -> nil
    end
  end

  defp name_matches?(a, b) when a == "" or b == "", do: false
  defp name_matches?(a, a), do: true

  defp name_matches?(a, b) do
    tokens_a = String.split(a)
    tokens_b = String.split(b)

    List.last(tokens_a) == List.last(tokens_b) and
      (Enum.all?(tokens_a, &(&1 in tokens_b)) or Enum.all?(tokens_b, &(&1 in tokens_a)) or
         String.first(hd(tokens_a)) == String.first(hd(tokens_b)))
  end

  defp team_matches?(a, b) when a == "" or b == "", do: false
  defp team_matches?(a, a), do: true

  defp team_matches?(a, b) do
    tokens_a = String.split(a)
    tokens_b = String.split(b)

    Enum.all?(tokens_a, &(&1 in tokens_b)) or Enum.all?(tokens_b, &(&1 in tokens_a))
  end

  defp persist_fotmob_player_binding(player, source_id) do
    with {:ok, season_bin} <- Ecto.UUID.dump(player.season_id),
         {:ok, league_bin} <- Ecto.UUID.dump(player.season.league_id),
         {:ok, %{rows: [[scope_bin]]}} <-
           Repo.query(
             "SELECT id FROM catalog_ingestion_scopes WHERE season_id = $1 AND league_id = $2 LIMIT 1",
             [season_bin, league_bin]
           ),
         {:ok, scope_id} <- Ecto.UUID.load(scope_bin) do
      %SourceBinding{
        scope_id: scope_id,
        season_scope_id: player.season_id,
        league_scope_id: player.season.league_id,
        provider: Scraping.provider_label(),
        kind: "player",
        source_id: source_id,
        player_id: player.id
      }
      |> Repo.insert(on_conflict: :nothing)
    end

    :ok
  rescue
    _ -> :ok
  end

  defp build_fotmob_envelopes(player, matches) do
    season = player.season
    league_code = season.league.code
    expected_league_id = Scraping.league_id(league_code)
    window_start = DateTime.new!(Date.new!(season.start_year, 7, 1), ~T[00:00:00], "Etc/UTC")
    window_end = DateTime.new!(Date.new!(season.end_year, 7, 1), ~T[00:00:00], "Etc/UTC")
    season_teams = Repo.all(from t in Team, where: t.season_id == ^season.id)
    team_bindings = load_fotmob_team_bindings(season.id)
    existing_identities = load_existing_fotmob_match_identities(season.id)

    matches
    |> Enum.filter(&eligible_fotmob_match?(&1, expected_league_id, window_start, window_end))
    |> Enum.flat_map(fn match ->
      case resolve_opponent_team(match, player.team_id, season_teams, team_bindings, league_code) do
        nil ->
          []

        opponent ->
          [
            fotmob_envelope(
              player,
              opponent,
              match,
              Map.get(existing_identities, match.id, match.match_identity)
            )
          ]
      end
    end)
  end

  defp eligible_fotmob_match?(match, expected_league_id, window_start, window_end) do
    match.played_in_match == true and
      is_integer(match.minutes_played) and match.minutes_played > 0 and
      is_boolean(match.is_home_team) and
      (is_nil(expected_league_id) or match.league_id == expected_league_id) and
      DateTime.compare(match.kickoff_at, window_start) != :lt and
      DateTime.compare(match.kickoff_at, window_end) == :lt
  end

  defp load_fotmob_team_bindings(season_id) do
    Repo.all(
      from b in SourceBinding,
        where:
          b.season_scope_id == ^season_id and b.kind == "team" and
            b.provider in ^@fotmob_providers and not is_nil(b.team_id),
        select: {b.source_id, b.team_id}
    )
    |> Map.new()
  end

  defp load_existing_fotmob_match_identities(season_id) do
    Repo.all(
      from m in Statistics.Match,
        where: m.season_id == ^season_id,
        select: m.match_identity
    )
    |> Enum.reduce(%{}, fn identity, acc ->
      case Regex.run(~r/(?:fotmob-|provider:v1:fotmob-public-html-v1:)([0-9]+)\z/, identity) do
        [_, match_id] -> Map.put_new(acc, match_id, identity)
        _ -> acc
      end
    end)
  end

  defp resolve_opponent_team(match, player_team_id, season_teams, team_bindings, league_code) do
    by_binding =
      case Map.get(team_bindings, match.opponent_team_id) do
        nil -> nil
        id -> Enum.find(season_teams, &(&1.id == id))
      end

    opponent =
      by_binding ||
        match_team_by_name(season_teams, match.opponent_team_name, league_code)

    if opponent && opponent.id != player_team_id, do: opponent
  end

  defp match_team_by_name(_teams, name, _league_code) when not is_binary(name) or name == "",
    do: nil

  defp match_team_by_name(teams, name, league_code) do
    target = Scraping.normalize_team_name(name, league_code)

    exact =
      Enum.find(teams, &(Scraping.normalize_team_name(&1.name, league_code) == target))

    exact ||
      case Enum.filter(
             teams,
             &team_matches?(Scraping.normalize_team_name(&1.name, league_code), target)
           ) do
        [single] -> single
        _ -> nil
      end
  end

  defp fotmob_envelope(player, opponent, match, match_identity) do
    {home_team_id, away_team_id} =
      if match.is_home_team,
        do: {player.team_id, opponent.id},
        else: {opponent.id, player.team_id}

    %{
      match: %{
        match_identity: match_identity,
        kickoff_at: match.kickoff_at,
        home_team_id: home_team_id,
        away_team_id: away_team_id
      },
      performances: [
        %{
          player_id: player.id,
          team_id: player.team_id,
          position_id: player.position_id,
          minutes_played: match.minutes_played,
          goals: match.goals,
          assists: match.assists,
          shots_on_target: match.shots_on_target,
          tackles: match.tackles,
          interceptions: match.interceptions,
          saves: match.saves,
          goals_conceded: match.goals_conceded,
          yellow_cards: match.yellow_cards,
          red_cards: match.red_cards
        }
      ]
    }
  end

  defp maybe_calculate_initial_quote(player, [_ | _] = envelopes, summary) do
    mapping_id = Application.get_env(:football_market, :quote_mapping_id)

    if is_binary(mapping_id) and mapping_id != "" and
         (summary.performances_added > 0 or Quotes.latest(player.id) == {:error, :quote_not_found}) do
      kickoffs = Enum.map(envelopes, & &1.match.kickoff_at)
      latest = Enum.max(kickoffs, DateTime) |> DateTime.truncate(:microsecond)
      earliest = Enum.min(kickoffs, DateTime) |> DateTime.truncate(:microsecond)
      week_start = DateTime.add(latest, -7 * 86_400, :second)

      case publish_quote_window(player, week_start, latest, mapping_id) do
        {:ok, %{quote: nil}} when earliest != latest ->
          publish_quote_window(player, earliest, latest, mapping_id)

        _ ->
          :ok
      end
    end

    :ok
  rescue
    _ -> :ok
  end

  defp maybe_calculate_initial_quote(_player, _envelopes, _summary), do: :ok

  defp publish_quote_window(player, from_dt, to_dt, mapping_id) do
    Quotes.calculate_and_publish(
      %{
        player_id: player.id,
        season_id: player.season_id,
        week_start: from_dt,
        week_end: to_dt
      },
      :active,
      mapping_id
    )
  end

  # --- Local Ops Dashboard Snapshot & Commands (`/__local/ops`) ---

  def ops_snapshot do
    %{
      db: database_status(),
      redis: redis_status(),
      table_counts: table_counts(),
      primary_inventory_account: primary_inventory_account(),
      queues: queue_counts(),
      job_contexts: recent_jobs(),
      execution_log: recent_execution_log(),
      queue_names: @known_queues,
      quote_requests: recent_quote_requests(),
      football_data_configured: football_data_configured?(),
      fotmob_enabled:
        Application.get_env(:football_market, :scraping_assessment) == :local_development
    }
  end

  def run_support_job("quote_close"),
    do: Oban.insert(Oban, QuoteClose.new(%{"mode" => "manual"}))

  def run_support_job("quote_recovery"),
    do: Oban.insert(Oban, QuoteRecovery.new(%{}))

  def run_support_job("conditional_recovery"),
    do: Oban.insert(Oban, ConditionalOrderRecovery.new(%{}))

  def run_support_job(_), do: nil

  def retry_job(id) do
    with {job_id, ""} when job_id > 0 <- Integer.parse(to_string(id)),
         %Oban.Job{} = job <- Repo.get(Oban.Job, job_id),
         true <- job.state in ["scheduled", "retryable", "cancelled", "discarded"] do
      :ok = Oban.retry_job(Oban, job.id)
      {:ok, job.id}
    else
      _ -> {:error, :not_retryable}
    end
  end

  # --- Private Ops Helpers ---

  defp current_season_year do
    today = Date.utc_today()
    if today.month >= 7, do: today.year, else: today.year - 1
  end

  defp football_data_configured? do
    token = System.get_env("FOOTBALL_DATA_ORG_TOKEN")
    is_binary(token) and String.trim(token) != ""
  end

  defp database_status do
    case Repo.query("SELECT current_database(), CURRENT_TIMESTAMP") do
      {:ok, %{rows: [[name, ts]]}} -> %{status: :connected, name: name, timestamp: ts}
      _ -> %{status: :unavailable, name: nil, timestamp: nil}
    end
  rescue
    _ -> %{status: :unavailable, name: nil, timestamp: nil}
  end

  defp redis_status do
    case Application.get_env(:football_market, :redis) do
      config when is_list(config) ->
        if FootballMarket.Infrastructure.Health.ping_redis(config) == :ready,
          do: :connected,
          else: :unavailable

      _ ->
        :unconfigured
    end
  end

  defp table_counts do
    [
      {:users, FootballMarket.Accounts.User},
      {:leagues, League},
      {:seasons, Season},
      {:teams, Team},
      {:players, Player},
      {:matches, Statistics.Match},
      {:performances, Statistics.Performance},
      {:jobs, Oban.Job}
    ]
    |> Enum.map(fn {label, schema} -> {label, safe_count(schema)} end)
  end

  defp safe_count(schema) do
    Repo.aggregate(schema, :count, :id)
  rescue
    _ -> :unavailable
  end

  defp primary_inventory_account do
    case Application.get_env(:football_market, :initial_issuance_recipients, []) do
      [id] ->
        case Repo.get(FootballMarket.Accounts.User, id) do
          %{email: email} -> %{status: :configured, email: email}
          _ -> %{status: :invalid, email: nil}
        end

      [] ->
        %{status: :missing, email: nil}

      _ ->
        %{status: :ambiguous, email: nil}
    end
  rescue
    _ -> %{status: :invalid, email: nil}
  end

  defp queue_counts do
    from(j in Oban.Job,
      where:
        j.state in ["available", "executing", "scheduled", "retryable"] and
          j.queue not in ^@hidden_queues,
      group_by: [j.queue, j.state],
      order_by: [asc: j.queue, asc: j.state],
      select: {j.queue, j.state, count(j.id)}
    )
    |> Repo.all()
  rescue
    _ -> []
  end

  defp recent_execution_log do
    from(j in Oban.Job,
      where: not is_nil(j.attempted_at) and j.queue not in ^@hidden_queues,
      order_by: [desc: j.attempted_at, desc: j.id],
      limit: 5
    )
    |> Repo.all()
  rescue
    _ -> []
  end

  defp recent_jobs do
    from(j in Oban.Job,
      where: j.queue not in ^@hidden_queues,
      order_by: [desc: j.inserted_at, desc: j.id],
      limit: 50
    )
    |> Repo.all()
    |> Enum.map(&%{job: &1, run: nil, players: %{}, quote_contexts: %{}})
  rescue
    _ -> []
  end

  defp recent_quote_requests do
    from(r in CalculationRequest,
      join: p in Player,
      on: p.id == r.player_id,
      join: s in Season,
      on: s.id == r.season_id,
      join: l in League,
      on: l.id == s.league_id,
      order_by: [desc: r.inserted_at, desc: r.id],
      limit: 30,
      select: %{
        id: r.id,
        player: p.display_name,
        league: l.name,
        season: fragment("concat(?, '/', ?)", s.start_year, s.end_year),
        week_start: r.week_start,
        state: r.state,
        reason: r.reason,
        admitted_at: r.admitted_at,
        initial_only: r.initial_only,
        mapping_id: r.mapping_id,
        inserted_at: r.inserted_at
      }
    )
    |> Repo.all()
  rescue
    _ -> []
  end
end

defmodule FootballMarket.Infrastructure.Health do
  @moduledoc "Bounded dependency probes for public application health endpoints."

  alias Ecto.Adapters.SQL
  alias FootballMarket.Repo

  @probe_timeout 500
  @redis_probe_timeout 3 * @probe_timeout

  def info do
    version =
      case Application.spec(:football_market, :vsn) do
        vsn when is_list(vsn) -> List.to_string(vsn)
        _ -> "unknown"
      end

    %{
      application: "football_market",
      version: version,
      elixir: System.version(),
      otp_release: List.to_string(:erlang.system_info(:otp_release))
    }
  end

  def readiness(probes \\ default_probes()) when is_map(probes) do
    dependencies =
      Map.new([:postgresql, :redis, :oban], fn dependency ->
        {dependency, safe_probe(Map.get(probes, dependency, fn -> :unavailable end))}
      end)

    status =
      if dependencies.postgresql == :ready and dependencies.oban == :ready,
        do: :ready,
        else: :unavailable

    dependencies =
      if dependencies.redis == :unavailable,
        do: Map.put(dependencies, :redis, :degraded),
        else: dependencies

    %{status: status, dependencies: dependencies}
  end

  defp default_probes do
    %{
      postgresql: &postgresql_ready/0,
      redis: &redis_ready/0,
      oban: &oban_ready/0
    }
  end

  defp postgresql_ready do
    case SQL.query(Repo, "SELECT 1", [], timeout: @probe_timeout, pool_timeout: @probe_timeout) do
      {:ok, %{rows: [[1]]}} -> :ready
      _ -> :unavailable
    end
  rescue
    _ -> :unavailable
  catch
    :exit, _ -> :unavailable
  end

  defp redis_ready do
    {worker, monitor} = spawn_monitor(fn -> exit({:redis_probe_result, check_redis()}) end)

    receive do
      {:DOWN, ^monitor, :process, ^worker, {:redis_probe_result, :ready}} -> :ready
      {:DOWN, ^monitor, :process, ^worker, _reason} -> :unavailable
    after
      @redis_probe_timeout ->
        Process.exit(worker, :kill)
        Process.demonitor(monitor, [:flush])
        :unavailable
    end
  end

  def ping_redis(config, timeout \\ @probe_timeout) when is_list(config) do
    opts =
      config
      |> Keyword.take([:host, :port, :password, :database, :ssl])
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Keyword.merge(timeout: timeout, sync_connect: true, socket_opts: [:inet])

    prev = Process.flag(:trap_exit, true)

    try do
      case Redix.start_link(opts) do
        {:ok, client} ->
          Process.unlink(client)

          try do
            if Redix.command(client, ["PING"], timeout: timeout) == {:ok, "PONG"},
              do: :ready,
              else: :unavailable
          after
            GenServer.stop(client, :normal, timeout)
          end

        _ ->
          :unavailable
      end
    rescue
      _ -> :unavailable
    catch
      :exit, _ -> :unavailable
    after
      Process.flag(:trap_exit, prev)
    end
  end

  defp check_redis do
    case Application.get_env(:football_market, :redis) do
      config when is_list(config) -> ping_redis(config, @probe_timeout)
      _ -> :unavailable
    end
  end

  defp oban_ready do
    name = Application.get_env(:football_market, Oban, []) |> Keyword.get(:name, Oban)
    if Oban.Registry.lookup(name), do: :ready, else: :unavailable
  rescue
    _ -> :unavailable
  end

  defp safe_probe(probe) when is_function(probe, 0) do
    case probe.() do
      :ready -> :ready
      _ -> :unavailable
    end
  rescue
    _ -> :unavailable
  catch
    :exit, _ -> :unavailable
  end

  defp safe_probe(_), do: :unavailable
end

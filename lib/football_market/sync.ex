defmodule FootballMarket.Sync do
  @moduledoc """
  Coordinates catalog sync, player statistics refresh, scouting execution, and
  the local development operations snapshot (`/__local/ops`).
  """

  import Ecto.Query

  alias FootballMarket.{Catalog, Repo, Statistics}
  alias FootballMarket.Catalog.{League, Player, ScoutRun, Scouting, Season, Team}
  alias FootballMarket.Providers.{FootballDataOrg, Scraping}
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.Workers.{CatalogSync, ConditionalOrderRecovery, QuoteClose, QuoteRecovery}

  @supported_leagues ["PL", "BL1", "PD", "SA", "FL1"]
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

  @doc "Refreshes statistics for a player and updates their freshness check timestamp."
  def sync_player_statistics(player_id, season_id, source_ref) do
    case Repo.get(Player, player_id) do
      nil ->
        {:error, :not_found}

      _player ->
        Statistics.import_performances(season_id, [], provider: source_ref, player_id: player_id)
    end
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
      config when is_list(config) -> ping_redis(Map.new(config))
      _ -> :unconfigured
    end
  rescue
    _ -> :unavailable
  catch
    :exit, _ -> :unavailable
  end

  defp ping_redis(config) do
    opts = [host: config.host, port: config.port, sync_connect: true, socket_opts: [:inet]]
    opts = if config[:password], do: Keyword.put(opts, :password, config.password), else: opts
    prev = Process.flag(:trap_exit, true)

    try do
      case Redix.start_link(opts) do
        {:ok, client} ->
          Process.unlink(client)

          try do
            if Redix.command(client, ["PING"]) == {:ok, "PONG"},
              do: :connected,
              else: :unavailable
          after
            GenServer.stop(client)
          end

        _ ->
          :unavailable
      end
    after
      Process.flag(:trap_exit, prev)
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

  defp check_redis do
    with config when is_list(config) <- Application.get_env(:football_market, :redis),
         opts =
           config
           |> Keyword.take([:host, :port, :password, :database, :ssl])
           |> Keyword.put(:timeout, @probe_timeout)
           |> Keyword.put(:sync_connect, true),
         {:ok, client} <- Redix.start_link(opts) do
      try do
        case Redix.command(client, ["PING"], timeout: @probe_timeout) do
          {:ok, "PONG"} -> :ready
          _ -> :unavailable
        end
      after
        GenServer.stop(client, :normal, @probe_timeout)
      end
    else
      _ -> :unavailable
    end
  rescue
    _ -> :unavailable
  catch
    :exit, _ -> :unavailable
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

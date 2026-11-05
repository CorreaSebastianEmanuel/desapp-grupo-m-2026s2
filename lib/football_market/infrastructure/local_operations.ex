defmodule FootballMarket.Infrastructure.LocalOperations do
  @moduledoc "Development operational snapshots and bounded job commands; no web dependency."
  import Ecto.Query

  alias FootballMarket.{Catalog, Repo, Statistics}
  alias FootballMarket.Catalog.{League, Season}
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.Synchronization
  alias FootballMarket.Synchronization.{Attempt, Input, Run}
  alias FootballMarket.Statistics.Ingestion.{CalculationIntent, Check}

  @max_jobs 100
  @max_runs 5
  @supported_leagues ["PL", "BL1", "PD", "SA", "FL1"]
  @known_queues [
    "catalog_sync",
    "statistics_import",
    "quote_calculation",
    "conditional_orders"
  ]
  @hidden_queues ["catalog_scout"]
  @primary_queues ["catalog_sync", "statistics_import", "quote_calculation"]
  @tables [
    {:users, FootballMarket.Accounts.User},
    {:leagues, Catalog.League},
    {:seasons, Catalog.Season},
    {:teams, Catalog.Team},
    {:players, Catalog.Player},
    {:matches, Statistics.Match},
    {:performances, Statistics.Performance},
    {:runs, Run},
    {:attempts, Attempt},
    {:jobs, Oban.Job}
  ]

  def snapshot() do
    %{
      db: database_status(),
      redis: redis_status(),
      table_counts: table_counts(),
      primary_inventory_account: primary_inventory_account(),
      queues: queue_counts(),
      job_contexts: recent_jobs(),
      execution_log: recent_execution_log(),
      queue_names: queue_names(),
      quote_requests: recent_quote_requests(),
      football_data_configured: match?({:ok, _}, Input.resolve("football-data-org")),
      fotmob_enabled:
        Application.get_env(:football_market, :scraping_assessment) == :local_development
    }
  end

  def start_catalog do
    year = current_season()

    Enum.map(@supported_leagues, fn code ->
      Synchronization.request_catalog(
        %{league_code: code, start_year: year, end_year: year + 1, timeout_ms: 1_800_000},
        source_ref: "football-data-org",
        policy: %{attempt_limit: 3, waits: [60, 300], worker_timeout_ms: 1_830_000}
      )
    end)
  end

  def run_support_job(name) do
    job =
      case name do
        "quote_close" -> FootballMarket.Workers.QuoteClose.new(%{"mode" => "manual"})
        "quote_recovery" -> FootballMarket.Workers.QuoteRecovery.new(%{})
        "conditional_recovery" -> FootballMarket.Workers.ConditionalOrderRecovery.new(%{})
        _ -> nil
      end

    job && Oban.insert(Oban, job)
  end

  def retry_job(id) do
    with {job_id, ""} when job_id > 0 <- Integer.parse(id),
         %Oban.Job{} = job <- Repo.get(Oban.Job, job_id),
         true <- job.queue not in ["catalog_sync", "statistics_import", "quote_calculation"],
         true <- job.state in ["scheduled", "retryable", "cancelled", "discarded"] do
      :ok = Oban.retry_job(Oban, job.id)
      {:ok, job.id}
    else
      _ -> {:error, :not_retryable}
    end
  end

  defp database_status do
    case Repo.query("SELECT current_database(), CURRENT_TIMESTAMP") do
      {:ok, %{rows: [[database, timestamp]]}} ->
        %{status: :connected, name: database, timestamp: timestamp}

      _ ->
        %{status: :unavailable, name: nil, timestamp: nil}
    end
  rescue
    _ -> %{status: :unavailable, name: nil, timestamp: nil}
  end

  defp redis_status do
    case Application.get_env(:football_market, :redis) do
      config when is_list(config) ->
        case FootballMarket.Infrastructure.Redis.start_link(Map.new(config)) do
          {:ok, client} ->
            Process.unlink(client)

            try do
              case FootballMarket.Infrastructure.Redis.ping(client) do
                {:ok, "PONG"} -> :connected
                _ -> :unavailable
              end
            after
              GenServer.stop(client)
            end

          _ ->
            :unavailable
        end

      _ ->
        :unconfigured
    end
  rescue
    _ -> :unavailable
  catch
    :exit, _ -> :unavailable
  end

  defp table_counts do
    Enum.map(@tables, fn {label, schema} ->
      {label, safe_count(schema)}
    end)
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

  defp safe_count(schema) do
    Repo.aggregate(schema, :count, :id)
  rescue
    _ -> :unavailable
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

  defp queue_names do
    from(j in Oban.Job, select: j.queue, distinct: true, order_by: [asc: j.queue])
    |> Repo.all()
    |> Enum.reject(&(&1 in @hidden_queues))
    |> Kernel.++(@known_queues)
    |> Enum.uniq()
    |> Enum.sort()
  rescue
    _ -> @known_queues
  end

  defp recent_execution_log do
    from(j in Oban.Job,
      where: not is_nil(j.attempted_at) and j.queue not in ^@hidden_queues,
      order_by: [desc: j.attempted_at, desc: j.id],
      limit: @max_runs
    )
    |> Repo.all()
  rescue
    _ -> []
  end

  defp recent_quote_requests do
    from(r in CalculationRequest,
      join: p in Catalog.Player,
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
        mapping_id: r.mapping_id,
        inserted_at: r.inserted_at
      }
    )
    |> Repo.all()
  rescue
    _ -> []
  end

  defp recent_jobs do
    jobs =
      from(j in Oban.Job,
        where:
          j.state in [
            "available",
            "executing",
            "scheduled",
            "retryable",
            "cancelled",
            "discarded",
            "completed"
          ] and j.queue not in ^@hidden_queues,
        order_by: [desc: j.queue in ^@primary_queues, desc: j.inserted_at, desc: j.id],
        limit: @max_jobs
      )
      |> Repo.all()

    run_ids = job_run_ids(jobs)

    calculation_intent_ids = calculation_intent_ids(jobs)

    calculation_runs =
      from(i in CalculationIntent,
        join: c in Check,
        on: c.id == i.accepted_check_id,
        join: r in Run,
        on: r.id == c.run_id,
        where: i.id in ^calculation_intent_ids,
        select: {i.id, r}
      )
      |> Repo.all()

    run_ids =
      (run_ids ++ Enum.map(calculation_runs, fn {_intent_id, run} -> run.id end))
      |> Enum.uniq()

    runs =
      from(r in Run, where: r.id in ^run_ids)
      |> Repo.all()
      |> Map.new(&{&1.id, &1})

    runs = Map.merge(runs, Map.new(calculation_runs, fn {_intent_id, run} -> {run.id, run} end))

    player_ids =
      runs
      |> Map.values()
      |> Enum.map(&get_in(&1.input || %{}, ["player_id"]))
      |> Enum.filter(&is_binary/1)
      |> Enum.uniq()

    players =
      from(p in Catalog.Player, where: p.id in ^player_ids, select: {p.id, p.display_name})
      |> Repo.all()
      |> Map.new()

    quote_contexts = quote_job_contexts(jobs)

    Enum.map(jobs, fn job ->
      run =
        Map.get(runs, get_in(job.args || %{}, ["run_id"])) ||
          calculation_run(job, calculation_runs, runs)

      %{job: job, run: run, players: players, quote_contexts: quote_contexts}
    end)
  rescue
    _ -> []
  end

  defp job_run_ids(jobs), do: unique_job_arg(jobs, "run_id")

  defp calculation_intent_ids(jobs) do
    jobs
    |> Enum.filter(&String.ends_with?(&1.worker, "CalculationDispatch"))
    |> unique_job_arg("intent_id")
  end

  defp unique_job_arg(jobs, key) do
    jobs
    |> Enum.map(&get_in(&1.args || %{}, [key]))
    |> Enum.filter(&is_binary/1)
    |> Enum.uniq()
  end

  defp quote_job_contexts(jobs) do
    ids =
      jobs
      |> Enum.filter(&String.ends_with?(&1.worker, "QuoteCalculation"))
      |> Enum.map(&get_in(&1.args || %{}, ["request_id"]))
      |> Enum.filter(&is_binary/1)
      |> Enum.uniq()

    from(r in CalculationRequest,
      join: p in Catalog.Player,
      on: p.id == r.player_id,
      join: s in Season,
      on: s.id == r.season_id,
      join: l in League,
      on: l.id == s.league_id,
      where: r.id in ^ids,
      select:
        {r.id,
         fragment(
           "concat(?, ' · ', ?, ' · ', ?, '/', ?)",
           p.display_name,
           l.name,
           s.start_year,
           s.end_year
         )}
    )
    |> Repo.all()
    |> Map.new()
  rescue
    _ -> %{}
  end

  defp calculation_run(job, calculation_runs, runs) do
    intent_id =
      if String.ends_with?(job.worker, "CalculationDispatch"),
        do: get_in(job.args || %{}, ["intent_id"])

    find_calculation_run(intent_id, calculation_runs, runs)
  end

  defp find_calculation_run(nil, _calculation_runs, _runs), do: nil

  defp find_calculation_run(intent_id, calculation_runs, runs) do
    case Enum.find(calculation_runs, fn {id, _run} -> id == intent_id end) do
      {_id, run} -> Map.get(runs, run.id)
      nil -> nil
    end
  end

  defp current_season do
    today = Date.utc_today()
    if today.month >= 7, do: today.year, else: today.year - 1
  end
end

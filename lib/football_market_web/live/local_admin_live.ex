defmodule FootballMarketWeb.LocalAdminLive do
  @moduledoc "Development-only local operations page."
  use FootballMarketWeb, :live_view
  import Ecto.Query

  alias FootballMarket.{Catalog, Repo, Statistics}
  alias FootballMarket.Catalog.{League, Season}
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.Synchronization
  alias FootballMarket.Synchronization.{Attempt, Input, Run}
  alias FootballMarket.Statistics.Ingestion.{CalculationIntent, Check}

  @refresh_ms 10_000
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
  @worker_labels %{
    "CatalogSync" => "Carga de catálogo",
    "StatisticsImport" => "Importación de estadísticas",
    "CalculationDispatch" => "Despacho de cálculos derivados",
    "ConditionalOrderEvaluation" => "Evaluación de órdenes condicionales",
    "ConditionalOrderRecovery" => "Recuperación de órdenes condicionales",
    "QuoteCalculation" => "Cálculo de cotización",
    "QuoteClose" => "Cierre de cotizaciones",
    "QuoteRecovery" => "Recuperación de cotizaciones"
  }
  @tables [
    {"Usuarios", FootballMarket.Accounts.User},
    {"Ligas", Catalog.League},
    {"Temporadas", Catalog.Season},
    {"Equipos", Catalog.Team},
    {"Jugadores", Catalog.Player},
    {"Partidos", Statistics.Match},
    {"Estadísticas por partido", Statistics.Performance},
    {"Ejecuciones de sincronización", Run},
    {"Intentos de sincronización", Attempt},
    {"Jobs Oban", Oban.Job}
  ]

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: schedule_refresh()

    {:ok, socket |> assign(:notice, nil) |> reload_data()}
  end

  @impl true
  def handle_info(:refresh, socket) do
    schedule_refresh()
    {:noreply, reload_data(socket)}
  end

  @impl true
  def handle_event("refresh", _params, socket), do: {:noreply, reload_data(socket)}

  def handle_event("start_catalog", _params, socket) do
    year = current_season()

    results =
      Enum.map(@supported_leagues, fn code ->
        Synchronization.request_catalog(
          %{league_code: code, start_year: year, end_year: year + 1, timeout_ms: 1_800_000},
          source_ref: "football-data-org",
          policy: %{attempt_limit: 3, waits: [60, 300], worker_timeout_ms: 1_830_000}
        )
      end)

    queued = Enum.count(results, &match?({:ok, _}, &1))

    notice =
      cond do
        queued == length(@supported_leagues) ->
          "Sincronización completa encolada para las cinco ligas."

        queued > 0 ->
          "Se encolaron #{queued} de cinco ligas; revisá la configuración del proveedor."

        true ->
          "No se pudo encolar la sincronización completa. Revisá la configuración del proveedor."
      end

    {:noreply, socket |> assign(:notice, notice) |> reload_data()}
  end

  def handle_event("run_support_job", %{"job" => job}, socket) do
    job =
      case job do
        "quote_close" -> FootballMarket.Workers.QuoteClose.new(%{"mode" => "manual"})
        "quote_recovery" -> FootballMarket.Workers.QuoteRecovery.new(%{})
        "conditional_recovery" -> FootballMarket.Workers.ConditionalOrderRecovery.new(%{})
        _ -> nil
      end

    case job && Oban.insert(Oban, job) do
      {:ok, job} ->
        {:noreply,
         socket
         |> assign(:notice, manual_job_notice(job))
         |> reload_data()}

      _ ->
        {:noreply, assign(socket, :notice, "No se pudo encolar ese job auxiliar.")}
    end
  end

  def handle_event("run_job", %{"id" => id}, socket) do
    with {job_id, ""} when job_id > 0 <- Integer.parse(id),
         %Oban.Job{} = job <- Repo.get(Oban.Job, job_id),
         true <- job.queue not in ["catalog_sync", "statistics_import", "quote_calculation"],
         true <- job.state in ["scheduled", "retryable", "cancelled", "discarded"] do
      :ok = Oban.retry_job(Oban, job.id)

      {:noreply,
       socket
       |> assign(:notice, "Job #{job.id} listo para ejecutarse.")
       |> reload_data()}
    else
      _ ->
        {:noreply,
         assign(
           socket,
           :notice,
           "No se pudo ejecutar ese job. Los jobs de sincronización se inician desde el formulario para conservar su historial."
         )}
    end
  end

  defp manual_job_notice(%Oban.Job{worker: "FootballMarket.Workers.QuoteClose"}),
    do: "Cierre manual de cotizaciones encolado para todas las ligas."

  defp manual_job_notice(%Oban.Job{} = job),
    do: "#{worker_label(job.worker)} encolado para ejecución inmediata."

  defp reload_data(socket) do
    assign(socket,
      db: database_status(),
      redis: redis_status(),
      table_counts: table_counts(),
      primary_inventory_account: primary_inventory_account(),
      queues: queue_counts(),
      jobs: recent_jobs(),
      execution_log: recent_execution_log(),
      queue_names: queue_names(),
      quote_requests: recent_quote_requests(),
      football_data_configured: match?({:ok, _}, Input.resolve("football-data-org")),
      fotmob_enabled:
        Application.get_env(:football_market, :scraping_assessment) == :local_development
    )
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

  defp queue_counts_for(counts, queue),
    do: Enum.filter(counts, fn {name, _, _} -> name == queue end)

  defp primary_queue?(name), do: name in @primary_queues
  defp queue_jobs(jobs, queue), do: jobs |> Enum.filter(&(&1.queue == queue)) |> Enum.take(12)

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

      context = context_for_job(job, run, players, quote_contexts)

      job
      |> Map.put(:context, context)
      |> Map.put(:execution_state, run && run.state)
      |> Map.put(:execution_detail, run_execution_detail(run))
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

  defp context_for_job(job, run, players, quote_contexts) do
    Map.get(quote_contexts, get_in(job.args || %{}, ["request_id"])) ||
      manual_quote_close_context(job) || job_context(run, players, job.worker)
  end

  defp manual_quote_close_context(job) do
    if job.worker == "FootballMarket.Workers.QuoteClose" and
         get_in(job.args || %{}, ["mode"]) == "manual",
       do: "Cierre manual de cotizaciones · todas las ligas"
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
    |> Map.new(fn {id, context} -> {id, "Calcular cotización · #{context}"} end)
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

  defp job_context(%Run{} = run, players, worker) do
    input = run.input || %{}
    player_id = input["player_id"]
    target = if player_id, do: Map.get(players, player_id, player_id), else: nil
    scope = league_scope(run)

    case {String.split(worker, ".") |> List.last(), run.operation, target} do
      {"CalculationDispatch", "statistics", name} when is_binary(name) ->
        "Enviar cálculo de estadísticas de #{name} · #{scope}"

      {"CalculationDispatch", "statistics", _} ->
        "Enviar cálculo de estadísticas · #{scope}"

      {_, "statistics", name} when is_binary(name) ->
        "Importar estadísticas de #{name} · #{scope}"

      {_, "statistics", _} ->
        "Importar estadísticas de #{scope}"

      {_, "catalog", _} ->
        "Actualizar equipos y planteles · #{scope}"

      {_, operation, _} ->
        "Ejecutar #{operation} · #{scope}"
    end
  end

  defp job_context(_, _, worker), do: worker_activity(worker)

  defp run_execution_detail(%Run{state: "failed", outcome: outcome} = run) do
    category = outcome && outcome["category"]
    reason = outcome && outcome["reason"]

    details =
      [provider_error_label(category), provider_error_label(reason)]
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    retry = if run.reason == "non_retryable", do: "No reintentable", else: nil

    (details ++ [retry])
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" · ")
    |> case do
      "" -> "La ejecución terminó con error"
      value -> value
    end
  end

  defp run_execution_detail(_), do: nil

  defp provider_error_label("invalid_response"), do: "Respuesta no válida del proveedor"
  defp provider_error_label("provider_failure"), do: "Fallo del proveedor"
  defp provider_error_label("rate_limited"), do: "Proveedor limitó las solicitudes"

  defp provider_error_label("unsupported_capability"),
    do: "FotMob no cubre esta liga/temporada"

  defp provider_error_label("timeout"), do: "Tiempo de espera agotado"
  defp provider_error_label(_), do: nil

  defp execution_state_label("queued"), do: "Ejecución en cola"
  defp execution_state_label("executing"), do: "Ejecución en curso"
  defp execution_state_label("retry_wait"), do: "Reintento programado"
  defp execution_state_label("succeeded"), do: "Importación exitosa"
  defp execution_state_label("failed"), do: "Importación fallida"
  defp execution_state_label(_), do: nil

  defp worker_activity(worker) do
    case String.split(worker, ".") |> List.last() do
      "ConditionalOrderEvaluation" -> "Evaluar si una orden condicional debe ejecutarse"
      "ConditionalOrderRecovery" -> "Revisar órdenes condicionales pendientes"
      "QuoteClose" -> "Cerrar cotizaciones vencidas"
      "QuoteRecovery" -> "Recuperar cálculos de cotización pendientes"
      "QuoteCalculation" -> "Calcular la cotización de un jugador"
      "CalculationDispatch" -> "Enviar un cálculo derivado de estadísticas importadas"
      other -> "Procesar tarea auxiliar · #{other}"
    end
  end

  defp league_scope(run) do
    name = Map.get(FootballMarket.Providers.Request.leagues(), run.league_code, run.league_code)
    "#{name} · #{run.start_year}/#{run.end_year}"
  end

  defp schedule_refresh, do: Process.send_after(self(), :refresh, @refresh_ms)

  defp current_season do
    today = Date.utc_today()
    if today.month >= 7, do: today.year, else: today.year - 1
  end

  defp timestamp(nil), do: "—"
  defp timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")

  defp state_label("available"), do: "Lista para iniciar"
  defp state_label("retryable"), do: "Espera reintento"
  defp state_label("scheduled"), do: "Programada"
  defp state_label("executing"), do: "Ejecutando"
  defp state_label("completed"), do: "Completada"
  defp state_label("discarded"), do: "descartada"
  defp state_label("cancelled"), do: "cancelada"
  defp state_label(value), do: value

  defp job_error(%Oban.Job{errors: errors}) when is_list(errors) and errors != [],
    do: errors |> List.last() |> Map.get("error", "Error registrado")

  defp job_error(_), do: "—"

  defp queue_label("catalog_sync"), do: "Sincronización de catálogo"
  defp queue_label("statistics_import"), do: "Scraping e importación de estadísticas"
  defp queue_label("quote_calculation"), do: "Cálculo de cotizaciones"
  defp queue_label("conditional_orders"), do: "Órdenes condicionales"
  defp queue_label(queue), do: "Procesos auxiliares · #{queue}"

  @impl true
  def render(assigns) do
    ~H"""
    <main id="local-admin" class="local-admin">
      <header class="local-admin-header">
        <div>
          <p class="eyebrow">SOLO DESARROLLO LOCAL</p>
          <h1>Operaciones</h1>
          <p>
            Estado de PostgreSQL, catálogo y trabajos en segundo plano. Se actualiza cada 10 segundos.
          </p>
        </div>
        <button type="button" phx-click="refresh">Actualizar</button>
      </header>

      <p :if={@notice} id="local-admin-notice" role="status">{@notice}</p>

      <section class="local-admin-panel" aria-labelledby="data-heading">
        <h2 id="data-heading">1 · Datos y servicios</h2>
        <section aria-labelledby="database-heading">
          <h2 id="database-heading">PostgreSQL · base principal</h2>
          <p>
            Estado:
            <strong class={if(@db.status == :connected, do: "status-good", else: "status-bad")}>
              {if(@db.status == :connected, do: "conectada", else: "no disponible")}
            </strong>
            <span :if={@db.name}> · {@db.name} · revisada {@db.timestamp}</span>
          </p>
          <dl class="local-admin-counts">
            <div :for={{label, value} <- @table_counts}>
              <dt>{label}</dt><dd>{value}</dd>
            </div>
          </dl>
        </section>

        <section aria-labelledby="primary-inventory-heading">
          <h2 id="primary-inventory-heading">Cuenta principal de fichas iniciales</h2>
          <p :if={@primary_inventory_account.status == :configured}>
            Jugadores nuevos del catálogo reciben sus 100 fichas iniciales en {@primary_inventory_account.email}.
          </p>
          <p :if={@primary_inventory_account.status == :missing} class="status-bad">
            Sin configurar: los jugadores nuevos no reciben fichas iniciales automáticamente.
            Definí MARKET_PRIMARY_ACCOUNT_ID.
          </p>
          <p :if={@primary_inventory_account.status == :ambiguous} class="status-bad">
            Configuración ambigua: debe haber exactamente una cuenta principal.
          </p>
          <p :if={@primary_inventory_account.status == :invalid} class="status-bad">
            La cuenta principal configurada no existe o no se pudo consultar.
          </p>
        </section>

        <section aria-labelledby="redis-heading">
          <h2 id="redis-heading">Redis · servicio auxiliar</h2>
          <p>
            Estado:
            <strong class={if(@redis == :connected, do: "status-good", else: "status-bad")}>
              {case @redis do
                :connected -> "conectado"
                :unconfigured -> "sin configurar"
                _ -> "no disponible"
              end}
            </strong>
            · Esta app solo comprueba la conexión; los jobs y los datos del catálogo viven en PostgreSQL.
          </p>
        </section>
      </section>

      <section class="local-admin-panel" aria-labelledby="jobs-heading">
        <h2 id="jobs-heading">2 · Jobs</h2>
        <p>
          Acciones manuales disponibles. Las tareas iniciadas desde fichas se ejecutan para ese jugador.
        </p>
        <div class="local-admin-job-grid">
          <article class="local-admin-job-card">
            <h3 id="catalog-heading">Sincronizar catálogo completo</h3>
            <p>
              Actualiza ligas, temporadas, equipos y planteles de las cinco ligas europeas para la temporada actual.
            </p>
            <p :if={!@football_data_configured} role="alert">
              Football-Data.org no está configurado en este proceso.
            </p>
            <button :if={@football_data_configured} type="button" phx-click="start_catalog">Ejecutar ahora</button>
          </article>
          <article class="local-admin-job-card">
            <h3>Cierre de cotizaciones</h3>
            <p>
              Fuerza ahora el cierre en todas las ligas: admite las solicitudes pendientes y encola los cálculos.
            </p>
            <button type="button" phx-click="run_support_job" phx-value-job="quote_close">Ejecutar ahora</button>
          </article>
          <article class="local-admin-job-card">
            <h3>Recuperar cálculos de cotización</h3>
            <p>Busca solicitudes admitidas y encola sus cálculos pendientes.</p>
            <button type="button" phx-click="run_support_job" phx-value-job="quote_recovery">Ejecutar ahora</button>
          </article>
          <article class="local-admin-job-card">
            <h3>Revisar órdenes condicionales</h3>
            <p>Reanuda la evaluación de órdenes pendientes.</p>
            <button type="button" phx-click="run_support_job" phx-value-job="conditional_recovery">Ejecutar ahora</button>
          </article>
        </div>

        <section class="local-admin-queue" aria-labelledby="runs-heading">
          <h3 id="runs-heading">Últimas 5 ejecuciones</h3>
          <div class="table-scroll">
            <table>
              <thead>
                <tr>
                  <th>Inicio</th><th>Job</th><th>Cola</th><th>Estado</th><th>Intentos</th><th>
                    Error reciente
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr :for={job <- @execution_log}>
                  <td>{timestamp(job.attempted_at)}</td><td>{worker_label(job.worker)}</td><td>
                    {job.queue}
                  </td>
                  <td>{state_label(job.state)}</td><td>{job.attempt} de {job.max_attempts}</td>
                  <td>{job_error(job)}</td>
                </tr>
                <tr :if={@execution_log == []}>
                  <td colspan="6">Todavía no hay ejecuciones.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </section>

      <section class="local-admin-panel" aria-labelledby="queues-heading">
        <h2 id="queues-heading">3 · Colas</h2>
        <p>
          Cada sección muestra el canal y sus mensajes recientes. Se actualiza automáticamente cada 10 segundos.
        </p>
        <div :for={queue <- @queue_names} class="local-admin-queue" id={"queue-#{queue}"}>
          <h3>{queue_label(queue)} · <code>{queue}</code></h3>
          <p :if={queue == "statistics_import" and @fotmob_enabled}>
            Abrir la ficha de un jugador encola su scraping e importación de estadísticas. El mensaje incluye el jugador y la liga/temporada.
          </p>
          <.queue_details
            queue={queue}
            counts={queue_counts_for(@queues, queue)}
            jobs={queue_jobs(@jobs, queue)}
          />
          <div :if={queue == "quote_calculation"}>
            <h4>Solicitudes de cotización <span>({length(@quote_requests)} recientes)</span></h4>
            <div class="table-scroll">
              <table>
                <thead>
                  <tr>
                    <th>Solicitada</th><th>Jugador</th><th>Liga · temporada</th><th>Semana</th>
                    <th>Estado</th><th>Admisión</th><th>Conversión</th><th>Detalle</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={request <- @quote_requests}>
                    <td>{timestamp(request.inserted_at)}</td><td>{request.player}</td>
                    <td>{request.league} · {request.season}</td>
                    <td>{Calendar.strftime(request.week_start, "%d/%m/%Y")}</td>
                    <td>
                      <span class={"job-state job-state-#{request.state}"}>{quote_state_label(
                        request.state
                      )}</span>
                    </td>
                    <td>
                      {if request.admitted_at,
                        do: timestamp(request.admitted_at),
                        else: "Espera el cierre diario"}
                    </td>
                    <td>
                      {if request.mapping_id, do: "Configurada", else: "Falta mapping de conversión"}
                    </td>
                    <td>{quote_request_detail(request)}</td>
                  </tr>
                  <tr :if={@quote_requests == []}>
                    <td colspan="8">Todavía no hay solicitudes de cotización.</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </section>

      <footer><a href="/players">Volver a jugadores</a></footer>
    </main>
    """
  end

  defp queue_details(assigns) do
    ~H"""
    <div class="table-scroll">
      <table>
        <thead>
          <tr>
            <th>Cola</th><th>Estado</th><th>Jobs activos</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={{queue, state, count} <- @counts}>
            <td>{queue}</td><td>{state_label(state)}</td><td>{count}</td>
          </tr>
          <tr :if={@counts == []}>
            <td colspan="3">Sin jobs pendientes o en curso.</td>
          </tr>
        </tbody>
      </table>
    </div>
    <h4>Jobs recientes <span>({length(@jobs)} mostrados)</span></h4>
    <div class="table-scroll">
      <table>
        <thead>
          <tr>
            <th>ID</th><th>Worker</th><th>Estado</th><th>Intentos</th><th>Trabajo y alcance</th><th>
              Acción
            </th>
          </tr>
        </thead>
        <tbody>
          <tr :for={job <- @jobs}>
            <td><code>#{job.id}</code></td><td>{worker_label(job.worker)}</td>
            <td>
              <span class={"job-state job-state-#{job.state}"}>{state_label(job.state)}</span>
              <span
                :if={execution_state_label(job.execution_state)}
                class={"run-state run-state-#{job.execution_state}"}
              >{execution_state_label(job.execution_state)}</span>
              <small :if={job.execution_detail} class="run-detail">{job.execution_detail}</small>
            </td>
            <td>{job.attempt} de {job.max_attempts}</td>
            <td>{job.context}</td>
            <td>
              <button
                :if={
                  not primary_queue?(@queue) and
                    job.state in ["scheduled", "retryable", "cancelled", "discarded"]
                }
                type="button"
                phx-click="run_job"
                phx-value-id={job.id}
              >Ejecutar ahora</button>
              <span :if={primary_queue?(@queue)}>Automático · ligado a la ejecución</span>
              <span :if={not primary_queue?(@queue) and job.state in ["available", "executing"]}>Lo procesa el worker</span>
              <span :if={not primary_queue?(@queue) and job.state == "completed"}>Finalizado</span>
            </td>
          </tr>
          <tr :if={@jobs == []}>
            <td colspan="6">Esta cola todavía no tiene jobs.</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  defp worker_label(worker) do
    name = worker |> String.trim_leading("Elixir.") |> String.split(".") |> List.last()

    Map.get(@worker_labels, name, name)
  end

  defp quote_state_label("pending"), do: "Pendiente"
  defp quote_state_label("running"), do: "En cálculo"
  defp quote_state_label("retrying"), do: "Reintentando"
  defp quote_state_label("successful"), do: "Cotización lista"
  defp quote_state_label("no_quote"), do: "Sin cotización"
  defp quote_state_label("validation_failed"), do: "Error de validación"
  defp quote_state_label("unsupported_strategy"), do: "Estrategia no disponible"
  defp quote_state_label("unreproducible"), do: "Sin datos reproducibles"
  defp quote_state_label("exhausted"), do: "Reintentos agotados"
  defp quote_state_label(state), do: state

  defp quote_request_detail(%{reason: "mapping_unavailable"}),
    do: "No se inició: falta configurar la conversión aprobada"

  defp quote_request_detail(%{reason: "original_unavailable"}),
    do: "Importación histórica sin snapshot original"

  defp quote_request_detail(%{reason: reason}) when is_binary(reason), do: reason
  defp quote_request_detail(_), do: "Cálculo sujeto al cierre diario de liga/temporada"
end

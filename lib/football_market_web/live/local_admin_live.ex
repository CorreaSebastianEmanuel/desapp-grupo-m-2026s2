defmodule FootballMarketWeb.LocalAdminLive do
  @moduledoc "Development-only local operations page."
  use FootballMarketWeb, :live_view
  alias FootballMarket.Infrastructure.LocalOperations
  import FootballMarketWeb.LocalOperationsProjection, only: [execution_state_label: 1]
  alias FootballMarketWeb.LocalOperationsProjection

  @refresh_ms 10_000
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

  def mount(_params, _session, socket) do
    if connected?(socket), do: schedule_refresh()

    {:ok, socket |> assign(:notice, nil) |> reload_data()}
  end

  def handle_info(:refresh, socket) do
    schedule_refresh()
    {:noreply, reload_data(socket)}
  end

  def handle_event("refresh", _params, socket), do: {:noreply, reload_data(socket)}

  def handle_event("start_catalog", _params, socket) do
    results = LocalOperations.start_catalog()

    queued = Enum.count(results, &match?({:ok, _}, &1))

    notice =
      cond do
        queued == 5 ->
          "Sincronización completa encolada para las cinco ligas."

        queued > 0 ->
          "Se encolaron #{queued} de cinco ligas; revisá la configuración del proveedor."

        true ->
          "No se pudo encolar la sincronización completa. Revisá la configuración del proveedor."
      end

    {:noreply, socket |> assign(:notice, notice) |> reload_data()}
  end

  def handle_event("run_support_job", %{"job" => job}, socket) do
    case LocalOperations.run_support_job(job) do
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
    case LocalOperations.retry_job(id) do
      {:ok, job_id} ->
        {:noreply,
         socket
         |> assign(:notice, "Job #{job_id} listo para ejecutarse.")
         |> reload_data()}

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

  defp queue_counts_for(counts, queue),
    do: Enum.filter(counts, fn {name, _, _} -> name == queue end)

  defp primary_queue?(name), do: name in @primary_queues
  defp queue_jobs(jobs, queue), do: jobs |> Enum.filter(&(&1.queue == queue)) |> Enum.take(12)

  defp schedule_refresh, do: Process.send_after(self(), :refresh, @refresh_ms)

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

  defp reload_data(socket),
    do: assign(socket, LocalOperations.snapshot() |> LocalOperationsProjection.snapshot())
end

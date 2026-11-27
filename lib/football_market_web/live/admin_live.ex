# Administration LiveViews:
#   * `FootballMarketWeb.AdministrationLive` (`/administration`) — valuation strategy selector
#   * `FootballMarketWeb.LocalAdminLive` (`/__local/ops`) — local dev operational dashboard

defmodule FootballMarketWeb.AdministrationLive do
  @moduledoc "Administrator UI to inspect and switch between the two valuation strategies."
  use FootballMarketWeb, :live_view

  import FootballMarketWeb.WorkspaceComponents, only: [shell: 1, metric_name: 1, role_name: 1]

  alias FootballMarket.{Sync, Valuation}
  alias FootballMarket.Valuation.Configurations
  alias FootballMarketWeb.Workspace.Helpers, as: Session

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(notice: nil)
     |> Session.reload_credit_balance()
     |> reload()}
  end

  def handle_event("activate", %{"version_id" => id}, socket) do
    notice =
      case Configurations.activate_for(
             Session.domain_actor(socket.assigns.actor),
             id,
             socket.assigns.active_version_id
           ) do
        {:ok, _} ->
          _ = Sync.run_support_job("quote_close")

          "Estrategia activa actualizada. La primera cotización se prepara en segundo plano; las siguientes cambian en el próximo cierre."

        {:error, :predecessor_conflict} ->
          "Otra sesión cambió la selección. Revisá la estrategia activa e intentá de nuevo."

        _ ->
          "No se pudo activar la estrategia seleccionada."
      end

    {:noreply, socket |> assign(notice: notice) |> reload()}
  end

  def handle_event(_, _, socket),
    do: {:noreply, assign(socket, notice: "Elegí una de las dos estrategias disponibles.")}

  defp reload(socket) do
    case Configurations.inspect_for(Session.domain_actor(socket.assigns.actor)) do
      {:ok, data} ->
        assign(socket,
          versions: data.versions,
          active_version_id: data.active_version_id,
          configurations_unavailable: false
        )

      _ ->
        assign(socket, versions: [], active_version_id: nil, configurations_unavailable: true)
    end
  end

  defp title("balanced"), do: "General"
  defp title("position_aware"), do: "Por posición"
  defp description("balanced"), do: "Los mismos criterios para todos los jugadores."

  defp description("position_aware"),
    do: "Un peso diferente para cada métrica según la posición del jugador."

  defp groups(%{strategy_id: "balanced"}), do: [:overall]
  defp groups(_), do: [:goalkeeper, :defender, :midfielder, :forward]
  defp weights(%{strategy_id: "balanced"} = version, :overall), do: version.config.weights
  defp weights(version, group), do: Map.fetch!(version.config.weights, group)
  defp number(nil), do: "Excluida"
  defp number(%Decimal{} = value), do: Decimal.to_string(value, :normal)
  defp number(value), do: to_string(value)

  defp legacy_selection?(versions, id),
    do: not is_nil(id) and Enum.all?(versions, &(&1.id != id))

  def render(assigns) do
    ~H"""
    <.shell
      actor={@actor}
      destination="/administration"
      administrator={true}
      credit_balance={@credit_balance}
      credit_balance_unavailable={@credit_balance_unavailable}
    >
      <section id="administration" aria-labelledby="administration-heading">
        <header class="page-heading">
          <div>
            <p class="eyebrow">ESPACIO DE TRABAJO / ADMINISTRACIÓN</p>
            <h1 id="administration-heading">Estrategias del mercado</h1>
            <p class="section-description">
              Dos formas de valorar el rendimiento. Elegí la que mejor represente tu visión del juego.
            </p>
          </div>
          <span id="configuration-counts" class="strategy-count">2 fórmulas base</span>
        </header>

        <p :if={@notice} id="activation-notice" class="strategy-notice" role="status">{@notice}</p>
        <p
          :if={@configurations_unavailable}
          id="configuration-unavailable"
          class="strategy-notice"
          role="alert"
        >
          No se pudieron preparar las estrategias. Revisá las posiciones del catálogo e intentá de nuevo.
        </p>
        <p
          :if={!@configurations_unavailable and is_nil(@active_version_id)}
          id="no-active-configuration"
          class="strategy-notice"
        >
          Todavía no hay una estrategia activa. Elegí una para preparar primeras cotizaciones y los próximos cierres.
        </p>
        <p
          :if={!@configurations_unavailable and legacy_selection?(@versions, @active_version_id)}
          id="legacy-active-configuration"
          class="strategy-notice"
        >
          Hay una configuración anterior activa. Elegí General o Por posición para preparar primeras cotizaciones y usar una de las dos bases en los próximos cierres.
        </p>

        <div class="strategy-grid">
          <section :for={version <- @versions} id={"strategy-#{version.strategy_id}"}>
            <article
              id={"configuration-#{version.id}"}
              class={["strategy-card", version.id == @active_version_id && "strategy-card-active"]}
            >
              <div class="strategy-card-top">
                <span class="strategy-symbol" aria-hidden="true">
                  <.icon
                    name={
                      if version.strategy_id == "balanced", do: "hero-scale", else: "hero-user-group"
                    }
                    class="strategy-icon"
                  />
                </span>
                <span :if={version.id == @active_version_id} class="active-configuration">
                  <span class="status-dot"></span>Activa
                </span>
                <span :if={version.id != @active_version_id} class="strategy-origin">Predefinida</span>
              </div>
              <h2>{title(version.strategy_id)}</h2>
              <p class="strategy-description">{description(version.strategy_id)}</p>
              <p class="strategy-summary">
                {if version.strategy_id == "balanced",
                  do: "Goles y asistencias, con descuentos por tarjetas.",
                  else: "Goles, asistencias y acciones de ataque, defensa o arco según el rol."}
              </p>
              <div class="strategy-actions">
                <button
                  :if={version.id != @active_version_id}
                  class="primary-button"
                  phx-click="activate"
                  phx-value-version_id={version.id}
                >Usar {title(version.strategy_id)}</button>
                <span :if={version.id == @active_version_id} class="strategy-selected">
                  Seleccionada para primeras cotizaciones y próximos cierres
                </span>
              </div>
              <details class="strategy-rules">
                <summary>Ver cómo calcula</summary>
                <div
                  class="table-scroll"
                  role="region"
                  aria-label={"Reglas de " <> title(version.strategy_id)}
                  tabindex="0"
                >
                  <table>
                    <thead>
                      <tr>
                        <th scope="col">Métrica</th><th scope="col">Referencia semanal</th>
                        <th :for={group <- groups(version)} scope="col">{role_name(group)}</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr :for={metric <- Valuation.metrics()}>
                        <th scope="row">{metric_name(metric)}</th>
                        <td>{number(Map.get(version.references, metric))}</td>
                        <td :for={group <- groups(version)}>
                          {number(Map.get(weights(version, group), metric))}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <details class="strategy-version">
                  <summary>Información de la versión</summary>
                  <p>
                    Fórmula {version.formula_version} · Guardada {Calendar.strftime(
                      version.created_at,
                      "%d/%m/%Y %H:%M UTC"
                    )}
                  </p>
                  <p>Identificador: <code>{version.id}</code></p>
                </details>
              </details>
            </article>
          </section>
        </div>
      </section>
    </.shell>
    """
  end
end

defmodule FootballMarketWeb.LocalAdminLive do
  @moduledoc "Development-only local operations LiveView (`/__local/ops`)."
  use FootballMarketWeb, :live_view

  alias FootballMarket.Sync

  @refresh_ms 10_000
  @table_labels %{
    users: "Usuarios",
    leagues: "Ligas",
    seasons: "Temporadas",
    teams: "Equipos",
    players: "Jugadores",
    matches: "Partidos",
    performances: "Estadísticas por partido",
    jobs: "Jobs Oban"
  }

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :refresh, @refresh_ms)
    {:ok, socket |> assign(:notice, nil) |> reload_data()}
  end

  def handle_info(:refresh, socket) do
    Process.send_after(self(), :refresh, @refresh_ms)
    {:noreply, reload_data(socket)}
  end

  def handle_event("refresh", _params, socket), do: {:noreply, reload_data(socket)}

  def handle_event("start_catalog", _params, socket) do
    queued = Sync.enqueue_all_catalogs() |> Enum.count(&match?({:ok, _}, &1))

    notice =
      if queued == 5,
        do: "Sincronización completa encolada para las cinco ligas.",
        else: "Se encolaron #{queued} de cinco ligas."

    {:noreply, socket |> assign(:notice, notice) |> reload_data()}
  end

  def handle_event("run_support_job", %{"job" => job}, socket) do
    notice =
      case Sync.run_support_job(job) do
        {:ok, _} -> "Job auxiliar encolado para ejecución inmediata."
        _ -> "No se pudo encolar ese job auxiliar."
      end

    {:noreply, socket |> assign(:notice, notice) |> reload_data()}
  end

  def handle_event("run_job", %{"id" => id}, socket) when is_binary(id) or is_integer(id) do
    notice =
      case Sync.retry_job(id) do
        {:ok, job_id} -> "Job #{job_id} listo para ejecutarse."
        _ -> "No se pudo reintentar ese job."
      end

    {:noreply, socket |> assign(:notice, notice) |> reload_data()}
  end

  def handle_event(_, _, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <main id="local-admin" class="local-admin">
      <header class="local-admin-header">
        <div>
          <p class="eyebrow">SOLO DESARROLLO LOCAL</p>
          <h1>Operaciones</h1>
          <p>Estado de PostgreSQL, catálogo y trabajos en segundo plano.</p>
        </div>
        <button type="button" phx-click="refresh">Actualizar</button>
      </header>

      <p :if={@notice} id="local-admin-notice" role="status">{@notice}</p>

      <section class="local-admin-panel">
        <h2>1 · Datos y servicios</h2>
        <p>
          PostgreSQL:
          <strong>{if(@db.status == :connected, do: "conectada", else: "no disponible")}</strong>
          <span :if={@db.name}> · {@db.name}</span>
        </p>
        <p>Redis: <strong>{@redis}</strong></p>
        <dl class="local-admin-counts">
          <div :for={{label, value} <- @table_counts}>
            <dt>{label}</dt><dd>{value}</dd>
          </div>
        </dl>
      </section>

      <section class="local-admin-panel">
        <h2>2 · Jobs</h2>
        <div class="local-admin-job-grid">
          <button :if={@football_data_configured} type="button" phx-click="start_catalog">
            Sincronizar catálogo completo
          </button>
          <button type="button" phx-click="run_support_job" phx-value-job="quote_close">
            Cierre de cotizaciones
          </button>
          <button type="button" phx-click="run_support_job" phx-value-job="quote_recovery">
            Recuperar cotizaciones
          </button>
          <button type="button" phx-click="run_support_job" phx-value-job="conditional_recovery">
            Revisar órdenes condicionales
          </button>
        </div>
      </section>

      <footer><a href="/players">Volver a jugadores</a></footer>
    </main>
    """
  end

  defp reload_data(socket) do
    data = Sync.ops_snapshot()

    assign(socket,
      db: data.db,
      redis: data.redis,
      table_counts:
        Enum.map(data.table_counts, fn {k, v} -> {Map.get(@table_labels, k, to_string(k)), v} end),
      primary_inventory_account: data.primary_inventory_account,
      queues: data.queues,
      queue_names: data.queue_names,
      football_data_configured: data.football_data_configured,
      fotmob_enabled: data.fotmob_enabled
    )
  end
end

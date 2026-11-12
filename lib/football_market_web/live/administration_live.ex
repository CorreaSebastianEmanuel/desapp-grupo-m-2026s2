defmodule FootballMarketWeb.AdministrationLive do
  @moduledoc "Two fixed valuation formulas within the authenticated workspace."
  use FootballMarketWeb, :live_view

  import FootballMarketWeb.WorkspaceComponents, only: [shell: 1, metric_name: 1, role_name: 1]

  alias FootballMarket.Valuation.Configurations
  alias FootballMarketWeb.Workspace.Session

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
          "Estrategia activa actualizada. Las cotizaciones cambian en el próximo cierre."

        {:error, %{reason: :stale_selection}} ->
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
          Todavía no hay una estrategia activa. Elegí una para los próximos cierres.
        </p>
        <p
          :if={!@configurations_unavailable and legacy_selection?(@versions, @active_version_id)}
          id="legacy-active-configuration"
          class="strategy-notice"
        >
          Hay una configuración anterior activa. Elegí General o Por posición para usar una de las dos bases en los próximos cierres.
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
                  Seleccionada para el próximo cierre
                </span>
              </div>
              <details class="strategy-rules">
                <summary>Ver cómo calcula</summary>
                <p>
                  Las métricas excluidas no son requisitos. Un dato requerido faltante produce datos insuficientes.
                </p>
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
                      <tr :for={metric <- FootballMarket.Valuation.Request.metrics()}>
                        <th scope="row">{metric_name(metric)}</th>
                        <td>{number(Map.get(version.references, metric))}</td>
                        <td :for={group <- groups(version)}>
                          {number(Map.get(weights(version, group), metric))}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <p>
                  La posición es la registrada en cada partido. Cada aporte semanal tiene un tope de uno antes de aplicar su peso.
                </p>
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
        <aside class="strategy-footnote">
          <.icon name="hero-information-circle" class="button-icon" />
          <p>
            Cambiar la estrategia conserva las cotizaciones históricas. La elegida se aplica en el próximo cierre nocturno; un resultado no positivo no publica una cotización positiva.
          </p>
        </aside>
      </section>
    </.shell>
    """
  end
end

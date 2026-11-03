defmodule FootballMarketWeb.AdministrationLive do
  @moduledoc "Authenticated selection of existing immutable valuation versions."
  use FootballMarketWeb, :live_view
  import FootballMarketWeb.WorkspaceComponents, only: [strategy_name: 1]

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Valuation.Configurations

  def mount(_, _, socket), do: {:ok, socket |> assign(notice: nil) |> reload()}

  def handle_event("activate", %{"version_id" => id}, socket) do
    result = Configurations.activate_for(actor(socket), id, socket.assigns.active_version_id)

    notice =
      case result do
        {:ok, _} ->
          "Estrategia activa actualizada. Las cotizaciones cambian en el próximo cierre."

        {:error, %{reason: :stale_selection}} ->
          "Otra sesión cambió la selección. Revisá la versión activa e intentá de nuevo."

        _ ->
          "No se pudo activar la versión seleccionada."
      end

    {:noreply, socket |> assign(notice: notice) |> reload()}
  end

  defp reload(socket) do
    case Configurations.inspect_for(actor(socket)) do
      {:ok, data} ->
        assign(socket, versions: data.versions, active_version_id: data.active_version_id)

      _ ->
        assign(socket, versions: [], active_version_id: nil)
    end
  end

  defp actor(socket) do
    %AuthenticatedActor{
      account_id: socket.assigns.actor.account_id,
      authentication_method: :browser,
      credential_id: socket.assigns.actor.session_id
    }
  end

  def render(assigns) do
    ~H"""
    <main id="administration" class="local-admin">
      <a href="/portfolio">Volver al portafolio</a>
      <h1>Administración del mercado</h1>
      <p>
        Seleccioná una configuración existente. La activación no modifica cotizaciones históricas ni recalcula precios de inmediato.
      </p>
      <p :if={@notice} id="activation-notice" role="status">{@notice}</p>
      <p :if={@versions == []}>No hay versiones disponibles.</p>
      <section
        :for={{version, index} <- Enum.with_index(@versions, 1)}
        id={"configuration-#{version.id}"}
        class="local-admin-panel"
      >
        <h2>
          {strategy_name(version.strategy_id)} · Fórmula {version.formula_version} · Configuración {index}
        </h2>
        <p>Guardada {Calendar.strftime(version.created_at, "%d/%m/%Y %H:%M UTC")}</p>
        <p :if={version.id == @active_version_id} class="active-configuration">Activa</p>
        <details>
          <summary>Ver reglas de esta versión</summary><pre>{Jason.encode!(version.rules, pretty: true)}</pre>
        </details>
        <button
          :if={version.id != @active_version_id}
          phx-click="activate"
          phx-value-version_id={version.id}
        >Activar configuración {index}</button>
      </section>
    </main>
    """
  end
end

defmodule FootballMarketWeb.AdministrationLive do
  @moduledoc "Authenticated selection of existing immutable valuation versions."
  use FootballMarketWeb, :live_view

  import FootballMarketWeb.WorkspaceComponents,
    only: [strategy_name: 1, metric_name: 1, role_name: 1]

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Valuation.Configurations
  alias FootballMarket.Valuation.Configurations.{Presets, Editor}

  def mount(_, _, socket),
    do: {:ok, socket |> assign(notice: nil, editing: nil, editor_values: nil) |> reload()}

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

  def handle_event("provision_presets", _, socket) do
    notice =
      case Configurations.provision_presets_for(actor(socket)) do
        {:ok, _} ->
          "Predefinidas disponibles. Elegí una versión para activarla por separado."

        {:error, :missing_standard_positions} ->
          "Faltan posiciones estándar (GK, DEF, MID, FWD). Completá el catálogo antes de instalar."

        _ ->
          "No se pudieron instalar las predefinidas."
      end

    {:noreply, socket |> assign(notice: notice) |> reload()}
  end

  def handle_event("edit", %{"version_id" => id}, socket) do
    case Enum.find(socket.assigns.versions, &(&1.id == id)) do
      nil ->
        {:noreply, assign(socket, notice: "Versión no disponible.")}

      version ->
        {:noreply, assign(socket, editing: version, editor_values: Editor.values(version))}
    end
  end

  def handle_event("save_custom", %{"configuration" => params}, socket) do
    case socket.assigns.editing &&
           Configurations.save_custom_for(actor(socket), socket.assigns.editing.id, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(
           editing: nil,
           editor_values: nil,
           notice:
             "Nueva versión personalizada guardada. Activala por separado; no se recalcularon precios."
         )
         |> reload()}

      _ ->
        {:noreply,
         assign(socket,
           editor_values: params,
           notice:
             "Revisá los valores: pesos decimales, referencias positivas para las métricas incluidas y al menos una métrica por grupo."
         )}
    end
  end

  def handle_event("cancel_edit", _, socket),
    do: {:noreply, assign(socket, editing: nil, editor_values: nil)}

  defp included_value(""), do: "Excluida"
  defp included_value(value), do: value

  defp distinct_rules(versions, family) do
    versions
    |> Enum.filter(&(&1.strategy_id == family))
    |> Enum.uniq_by(&Presets.equivalent_key/1)
    |> length()
  end

  defp equivalent_versions(version, versions),
    do:
      Enum.filter(
        versions,
        &(&1.id != version.id and Presets.equivalent_key(&1) == Presets.equivalent_key(version))
      )

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
      <a href="/portfolio" class="text-link">← Volver al portafolio</a>
      <header class="local-admin-header">
        <p class="eyebrow">CONFIGURACIÓN DEL MERCADO</p>
        <h1>Administración del mercado</h1>
        <p>
          Seleccioná una configuración existente. La activación no modifica cotizaciones históricas ni recalcula precios de inmediato.
        </p>
      </header>
      <p :if={@notice} id="activation-notice" role="status">{@notice}</p>
      <p :if={is_nil(@active_version_id)} id="no-active-configuration">
        Sin configuración activa. Guardar o instalar no activa reglas.
      </p>
      <p :if={@versions == []}>No hay versiones disponibles.</p>
      <p id="configuration-counts">
        2 familias de estrategia · {length(@versions)} versiones guardadas
      </p>
      <button id="provision-presets" phx-click="provision_presets">Instalar predefinidas v1</button>
      <p>
        Calibración educativa inicial editable. Referencias de conteos semanales UTC con tope de uno por métrica. Un resultado no positivo no genera cotización positiva.
      </p>
      <section :for={family <- Presets.families()} id={"strategy-#{family}"} class="local-admin-panel">
        <h2>{strategy_name(family)}</h2>
        <p>
          {Enum.count(@versions, &(&1.strategy_id == family))} versiones de esta fórmula · {distinct_rules(
            @versions,
            family
          )} conjuntos de reglas diferentes
        </p>
        <p :if={!Enum.any?(@versions, &(&1.strategy_id == family))}>
          Esta familia todavía no tiene versiones guardadas.
        </p>
        <article
          :for={{version, index} <- Enum.with_index(@versions, 1)}
          :if={version.strategy_id == family}
          id={"configuration-#{version.id}"}
        >
          <h3>Fórmula {version.formula_version} · Configuración {index}</h3>
          <p>{if version.preset_key, do: "Predefinida educativa v1", else: "Personalizada"}</p>
          <p>Identidad: <code>{version.id}</code></p>
          <p>Guardada {Calendar.strftime(version.created_at, "%d/%m/%Y %H:%M UTC")}</p>
          <p :if={version.id == @active_version_id} class="active-configuration">Activa</p>
          <p
            :for={equivalent <- equivalent_versions(version, @versions)}
            class="equivalent-configuration"
          >
            Reglas equivalentes a {equivalent.id}; conserva su identidad e historial.
          </p>
          <details>
            <summary>Ver reglas de esta versión</summary>
            <p>
              Las métricas excluidas no son requisitos. Faltantes requeridos producen datos insuficientes. Las posiciones corresponden al partido histórico.
            </p>
            <div class="table-scroll">
              <table>
                <thead>
                  <tr>
                    <th>Métrica</th><th>Referencia semanal</th><th :for={
                      group <- Editor.groups(version)
                    }>
                      {role_name(group)}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={metric <- FootballMarket.Valuation.Request.metrics()}>
                    <th>{metric_name(metric)}</th>
                    <td>
                      {get_in(Editor.values(version), ["references", Atom.to_string(metric)])
                      |> included_value()}
                    </td>
                    <td :for={group <- Editor.groups(version)}>
                      {get_in(Editor.values(version), [
                        "weights",
                        Atom.to_string(group),
                        Atom.to_string(metric)
                      ])
                      |> included_value()}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <p :for={{position_id, group} <- version.position_mapping}>
              Posición {position_id}: {role_name(group)}
            </p>
            <pre>{Jason.encode!(version.rules, pretty: true)}</pre>
          </details>
          <button phx-click="edit" phx-value-version_id={version.id}>Editar como nueva versión</button>
          <button
            :if={version.id != @active_version_id}
            phx-click="activate"
            phx-value-version_id={version.id}
          >Activar configuración {index}</button>
        </article>
      </section>
      <section :if={@editing} id="configuration-editor" class="local-admin-panel">
        <h2>Nueva versión de {strategy_name(@editing.strategy_id)}</h2>
        <p>
          Basada en {@editing.id}. Vacío excluye la métrica; cero es un peso incluido que exige datos. Las referencias deben ser positivas para las métricas incluidas y vacías para las excluidas de todos los grupos.
        </p>
        <form id="configuration-form" phx-submit="save_custom">
          <div class="table-scroll">
            <table>
              <thead>
                <tr>
                  <th>Métrica</th><th>Referencia semanal</th><th :for={
                    group <- Editor.groups(@editing)
                  }>
                    {role_name(group)}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr :for={metric <- FootballMarket.Valuation.Request.metrics()}>
                  <th>{metric_name(metric)}</th>
                  <td>
                    <input
                      aria-label={"Referencia: " <> metric_name(metric)}
                      name={"configuration[references][#{metric}]"}
                      value={get_in(@editor_values, ["references", Atom.to_string(metric)])}
                      inputmode="decimal"
                    />
                  </td>
                  <td :for={group <- Editor.groups(@editing)}>
                    <input
                      aria-label={role_name(group) <> ": " <> metric_name(metric)}
                      name={"configuration[weights][#{group}][#{metric}]"}
                      value={
                        get_in(@editor_values, [
                          "weights",
                          Atom.to_string(group),
                          Atom.to_string(metric)
                        ])
                      }
                      inputmode="decimal"
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <button type="submit">Guardar nueva versión</button>
          <button type="button" phx-click="cancel_edit">Cancelar</button>
        </form>
      </section>
    </main>
    """
  end
end

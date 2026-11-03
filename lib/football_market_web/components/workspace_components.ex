defmodule FootballMarketWeb.WorkspaceComponents do
  @moduledoc false
  use FootballMarketWeb, :html
  attr :actor, :map, required: true
  attr :destination, :string, required: true
  attr :credit_balance, :any, required: true
  attr :credit_balance_unavailable, :boolean, required: true
  slot :inner_block, required: true

  def shell(assigns) do
    ~H"""
    <section id="workspace" phx-hook="WorkspaceSession">
      <div id="connection-notice" role="alert" hidden>Se perdió la conexión. Reconectando…</div>
      <div id="private-workspace" data-private-workspace>
        <header>
          <a class="brand" href="/"><span class="brand-mark" aria-hidden="true">FM</span>
          Football Market</a>
          <nav aria-label="Espacio de trabajo">
            <a href="/players" aria-current={@destination == "/players" && "page"}>Jugadores</a>
            <a href="/ranking" aria-current={@destination == "/ranking" && "page"}>Ranking</a>
            <a href="/portfolio" aria-current={@destination == "/portfolio" && "page"}>Portafolio</a>
            <a
              href="/conditional-orders"
              aria-current={@destination == "/conditional-orders" && "page"}
            >Órdenes condicionales</a>
          </nav>
          <div class="workspace-account">
            <div class="workspace-account-details">
              <span class="account-email">{@actor.email}</span>
              <span
                :if={!@credit_balance_unavailable}
                id="credit-balance"
                class="account-credit-balance"
              >
                Créditos disponibles: {Decimal.round(@credit_balance, 2) |> Decimal.to_string(:normal)}
              </span>
              <span
                :if={@credit_balance_unavailable}
                id="credit-balance-unavailable"
                role="alert"
              >
                Saldo de créditos no disponible
              </span>
            </div>
            <form method="post" action="/sign-out">
              <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
              <button>Cerrar sesión</button>
            </form>
          </div>
        </header>
        <main id="workspace-main">{render_slot(@inner_block)}</main>
        <footer class="workspace-footer">
          Football Market <span>Tokens de jugadores · Cotizaciones según rendimiento</span>
        </footer>
      </div>
    </section>
    """
  end

  attr :card, :map, default: nil
  attr :quote, :map, default: nil
  attr :error, :string, default: nil
  attr :request_key, :string, required: true
  attr :credit_balance, :any, default: nil
  attr :credit_balance_unavailable, :boolean, default: false
  attr :initial_recipient, :boolean, default: false
  attr :initial_recipient_unavailable, :boolean, default: false
  attr :trade_quantity, :string, default: ""
  attr :positions, :list, default: []
  attr :portfolio_unavailable, :boolean, default: false
  attr :issuer_inventory, :list, default: []
  attr :issuer_inventory_unavailable, :boolean, default: false
  attr :trade_error, :string, default: nil
  attr :notice, :string, default: nil
  attr :complete, :boolean, default: false

  def player_card(assigns) do
    ~H"""
    <p :if={@error} role="alert">{@error}</p>
    <article :if={@card} id="player-card">
      <h2>{@card.player.display_name}</h2>
      <p class="player-subtitle">
        {position_name(@card.player.position.code)} · {@card.player.team.name} · {@card.player.team.season.league.name}
      </p>
      <p>Temporada {@card.player.team.season.start_year}–{@card.player.team.season.end_year}</p>
      <p :if={@quote} id="player-quote">
        Valor por token <strong>{money(@quote.unit_price)} créditos</strong>
        <span>· Vigente desde {Calendar.strftime(@quote.effective_at, "%d/%m/%Y %H:%M UTC")}</span>
      </p>
      <p :if={!@quote && @card.statistics.recorded_match_count > 0} id="player-quote-missing">
        Aún no hay una cotización disponible. Se habilitarán las operaciones cuando se publique.
      </p>
      <p
        :if={@card.statistics.recorded_match_count == 0 && @quote}
        id="player-statistics-unavailable"
        class="statistics-notice"
      >
        Todavía no hay estadísticas cargadas para esta temporada.
      </p>
      <p
        :if={@card.statistics.recorded_match_count == 0 && !@quote}
        id="player-statistics-unavailable"
        class="statistics-notice"
      >
        Todavía no hay estadísticas cargadas ni una cotización disponible. No se pueden operar tokens por ahora.
      </p>
      <p :if={@card.statistics.recorded_match_count > 0} id="player-statistics-coverage">
        Datos registrados para esta temporada; la cobertura puede ser parcial.
      </p>
      <dl :if={@card.statistics.recorded_match_count > 0} id="player-statistics">
        <dt>Partidos registrados</dt><dd>{@card.statistics.recorded_match_count}</dd>
        <dt :if={@card.statistics.minutes_played != nil}>Minutos jugados</dt>
        <dd :if={@card.statistics.minutes_played != nil}>{@card.statistics.minutes_played}</dd>
        <dt :if={@card.statistics.goals != nil}>Goles</dt>
        <dd :if={@card.statistics.goals != nil}>{@card.statistics.goals}</dd>
        <dt :if={@card.statistics.assists != nil}>Asistencias</dt>
        <dd :if={@card.statistics.assists != nil}>{@card.statistics.assists}</dd>
      </dl>
      <section id="player-position-summary" aria-label="Tu posición en este jugador">
        <h3>Tu posición</h3>
        <%= cond do %>
          <% @initial_recipient_unavailable ||
               (@initial_recipient && @issuer_inventory_unavailable) ||
               (!@initial_recipient && @portfolio_unavailable) -> %>
            <p id="player-position-unavailable" role="alert">
              Tus tenencias no están disponibles temporalmente.
            </p>
          <% @initial_recipient -> %>
            <%= if item = Enum.find(@issuer_inventory, &(&1.player_id == @card.player.id)) do %>
              <p><strong>{item.quantity} tokens</strong> del inventario inicial</p>
            <% else %>
              <p>Todavía no tenés tokens de este jugador.</p>
            <% end %>
          <% position = Enum.find(@positions, &(&1.player_id == @card.player.id)) -> %>
            <p>
              <strong>{position.quantity} tokens</strong><span :if={@quote}> · Valor estimado {money(
                Decimal.mult(@quote.unit_price, position.quantity)
              )} créditos</span>
            </p>
          <% true -> %>
            <p>Todavía no tenés tokens de este jugador.</p>
        <% end %>
      </section>
      <a
        :if={@quote && !@initial_recipient && !@initial_recipient_unavailable}
        href={~p"/conditional-orders?player_id=#{@card.player.id}"}
      >Crear orden</a>
      <p :if={@initial_recipient} id="initial-issuer-trade-note" class="statistics-notice">
        Esta cuenta emitió los tokens iniciales. Otros usuarios pueden comprarlos de su inventario; esta cuenta no puede operar sus propios tokens.
      </p>
      <p
        :if={@initial_recipient_unavailable}
        id="initial-issuer-check-unavailable"
        role="alert"
      >
        No se pueden operar tokens temporalmente porque no pudimos verificar el tipo de cuenta.
      </p>
      <form
        :if={@quote && !@complete && !@initial_recipient && !@initial_recipient_unavailable}
        id="trade-form"
        phx-submit="trade"
        phx-change="trade_preview"
      >
        <input type="hidden" name="request_key" value={@request_key} />
        <p :if={@credit_balance_unavailable} id="player-card-credit-balance-unavailable" role="alert">
          No se pudo consultar el saldo; la compra no está disponible temporalmente.
        </p>
        <label for="trade-quantity">Cantidad de tokens</label>
        <input
          id="trade-quantity"
          name="quantity"
          type="number"
          min="1"
          step="1"
          placeholder="Ingresá un número entero"
          value={@trade_quantity}
          required
        />
        <p id="trade-estimate" class="trade-estimate">
          Importe estimado:
          <strong>{estimated_total(@trade_quantity, @quote.unit_price)} créditos</strong>
        </p>
        <div id="trade-actions">
          <button
            type="submit"
            name="side"
            value="buy"
            class="trade-action-buy"
            disabled={@credit_balance_unavailable}
          >Comprar tokens</button>
          <button
            type="submit"
            name="side"
            value="sell"
            class="trade-action-sell"
            disabled={Enum.find(@positions, &(&1.player_id == @card.player.id)) == nil}
          >Vender tokens</button>
        </div>
      </form>
      <p :if={@trade_error} id="trade-error" role="alert">{@trade_error}</p>
      <p :if={@notice} id="trade-notice" role="status">{@notice}</p>
      <button :if={@complete || @trade_error} id="new-trade" phx-click="new_trade">Nueva operación</button>
    </article>
    """
  end

  attr :ranking, :map, default: nil
  attr :error, :string, default: nil

  def ranking_view(assigns) do
    ~H"""
    <section id="ranking">
      <h1>Ranking de estrategia activa</h1>
      <p :if={@error} role="alert">{@error}</p>
      <div :if={!@ranking && !@error} id="ranking-unavailable" class="empty-state">
        <h2>El ranking todavía no está disponible</h2>
        <p>Se mostrará cuando haya una estrategia de cotización activa.</p>
        <a class="text-link" href="/players">Explorar jugadores →</a>
      </div>
      <div :if={@ranking}>
        <p id="ranking-strategy">
          Estrategia activa: {@ranking.configuration.strategy_id} · Fórmula {@ranking.configuration.formula_version} · Configuración {@ranking.configuration.id}
        </p>
        <p :if={@ranking.entries == []} id="ranking-empty">
          No hay cotizaciones válidas para la estrategia activa.
        </p>
        <ol id="ranking-entries">
          <li :for={entry <- @ranking.entries} id={"ranking-player-#{entry.player_id}"}>
            <a href={~p"/players?player_id=#{entry.player_id}"}>Jugador {entry.player_id}</a>
            · {Decimal.to_string(entry.unit_price, :normal)} créditos
          </li>
        </ol>
      </div>
    </section>
    """
  end

  attr :allocation, :map, default: nil
  attr :allocation_unavailable, :boolean, default: false
  attr :history, :map, default: nil
  attr :history_unavailable, :boolean, default: false

  def portfolio_charts(assigns) do
    ~H"""
    <section id="portfolio-charts" aria-labelledby="portfolio-charts-heading">
      <h2 id="portfolio-charts-heading">Gráficos del portafolio</h2>
      <section id="allocation-chart" aria-labelledby="allocation-heading">
        <h3 id="allocation-heading">Distribución actual</h3>
        <p :if={@allocation_unavailable} role="alert">
          La distribución no está disponible temporalmente. Probá de nuevo en unos instantes.
        </p>
        <div :if={@allocation}>
          <p :if={@allocation.positions == []} id="allocation-empty">
            No hay posiciones para mostrar.
          </p>
          <ol :if={@allocation.positions != []} class="allocation-bars">
            <li :for={position <- @allocation.positions}>
              <span class="allocation-player">{position.player_name}</span>
              <span class="allocation-track" aria-hidden="true">
                <span class="allocation-fill" style={allocation_style(position.weight)}></span>
              </span>
              <span class="allocation-value">
                {if is_nil(position.weight), do: "Sin datos", else: percent(position.weight)}
              </span>
            </li>
          </ol>
          <p :if={@allocation.positions != [] && !@allocation.totals.valuation_complete}>
            La distribución estará disponible cuando todos tus jugadores tengan una cotización actual.
          </p>
          <p :if={@allocation.positions != []} class="chart-as-of">
            Distribución al {DateTime.to_iso8601(@allocation.as_of)} UTC · Porcentaje del valor de mercado
          </p>
        </div>
      </section>

      <section id="portfolio-history" aria-labelledby="history-heading">
        <h3 id="history-heading">Historial diario del portafolio</h3>
        <p :if={@history_unavailable} role="alert">
          El historial del portafolio no está disponible temporalmente. Probá de nuevo en unos instantes.
        </p>
        <div :if={@history && !has_historical_activity?(@history.points)} id="history-empty">
          <p>Todavía no hay movimientos. Las compras y ventas realizadas aparecerán acá.</p>
        </div>
        <div :if={@history && has_historical_activity?(@history.points)}>
          <.history_chart
            :for={{metric, label} <- history_metrics()}
            points={@history.points}
            metric={metric}
            label={label}
          />
          <p class="chart-as-of">
            Valores diarios del {@history.from} al {@history.to} (UTC). Cada punto corresponde al horario indicado.
          </p>
        </div>
      </section>
    </section>
    """
  end

  attr :points, :list, required: true
  attr :metric, :atom, required: true
  attr :label, :string, required: true

  def history_chart(assigns) do
    assigns = assign(assigns, :path, chart_path(assigns.points, assigns.metric))

    ~H"""
    <section class="history-chart" id={"history-chart-#{@metric}"}>
      <h4>{@label}</h4>
      <svg
        viewBox="0 0 620 200"
        role="img"
        aria-labelledby={"#{@metric}-title #{@metric}-description"}
      >
        <title id={"#{@metric}-title"}>{@label} por día</title>
        <desc id={"#{@metric}-description"}>
          Valores diarios en créditos. Los importes que dependen de una cotización faltante aparecen como espacios.
        </desc>
        <line x1="32" y1="170" x2="608" y2="170" class="chart-axis" />
        <path :if={@path != ""} d={@path} class="chart-line" />
        <text x="32" y="192">{first_chart_date(@points)}</text>
        <text x="608" y="192" text-anchor="end">{last_chart_date(@points)}</text>
      </svg>
      <p class="chart-scale">{chart_scale(@points, @metric)}</p>
      <details>
        <summary>Ver valores de {@label} y horarios UTC</summary>
        <div class="table-scroll chart-table">
          <table>
            <caption>{@label} · Créditos</caption>
            <thead>
              <tr>
                <th scope="col">Corte UTC</th><th scope="col">Valor</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={point <- @points}>
                <th scope="row">{DateTime.to_iso8601(point.cutoff_at)}</th>
                <td>{chart_value(Map.get(point, @metric))}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </details>
    </section>
    """
  end

  defp history_metrics do
    [
      {:market_value, "Valor de mercado del portafolio"},
      {:realized_profit_loss, "Ganancia/pérdida realizada"},
      {:unrealized_profit_loss, "Ganancia/pérdida no realizada"}
    ]
  end

  defp has_historical_activity?(points) do
    Enum.any?(points, fn point ->
      Decimal.positive?(point.purchase_expenditure) or Decimal.positive?(point.sale_proceeds)
    end)
  end

  defp allocation_style(nil), do: "width: 0%"

  defp allocation_style(weight) do
    percentage = weight |> Decimal.mult(Decimal.new(100)) |> Decimal.to_float()
    "width: #{min(max(percentage, 0.0), 100.0)}%"
  end

  defp percent(weight) do
    weight
    |> Decimal.mult(Decimal.new(100))
    |> Decimal.round(1, :half_up)
    |> Decimal.to_string(:normal)
    |> Kernel.<>("%")
  end

  defp chart_path(points, metric) do
    values = Enum.map(points, &Map.get(&1, metric))

    case chart_bounds(values) do
      nil ->
        ""

      {minimum, maximum} ->
        scale = {minimum, maximum, max(length(values) - 1, 1)}

        values
        |> Enum.with_index()
        |> Enum.chunk_by(fn {value, _index} -> is_nil(value) end)
        |> Enum.reject(&missing_chart_segment?/1)
        |> Enum.map_join(" ", &chart_segment_path(&1, scale))
    end
  end

  defp chart_bounds(values) do
    known = Enum.reject(values, &is_nil/1)

    case known do
      [] ->
        nil

      values ->
        floats = Enum.map(values, &Decimal.to_float/1)
        {Enum.min(floats), Enum.max(floats)}
    end
  end

  defp missing_chart_segment?([{nil, _index} | _rest]), do: true
  defp missing_chart_segment?(_segment), do: false

  defp chart_segment_path([{value, index}], scale) do
    command = chart_point_command(value, index, index, scale)
    command <> " L" <> String.replace_prefix(command, "M", "")
  end

  defp chart_segment_path([{_value, first_index} | _rest] = segment, scale) do
    Enum.map_join(segment, " ", fn {value, index} ->
      chart_point_command(value, index, first_index, scale)
    end)
  end

  defp chart_point_command(value, index, first_index, {minimum, maximum, last_index}) do
    x = 32 + 576 * index / last_index
    y = chart_y(value, minimum, maximum)
    command = if index == first_index, do: "M", else: "L"
    "#{command}#{Float.round(x, 2)},#{Float.round(y, 2)}"
  end

  defp chart_y(_value, minimum, maximum) when minimum == maximum, do: 88.0

  defp chart_y(value, minimum, maximum) do
    span = maximum - minimum
    16 + 144 * (maximum - Decimal.to_float(value)) / span
  end

  defp chart_value(nil), do: "Sin datos"
  defp chart_value(value), do: Decimal.to_string(value, :normal)

  defp chart_scale(points, metric) do
    values = points |> Enum.map(&Map.get(&1, metric)) |> Enum.reject(&is_nil/1)

    case values do
      [] ->
        "No hay valores para graficar."

      values ->
        minimum = Enum.min_by(values, &Decimal.to_float/1)
        maximum = Enum.max_by(values, &Decimal.to_float/1)
        "Escala: #{chart_value(minimum)} a #{chart_value(maximum)} créditos."
    end
  end

  defp first_chart_date([point | _]), do: Date.to_iso8601(point.date)
  defp first_chart_date([]), do: ""
  defp last_chart_date([]), do: ""
  defp last_chart_date(points), do: points |> List.last() |> then(&Date.to_iso8601(&1.date))

  def position_name("GK"), do: "Arquero"
  def position_name("DEF"), do: "Defensor"
  def position_name("DF"), do: "Defensor"
  def position_name("MID"), do: "Mediocampista"
  def position_name("MF"), do: "Mediocampista"
  def position_name("FWD"), do: "Delantero"
  def position_name("FW"), do: "Delantero"
  def position_name(value), do: value

  defp money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)

  defp estimated_total(quantity, unit_price) do
    case Integer.parse(quantity) do
      {amount, ""} when amount > 0 -> money(Decimal.mult(unit_price, amount))
      _ -> "—"
    end
  end

  attr :heading, :string, required: true

  def unavailable(assigns) do
    ~H"""
    <h1>{@heading}</h1>
    <p>
      Esta sección todavía no está disponible. Se agregarán más funciones en futuras actualizaciones.
    </p>
    """
  end

  attr :kind, :string, required: true

  def recovery(assigns) do
    ~H"""
    <main>
      <h1>{@kind}</h1><p role="alert">Este contenido no está disponible.</p><a href="/portfolio">Volver al espacio de trabajo</a><a href="/sign-in">Iniciar sesión</a>
    </main>
    """
  end
end

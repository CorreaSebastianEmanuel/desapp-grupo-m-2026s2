defmodule FootballMarketWeb.PortfolioComponents do
  @moduledoc false
  use FootballMarketWeb, :html

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
            Distribución al {timestamp(@allocation.as_of)} · Porcentaje del valor de mercado
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
            Valores diarios del {@history.from} al {@history.to} (UTC). Cada punto corresponde al cierre del día; el día actual es parcial.
          </p>
        </div>
      </section>
    </section>
    """
  end

  attr :allocation, :map, default: nil
  attr :portfolio_history, :map, default: nil

  def portfolio_tables(assigns) do
    ~H"""
    <div
      :if={@allocation}
      class="table-scroll"
      role="region"
      aria-label="Distribución de posiciones"
      tabindex="0"
    >
      <dl
        id="portfolio-allocation-totals"
        class="portfolio-metrics"
        aria-label="Totales de distribución en créditos"
      >
        <div class="portfolio-metric">
          <dt>Valor de mercado</dt><dd>{exact_money(@allocation.totals.market_value)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Costo base</dt><dd>{exact_money(@allocation.totals.cost_basis)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Compras</dt><dd>{exact_money(@allocation.totals.purchase_expenditure)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Ventas</dt><dd>{exact_money(@allocation.totals.sale_proceeds)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Invertido neto</dt><dd>{exact_money(@allocation.totals.net_invested)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Realizada</dt><dd>{exact_money(@allocation.totals.realized_profit_loss)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>No realizada</dt><dd>{exact_money(@allocation.totals.unrealized_profit_loss)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Resultado total</dt><dd>{exact_money(@allocation.totals.total_profit_loss)}</dd>
        </div>
        <div class="portfolio-metric">
          <dt>Valuación</dt><dd>
            {if @allocation.totals.valuation_complete, do: "Completa", else: "Incompleta"}
          </dd>
        </div>
      </dl>
      <p
        :if={!@allocation.totals.valuation_complete}
        id="allocation-missing-quotes"
        role="status"
      >
        Cotización pendiente para: {Enum.join(
          @allocation.totals.missing_quote_player_ids,
          ", "
        )}. Los valores faltantes se muestran como huecos.
      </p>
      <table :if={@allocation.positions != []} id="portfolio-allocation-table">
        <caption>Distribución actual del portafolio · {timestamp(@allocation.as_of)}</caption>
        <thead>
          <tr>
            <th>Jugador</th><th>Cantidad</th><th>Costo promedio</th><th>Costo base</th><th>
              Valor de mercado
            </th><th>
              Ganancia/pérdida realizada
            </th><th>No realizada</th><th>Peso</th><th>Cotización</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={item <- @allocation.positions}>
            <th scope="row">
              <a href={~p"/players?player_id=#{item.player_id}"}>{item.player_name}</a>
            </th>
            <td>{item.quantity}</td><td>{exact_money(item.average_unit_cost)}</td><td>
              {exact_money(item.cost_basis)}
            </td><td>
              {exact_money(item.market_value)}
            </td><td>{exact_money(item.realized_profit_loss)}</td><td>
              {exact_money(item.unrealized_profit_loss)}
            </td><td>
              {if item.weight,
                do: exact_money(Decimal.mult(item.weight, Decimal.new(100))) <> "%",
                else: "Sin datos"}
            </td>
            <td>
              <details>
                <summary>Ver cotización</summary><p :if={item.quote}>
                  {exact_money(item.quote.unit_price)} créditos por token · vigente desde {timestamp(
                    item.quote.effective_at
                  )}
                </p><p :if={!item.quote}>Sin cotización disponible</p>
              </details>
            </td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th>Totales</th><td></td><td></td><td>
              {exact_money(@allocation.totals.cost_basis)}
            </td><td>
              {exact_money(@allocation.totals.market_value)}
            </td><td>{exact_money(@allocation.totals.realized_profit_loss)}</td><td>
              {exact_money(@allocation.totals.unrealized_profit_loss)}
            </td><td></td><td>
              Resultado total: {exact_money(@allocation.totals.total_profit_loss)}
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
    <details
      :if={@portfolio_history && @portfolio_history.points != []}
      id="portfolio-history-details"
      class="portfolio-data-details"
    >
      <summary>Ver historial diario completo <span>Valores y detalle de cada día</span></summary>
      <div
        class="table-scroll"
        role="region"
        aria-label="Historial diario del portafolio"
        tabindex="0"
      >
        <table id="portfolio-history-table">
          <caption>
            Historial diario · {@portfolio_history.from} a {@portfolio_history.to} ({@portfolio_history.timezone}) · consultado {timestamp(
              @portfolio_history.as_of
            )}
          </caption>
          <thead>
            <tr>
              <th>Día (UTC)</th><th>Corte</th><th>Valor de mercado</th><th>Costo base</th><th>
                Compras
              </th><th>
                Ventas
              </th><th>Invertido neto</th><th>Realizada</th><th>No realizada</th><th>Total</th><th>
                Valuación
              </th><th>Jugadores sin cotización</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={point <- @portfolio_history.points}>
              <th scope="row">{point.date}</th><td>{daily_cutoff(point)}</td><td>
                {exact_money(point.market_value)}
              </td><td>
                {exact_money(point.cost_basis)}
              </td><td>{exact_money(point.purchase_expenditure)}</td><td>
                {exact_money(point.sale_proceeds)}
              </td><td>{exact_money(point.net_invested)}</td><td>
                {exact_money(point.realized_profit_loss)}
              </td><td>{exact_money(point.unrealized_profit_loss)}</td><td>
                {exact_money(point.total_profit_loss)}
              </td><td>
                {if point.valuation_complete, do: "Completa", else: "Incompleta"}{if point.partial,
                  do: " · parcial",
                  else: ""}
              </td><td>
                {if point.missing_quote_player_ids == [],
                  do: "—",
                  else: Enum.join(point.missing_quote_player_ids, ", ")}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </details>
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
        <summary>Ver valores diarios de {@label} (UTC)</summary>
        <div class="table-scroll chart-table">
          <table>
            <caption>{@label} · Créditos</caption>
            <thead>
              <tr>
                <th scope="col">Día (UTC)</th><th scope="col">Valor</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={point <- @points}>
                <th scope="row">
                  {point.date}{if Map.get(point, :partial, false),
                    do: " · parcial hasta " <> Calendar.strftime(point.cutoff_at, "%H:%M UTC"),
                    else: ""}
                </th>
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

  defp daily_cutoff(%{partial: true, cutoff_at: cutoff}),
    do: "Parcial hasta " <> Calendar.strftime(cutoff, "%H:%M UTC")

  defp daily_cutoff(_), do: "Cierre del día UTC"
  defp exact_money(nil), do: "Sin datos"
  defp exact_money(value), do: value |> Decimal.normalize() |> Decimal.to_string(:normal)
  defp timestamp(nil), do: "Sin datos"
  defp timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")
end

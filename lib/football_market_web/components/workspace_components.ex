defmodule FootballMarketWeb.WorkspaceComponents do
  @moduledoc false
  use FootballMarketWeb, :html
  attr :actor, :map, required: true
  attr :destination, :string, required: true
  slot :inner_block, required: true

  def shell(assigns) do
    ~H"""
    <section id="workspace" phx-hook="WorkspaceSession">
      <div id="connection-notice" role="alert" hidden>Connection lost. Reconnecting safely…</div>
      <div id="private-workspace" data-private-workspace>
        <header>
          <a class="brand" href="/"><span class="brand-mark" aria-hidden="true">FM</span>
          Football Market</a>
          <nav aria-label="Workspace">
            <a href="/players" aria-current={@destination == "/players" && "page"}>Players</a>
            <a href="/ranking" aria-current={@destination == "/ranking" && "page"}>Ranking</a>
            <a href="/portfolio" aria-current={@destination == "/portfolio" && "page"}>Portfolio</a>
            <a
              href="/conditional-orders"
              aria-current={@destination == "/conditional-orders" && "page"}
            >Conditional orders</a>
          </nav>
          <div class="workspace-account">
            <span>{@actor.email}</span>
            <form method="post" action="/sign-out">
              <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
              <button>Sign out</button>
            </form>
          </div>
        </header>
        <main id="workspace-main">{render_slot(@inner_block)}</main>
        <footer class="workspace-footer">
          Football Market <span>Player tokens · Performance-based quotes</span>
        </footer>
      </div>
    </section>
    """
  end

  attr :card, :map, default: nil
  attr :quote, :map, default: nil
  attr :error, :string, default: nil
  attr :request_key, :string, required: true
  attr :trade_error, :string, default: nil
  attr :notice, :string, default: nil
  attr :complete, :boolean, default: false

  def player_card(assigns) do
    ~H"""
    <p :if={@error} role="alert">{@error}</p>
    <article :if={@card} id="player-card">
      <h2>{@card.player.display_name}</h2>
      <p>
        {@card.player.position.name} · {@card.player.team.name} · {@card.player.team.season.league.name}
      </p>
      <p>Season {@card.player.team.season.start_year}–{@card.player.team.season.end_year}</p>
      <p :if={@quote} id="player-quote">
        Current quote: {Decimal.to_string(@quote.unit_price, :normal)} credits · Effective at {DateTime.to_iso8601(
          @quote.effective_at
        )}
      </p>
      <p :if={!@quote} id="player-quote-missing">Current quote missing or unavailable.</p>
      <p id="player-freshness">
        Statistics: {@card.statistics_status.freshness} · Refresh: {@card.statistics_status.refresh.state} · Valuation: {@card.statistics_status.valuation.state}
      </p>
      <p>Recorded local data for this catalog season; season coverage may be incomplete.</p>
      <dl id="player-statistics">
        <dt>Recorded matches</dt><dd>{@card.statistics.recorded_match_count}</dd>
        <dt>Minutes played</dt><dd>{known(@card.statistics.minutes_played)}</dd>
        <dt>Goals</dt><dd>{known(@card.statistics.goals)}</dd>
        <dt>Assists</dt><dd>{known(@card.statistics.assists)}</dd>
      </dl>
      <a href={~p"/conditional-orders?player_id=#{@card.player.id}"}>Create order</a>
      <p>The execution price is determined when the trade is processed.</p>
      <form :if={!@complete} id="trade-form" phx-submit="trade">
        <input type="hidden" name="request_key" value={@request_key} />
        <label for="trade-side">Action</label>
        <select id="trade-side" name="side"><option value="buy">Buy</option><option value="sell">
          Sell
        </option></select>
        <label for="trade-quantity">Token quantity</label>
        <input id="trade-quantity" name="quantity" type="number" min="1" step="1" required />
        <button type="submit">Confirm trade</button>
      </form>
      <p :if={@trade_error} id="trade-error" role="alert">{@trade_error}</p>
      <p :if={@notice} id="trade-notice" role="status">{@notice}</p>
      <button :if={@complete || @trade_error} id="new-trade" phx-click="new_trade">New trade</button>
    </article>
    """
  end

  attr :ranking, :map, default: nil
  attr :error, :string, default: nil

  def ranking_view(assigns) do
    ~H"""
    <section id="ranking">
      <h1>Active strategy ranking</h1>
      <p :if={@error} role="alert">{@error}</p>
      <div :if={@ranking}>
        <p id="ranking-strategy">
          Active strategy: {@ranking.configuration.strategy_id} · Formula {@ranking.configuration.formula_version} · Configuration {@ranking.configuration.id}
        </p>
        <p :if={@ranking.entries == []} id="ranking-empty">
          No eligible quotes for the active strategy.
        </p>
        <ol id="ranking-entries">
          <li :for={entry <- @ranking.entries} id={"ranking-player-#{entry.player_id}"}>
            <a href={~p"/players?player_id=#{entry.player_id}"}>Player {entry.player_id}</a>
            · {Decimal.to_string(entry.unit_price, :normal)} credits
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
      <h2 id="portfolio-charts-heading">Portfolio charts</h2>
      <section id="allocation-chart" aria-labelledby="allocation-heading">
        <h3 id="allocation-heading">Current allocation</h3>
        <p :if={@allocation_unavailable} role="alert">
          Current allocation is temporarily unavailable. Try again shortly.
        </p>
        <div :if={@allocation}>
          <p :if={@allocation.positions == []} id="allocation-empty">
            No current holdings to allocate.
          </p>
          <ol :if={@allocation.positions != []} class="allocation-bars">
            <li :for={position <- @allocation.positions}>
              <span class="allocation-player">{position.player_name}</span>
              <span class="allocation-track" aria-hidden="true">
                <span class="allocation-fill" style={allocation_style(position.weight)}></span>
              </span>
              <span class="allocation-value">
                {if is_nil(position.weight), do: "Unknown", else: percent(position.weight)}
              </span>
            </li>
          </ol>
          <p :if={@allocation.positions != [] && !@allocation.totals.valuation_complete}>
            Allocation is unknown until every held player has a current quote.
          </p>
          <p :if={@allocation.positions != []} class="chart-as-of">
            Current allocation as of {DateTime.to_iso8601(@allocation.as_of)} UTC · Percent of
            market value
          </p>
        </div>
      </section>

      <section id="portfolio-history" aria-labelledby="history-heading">
        <h3 id="history-heading">Daily portfolio history</h3>
        <p :if={@history_unavailable} role="alert">
          Portfolio history is temporarily unavailable. Try again shortly.
        </p>
        <div :if={@history && !has_historical_activity?(@history.points)} id="history-empty">
          <p>No portfolio history yet. Completed purchases and sales will appear here.</p>
        </div>
        <div :if={@history && has_historical_activity?(@history.points)}>
          <.history_chart
            :for={{metric, label} <- history_metrics()}
            points={@history.points}
            metric={metric}
            label={label}
          />
          <p class="chart-as-of">
            Daily values for {@history.from} through {@history.to}, UTC. Each point is measured at
            its displayed cutoff time.
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
        <title id={"#{@metric}-title"}>{@label} by day</title>
        <desc id={"#{@metric}-description"}>
          Daily values in credits. Missing quote-dependent values appear as gaps.
        </desc>
        <line x1="32" y1="170" x2="608" y2="170" class="chart-axis" />
        <path :if={@path != ""} d={@path} class="chart-line" />
        <text x="32" y="192">{first_chart_date(@points)}</text>
        <text x="608" y="192" text-anchor="end">{last_chart_date(@points)}</text>
      </svg>
      <p class="chart-scale">{chart_scale(@points, @metric)}</p>
      <details>
        <summary>View {@label} values and UTC timestamps</summary>
        <div class="table-scroll chart-table">
          <table>
            <caption>{@label} · Credits</caption>
            <thead>
              <tr>
                <th scope="col">UTC cutoff</th><th scope="col">Value</th>
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
      {:market_value, "Portfolio market value"},
      {:realized_profit_loss, "Realized profit/loss"},
      {:unrealized_profit_loss, "Unrealized profit/loss"}
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

  defp chart_value(nil), do: "Unknown"
  defp chart_value(value), do: Decimal.to_string(value, :normal)

  defp chart_scale(points, metric) do
    values = points |> Enum.map(&Map.get(&1, metric)) |> Enum.reject(&is_nil/1)

    case values do
      [] ->
        "No known values to plot."

      values ->
        minimum = Enum.min_by(values, &Decimal.to_float/1)
        maximum = Enum.max_by(values, &Decimal.to_float/1)
        "Scale: #{chart_value(minimum)} to #{chart_value(maximum)} credits."
    end
  end

  defp first_chart_date([point | _]), do: Date.to_iso8601(point.date)
  defp first_chart_date([]), do: ""
  defp last_chart_date([]), do: ""
  defp last_chart_date(points), do: points |> List.last() |> then(&Date.to_iso8601(&1.date))

  defp known(nil), do: "Unknown"
  defp known(value), do: value

  attr :heading, :string, required: true

  def unavailable(assigns) do
    ~H"""
    <h1>{@heading}</h1>
    <p>This area is not available yet. More features will be added in a future update.</p>
    """
  end

  attr :kind, :string, required: true

  def recovery(assigns) do
    ~H"""
    <main>
      <h1>{@kind}</h1><p role="alert">This resource is unavailable.</p><a href="/portfolio">Return to workspace</a><a href="/sign-in">Sign in</a>
    </main>
    """
  end
end

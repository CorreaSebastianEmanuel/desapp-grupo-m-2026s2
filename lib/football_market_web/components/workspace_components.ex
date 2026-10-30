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

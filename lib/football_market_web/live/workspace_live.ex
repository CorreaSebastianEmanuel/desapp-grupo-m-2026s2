defmodule FootballMarketWeb.WorkspaceLive do
  use FootballMarketWeb, :live_view
  import FootballMarketWeb.WorkspaceComponents

  alias FootballMarket.Accounts.AuthenticatedActor

  alias FootballMarket.{
    Catalog,
    Market,
    Market.ConditionalOrders,
    Market.Portfolio,
    Quotes,
    Ranking
  }

  def mount(_, _, socket) do
    if connected?(socket) and socket.assigns.actor do
      Phoenix.PubSub.subscribe(
        FootballMarket.PubSub,
        "conditional_orders:" <> socket.assigns.actor.account_id
      )
    end

    {:ok,
     assign(socket,
       card: nil,
       card_error: nil,
       quote: nil,
       trade_key: Ecto.UUID.generate(),
       trade_error: nil,
       trade_notice: nil,
       trade_intent: nil,
       trade_complete: false,
       ranking: nil,
       ranking_error: nil,
       destination: nil,
       heading: nil,
       orders: [],
       positions: [],
       portfolio_unavailable: false,
       order_form: empty_form(),
       order_error: nil,
       order_notice: nil,
       player_search: "",
       search_performed: false,
       player_results: [],
       selected_player: nil,
       player_search_unavailable: false,
       orders_unavailable: false
     )}
  end

  def handle_params(_, uri, socket) do
    destination = URI.parse(uri).path
    params = URI.parse(uri).query |> then(&if(&1, do: URI.decode_query(&1), else: %{}))

    socket = assign(socket, destination: destination, heading: workspace_heading(destination))

    {:noreply,
     case destination do
       "/conditional-orders" ->
         socket |> reload_orders() |> load_selected_player(params["player_id"])

       "/players" ->
         load_card(socket, params["player_id"])

       "/ranking" ->
         load_ranking(socket)

       _ ->
         reload_portfolio(socket)
     end}
  end

  def handle_event("create_order", params, socket) do
    with {:ok, quantity} <- quantity(params["quantity"]),
         {:ok, terms} <- order_terms(params, quantity),
         {:ok, _order} <- ConditionalOrders.create(domain_actor(socket.assigns.actor), terms) do
      {:noreply,
       socket
       |> assign(order_form: empty_form(), order_error: nil, order_notice: "Order created.")
       |> reload_orders()}
    else
      {:error, error} ->
        {:noreply,
         assign(socket,
           order_form: form_values(params),
           order_error: error_message(error),
           order_notice: nil
         )}
    end
  end

  def handle_event("search_players", %{"player_search" => term}, socket) do
    case Catalog.search_players(term) do
      {:ok, players} ->
        {:noreply,
         assign(socket,
           player_search: term,
           search_performed: true,
           player_results: players,
           selected_player: nil,
           order_form: Map.put(socket.assigns.order_form, "player_id", ""),
           player_search_unavailable: false
         )}

      {:error, _} ->
        {:noreply,
         assign(socket,
           player_search: term,
           search_performed: true,
           player_results: [],
           selected_player: nil,
           player_search_unavailable: true
         )}
    end
  end

  def handle_event("select_player", %{"id" => id}, socket) do
    case Enum.find(socket.assigns.player_results, &(to_string(&1.id) == id)) do
      nil ->
        {:noreply, socket}

      player ->
        {:noreply,
         assign(socket,
           player_search: player.display_name,
           player_results: [],
           selected_player: player,
           order_form: Map.put(socket.assigns.order_form, "player_id", player.id)
         )}
    end
  end

  def handle_event("cancel_order", %{"id" => id}, socket) do
    case ConditionalOrders.cancel(domain_actor(socket.assigns.actor), id) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> assign(order_error: nil, order_notice: "Order state refreshed.")
         |> reload_orders()}

      {:error, error} ->
        {:noreply, assign(socket, order_error: error_message(error), order_notice: nil)}
    end
  end

  def handle_event("trade", %{"side" => side} = params, socket) when side in ["buy", "sell"] do
    with %{player: player} <- socket.assigns.card,
         true <- params["request_key"] == socket.assigns.trade_key,
         {:ok, amount} <- quantity(params["quantity"]) do
      submit_trade(socket, player.id, side, amount)
    else
      _ ->
        {:noreply,
         assign(socket, trade_error: "Enter a positive integer quantity and select a player.")}
    end
  end

  def handle_event("trade", _, socket) do
    {:noreply,
     assign(socket, trade_error: "Choose Buy or Sell and enter a positive integer quantity.")}
  end

  def handle_event("new_trade", _, socket) do
    {:noreply,
     assign(socket,
       trade_key: Ecto.UUID.generate(),
       trade_intent: nil,
       trade_complete: false,
       trade_error: nil,
       trade_notice: nil
     )}
  end

  def handle_info({:conditional_order_changed, _id}, socket) do
    socket = reload_portfolio(socket)

    {:noreply,
     if(socket.assigns.destination == "/conditional-orders",
       do: reload_orders(socket),
       else: socket
     )}
  end

  def handle_info(:portfolio_changed, socket), do: {:noreply, reload_portfolio(socket)}

  defp workspace_heading("/conditional-orders"), do: "Conditional orders"
  defp workspace_heading("/players"), do: "Players"
  defp workspace_heading("/ranking"), do: "Ranking"
  defp workspace_heading(_), do: "Portfolio"

  defp submit_trade(socket, player_id, side, amount) do
    intent = {player_id, side, amount}

    if socket.assigns.trade_intent in [nil, intent] do
      socket = assign(socket, trade_intent: intent)
      input = %{player_id: player_id, quantity: amount, request_key: socket.assigns.trade_key}
      trade_result(socket, execute_trade(side, domain_actor(socket.assigns.actor), input))
    else
      {:noreply,
       assign(socket, trade_error: "This request has different terms. Start a new trade.")}
    end
  end

  defp trade_result(socket, {:ok, _}) do
    Phoenix.PubSub.broadcast_from(
      FootballMarket.PubSub,
      self(),
      "conditional_orders:" <> socket.assigns.actor.account_id,
      :portfolio_changed
    )

    {:noreply,
     socket
     |> assign(trade_error: nil, trade_notice: "Trade confirmed.", trade_complete: true)
     |> reload_portfolio()}
  end

  defp trade_result(socket, {:error, error}),
    do: {:noreply, assign(socket, trade_error: trade_error(error), trade_notice: nil)}

  defp execute_trade("buy", actor, input), do: Market.purchase(actor, input)
  defp execute_trade("sell", actor, input), do: Market.sale(actor, input)

  defp trade_error(%{kind: kind}), do: trade_error(kind)
  defp trade_error(:invalid_request), do: "Enter a positive integer quantity."
  defp trade_error(:insufficient_funds), do: "Insufficient credits."
  defp trade_error(:insufficient_inventory), do: "Insufficient available tokens."
  defp trade_error(:insufficient_holdings), do: "You do not own enough tokens."
  defp trade_error(:request_conflict), do: "This request was already used. Start a new trade."

  defp trade_error(_),
    do: "Trade unavailable. Check your balance, holdings and quantity, then retry."

  defp load_card(socket, nil), do: assign(socket, card: nil, card_error: nil)

  defp load_card(socket, id) do
    case Catalog.player_card(id) do
      {:ok, card} ->
        quote =
          case Quotes.latest(id) do
            {:ok, quote} -> quote
            _ -> nil
          end

        socket |> assign(card: card, quote: quote, card_error: nil) |> reload_portfolio()

      _ ->
        assign(socket, card: nil, card_error: "Player details are unavailable.")
    end
  end

  defp load_ranking(socket) do
    case Ranking.read() do
      {:ok, ranking} ->
        assign(socket, ranking: ranking, ranking_error: nil)

      {:error, :no_active_configuration} ->
        assign(socket, ranking: nil, ranking_error: "No active strategy configured.")

      _ ->
        assign(socket, ranking: nil, ranking_error: "Ranking is temporarily unavailable.")
    end
  end

  def render(assigns) do
    ~H"""
    <.shell actor={@actor} destination={@destination}>
      <%= if @destination == "/conditional-orders" do %>
        <section id="conditional-orders">
          <p class="eyebrow">WORKSPACE / ORDERS</p>
          <h1>Conditional orders</h1>
          <p>
            Orders do not reserve credits or tokens. A qualifying price does not guarantee a purchase.
          </p>

          <div class="orders-layout">
            <div class="order-compose">
              <h2>New order</h2>
              <p class="muted">Choose your player, price limit and expiry.</p>
              <form id="conditional-order-form" phx-submit="create_order">
                <p>Choose a player from the catalog first.</p>
                <a class="text-link" href="/players">Search players →</a>
                <input
                  id="order-player-id"
                  name="player_id"
                  type="hidden"
                  value={@order_form["player_id"]}
                />
                <p :if={@selected_player} id="selected-player" role="status">
                  Selected: {@selected_player.display_name} · {@selected_player.team.name} ({@selected_player.id})
                </p>
                <label for="order-quantity">Quantity</label>
                <input
                  id="order-quantity"
                  name="quantity"
                  type="number"
                  min="1"
                  max="100"
                  step="1"
                  required
                  value={@order_form["quantity"]}
                />

                <label for="order-maximum-unit-price">Maximum unit price</label>
                <input
                  id="order-maximum-unit-price"
                  name="maximum_unit_price"
                  type="number"
                  min="0.01"
                  step="0.01"
                  required
                  value={@order_form["maximum_unit_price"]}
                />

                <label for="order-expires-at">Expiry in UTC</label>
                <input
                  id="order-expires-at"
                  name="expires_at"
                  type="text"
                  placeholder="2026-10-30T12:00:00Z"
                  required
                  value={@order_form["expires_at"]}
                />
                <p>Enter a future ISO-8601 UTC time ending in Z. No default expiry is applied.</p>
                <button type="submit">Create order</button>
              </form>

              <p :if={@order_error} id="order-error" role="alert">{@order_error}</p>
              <p :if={@order_notice} id="order-notice" role="status">{@order_notice}</p>
              <p :if={@orders_unavailable} id="orders-unavailable" role="alert">
                Orders are temporarily unavailable. Try again shortly.
              </p>
            </div>
            <div class="orders-history">
              <h2>Your orders</h2>
              <p :if={@orders == [] && !@orders_unavailable} id="no-orders">
                You have no conditional orders.
              </p>
              <ul id="order-list">
                <li :for={order <- @orders} id={"conditional-order-#{order.id}"}>
                  <article>
                    <h3>Player {order.player_id}</h3>
                    <dl>
                      <dt>Quantity</dt><dd>{order.quantity}</dd>
                      <dt>Maximum unit price</dt><dd>{money(order.maximum_unit_price)}</dd>
                      <dt>Created</dt><dd>{timestamp(order.created_at)}</dd>
                      <dt>Expires</dt><dd>{timestamp(order.expires_at)}</dd>
                      <dt>Status</dt><dd>{order.status}</dd>
                    </dl>
                    <p :if={order.expiry_reached} class="expiry-reached">
                      Expiry time reached; status updates when evaluation is recorded.
                    </p>
                    <p :if={order.status == "executed" && order.execution}>
                      Executed at {money(order.execution.unit_price)} per token, total {money(
                        order.execution.total
                      )}.
                    </p>
                    <p :if={order.status == "rejected"}>
                      Rejected: {readable_reason(order.rejection_reason)}.
                    </p>
                    <button
                      :if={order.status == "pending" && !order.expiry_reached}
                      type="button"
                      phx-click="cancel_order"
                      phx-value-id={order.id}
                    >Cancel order</button>
                  </article>
                </li>
              </ul>
            </div>
          </div>
        </section>
      <% else %>
        <%= if @destination == "/players" do %>
          <section id="player-catalog">
            <.player_card
              card={@card}
              quote={@quote}
              error={@card_error}
              request_key={@trade_key}
              trade_error={@trade_error}
              notice={@trade_notice}
              complete={@trade_complete}
            />
            <div :if={@card} id="trade-positions">
              <p :if={@portfolio_unavailable} role="alert">
                Positions are temporarily unavailable.
              </p>
              <p :for={position <- @positions} id={"trade-position-#{position.player_id}"}>
                {position.player_name}: {position.quantity} tokens
              </p>
            </div>
            <div class="catalog-heading">
              <div>
                <h1>Players</h1>
                <p class="catalog-intro">
                  Search the catalog, compare club and league, then choose a player for your order.
                </p>
              </div>
            </div>
            <div class="catalog-search-card">
              <form id="player-catalog-search" phx-submit="search_players">
                <label for="player-search">Player name</label>
                <div class="player-search-controls">
                  <input
                    id="player-search"
                    name="player_search"
                    type="search"
                    placeholder="Try Bukayo Saka or Erling Haaland"
                    autocomplete="off"
                    value={@player_search}
                  />
                  <button type="submit">Search players</button>
                </div>
              </form>
              <p :if={!@search_performed} class="catalog-hint">
                Enter at least 2 characters, then search the catalog.
              </p>
            </div>
            <p :if={@player_search_unavailable} role="alert">
              Player search is temporarily unavailable. Try again shortly.
            </p>
            <div :if={@search_performed && @player_results != []} class="catalog-results-heading">
              <h2>Results for “{@player_search}”</h2>
              <span>{@player_results |> length()} players</span>
            </div>
            <p
              :if={@search_performed && @player_results == [] && !@player_search_unavailable}
              class="catalog-hint"
            >
              No players found. Try another name.
            </p>
            <div
              :if={@player_results != []}
              class="player-table-wrap"
              id="player-search-results"
              role="region"
              aria-label="Player search results"
              tabindex="0"
            >
              <table class="player-table">
                <thead>
                  <tr>
                    <th scope="col">Player</th><th scope="col">Club</th><th scope="col">League</th><th scope="col">
                      <span class="sr-only">Action</span>
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={player <- @player_results}>
                    <th scope="row">
                      <strong>{player.display_name}</strong><span>{player.position.code}</span>
                    </th>
                    <td>{player.team.name}</td>
                    <td>{player.team.season.league.name}</td>
                    <td>
                      <a href={~p"/players?player_id=#{player.id}"}>View player</a>
                      <a href={~p"/conditional-orders?player_id=#{player.id}"}>Create order</a>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>
        <% else %>
          <.ranking_view :if={@destination == "/ranking"} ranking={@ranking} error={@ranking_error} />
          <section :if={@destination != "/ranking"} id="portfolio">
            <p class="eyebrow">WORKSPACE / HOLDINGS</p>
            <h1>Portfolio</h1>
            <p class="section-description">Your players, positions and performance.</p>
            <p :if={@portfolio_unavailable} id="portfolio-unavailable" role="alert">
              Portfolio data is temporarily unavailable. Try again shortly.
            </p>
            <div :if={@positions == [] && !@portfolio_unavailable} class="empty-state">
              <span class="empty-symbol" aria-hidden="true">◎</span>
              <h2>Your portfolio starts here</h2>
              <p id="no-positions">
                You do not currently own any player tokens.
              </p>
              <a class="text-link" href="/conditional-orders">Set up a conditional order →</a>
            </div>
            <div
              :if={@positions != []}
              class="table-scroll"
              role="region"
              aria-label="Portfolio positions"
              tabindex="0"
            >
              <table id="portfolio-positions">
                <caption>Player positions · Values in credits</caption>
                <thead>
                  <tr>
                    <th scope="col">Player</th>
                    <th scope="col">Quantity</th>
                    <th scope="col">Average unit cost</th>
                    <th scope="col">Current quote</th>
                    <th scope="col">Current value</th>
                    <th scope="col">Realized profit/loss</th>
                    <th scope="col">Unrealized profit/loss</th>
                  </tr>
                </thead>
                <tbody>
                  <tr :for={position <- @positions} id={"portfolio-position-#{position.player_id}"}>
                    <th scope="row">
                      <a href={~p"/players?player_id=#{position.player_id}"}>{position.player_name}</a>
                    </th>
                    <td>{position.quantity}</td>
                    <td>{exact_money(position.average_unit_cost)}</td>
                    <td>{exact_money(position.current_quote)}</td>
                    <td>{exact_money(position.current_value)}</td>
                    <td>{exact_money(position.realized_profit_loss)}</td>
                    <td>{exact_money(position.unrealized_profit_loss)}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>
        <% end %>
      <% end %>
    </.shell>
    """
  end

  defp reload_orders(socket) do
    case ConditionalOrders.list(domain_actor(socket.assigns.actor)) do
      {:ok, orders} -> assign(socket, orders: orders, orders_unavailable: false)
      {:error, _} -> assign(socket, orders: [], orders_unavailable: true)
    end
  end

  defp reload_portfolio(socket) do
    case Portfolio.list(domain_actor(socket.assigns.actor)) do
      {:ok, positions} -> assign(socket, positions: positions, portfolio_unavailable: false)
      {:error, _} -> assign(socket, positions: [], portfolio_unavailable: true)
    end
  end

  defp load_selected_player(socket, nil), do: socket

  defp load_selected_player(socket, id) do
    case Catalog.get_player_detail(id) do
      {:ok, player} ->
        assign(socket,
          selected_player: player,
          player_search: player.display_name,
          order_form: Map.put(socket.assigns.order_form, "player_id", player.id)
        )

      _ ->
        socket
    end
  end

  defp domain_actor(actor) do
    %AuthenticatedActor{
      account_id: actor.account_id,
      authentication_method: :browser,
      credential_id: actor.session_id
    }
  end

  defp quantity(value) when is_binary(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value),
      do: {:ok, String.to_integer(value)},
      else: {:error, :invalid_request}
  end

  defp quantity(_), do: {:error, :invalid_request}

  defp order_terms(params, quantity) do
    {:ok,
     %{
       player_id: params["player_id"],
       quantity: quantity,
       maximum_unit_price: params["maximum_unit_price"],
       expires_at: params["expires_at"]
     }}
  end

  defp empty_form,
    do: %{"player_id" => "", "quantity" => "", "maximum_unit_price" => "", "expires_at" => ""}

  defp form_values(params), do: Map.new(empty_form(), fn {key, _} -> {key, params[key] || ""} end)

  defp error_message(:invalid_request),
    do: "Check the player ID, quantity, price, and future UTC expiry."

  defp error_message(:player_not_found), do: "That player could not be found."
  defp error_message(:not_initialized), do: "That player is not available for conditional orders."
  defp error_message(:self_purchase), do: "You cannot create an order for your own issued tokens."

  defp error_message(:temporarily_unavailable),
    do: "Orders are temporarily unavailable. Try again shortly."

  defp error_message(%{kind: kind}), do: error_message(kind)
  defp error_message(_), do: "The order could not be completed. Check the terms and try again."

  defp money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
  defp exact_money(value), do: value |> Decimal.normalize() |> Decimal.to_string(:normal)
  defp timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")
  defp readable_reason(nil), do: "not available"
  defp readable_reason(reason), do: reason |> String.replace("_", " ")
end

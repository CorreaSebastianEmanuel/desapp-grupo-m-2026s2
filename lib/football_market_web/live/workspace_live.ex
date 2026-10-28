defmodule FootballMarketWeb.WorkspaceLive do
  use FootballMarketWeb, :live_view
  import FootballMarketWeb.WorkspaceComponents

  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.ConditionalOrders

  def mount(_, _, socket) do
    if connected?(socket) and socket.assigns.actor do
      Phoenix.PubSub.subscribe(
        FootballMarket.PubSub,
        "conditional_orders:" <> socket.assigns.actor.account_id
      )
    end

    {:ok,
     assign(socket,
       destination: nil,
       heading: nil,
       orders: [],
       order_form: empty_form(),
       order_error: nil,
       order_notice: nil,
       orders_unavailable: false
     )}
  end

  def handle_params(_, uri, socket) do
    destination = URI.parse(uri).path
    heading = if destination == "/conditional-orders", do: "Conditional orders", else: "Portfolio"
    socket = assign(socket, destination: destination, heading: heading)
    {:noreply, if(destination == "/conditional-orders", do: reload_orders(socket), else: socket)}
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

  def handle_info({:conditional_order_changed, _id}, socket) do
    if socket.assigns.destination == "/conditional-orders",
      do: {:noreply, reload_orders(socket)},
      else: {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.shell actor={@actor} destination={@destination}>
      <%= if @destination == "/conditional-orders" do %>
        <section id="conditional-orders">
          <h1>Conditional orders</h1>
          <p>
            Orders do not reserve credits or tokens. A qualifying price does not guarantee a purchase.
          </p>

          <form id="conditional-order-form" phx-submit="create_order">
            <label for="order-player-id">Player ID</label>
            <input
              id="order-player-id"
              name="player_id"
              type="text"
              required
              autocomplete="off"
              value={@order_form["player_id"]}
            />

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
        </section>
      <% else %>
        <.unavailable heading={@heading} />
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
  defp timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")
  defp readable_reason(nil), do: "not available"
  defp readable_reason(reason), do: reason |> String.replace("_", " ")
end

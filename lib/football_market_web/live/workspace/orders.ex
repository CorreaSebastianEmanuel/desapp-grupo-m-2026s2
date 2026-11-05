defmodule FootballMarketWeb.Workspace.Orders do
  @moduledoc false
  import Phoenix.Component, only: [assign: 2]
  import FootballMarketWeb.Workspace.Session
  alias FootballMarket.{Catalog, Quotes}
  alias FootballMarket.Market.ConditionalOrders

  def handle_event("create_order", params, socket) do
    with {:ok, quantity} <- quantity(params["quantity"]),
         {:ok, terms} <- order_terms(params, quantity),
         {:ok, _order} <- ConditionalOrders.create(domain_actor(socket.assigns.actor), terms) do
      {:noreply,
       socket
       |> assign(order_form: empty_form(), order_error: nil, order_notice: "Orden creada.")
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
         |> assign(order_error: nil, order_notice: "Estado de la orden actualizado.")
         |> reload_orders()}

      {:error, error} ->
        {:noreply, assign(socket, order_error: error_message(error), order_notice: nil)}
    end
  end

  def reload_orders(socket) do
    case ConditionalOrders.list(domain_actor(socket.assigns.actor)) do
      {:ok, orders} ->
        orders =
          Enum.map(orders, &Map.put(&1, :player_name, player_name(&1.player_id)))

        assign(socket, orders: orders, orders_unavailable: false)

      {:error, _} ->
        assign(socket, orders: [], orders_unavailable: true)
    end
  end

  def load_selected_player(socket, nil), do: socket

  def load_selected_player(socket, id) do
    case Catalog.get_player_detail(id) do
      {:ok, player} ->
        quote =
          case Quotes.latest(id) do
            {:ok, quote} -> quote
            _ -> nil
          end

        assign(socket,
          selected_player: player,
          selected_quote: quote,
          player_search: player.display_name,
          order_form: Map.put(socket.assigns.order_form, "player_id", player.id)
        )

      _ ->
        socket
    end
  end

  defp order_terms(params, quantity) do
    {:ok,
     %{
       player_id: params["player_id"],
       quantity: quantity,
       maximum_unit_price: params["maximum_unit_price"],
       expires_at: utc_expiry(params["expires_at"])
     }}
  end

  defp utc_expiry(value) when is_binary(value) do
    normalized = value <> if(byte_size(value) == 16, do: ":00", else: "")

    if Regex.match?(~r/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2}(\.\d{1,6})?)?\z/, value) do
      case NaiveDateTime.from_iso8601(normalized) do
        {:ok, naive} -> DateTime.from_naive!(naive, "Etc/UTC")
        _ -> value
      end
    else
      value
    end
  end

  defp utc_expiry(value), do: value

  def empty_form,
    do: %{"player_id" => "", "quantity" => "", "maximum_unit_price" => "", "expires_at" => ""}

  defp form_values(params), do: Map.new(empty_form(), fn {key, _} -> {key, params[key] || ""} end)

  defp error_message(:invalid_request),
    do: "Revisá el jugador, la cantidad, el precio y que el vencimiento UTC sea futuro."

  defp error_message(:player_not_found), do: "No encontramos ese jugador."

  defp error_message(:not_initialized),
    do: "Ese jugador no está habilitado para órdenes condicionales."

  defp error_message(:self_purchase),
    do: "No podés crear una orden para comprar tus propios tokens emitidos."

  defp error_message(:temporarily_unavailable),
    do: "Las órdenes no están disponibles temporalmente. Probá de nuevo en unos instantes."

  defp error_message(%{kind: kind}), do: error_message(kind)

  defp error_message(_),
    do: "No se pudo completar la orden. Revisá las condiciones e intentá de nuevo."
end

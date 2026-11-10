defmodule FootballMarketWeb.Workspace.Trading do
  @moduledoc false
  import Phoenix.Component, only: [assign: 2]
  import FootballMarketWeb.Workspace.Session
  alias FootballMarket.Market
  alias FootballMarketWeb.Workspace.Portfolio

  def handle_event("trade", %{"side" => side} = params, socket) when side in ["buy", "sell"] do
    with %{player: player} <- socket.assigns.card,
         true <- params["request_key"] == socket.assigns.trade_key,
         {:ok, amount} <- quantity(params["quantity"]) do
      submit_trade(socket, player.id, side, amount)
    else
      _ ->
        {:noreply,
         assign(socket,
           trade_error: "Ingresá una cantidad entera mayor que cero y elegí un jugador.",
           trade_quantity: Map.get(params, "quantity", "")
         )}
    end
  end

  def handle_event("trade_preview", %{"quantity" => quantity}, socket) do
    {:noreply, assign(socket, trade_quantity: quantity)}
  end

  def handle_event("trade", params, socket) do
    {:noreply,
     assign(socket,
       trade_error: "Elegí comprar o vender e ingresá una cantidad entera mayor que cero.",
       trade_quantity: Map.get(params, "quantity", "")
     )}
  end

  def handle_event(
        "new_trade",
        _,
        %{assigns: %{trade_intent: intent, trade_complete: false}} = socket
      )
      when not is_nil(intent), do: {:noreply, socket}

  def handle_event("new_trade", _, socket) do
    {:noreply,
     assign(socket,
       trade_key: Ecto.UUID.generate(),
       trade_intent: nil,
       trade_complete: false,
       trade_quantity: "",
       trade_error: nil,
       trade_notice: nil
     )}
  end

  defp submit_trade(socket, player_id, side, amount) do
    intent = {player_id, side, amount}

    if socket.assigns.trade_intent in [nil, intent] do
      socket = assign(socket, trade_intent: intent, trade_quantity: Integer.to_string(amount))
      input = %{player_id: player_id, quantity: amount, request_key: socket.assigns.trade_key}
      trade_result(socket, execute_trade(side, domain_actor(socket.assigns.actor), input))
    else
      {:noreply,
       assign(
         socket,
         trade_error:
           "Esta solicitud ya se usó con otros datos. Iniciá una nueva operación antes de cambiar la acción o la cantidad."
       )}
    end
  end

  defp trade_result(socket, {:ok, record}) do
    Phoenix.PubSub.broadcast_from(
      FootballMarket.PubSub,
      self(),
      "conditional_orders:" <> socket.assigns.actor.account_id,
      :portfolio_changed
    )

    {:noreply,
     socket
     |> assign(
       trade_error: nil,
       trade_notice: "Operación confirmada.",
       trade_complete: true,
       trade_record: Map.put(record, :type, elem(socket.assigns.trade_intent, 1))
     )
     |> reload_credit_balance()
     |> Portfolio.reload_portfolio()
     |> Portfolio.reload_issuer_inventory()
     |> Portfolio.reload_charts()}
  end

  defp trade_result(socket, {:error, error}) do
    socket =
      if definitive_rejection?(error) do
        assign(socket, trade_intent: nil, trade_key: Ecto.UUID.generate())
      else
        socket
      end

    {:noreply, assign(socket, trade_error: trade_error(error), trade_notice: nil)}
  end

  defp definitive_rejection?(%{kind: kind, reason: reason}) do
    kind in [:insufficient_funds, :insufficient_inventory, :insufficient_holdings] or
      (kind == :invalid_request and reason == :invalid_request)
  end

  defp definitive_rejection?(_), do: false

  defp execute_trade("buy", actor, input), do: Market.purchase(actor, input)
  defp execute_trade("sell", actor, input), do: Market.sale(actor, input)

  defp trade_error(%{reason: :transaction_in_progress}),
    do: "La operación aún no se pudo confirmar. Reintentá con la misma acción y cantidad."

  defp trade_error(%{kind: :temporarily_unavailable}),
    do: "No se pudo confirmar el resultado. Reintentá con la misma acción y cantidad."

  defp trade_error(%{kind: kind}), do: trade_error(kind)
  defp trade_error(:invalid_request), do: "Ingresá una cantidad entera mayor que cero."
  defp trade_error(:insufficient_funds), do: "No tenés créditos suficientes."
  defp trade_error(:insufficient_inventory), do: "No hay suficientes tokens disponibles."
  defp trade_error(:insufficient_holdings), do: "No tenés tantos tokens para vender."

  defp trade_error(:quote_unavailable),
    do: "Todavía no hay una cotización de rendimiento válida para comprar este jugador."

  defp trade_error(:self_purchase),
    do:
      "Esta cuenta aporta el inventario inicial. Para comprar, ingresá con una cuenta inversora."

  defp trade_error(:self_sale),
    do:
      "Esta cuenta recibió el inventario inicial y no puede venderse tokens a sí misma. Usá una cuenta inversora."

  defp trade_error(:request_conflict),
    do:
      "Esta solicitud ya se usó con otros datos. Iniciá una nueva operación antes de cambiar la acción o la cantidad."

  defp trade_error(_),
    do:
      "No se pudo completar la operación. Revisá tus créditos para comprar, tus tokens para vender y que la cantidad sea un número entero. Se necesita una cotización actual."
end

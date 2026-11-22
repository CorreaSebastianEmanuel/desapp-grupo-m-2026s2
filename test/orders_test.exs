defmodule FootballMarket.OrdersTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Market
  alias FootballMarket.Market.OrderEvaluation

  test "creates, lists, executes, cancels, and rejects conditional buy orders" do
    market = create_tradable_market!("1000.00")
    investor = actor_for(market.investor)
    future = DateTime.add(DateTime.utc_now(), 3600, :second) |> DateTime.truncate(:microsecond)

    # Order with max price >= current quote executes when evaluated
    {:ok, order} =
      Market.create_conditional_order(investor, %{
        player_id: market.player.id,
        quantity: 2,
        maximum_unit_price: Decimal.add(market.quote.unit_price, Decimal.new("5.00")),
        expires_at: future
      })

    assert order.status == "pending"
    assert {:ok, [listed]} = Market.list_conditional_orders(investor)
    assert listed.id == order.id

    assert {:ok, executed} = Market.evaluate_conditional_order(order.id)
    assert executed.status == "executed"
    assert executed.execution.purchase_id != nil

    # Order with max price below current quote stays pending and can be cancelled
    {:ok, pending} =
      Market.create_conditional_order(investor, %{
        player_id: market.player.id,
        quantity: 1,
        maximum_unit_price: Decimal.new("1.00"),
        expires_at: future
      })

    assert {:ok, still_pending} = Market.evaluate_conditional_order(pending.id)
    assert still_pending.status == "pending"

    assert {:ok, cancelled} = Market.cancel_conditional_order(investor, pending.id)
    assert cancelled.status == "cancelled"

    # Order exceeding funds is rejected when price matches
    {:ok, unfunded} =
      Market.create_conditional_order(investor, %{
        player_id: market.player.id,
        quantity: 50,
        maximum_unit_price: Decimal.add(market.quote.unit_price, Decimal.new("5.00")),
        expires_at: future
      })

    assert :ok = OrderEvaluation.recover()
    assert {:ok, rejected} = Market.get_conditional_order(investor, unfunded.id)
    assert rejected.status == "rejected"
    assert rejected.rejection_reason == "insufficient_funds"
  end
end

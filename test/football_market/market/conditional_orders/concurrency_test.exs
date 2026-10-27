defmodule FootballMarket.Market.ConditionalOrders.ConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{ConditionalOrdersCase, PurchasesCase, Repo}
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  alias FootballMarket.ConditionalOrders.RuntimeProbe
  setup do: ConditionalOrdersCase.fixture()

  test "concurrent and ambiguous deliveries execute once despite preoccupied direct identities",
       f do
    o = ConditionalOrdersCase.order!(f)

    for {key, quantity} <- [{o.id, 3}, {"conditional:" <> o.id, 1}] do
      assert {:ok, p} = PurchasesCase.purchase(f, key, quantity)
      assert p.id != o.id
    end

    results =
      RuntimeProbe.queued(
        f,
        for(_ <- 1..4, do: fn -> Orders.evaluate(o.id) end),
        "market_conditional_buy_orders"
      )

    assert Enum.all?(results, &match?({:ok, %{status: "executed"}}, &1))
    [{:ok, first} | _] = results
    assert Enum.all?(results, &(&1 == {:ok, first}))
    before = ConditionalOrdersCase.snapshot()
    assert {:ok, ^first} = Orders.evaluate(o.id)
    assert before == ConditionalOrdersCase.snapshot()

    assert Repo.query!(
             "SELECT count(*) FROM market_purchases WHERE conditional_order_id IS NOT NULL"
           ).rows == [[1]]

    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[3]]
    assert {:ok, _} = PurchasesCase.purchase(f, o.id, 3)
    assert before == ConditionalOrdersCase.snapshot()
    ConditionalOrdersCase.invariant!()
  end
end

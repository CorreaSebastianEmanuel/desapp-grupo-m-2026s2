defmodule FootballMarket.Market.ConditionalOrders.ContentionTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{ConditionalOrdersCase, PurchasesCase, Repo, Market}
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  alias FootballMarket.ConditionalOrders.RuntimeProbe
  setup do: ConditionalOrdersCase.fixture()

  test "competing orders and direct trades cannot overspend or exceed inventory", f do
    PurchasesCase.fund(f.buyer, "5")
    orders = for _ <- 1..3, do: ConditionalOrdersCase.order!(f)

    calls =
      Enum.map(orders, fn o -> fn -> Orders.evaluate(o.id) end end) ++
        [fn -> PurchasesCase.purchase(f) end]

    results = RuntimeProbe.queued(f, calls)
    assert Enum.count(results, &match?({:ok, _}, &1)) >= 3
    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[1]]
    ConditionalOrdersCase.invariant!()
  end

  test "different player locks still serialize a shared buyer balance", f do
    {:ok, _} = Market.initialize_player(f.other.id)
    PurchasesCase.fund(f.buyer, "5")
    first = ConditionalOrdersCase.order!(f)
    second = ConditionalOrdersCase.order!(f, %{player_id: f.other.id})

    results =
      RuntimeProbe.queued(
        f,
        [fn -> Orders.evaluate(first.id) end, fn -> Orders.evaluate(second.id) end],
        "users"
      )

    assert Enum.sort(Enum.map(results, fn {:ok, o} -> o.status end)) == ["executed", "rejected"]
    ConditionalOrdersCase.invariant!()
  end
end

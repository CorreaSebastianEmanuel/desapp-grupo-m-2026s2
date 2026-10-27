defmodule FootballMarket.Market.Sales.ConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{PurchasesCase, Repo, SalesCase}
  alias FootballMarket.Purchases.RuntimeProbe

  setup do
    SalesCase.fixture()
  end

  test "concurrent identical deliveries return one immutable sale", fixture do
    assert [{:ok, first}, {:ok, second}] =
             RuntimeProbe.queued(fixture, [
               fn -> SalesCase.sell(fixture) end,
               fn -> SalesCase.sell(fixture) end
             ])

    assert first == second
    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
    assert Repo.query!("SELECT count(*) FROM market_sale_credit_entries").rows == [[2]]
  end

  test "competing sales cannot double-sell one holding", fixture do
    results =
      RuntimeProbe.queued(fixture, [
        fn -> SalesCase.sell(fixture, "first", 4) end,
        fn -> SalesCase.sell(fixture, "second", 4) end
      ])

    assert Enum.count(results, &match?({:ok, _}, &1)) == 1
    assert Enum.count(results, &match?({:error, %{kind: :insufficient_tokens}}, &1)) == 1

    assert Repo.query!("SELECT sum(quantity), min(quantity) FROM market_holdings").rows == [
             [100, 1]
           ]
  end

  test "concurrent purchase and sale serialize without breaking either invariant", fixture do
    results =
      RuntimeProbe.queued(fixture, [
        fn -> SalesCase.sell(fixture, "sell-five", 5) end,
        fn -> PurchasesCase.purchase(fixture, "buy-five", 5) end
      ])

    assert Enum.all?(results, &match?({:ok, _}, &1))

    assert Repo.query!("SELECT sum(quantity), min(quantity) FROM market_holdings").rows == [
             [100, 5]
           ]

    assert Repo.query!("SELECT sum(amount), min(amount) FROM market_credit_balances").rows == [
             [Decimal.new("10"), Decimal.new("5")]
           ]
  end
end

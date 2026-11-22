defmodule FootballMarket.PortfolioTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Market

  test "tracks holdings, credit balance, initial inventory, transaction history, allocation, and daily history" do
    market = create_tradable_market!("1000.00")
    investor = actor_for(market.investor)
    admin = actor_for(market.admin)

    assert {:ok, true} = Market.initial_recipient?(admin)
    assert {:ok, false} = Market.initial_recipient?(investor)
    assert {:ok, [%{quantity: 100}]} = Market.initial_inventory(admin)

    {:ok, _buy} =
      Market.purchase(investor, %{player_id: market.player.id, quantity: 4, request_key: "p1"})

    {:ok, _sell} =
      Market.sale(investor, %{player_id: market.player.id, quantity: 1, request_key: "s1"})

    assert {:ok, [pos]} = Market.portfolio(investor)
    assert pos.player_id == market.player.id
    assert pos.quantity == 3
    assert Decimal.equal?(pos.average_unit_cost, market.quote.unit_price)

    assert {:ok, balance} = Market.credit_balance(investor)

    expected_balance =
      Decimal.sub(Decimal.new("1000.00"), Decimal.mult(market.quote.unit_price, 3))

    assert Decimal.equal?(balance, expected_balance)

    assert {:ok, [%{quantity: 97}]} = Market.initial_inventory(admin)

    # Transaction history pagination
    assert {:ok, page1} = Market.transaction_history(investor, %{page_size: 1, cursor: nil})
    assert length(page1.data) == 1
    assert page1.pagination.has_more

    assert {:ok, page2} =
             Market.transaction_history(investor, %{
               page_size: 1,
               cursor: page1.pagination.next_cursor
             })

    assert length(page2.data) == 1
    refute page2.pagination.has_more

    # Portfolio allocation & daily valuation history
    assert {:ok, alloc} = Market.portfolio_allocation(investor)
    assert alloc.totals.valuation_complete
    assert length(alloc.positions) == 1
    assert Decimal.equal?(hd(alloc.positions).weight, Decimal.new("1"))

    today = Date.utc_today()

    assert {:ok, hist} =
             Market.portfolio_history(investor, %{from: Date.add(today, -2), to: today})

    assert hist.interval == "day"
    assert length(hist.points) == 3
  end
end

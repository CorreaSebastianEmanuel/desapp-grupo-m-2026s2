defmodule FootballMarket.TradingTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  alias FootballMarket.Market

  test "initializes a player with 100 tokens at 1.00 idempotently" do
    admin = create_admin!()
    fixture = create_catalog_fixture!()

    assert {:ok, %{outcome: :issued, issuance: issuance}} =
             Market.initialize_player(fixture.player.id)

    assert issuance.recipient_id == admin.id
    assert issuance.quantity == 100
    assert Decimal.equal?(issuance.initial_unit_price, Decimal.new(1))

    assert {:ok, %{outcome: :already_completed, issuance: same}} =
             Market.initialize_player(fixture.player.id)

    assert same.id == issuance.id
    assert {:ok, fetched} = Market.get_initial_issuance(fixture.player.id)
    assert fetched.id == issuance.id
  end

  test "executes atomic idempotent purchase and sale with double-entry ledger" do
    market = create_tradable_market!("1000.00")
    buyer = actor_for(market.investor)

    input = %{player_id: market.player.id, quantity: 3, request_key: "buy-1"}
    assert {:ok, purchase} = Market.purchase(buyer, input)
    assert purchase.quantity == 3
    assert Decimal.equal?(purchase.unit_price, market.quote.unit_price)
    assert Decimal.equal?(purchase.total, Decimal.mult(market.quote.unit_price, 3))
    assert purchase.transfer.quantity == 3
    assert length(purchase.ledger) == 2

    # Idempotent retry returns the exact same purchase
    assert {:ok, replayed} = Market.purchase(buyer, input)
    assert replayed.id == purchase.id

    # Reusing request_key with different quantity fails with :key_conflict
    assert {:error, %{kind: :key_conflict}} =
             Market.purchase(buyer, %{input | quantity: 4})

    # Sell 2 tokens back to initial recipient
    sale_input = %{player_id: market.player.id, quantity: 2, request_key: "sell-1"}
    assert {:ok, sale} = Market.sale(buyer, sale_input)
    assert sale.quantity == 2
    assert sale.transfer.from_user_id == market.investor.id
    assert sale.transfer.to_user_id == market.admin.id
    assert length(sale.ledger) == 2

    assert {:ok, fetched_buy} = Market.get_purchase(market.investor.id, purchase.id)
    assert fetched_buy.id == purchase.id
    assert {:ok, fetched_sell} = Market.get_sale(market.investor.id, sale.id)
    assert fetched_sell.id == sale.id
  end

  test "rejects insufficient funds, insufficient inventory, and self-trades" do
    market = create_tradable_market!("5.00")
    buyer = actor_for(market.investor)
    admin_actor = actor_for(market.admin)

    assert {:error, %{kind: :insufficient_funds}} =
             Market.purchase(buyer, %{player_id: market.player.id, quantity: 5, request_key: "k1"})

    assert {:error, %{kind: :self_purchase}} =
             Market.purchase(admin_actor, %{
               player_id: market.player.id,
               quantity: 1,
               request_key: "k2"
             })

    assert {:error, %{kind: :insufficient_inventory}} =
             Market.sale(buyer, %{player_id: market.player.id, quantity: 1, request_key: "k3"})
  end
end

defmodule FootballMarket.Market.ConditionalOrders.CreationTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{ConditionalOrdersCase, PurchasesCase, Repo}
  alias FootballMarket.Market.ConditionalOrders
  setup do: ConditionalOrdersCase.fixture()

  test "creates exact owned pending terms without reserving resources", f do
    before = PurchasesCase.snapshot()
    assert {:ok, order} = ConditionalOrdersCase.create(f)
    assert order.owner_id == f.buyer.id
    assert order.player_id == f.player.id
    assert order.status == "pending"
    assert order.quantity == 3
    assert Decimal.equal?(order.maximum_unit_price, "1.00")
    refute order.expiry_reached
    assert before == PurchasesCase.snapshot()
    assert {:ok, another} = ConditionalOrdersCase.create(f, %{expires_at: "2099-01-01T00:00:00Z"})
    refute another.id == order.id
    assert Repo.query!("SELECT count(*) FROM market_conditional_buy_orders").rows == [[2]]
  end

  test "invalid identity lifetime or initialized-player terms never persist", f do
    for {overrides, kind} <- [
          {%{player_id: Ecto.UUID.generate()}, :player_not_found},
          {%{player_id: f.other.id}, :not_initialized},
          {%{expires_at: DateTime.add(DateTime.utc_now(), -1)}, :invalid_request},
          {%{quantity: 101}, :invalid_request}
        ] do
      before = ConditionalOrdersCase.snapshot()
      assert {:error, %{kind: ^kind}} = ConditionalOrdersCase.create(f, overrides)
      assert before == ConditionalOrdersCase.snapshot()
    end

    assert {:error, %{kind: :self_purchase}} =
             ConditionalOrders.create(
               ConditionalOrdersCase.actor(f.owner),
               ConditionalOrdersCase.terms(f)
             )

    assert {:error, %{kind: :unauthenticated}} =
             ConditionalOrders.create(nil, ConditionalOrdersCase.terms(f))

    assert {:ok, {:error, %{kind: :invalid_request}}} =
             Repo.transaction(fn -> ConditionalOrdersCase.create(f) end)
  end
end

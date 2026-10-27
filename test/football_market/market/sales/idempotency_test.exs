defmodule FootballMarket.Market.Sales.IdempotencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{Market, PurchasesCase, Repo, SalesCase}
  alias FootballMarket.Market.Sales

  setup do
    SalesCase.fixture()
  end

  test "replay returns original result and conflicting details preserve it", fixture do
    assert {:ok, original} = SalesCase.sell(fixture)
    before = SalesCase.snapshot()
    assert {:ok, ^original} = SalesCase.sell(fixture)
    assert before == SalesCase.snapshot()
    assert {:error, %{kind: :key_conflict}} = SalesCase.sell(fixture, "sale-key", 2)

    assert {:error, %{kind: :key_conflict}} =
             Market.sell(PurchasesCase.actor(fixture.buyer), %{
               SalesCase.request(fixture)
               | player_id: fixture.other.id
             })

    PurchasesCase.fund(fixture.owner, "0")
    assert {:ok, ^original} = SalesCase.sell(fixture)
    assert {:ok, ^original} = Sales.get_for_seller(fixture.buyer.id, original.id)
    assert {:error, :not_found} = Sales.get_for_seller(fixture.owner.id, original.id)
    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
  end

  test "completed evidence survives a fresh BEAM", fixture do
    assert {:ok, original} = SalesCase.sell(fixture)

    FootballMarket.MarketCase.fresh(fixture.schema, """
    assert {:ok, sale} = FootballMarket.Market.Sales.get_for_seller(#{inspect(fixture.buyer.id)}, #{inspect(original.id)})
    assert sale.request_key == "sale-key"
    assert length(sale.ledger) == 2
    """)
  end
end

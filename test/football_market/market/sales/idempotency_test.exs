defmodule FootballMarket.Market.Sales.IdempotencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{SalesCase, Repo}
  alias FootballMarket.Market.Sales

  setup do
    f = SalesCase.fixture()
    f
  end

  test "arbitrary direct keys including order-shaped identities replay without new evidence", f do
    for key <- [
          "conditional:" <> Ecto.UUID.generate(),
          Ecto.UUID.generate(),
          "arbitrary / unicode ñ"
        ] do
      assert {:ok, sale} = SalesCase.sale(f, key, 1)
      before = SalesCase.snapshot()
      assert {:ok, ^sale} = SalesCase.sale(f, key, 1)
      assert before == SalesCase.snapshot()
      assert {:error, %{kind: :key_conflict}} = SalesCase.sale(f, key, 2)
      assert before == SalesCase.snapshot()
    end

    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[3]]
    assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[6]]
    assert Repo.query!("SELECT count(*) FROM market_token_transfers").rows == [[3]]
  end

  test "lost acknowledgement replay returns original after balance and inventory change", f do
    assert {:ok, original} = SalesCase.sale(f)
    before = SalesCase.snapshot()
    assert {:ok, ^original} = SalesCase.sale(f)
    assert before == SalesCase.snapshot()
    assert {:error, %{kind: :key_conflict}} = SalesCase.sale(f, "sale-key", 4)

    assert {:error, %{kind: :key_conflict}} =
             FootballMarket.Market.sale(SalesCase.actor(f.buyer), %{
               SalesCase.request(f)
               | player_id: f.other.id
             })

    SalesCase.fund(f.owner, "0")
    assert {:ok, ^original} = SalesCase.sale(f)
    assert {:ok, ^original} = Sales.get_for_seller(f.buyer.id, original.id)
    assert {:error, :not_found} = Sales.get_for_seller(f.owner.id, original.id)

    FootballMarket.MarketCase.fresh(f.schema, """
    assert {:ok, s} = FootballMarket.Market.Sales.get_for_seller(#{inspect(f.buyer.id)}, #{inspect(original.id)})
    assert s.request_key == "sale-key"
    assert length(s.ledger) == 2
    """)

    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
    SalesCase.fund(f.owner, "100")
    # Restock the seller to two owned tokens before the follow-up sale.
    Repo.transaction(fn ->
      Repo.query!(
        "UPDATE market_holdings SET quantity=CASE WHEN user_id=$1 THEN 3 ELSE 97 END WHERE player_id=$2",
        [Ecto.UUID.dump!(f.buyer.id), Ecto.UUID.dump!(f.player.id)]
      )
    end)

    assert {:ok, later} = SalesCase.sale(f, "later-sale", 2)
    refute original.id == later.id
    assert {:ok, ^original} = SalesCase.sale(f)

    FootballMarket.MarketCase.fresh(f.schema, """
    assert {:ok, s} = FootballMarket.Market.Sales.get_for_seller(#{inspect(f.buyer.id)}, #{inspect(original.id)})
    assert s.quantity == 3
    assert s.id != #{inspect(later.id)}
    """)
  end
end

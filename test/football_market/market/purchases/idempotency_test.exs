defmodule FootballMarket.Market.Purchases.IdempotencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{PurchasesCase, Repo}
  alias FootballMarket.Market.Purchases

  setup do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "10")
    f
  end

  test "arbitrary direct keys including order-shaped identities replay without new evidence", f do
    for key <- [
          "conditional:" <> Ecto.UUID.generate(),
          Ecto.UUID.generate(),
          "arbitrary / unicode ñ"
        ] do
      assert {:ok, purchase} = PurchasesCase.purchase(f, key, 1)
      before = PurchasesCase.snapshot()
      assert {:ok, ^purchase} = PurchasesCase.purchase(f, key, 1)
      assert before == PurchasesCase.snapshot()
      assert {:error, %{kind: :key_conflict}} = PurchasesCase.purchase(f, key, 2)
      assert before == PurchasesCase.snapshot()
    end

    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[3]]
    assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[6]]
    assert Repo.query!("SELECT count(*) FROM market_token_transfers").rows == [[3]]
  end

  test "lost acknowledgement replay returns original after balance and inventory change", f do
    assert {:ok, original} = PurchasesCase.purchase(f)
    before = PurchasesCase.snapshot()
    assert {:ok, ^original} = PurchasesCase.purchase(f)
    assert before == PurchasesCase.snapshot()
    assert {:error, %{kind: :key_conflict}} = PurchasesCase.purchase(f, "purchase-key", 4)

    assert {:error, %{kind: :key_conflict}} =
             FootballMarket.Market.purchase(PurchasesCase.actor(f.buyer), %{
               PurchasesCase.request(f)
               | player_id: f.other.id
             })

    PurchasesCase.fund(f.buyer, "0")
    assert {:ok, ^original} = PurchasesCase.purchase(f)
    assert {:ok, ^original} = Purchases.get_for_buyer(f.buyer.id, original.id)
    assert {:error, :not_found} = Purchases.get_for_buyer(f.owner.id, original.id)

    FootballMarket.MarketCase.fresh(f.schema, """
    assert {:ok, p} = FootballMarket.Market.Purchases.get_for_buyer(#{inspect(f.buyer.id)}, #{inspect(original.id)})
    assert p.request_key == "purchase-key"
    assert length(p.ledger) == 2
    """)

    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[1]]
    PurchasesCase.fund(f.buyer, "100")
    assert {:ok, later} = PurchasesCase.purchase(f, "later-purchase", 2)
    refute original.id == later.id
    assert {:ok, ^original} = PurchasesCase.purchase(f)

    FootballMarket.MarketCase.fresh(f.schema, """
    assert {:ok, p} = FootballMarket.Market.Purchases.get_for_buyer(#{inspect(f.buyer.id)}, #{inspect(original.id)})
    assert p.quantity == 3
    assert p.id != #{inspect(later.id)}
    """)
  end
end

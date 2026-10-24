defmodule FootballMarket.Market.Purchases.RejectionTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{PurchasesCase, Market, Repo}

  setup do
    PurchasesCase.fixture()
  end

  test "all business refusals preserve exact state and failed key can recover", f do
    assert_rejected(f, :insufficient_funds)
    PurchasesCase.fund(f.buyer, "1000")
    assert_rejected(f, :insufficient_inventory, 101)
    before = PurchasesCase.snapshot()

    assert {:error, %{kind: :self_purchase}} =
             Market.purchase(PurchasesCase.actor(f.owner), PurchasesCase.request(f))

    assert {:error, %{kind: :not_initialized}} =
             Market.purchase(PurchasesCase.actor(f.buyer), %{
               PurchasesCase.request(f)
               | player_id: f.other.id
             })

    assert {:error, %{kind: :player_not_found}} =
             Market.purchase(PurchasesCase.actor(f.buyer), %{
               PurchasesCase.request(f)
               | player_id: Ecto.UUID.generate()
             })

    assert before == PurchasesCase.snapshot()
    assert {:ok, _} = PurchasesCase.purchase(f)
    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[1]]
  end

  test "insufficient inventory retry after restored recipient inventory", f do
    PurchasesCase.fund(f.buyer, "1000")
    assert {:ok, _} = FootballMarket.MarketCase.transfer(f, 99)
    assert_rejected(f, :insufficient_inventory)

    Repo.transaction(fn ->
      Repo.query!(
        "UPDATE market_holdings SET quantity=CASE WHEN user_id=$1 THEN 100 ELSE 0 END WHERE player_id=$2",
        [Ecto.UUID.dump!(f.owner.id), Ecto.UUID.dump!(f.player.id)]
      )
    end)

    assert {:ok, _} = PurchasesCase.purchase(f)
  end

  test "absent or invalid current quote never falls back or changes financial state", f do
    PurchasesCase.fund(f.buyer, "100")
    Repo.query!("ALTER TABLE market_quotes DISABLE TRIGGER ALL")
    Repo.query!("ALTER TABLE market_quotes DROP CONSTRAINT market_quote_canonical")
    Repo.query!("UPDATE market_quotes SET unit_price=0")
    assert_rejected(f, :quote_unavailable)
    Repo.query!("DELETE FROM market_quotes")
    assert_rejected(f, :quote_unavailable)
  end

  test "inconsistent supply is refused rather than repaired", f do
    PurchasesCase.fund(f.buyer, "100")
    Repo.query!("ALTER TABLE market_holdings DISABLE TRIGGER ALL")
    Repo.query!("UPDATE market_holdings SET quantity=99")
    assert_rejected(f, :inconsistent_state)
  end

  defp assert_rejected(f, kind, quantity \\ 3) do
    before = PurchasesCase.snapshot()
    assert {:error, %{kind: ^kind}} = PurchasesCase.purchase(f, "purchase-key", quantity)
    assert before == PurchasesCase.snapshot()
  end
end

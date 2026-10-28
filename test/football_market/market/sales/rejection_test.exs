defmodule FootballMarket.Market.Sales.RejectionTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{Market, SalesCase, Repo}

  setup do
    SalesCase.fixture()
  end

  test "all business refusals preserve exact state and failed key can recover", f do
    SalesCase.fund(f.owner, "0")
    assert_rejected(f, :insufficient_funds)
    SalesCase.fund(f.owner, "1000")
    assert_rejected(f, :insufficient_inventory, 5)
    before = SalesCase.snapshot()

    assert {:error, %{kind: :self_sale}} =
             Market.sale(SalesCase.actor(f.owner), SalesCase.request(f))

    assert {:error, %{kind: :not_initialized}} =
             Market.sale(SalesCase.actor(f.buyer), %{
               SalesCase.request(f)
               | player_id: f.other.id
             })

    assert {:error, %{kind: :player_not_found}} =
             Market.sale(SalesCase.actor(f.buyer), %{
               SalesCase.request(f)
               | player_id: Ecto.UUID.generate()
             })

    assert before == SalesCase.snapshot()
    assert {:ok, _} = SalesCase.sale(f, "sale-key", 3)
    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
  end

  test "insufficient inventory retry after restored seller inventory", f do
    SalesCase.fund(f.owner, "1000")
    # Seller hands the tokens to the other holder, so the sale cannot cover quantity.
    Repo.transaction(fn ->
      Repo.query!("SELECT id FROM players WHERE id=$1 FOR UPDATE", [
        Ecto.UUID.dump!(f.player.id)
      ])

      Repo.query!(
        "UPDATE market_holdings SET quantity=CASE WHEN user_id=$1 THEN 0 ELSE 100 END WHERE player_id=$2",
        [Ecto.UUID.dump!(f.buyer.id), Ecto.UUID.dump!(f.player.id)]
      )
    end)

    assert_rejected(f, :insufficient_inventory)

    Repo.transaction(fn ->
      Repo.query!(
        "UPDATE market_holdings SET quantity=CASE WHEN user_id=$1 THEN 4 ELSE 96 END WHERE player_id=$2",
        [Ecto.UUID.dump!(f.buyer.id), Ecto.UUID.dump!(f.player.id)]
      )
    end)

    assert {:ok, _} = SalesCase.sale(f, "sale-key", 3)
  end

  test "absent or invalid current quote never falls back or changes financial state", f do
    SalesCase.fund(f.owner, "100")
    Repo.query!("ALTER TABLE market_quotes DISABLE TRIGGER ALL")
    Repo.query!("ALTER TABLE market_quotes DROP CONSTRAINT market_quote_canonical")
    Repo.query!("UPDATE market_quotes SET unit_price=0")
    assert_rejected(f, :quote_unavailable)
    Repo.query!("DELETE FROM market_quotes")
    assert_rejected(f, :quote_unavailable)
  end

  test "inconsistent supply is refused rather than repaired", f do
    SalesCase.fund(f.owner, "100")
    Repo.query!("ALTER TABLE market_holdings DISABLE TRIGGER ALL")
    Repo.query!("UPDATE market_holdings SET quantity=79")

    assert_rejected(f, :inconsistent_state)
  end

  defp assert_rejected(f, kind, quantity \\ 3) do
    before = SalesCase.snapshot()
    assert {:error, %{kind: ^kind}} = SalesCase.sale(f, "sale-key", quantity)
    assert before == SalesCase.snapshot()
  end
end

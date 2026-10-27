defmodule FootballMarket.Market.Sales.RejectionTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{Market, PurchasesCase, Repo, SalesCase}

  setup do
    SalesCase.fixture()
  end

  test "business refusals preserve exact state and failed key can recover", fixture do
    assert_rejected(fixture, :insufficient_tokens, 6)
    PurchasesCase.fund(fixture.owner, "0")
    assert_rejected(fixture, :insufficient_market_funds)
    PurchasesCase.fund(fixture.owner, "5")
    before = SalesCase.snapshot()

    assert {:error, %{kind: :self_sale}} =
             Market.sell(PurchasesCase.actor(fixture.owner), SalesCase.request(fixture))

    assert {:error, %{kind: :not_initialized}} =
             Market.sell(PurchasesCase.actor(fixture.buyer), %{
               SalesCase.request(fixture)
               | player_id: fixture.other.id
             })

    assert {:error, %{kind: :player_not_found}} =
             Market.sell(PurchasesCase.actor(fixture.buyer), %{
               SalesCase.request(fixture)
               | player_id: Ecto.UUID.generate()
             })

    assert before == SalesCase.snapshot()
    assert {:ok, _sale} = SalesCase.sell(fixture)
    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
  end

  test "invalid or absent current quote never falls back", fixture do
    Repo.query!("ALTER TABLE market_quotes DISABLE TRIGGER ALL")
    Repo.query!("ALTER TABLE market_quotes DROP CONSTRAINT market_quote_canonical")
    Repo.query!("UPDATE market_quotes SET unit_price=0")
    assert_rejected(fixture, :quote_unavailable)
    Repo.query!("DELETE FROM market_quotes")
    assert_rejected(fixture, :quote_unavailable)
  end

  test "inconsistent supply is refused rather than repaired", fixture do
    Repo.query!("ALTER TABLE market_holdings DISABLE TRIGGER ALL")

    Repo.query!("UPDATE market_holdings SET quantity=quantity - 1 WHERE user_id=$1", [
      Ecto.UUID.dump!(fixture.owner.id)
    ])

    assert_rejected(fixture, :inconsistent_state)
  end

  defp assert_rejected(fixture, kind, quantity \\ 3) do
    before = SalesCase.snapshot()
    assert {:error, %{kind: ^kind}} = SalesCase.sell(fixture, "sale-key", quantity)
    assert before == SalesCase.snapshot()
  end
end

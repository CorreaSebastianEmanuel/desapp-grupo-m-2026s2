defmodule FootballMarket.Market.Sales.TransferTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{Repo, SalesCase}

  setup do
    SalesCase.fixture()
  end

  test "sale conserves credits and supply with complete exact evidence", fixture do
    assert {:ok, sale} = SalesCase.sell(fixture)
    assert sale.seller_id == fixture.buyer.id
    assert sale.recipient_id == fixture.owner.id
    assert sale.quantity == 3
    assert Decimal.equal?(sale.unit_price, "1")
    assert Decimal.equal?(sale.total, "3")
    assert sale.transfer.from_user_id == fixture.buyer.id
    assert sale.transfer.to_user_id == fixture.owner.id
    assert Enum.map(sale.ledger, & &1.side) == ["credit", "debit"]

    assert Repo.query!("SELECT sum(quantity), min(quantity) FROM market_holdings").rows == [
             [100, 2]
           ]

    assert Repo.query!("SELECT sum(amount) FROM market_credit_balances").rows == [
             [Decimal.new("10")]
           ]

    assert Repo.query!("SELECT quantity FROM market_holdings WHERE player_id=$1 AND user_id=$2", [
             Ecto.UUID.dump!(fixture.player.id),
             Ecto.UUID.dump!(fixture.owner.id)
           ]).rows == [[98]]

    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
    assert Repo.query!("SELECT count(*) FROM market_sale_credit_entries").rows == [[2]]
    assert Repo.query!("SELECT count(*) FROM market_sale_token_transfers").rows == [[1]]
  end

  test "seller without an existing balance receives exact proceeds", fixture do
    Repo.query!("DELETE FROM market_credit_balances WHERE user_id=$1", [
      Ecto.UUID.dump!(fixture.buyer.id)
    ])

    assert {:ok, _sale} = SalesCase.sell(fixture)

    assert Repo.query!("SELECT amount FROM market_credit_balances WHERE user_id=$1", [
             Ecto.UUID.dump!(fixture.buyer.id)
           ]).rows == [[Decimal.new("3")]]
  end

  test "large balances remain exact", fixture do
    FootballMarket.PurchasesCase.fund(fixture.owner, "1e40")
    FootballMarket.PurchasesCase.fund(fixture.buyer, "1e40")
    assert {:ok, _sale} = SalesCase.sell(fixture)

    [[seller_delta]] =
      Repo.query!(
        "SELECT amount - (1e40::numeric + 3::numeric) FROM market_credit_balances WHERE user_id=$1",
        [Ecto.UUID.dump!(fixture.buyer.id)]
      ).rows

    [[recipient_delta]] =
      Repo.query!(
        "SELECT amount - (1e40::numeric - 3::numeric) FROM market_credit_balances WHERE user_id=$1",
        [Ecto.UUID.dump!(fixture.owner.id)]
      ).rows

    assert Decimal.equal?(seller_delta, 0)
    assert Decimal.equal?(recipient_delta, 0)
  end
end

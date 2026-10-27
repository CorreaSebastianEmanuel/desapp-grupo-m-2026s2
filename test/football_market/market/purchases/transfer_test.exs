defmodule FootballMarket.Market.Purchases.TransferTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{Market, PurchasesCase, Repo}

  setup do
    f = PurchasesCase.fixture()
    PurchasesCase.fund(f.buyer, "10.25")
    f
  end

  test "purchase conserves credits and supply with durable exact evidence", f do
    actor = %FootballMarket.Accounts.AuthenticatedActor{
      account_id: f.buyer.id,
      authentication_method: :jwt,
      credential_id: Ecto.UUID.generate()
    }

    assert {:ok, p} = Market.purchase(actor, PurchasesCase.request(f))
    assert p.buyer_id == f.buyer.id
    assert p.recipient_id == f.owner.id
    assert p.quantity == 3
    assert Decimal.equal?(p.total, Decimal.mult(p.unit_price, 3))
    assert Repo.query!("SELECT sum(quantity) FROM market_holdings").rows == [[100]]

    assert Repo.query!("SELECT sum(amount) FROM market_credit_balances").rows == [
             [Decimal.new("10.25")]
           ]

    assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[2]]
    assert Repo.query!("SELECT count(*) FROM market_token_transfers").rows == [[1]]
  end

  test "existing buyer holding accumulates and another player's supply and balances remain intact",
       f do
    assert {:ok, _} = Market.initialize_player(f.other.id)
    assert {:ok, _} = FootballMarket.MarketCase.transfer(f, 2)

    other_before =
      Repo.query!("SELECT row_to_json(h)::text FROM market_holdings h WHERE player_id=$1", [
        Ecto.UUID.dump!(f.other.id)
      ]).rows

    assert {:ok, p} = PurchasesCase.purchase(f)
    assert Decimal.equal?(p.total, "3")

    assert Repo.query!("SELECT quantity FROM market_holdings WHERE player_id=$1 AND user_id=$2", [
             Ecto.UUID.dump!(f.player.id),
             Ecto.UUID.dump!(f.buyer.id)
           ]).rows == [[5]]

    assert other_before ==
             Repo.query!(
               "SELECT row_to_json(h)::text FROM market_holdings h WHERE player_id=$1",
               [Ecto.UUID.dump!(f.other.id)]
             ).rows
  end

  test "large accepted buyer balance is debited exactly", f do
    PurchasesCase.fund(f.buyer, "1e40")

    assert {:ok, _purchase} = PurchasesCase.purchase(f)

    [[buyer_delta]] =
      Repo.query!(
        "SELECT amount - (1e40::numeric - 3::numeric) FROM market_credit_balances WHERE user_id=$1",
        [Ecto.UUID.dump!(f.buyer.id)]
      ).rows

    assert Decimal.equal?(buyer_delta, 0)
  end

  test "large accepted recipient balance is credited exactly", f do
    PurchasesCase.fund(f.buyer, "10.25")
    PurchasesCase.fund(f.owner, "1e40")

    assert {:ok, _purchase} = PurchasesCase.purchase(f)

    [[recipient_delta]] =
      Repo.query!(
        "SELECT amount - (1e40::numeric + 3::numeric) FROM market_credit_balances WHERE user_id=$1",
        [Ecto.UUID.dump!(f.owner.id)]
      ).rows

    assert Decimal.equal?(recipient_delta, 0)
  end
end

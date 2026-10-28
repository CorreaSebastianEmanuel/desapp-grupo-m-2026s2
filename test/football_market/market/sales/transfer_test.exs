defmodule FootballMarket.Market.Sales.TransferTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{Market, SalesCase, Repo}

  setup do
    f = SalesCase.fixture()
    f
  end

  test "sale conserves credits and supply with durable exact evidence", f do
    assert {:ok, s} = SalesCase.sale(f)
    assert s.seller_id == f.buyer.id
    assert s.buyer_id == f.owner.id
    assert s.quantity == 3
    assert Decimal.equal?(s.total, Decimal.mult(s.unit_price, 3))
    assert Repo.query!("SELECT sum(quantity) FROM market_holdings").rows == [[100]]

    assert Repo.query!("SELECT sum(amount) FROM market_credit_balances").rows == [
             [Decimal.new("10")]
           ]

    assert Repo.query!("SELECT count(*) FROM market_credit_entries").rows == [[2]]
    assert Repo.query!("SELECT count(*) FROM market_token_transfers").rows == [[1]]
    assert Repo.query!("SELECT count(*) FROM market_sales").rows == [[1]]
  end

  test "existing market holding accumulates and another player's supply and balances remain intact",
       f do
    assert {:ok, _} = Market.initialize_player(f.other.id)

    other_before =
      Repo.query!(
        "SELECT row_to_json(h)::text FROM market_holdings h WHERE player_id=$1 ORDER BY row_to_json(h)::text",
        [Ecto.UUID.dump!(f.other.id)]
      ).rows

    assert {:ok, s} = SalesCase.sale(f, "sale-key", 4)
    assert Decimal.equal?(s.total, "4")

    assert Repo.query!(
             "SELECT quantity FROM market_holdings WHERE player_id=$1 AND user_id=$2",
             [Ecto.UUID.dump!(f.player.id), Ecto.UUID.dump!(f.owner.id)]
           ).rows == [[100]]

    assert other_before ==
             Repo.query!(
               "SELECT row_to_json(h)::text FROM market_holdings h WHERE player_id=$1 ORDER BY row_to_json(h)::text",
               [Ecto.UUID.dump!(f.other.id)]
             ).rows
  end

  test "large accepted payer and payee balances settle exactly", f do
    SalesCase.fund(f.owner, "1e40")

    assert {:ok, _sale} = SalesCase.sale(f)

    [[payer_delta]] =
      Repo.query!(
        "SELECT amount - (1e40::numeric - 3::numeric) FROM market_credit_balances WHERE user_id=$1",
        [Ecto.UUID.dump!(f.owner.id)]
      ).rows

    assert Decimal.equal?(payer_delta, 0)

    [[payee_amount]] =
      Repo.query!("SELECT amount FROM market_credit_balances WHERE user_id=$1", [
        Ecto.UUID.dump!(f.buyer.id)
      ]).rows

    assert Decimal.equal?(payee_amount, "3")
  end
end

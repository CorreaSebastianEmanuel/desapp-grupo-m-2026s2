defmodule FootballMarket.Market.ConditionalOrders.EvaluationTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{ConditionalOrdersCase, PurchasesCase, Repo}
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  setup do: ConditionalOrdersCase.fixture()

  test "equal and below limits execute entirely at the single current quote once", f do
    for limit <- ["1.00", "2.00"] do
      o = ConditionalOrdersCase.order!(f, %{maximum_unit_price: limit})
      assert {:ok, executed} = Orders.evaluate(o.id)
      assert executed.status == "executed"
      assert Decimal.equal?(executed.execution.unit_price, "1")
      assert Decimal.equal?(executed.execution.total, "3")
      assert executed.completed_at == executed.execution.completed_at
      before = ConditionalOrdersCase.snapshot()
      assert {:ok, ^executed} = Orders.evaluate(o.id)
      assert before == ConditionalOrdersCase.snapshot()
      ConditionalOrdersCase.invariant!()
    end

    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[2]]

    assert Repo.query!("SELECT amount FROM market_credit_balances WHERE user_id=$1", [
             Ecto.UUID.dump!(f.buyer.id)
           ]).rows == [[Decimal.new("94")]]
  end

  test "high absent invalid and nonpositive quotes cannot execute; expiry dominates all", f do
    o = ConditionalOrdersCase.order!(f, %{maximum_unit_price: "0.01"})
    before = ConditionalOrdersCase.snapshot()
    assert {:ok, %{status: "pending"}} = Orders.evaluate(o.id)
    assert before == ConditionalOrdersCase.snapshot()

    for price <- ["0", "-1", "NaN", "Infinity"] do
      Repo.query!("ALTER TABLE market_quotes DISABLE TRIGGER ALL")
      Repo.query!("ALTER TABLE market_quotes DROP CONSTRAINT IF EXISTS market_quote_canonical")
      Repo.query!("UPDATE market_quotes SET unit_price=$1::numeric", [Decimal.new(price)])
      before = ConditionalOrdersCase.snapshot()
      assert {:ok, %{status: "pending"}} = Orders.evaluate(o.id)
      assert before == ConditionalOrdersCase.snapshot()
    end

    # An empty quote table models absent current authority without mutating an order read.
    Repo.query!("ALTER TABLE market_quotes RENAME TO saved_quotes")
    Repo.query!("CREATE TABLE market_quotes AS TABLE saved_quotes WITH NO DATA")

    try do
      assert {:ok, %{status: "pending"}} = Orders.evaluate(o.id)
      ConditionalOrdersCase.due!(o)
      assert {:ok, %{status: "expired"}} = Orders.evaluate(o.id)
    after
      Repo.query!("DROP TABLE market_quotes")
      Repo.query!("ALTER TABLE saved_quotes RENAME TO market_quotes")
    end

    assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [[0]]
  end

  test "qualifying insufficiencies reject distinctly without partial effects", f do
    PurchasesCase.fund(f.buyer, "0")
    o = ConditionalOrdersCase.order!(f)
    before = PurchasesCase.snapshot()

    assert {:ok, %{status: "rejected", rejection_reason: "insufficient_funds"}} =
             Orders.evaluate(o.id)

    assert before == PurchasesCase.snapshot()
    PurchasesCase.fund(f.buyer, "1000")
    assert {:ok, _} = PurchasesCase.purchase(f, "use-inventory", 99)
    o = ConditionalOrdersCase.order!(f)
    before = PurchasesCase.snapshot()

    assert {:ok, %{status: "rejected", rejection_reason: "insufficient_inventory"}} =
             Orders.evaluate(o.id)

    assert before == PurchasesCase.snapshot()
    o = ConditionalOrdersCase.order!(f)
    ConditionalOrdersCase.due!(o)
    assert {:ok, %{status: "expired"}} = Orders.evaluate(o.id)
    ConditionalOrdersCase.invariant!()
  end
end

defmodule FootballMarket.Market.ConditionalOrders.ReadsTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.ConditionalOrdersCase, as: C
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  setup do: C.fixture()

  test "persisted expiry execution and rejection expose stable terminal facts with pure reads",
       f do
    a = C.actor(f.buyer)
    expired = C.order!(f)
    C.due!(expired)
    assert {:ok, %{status: "expired"}} = Orders.evaluate(expired.id)
    executed = C.order!(f)
    assert {:ok, %{status: "executed", execution: facts}} = Orders.evaluate(executed.id)
    assert Decimal.equal?(facts.total, "3")
    FootballMarket.PurchasesCase.fund(f.buyer, "0")
    rejected = C.order!(f)
    assert {:ok, %{status: "rejected"}} = Orders.evaluate(rejected.id)
    before = C.snapshot()

    for {o, status} <- [{expired, "expired"}, {executed, "executed"}, {rejected, "rejected"}] do
      assert {:ok, row} = Orders.get(a, o.id)
      assert row.status == status
      assert row.expiry_reached == (status == "expired")
      if status == "executed", do: assert(row.execution == facts)
    end

    assert {:ok, list} = Orders.list(a)
    assert length(list) == 3
    assert before == C.snapshot()
  end

  test "owned reads list persisted status across expiry without updates or jobs", f do
    o = C.order!(f, %{maximum_unit_price: "0.01"})
    a = C.actor(f.buyer)
    before = C.snapshot()
    assert {:ok, fresh} = Orders.get(a, o.id)
    refute fresh.expiry_reached
    assert {:ok, [^fresh]} = Orders.list(a)
    assert before == C.snapshot()
    C.due!(o)
    before = C.snapshot()
    assert {:ok, due} = Orders.get(a, o.id)
    assert due.status == "pending" and due.expiry_reached
    assert {:ok, [^due]} = Orders.list(a)
    assert before == C.snapshot()

    for id <- [o.id, Ecto.UUID.generate(), "bad"] do
      assert {:error, :not_found} = Orders.get(C.actor(f.owner), id)
    end

    assert {:ok, []} = Orders.list(C.actor(f.owner))
    assert before == C.snapshot()
  end
end

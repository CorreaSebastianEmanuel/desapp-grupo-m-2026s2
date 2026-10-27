defmodule FootballMarket.Market.ConditionalOrders.CancellationTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.ConditionalOrdersCase, as: C
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  setup do: C.fixture()

  test "owner cancels before expiry and due cancellation persists expired with no purchase", f do
    for due <- [false, true] do
      o = C.order!(f)
      if due, do: C.due!(o)
      before = FootballMarket.PurchasesCase.snapshot()
      assert {:ok, result} = Orders.cancel(C.actor(f.buyer), o.id)
      assert result.status == if(due, do: "expired", else: "cancelled")
      assert {:ok, ^result} = Orders.cancel(C.actor(f.buyer), o.id)
      assert {:ok, ^result} = Orders.evaluate(o.id)
      assert before == FootballMarket.PurchasesCase.snapshot()
    end
  end

  test "all terminal cancellations preserve original outcome and pure financial evidence", f do
    for status <- ["executed", "rejected", "expired", "cancelled"] do
      o = C.order!(f)
      if status == "rejected", do: FootballMarket.PurchasesCase.fund(f.buyer, "0")
      if status == "expired", do: C.due!(o)

      {:ok, result} =
        if status == "cancelled",
          do: Orders.cancel(C.actor(f.buyer), o.id),
          else: Orders.evaluate(o.id)

      assert result.status == status
      before = C.snapshot()
      assert {:ok, ^result} = Orders.cancel(C.actor(f.buyer), o.id)
      assert {:ok, ^result} = Orders.evaluate(o.id)
      assert before == C.snapshot()
    end
  end

  test "foreign absent malformed and unauthenticated attempts disclose and change nothing", f do
    o = C.order!(f)
    before = C.snapshot()

    for id <- [o.id, Ecto.UUID.generate(), "bad"] do
      assert {:error, :not_found} = Orders.cancel(C.actor(f.owner), id)
    end

    assert {:error, %{kind: :unauthenticated}} = Orders.cancel(nil, o.id)
    assert before == C.snapshot()
  end
end

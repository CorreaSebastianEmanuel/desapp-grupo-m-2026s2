defmodule FootballMarket.Market.OrderEvaluation.DeliveryTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.OrderEvaluationCase
  alias FootballMarket.ConditionalOrdersCase
  alias FootballMarket.PurchasesCase

  setup do: OrderEvaluationCase.fixture()

  test "creation atomically records safe durable wake; enqueue failure rolls back", f do
    order = OrderEvaluationCase.order!(f)
    assert [%{args: %{"source" => "order", "order_id" => id}}] = OrderEvaluationCase.jobs()
    assert id == order.id
    assert OrderEvaluationCase.status(order) == "pending"
    before = ConditionalOrdersCase.snapshot()
    OrderEvaluationCase.fail_jobs!()
    assert {:error, _} = ConditionalOrdersCase.create(f)
    OrderEvaluationCase.repair_jobs!()
    assert before == ConditionalOrdersCase.snapshot()
  end

  test "a committed creation is executed through worker and duplicate delivery is harmless", f do
    order = OrderEvaluationCase.order!(f)
    assert :ok = OrderEvaluationCase.perform()
    assert OrderEvaluationCase.status(order) == "executed"
    before = PurchasesCase.snapshot()
    assert :ok = OrderEvaluationCase.perform()
    assert before == PurchasesCase.snapshot()
    OrderEvaluationCase.invariant!()
  end
end

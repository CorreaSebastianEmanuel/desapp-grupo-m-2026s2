defmodule FootballMarket.Market.OrderEvaluation.RetryTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.OrderEvaluationCase
  alias FootballMarket.PurchasesCase
  alias FootballMarket.Repo
  alias FootballMarket.Market.OrderEvaluation
  alias FootballMarket.Market.OrderEvaluationStore
  alias FootballMarket.Workers.ConditionalOrderEvaluation

  setup do: OrderEvaluationCase.fixture()

  test "financial failure rolls back cursor and every effect; exhaustion stays recoverable", f do
    order = OrderEvaluationCase.order!(f)
    assert {:ok, _} = OrderEvaluationStore.request_pass()
    before = PurchasesCase.snapshot()
    OrderEvaluationCase.fail_purchase!()

    for attempt <- 1..3 do
      assert {:error, :temporarily_unavailable} =
               ConditionalOrderEvaluation.perform(%Oban.Job{
                 args: %{"source" => "continuation"},
                 attempt: attempt
               })

      assert OrderEvaluationCase.status(order) == "pending"
      assert before == PurchasesCase.snapshot()

      assert Repo.query!("SELECT cursor_ordinal FROM market_order_evaluation_passes").rows == [
               [0]
             ]
    end

    OrderEvaluationCase.repair_purchase!()
    assert :ok = OrderEvaluation.recover(nil)
    assert :ok = OrderEvaluationCase.perform()
    assert OrderEvaluationCase.status(order) == "executed"
    before = PurchasesCase.snapshot()
    assert :ok = OrderEvaluationCase.perform(%{"source" => "continuation"})
    assert before == PurchasesCase.snapshot()
    OrderEvaluationCase.invariant!()
  end

  test "failed continuation cannot strand remaining captured members", f do
    orders = for _ <- 1..101, do: OrderEvaluationCase.order!(f, %{maximum_unit_price: "0.01"})
    OrderEvaluationCase.fail_jobs!()
    assert {:error, :temporarily_unavailable} = OrderEvaluationCase.perform()

    assert Repo.query!("SELECT cursor_ordinal FROM market_order_evaluation_passes").rows == [
             [100]
           ]

    assert Enum.all?(orders, &(OrderEvaluationCase.status(&1) == "pending"))
    OrderEvaluationCase.repair_jobs!()
    assert :ok = OrderEvaluation.recover(nil)
    assert :ok = OrderEvaluationCase.perform(%{"source" => "continuation"})
    # Recovery coalesces a fresh rescan. Its 101 pending members require a
    # second bounded continuation, rather than exceeding the 100-step budget.
    assert Repo.query!("SELECT state FROM market_order_evaluation_passes").rows == [["running"]]
    assert :ok = OrderEvaluationCase.perform(%{"source" => "continuation"})
    assert Repo.query!("SELECT state FROM market_order_evaluation_passes").rows == [["idle"]]
    OrderEvaluationCase.invariant!()
  end
end

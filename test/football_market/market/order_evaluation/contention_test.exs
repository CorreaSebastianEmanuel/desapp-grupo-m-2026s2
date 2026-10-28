defmodule FootballMarket.Market.OrderEvaluation.ContentionTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.OrderEvaluationCase
  alias FootballMarket.PurchasesCase
  alias FootballMarket.Repo
  alias FootballMarket.Market.OrderEvaluation

  setup do: OrderEvaluationCase.fixture()

  test "shared-user cross-player balances cannot overspend under overlapping wakes", f do
    assert {:ok, _} = FootballMarket.Market.initialize_player(f.other.id)
    PurchasesCase.fund(f.buyer, "3")
    first = OrderEvaluationCase.order!(f)
    second = OrderEvaluationCase.order!(f, %{player_id: f.other.id})

    results =
      FootballMarket.OrderEvaluation.RuntimeProbe.queued(
        f,
        [fn -> OrderEvaluation.run(true) end, fn -> OrderEvaluation.recover(nil) end],
        "market_order_evaluation_passes"
      )

    assert results == [:ok, :ok]
    assert :ok = OrderEvaluationCase.perform()
    assert OrderEvaluationCase.status(first) == "executed"

    assert Repo.get!(FootballMarket.Market.ConditionalOrder, second.id).rejection_reason ==
             "insufficient_funds"

    OrderEvaluationCase.invariant!()
  end
end

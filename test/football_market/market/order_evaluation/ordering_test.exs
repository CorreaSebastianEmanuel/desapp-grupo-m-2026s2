defmodule FootballMarket.Market.OrderEvaluation.OrderingTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.OrderEvaluationCase
  alias FootballMarket.Repo
  alias FootballMarket.Market.OrderEvaluation
  alias FootballMarket.Market.OrderEvaluationStore

  setup do: OrderEvaluationCase.fixture()

  test "snapshot ordinals use creation then UUID; arrivals cannot enter current membership", f do
    first = OrderEvaluationCase.order!(f, %{maximum_unit_price: "0.01"})
    second = OrderEvaluationCase.order!(f, %{maximum_unit_price: "0.01"})

    Repo.query!(
      "ALTER TABLE market_conditional_buy_orders DISABLE TRIGGER market_order_immutable"
    )

    Repo.query!(
      "UPDATE market_conditional_buy_orders SET created_at=(SELECT min(created_at) FROM market_conditional_buy_orders)"
    )

    Repo.query!("ALTER TABLE market_conditional_buy_orders ENABLE TRIGGER market_order_immutable")
    assert {:ok, _} = OrderEvaluationStore.request_pass()

    ids =
      Repo.query!("SELECT order_id FROM market_order_evaluation_members ORDER BY ordinal").rows
      |> List.flatten()
      |> Enum.map(&Ecto.UUID.load!/1)

    assert ids == Enum.sort([first.id, second.id])
    late = OrderEvaluationCase.order!(f)
    assert {:ok, _} = OrderEvaluationStore.request_pass()
    assert Repo.query!("SELECT count(*) FROM market_order_evaluation_members").rows == [[2]]
    assert {:ok, _} = OrderEvaluationStore.step()
    assert {:ok, _} = OrderEvaluationStore.step()
    assert OrderEvaluationCase.status(late) == "pending"
    assert :ok = OrderEvaluation.run(false)
    assert OrderEvaluationCase.status(late) == "executed"
  end

  test "competing inventory is awarded in captured order on independent workers", f do
    first = OrderEvaluationCase.order!(f, %{quantity: 60})
    second = OrderEvaluationCase.order!(f, %{quantity: 60})

    results =
      FootballMarket.OrderEvaluation.RuntimeProbe.queued(
        f,
        [fn -> OrderEvaluation.run(true) end, fn -> OrderEvaluation.run(true) end],
        "market_order_evaluation_passes"
      )

    assert results == [:ok, :ok]
    assert OrderEvaluationCase.status(first) == "executed"
    assert OrderEvaluationCase.status(second) == "rejected"
    OrderEvaluationCase.invariant!()
  end

  test "a backdated committed arrival stays outside the captured pass", f do
    first = OrderEvaluationCase.order!(f, %{maximum_unit_price: "0.01"})
    assert {:ok, _} = OrderEvaluationStore.request_pass()
    late = OrderEvaluationCase.order!(f)

    Repo.query!(
      "ALTER TABLE market_conditional_buy_orders DISABLE TRIGGER market_order_immutable"
    )

    Repo.query!(
      "UPDATE market_conditional_buy_orders SET created_at=created_at-interval '1 minute' WHERE id=$1",
      [Ecto.UUID.dump!(late.id)]
    )

    Repo.query!("ALTER TABLE market_conditional_buy_orders ENABLE TRIGGER market_order_immutable")
    assert {:ok, _} = OrderEvaluationStore.step()
    assert OrderEvaluationCase.status(first) == "pending"
    assert OrderEvaluationCase.status(late) == "pending"
    assert {:ok, :idle} = OrderEvaluationStore.step()
    assert :ok = OrderEvaluationCase.perform()
    assert OrderEvaluationCase.status(late) == "executed"
  end
end

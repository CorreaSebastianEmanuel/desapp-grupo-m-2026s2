defmodule FootballMarket.Market.OrderEvaluation.NotificationsTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.OrderEvaluationCase
  alias FootballMarket.ConditionalOrdersCase
  alias FootballMarket.PurchasesCase
  alias FootballMarket.Repo

  setup do: OrderEvaluationCase.fixture()

  test "post-commit owner hints have only identity; no pending/replay signal", f do
    :ok = Phoenix.PubSub.subscribe(FootballMarket.PubSub, "conditional_orders:" <> f.buyer.id)
    pending = OrderEvaluationCase.order!(f, %{maximum_unit_price: "0.01"})
    assert :ok = OrderEvaluationCase.perform()
    refute_receive {:conditional_order_changed, _}
    order = OrderEvaluationCase.order!(f)
    assert :ok = OrderEvaluationCase.perform()
    assert_receive {:conditional_order_changed, id}
    assert id == order.id
    assert OrderEvaluationCase.status(order) == "executed"
    assert :ok = OrderEvaluationCase.perform()
    refute_receive {:conditional_order_changed, _}

    assert {:ok, %{status: "cancelled"}} =
             FootballMarket.Market.ConditionalOrders.cancel(
               PurchasesCase.actor(f.buyer),
               pending.id
             )

    assert_receive {:conditional_order_changed, id}
    assert id == pending.id

    assert {:ok, result} =
             FootballMarket.Market.ConditionalOrders.get(PurchasesCase.actor(f.buyer), order.id)

    assert result.status == "executed"
  end

  test "rollback never signals; rejected and expired outcomes signal after commit", f do
    :ok = Phoenix.PubSub.subscribe(FootballMarket.PubSub, "conditional_orders:" <> f.buyer.id)
    order = OrderEvaluationCase.order!(f)
    OrderEvaluationCase.fail_purchase!()
    assert {:error, _} = OrderEvaluationCase.perform()
    refute_receive {:conditional_order_changed, _}
    OrderEvaluationCase.repair_purchase!()
    PurchasesCase.fund(f.buyer, "0")
    assert :ok = OrderEvaluationCase.perform()
    assert_receive {:conditional_order_changed, id}
    assert id == order.id
    due = OrderEvaluationCase.order!(f)
    ConditionalOrdersCase.due!(due)
    assert :ok = OrderEvaluationCase.perform()
    assert_receive {:conditional_order_changed, id}
    assert id == due.id
  end

  test "blocked commit cannot publish early and an unavailable PubSub cannot undo purchase", f do
    :ok = Phoenix.PubSub.subscribe(FootballMarket.PubSub, "conditional_orders:" <> f.buyer.id)
    order = OrderEvaluationCase.order!(f)

    Repo.query!(
      "CREATE FUNCTION evaluation_commit_barrier() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(60060); RETURN NEW; END $$"
    )

    Repo.query!(
      "CREATE CONSTRAINT TRIGGER evaluation_commit_barrier AFTER INSERT ON market_purchases DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION evaluation_commit_barrier()"
    )

    parent = self()

    {:ok, task} =
      Repo.transaction(fn ->
        Repo.query!("SELECT pg_advisory_xact_lock(60060)")

        task =
          FootballMarket.OrderEvaluation.RuntimeProbe.start(f, parent, :commit_worker, fn ->
            OrderEvaluationCase.perform()
          end)

        assert_receive {:commit_worker, backend}, 10_000
        FootballMarket.MarketCase.blocked(backend)
        refute_receive {:conditional_order_changed, _}
        assert OrderEvaluationCase.status(order) == "pending"
        task
      end)

    assert :ok = Task.await(task, 20_000)
    assert_receive {:conditional_order_changed, id}
    assert id == order.id
    second = OrderEvaluationCase.order!(f)
    :ok = Phoenix.PubSub.unsubscribe(FootballMarket.PubSub, "conditional_orders:" <> f.buyer.id)
    :ok = Supervisor.terminate_child(FootballMarket.Supervisor, Phoenix.PubSub.Supervisor)

    try do
      assert :ok = OrderEvaluationCase.perform()
      assert OrderEvaluationCase.status(second) == "executed"
    after
      assert {:ok, _} =
               Supervisor.restart_child(FootballMarket.Supervisor, Phoenix.PubSub.Supervisor)
    end

    assert {:ok, result} =
             FootballMarket.Market.ConditionalOrders.get(PurchasesCase.actor(f.buyer), second.id)

    assert result.status == "executed"
  end
end

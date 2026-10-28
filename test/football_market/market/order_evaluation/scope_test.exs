defmodule FootballMarket.Market.OrderEvaluation.ScopeTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.OrderEvaluationCase
  alias FootballMarket.Repo
  alias FootballMarket.Market.OrderEvaluationPass
  setup do: OrderEvaluationCase.fixture()

  test "singleton cursor exists and invalid identity or ordinal is rejected" do
    assert %{id: 1, state: "idle", cursor_ordinal: 0} = Repo.get!(OrderEvaluationPass, 1)

    assert_raise Postgrex.Error, fn ->
      Repo.query!("INSERT INTO market_order_evaluation_passes(id) VALUES(2)")
    end

    assert_raise Postgrex.Error, fn ->
      Repo.query!("UPDATE market_order_evaluation_passes SET cursor_ordinal=-1")
    end

    assert {:error, :test_rollback} =
             Repo.transaction(fn ->
               Repo.query!("UPDATE market_order_evaluation_passes SET rescan_requested=true")
               Repo.rollback(:test_rollback)
             end)

    refute Repo.get!(OrderEvaluationPass, 1).rescan_requested
  end

  test "reads do not enqueue, reserve resources or depend on Redis", f do
    order = OrderEvaluationCase.order!(f)
    before = FootballMarket.ConditionalOrdersCase.snapshot()

    assert {:ok, _} =
             FootballMarket.Market.ConditionalOrders.get(
               FootballMarket.PurchasesCase.actor(f.buyer),
               order.id
             )

    assert {:ok, _} =
             FootballMarket.Market.ConditionalOrders.list(
               FootballMarket.PurchasesCase.actor(f.buyer)
             )

    assert before == FootballMarket.ConditionalOrdersCase.snapshot()

    for path <- ~w(order_evaluation order_evaluation_store order_notifications) do
      refute File.read!("lib/football_market/market/#{path}.ex") =~ "Redix"
    end
  end

  test "scheduler members enforce active generation, unique order and positive positions", f do
    order = OrderEvaluationCase.order!(f, %{maximum_unit_price: "0.01"})
    assert {:ok, _} = FootballMarket.Market.OrderEvaluationStore.request_pass()

    [generation, ordinal, order_id, captured] =
      hd(
        Repo.query!(
          "SELECT pass_generation, ordinal, order_id, captured_created_at FROM market_order_evaluation_members"
        ).rows
      )

    for {gen, pos, id} <- [
          {generation, ordinal, order_id},
          {generation, ordinal + 1, order_id},
          {generation, 0, order_id},
          {generation + 1, 1, order_id},
          {generation, 2, Ecto.UUID.dump!(Ecto.UUID.generate())}
        ] do
      assert_raise Postgrex.Error, fn ->
        Repo.transaction(fn ->
          Repo.query!(
            "INSERT INTO market_order_evaluation_members(pass_generation,ordinal,captured_created_at,order_id) VALUES($1,$2,$3,$4)",
            [gen, pos, captured, id]
          )
        end)
      end
    end

    assert OrderEvaluationCase.status(order) == "pending"
  end

  test "missing configured Oban is a safe temporary failure with no persisted order", f do
    key = FootballMarket.Synchronization
    previous = Application.fetch_env(:football_market, key)
    Application.put_env(:football_market, key, oban_name: FootballMarket.MissingOrderOban)
    before = FootballMarket.ConditionalOrdersCase.snapshot()

    try do
      assert {:error, %{kind: :temporarily_unavailable}} =
               FootballMarket.ConditionalOrdersCase.create(f)

      assert before == FootballMarket.ConditionalOrdersCase.snapshot()
    after
      case previous do
        {:ok, value} -> Application.put_env(:football_market, key, value)
        :error -> Application.delete_env(:football_market, key)
      end
    end
  end
end

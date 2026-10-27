defmodule FootballMarket.Market.ConditionalOrders.CancellationRaceTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.{MarketCase, Repo}
  alias FootballMarket.ConditionalOrdersCase, as: C
  alias FootballMarket.Market.ConditionalOrders, as: Orders
  alias FootballMarket.ConditionalOrders.RuntimeProbe
  setup do: C.fixture()

  test "committed connections force either cancellation or execution to win exclusively", f do
    for winner <- [:cancel, :evaluate] do
      o = C.order!(f)

      Repo.query!(
        "CREATE OR REPLACE FUNCTION cancel_pause() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN PERFORM pg_advisory_xact_lock(29040); RETURN NEW; END $$"
      )

      {table, action} =
        if winner == :cancel,
          do: {"market_conditional_buy_orders", "UPDATE"},
          else: {"market_purchases", "INSERT"}

      Repo.query!(
        "CREATE TRIGGER cancel_pause BEFORE #{action} ON #{table} FOR EACH ROW EXECUTE FUNCTION cancel_pause()"
      )

      parent = self()

      call = fn
        :cancel -> Orders.cancel(C.actor(f.buyer), o.id)
        :evaluate -> Orders.evaluate(o.id)
      end

      loser = if winner == :cancel, do: :evaluate, else: :cancel
      before_count = Repo.query!("SELECT count(*) FROM market_purchases").rows

      {:ok, {first, second}} =
        Repo.transaction(fn ->
          Repo.query!("SELECT pg_advisory_xact_lock(29040)")
          first = RuntimeProbe.start(f, parent, :first, fn -> call.(winner) end)
          assert_receive {:first, backend}, 10_000
          MarketCase.blocked(backend)
          second = RuntimeProbe.start(f, parent, :second, fn -> call.(loser) end)
          assert_receive {:second, backend}, 10_000
          MarketCase.blocked(backend)
          refute Task.yield(first, 0)
          refute Task.yield(second, 0)
          {first, second}
        end)

      assert {:ok, result} = Task.await(first, 20_000)
      assert {:ok, ^result} = Task.await(second, 20_000)
      assert result.status == if(winner == :cancel, do: "cancelled", else: "executed")
      [[before_count]] = before_count

      assert Repo.query!("SELECT count(*) FROM market_purchases").rows == [
               [before_count + if(winner == :evaluate, do: 1, else: 0)]
             ]

      Repo.query!("DROP TRIGGER cancel_pause ON #{table}")
      C.invariant!()
    end
  end
end

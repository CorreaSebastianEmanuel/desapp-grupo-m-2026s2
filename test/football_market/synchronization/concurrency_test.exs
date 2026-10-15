defmodule FootballMarket.Synchronization.ConcurrencyTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.Synchronization.ExecutionGuard

  test "dedicated execution lock enforces global capacity and dies with owner" do
    parent = self()
    scope = %{league_code: "PL", start_year: 2091, end_year: 2092}

    owner =
      spawn(fn ->
        result = ExecutionGuard.acquire(scope)
        send(parent, {:guard, result})

        receive do
          :stop -> :ok
        end
      end)

    assert_receive {:guard, {:ok, guard}}, 5000
    assert {:error, :busy} = ExecutionGuard.acquire(scope)
    assert {:error, :busy} = ExecutionGuard.acquire(%{scope | start_year: 2092, end_year: 2093})
    monitor = Process.monitor(guard)
    Process.exit(owner, :kill)
    assert_receive {:DOWN, ^monitor, :process, ^guard, _}, 5000
    assert {:ok, next} = ExecutionGuard.acquire(scope)
    GenServer.stop(next)
  end

  test "ten independent PostgreSQL callers across initial/manual triggers admit one durable run" do
    FootballMarket.Synchronization.Case.with_store(fn repo ->
      results =
        FootballMarket.Synchronization.Case.race(
          10,
          fn index ->
            trigger = Enum.at([:initial, :manual, :scheduled], rem(index, 3))

            {:ok, input} =
              FootballMarket.Synchronization.Input.normalize(
                FootballMarket.Synchronization.Fixtures.scope(),
                source_ref: "fixture",
                trigger: trigger
              )

            FootballMarket.Synchronization.Store.admit(input)
          end,
          repo
        )

      assert Enum.all?(results, &match?({:ok, _}, &1))
      ids = Enum.map(results, fn {:ok, run} -> run.run_id end)
      assert length(Enum.uniq(ids)) == 1
      assert Enum.count(results, fn {:ok, run} -> run.disposition == :created end) == 1
      assert FootballMarket.Repo.aggregate(FootballMarket.Synchronization.Run, :count) == 1
      assert FootballMarket.Repo.aggregate(FootballMarket.Synchronization.Trigger, :count) == 10
    end)
  end

  test "requester termination preserves committed run, prepared delivery and original policy" do
    FootballMarket.Synchronization.Case.with_store(fn repo ->
      parent = self()

      {pid, ref} =
        spawn_monitor(fn ->
          FootballMarket.Repo.put_dynamic_repo(repo)

          Ecto.Adapters.SQL.Sandbox.unboxed_run(FootballMarket.Repo, fn ->
            result =
              FootballMarket.Synchronization.request_catalog(
                FootballMarket.Synchronization.Fixtures.scope(),
                source_ref: "fixture",
                policy: %{attempt_limit: 1, waits: []}
              )

            send(parent, {:accepted_before_exit, result})
          end)

          exit(:shutdown)
        end)

      assert_receive {:accepted_before_exit, {:ok, accepted}}, 5000
      assert_receive {:DOWN, ^ref, :process, ^pid, :shutdown}, 5000
      assert {:ok, run} = FootballMarket.Synchronization.get_run(accepted.run_id)
      assert run.state == "queued"
      assert run.policy["attempt_limit"] == 1

      assert {:ok, coalesced} =
               FootballMarket.Synchronization.request_catalog(
                 FootballMarket.Synchronization.Fixtures.scope(),
                 source_ref: "fixture"
               )

      assert coalesced.run_id == run.id
      assert {:ok, unchanged} = FootballMarket.Synchronization.get_run(run.id)
      assert unchanged.policy == run.policy

      assert FootballMarket.Repo.get!(Oban.Job, run.job_id,
               prefix: Oban.config(FootballMarket.Synchronization.TestOban).prefix
             ).args == %{"run_id" => run.id, "delivery_id" => run.delivery_id}
    end)
  end
end

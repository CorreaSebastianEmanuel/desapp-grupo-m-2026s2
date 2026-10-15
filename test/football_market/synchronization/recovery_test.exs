defmodule FootballMarket.Synchronization.RecoveryTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Synchronization
  alias FootballMarket.Synchronization.{Fixtures, Run, Recovery, Store}

  setup do
    old = Application.get_env(:football_market, Synchronization)

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source()}
    )

    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)
    FootballMarket.IngestionFixtures.positions!()
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
    :ok
  end

  test "lost completion confirms existing receipt without another domain attempt" do
    assert {:ok, accepted} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    run = Repo.get!(Run, accepted.run_id)
    Process.put(:synchronization_failpoint, :after_publication)

    assert :ok =
             FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
               args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
             })

    assert Repo.get!(Run, run.id).state == "executing"
    assert {:ok, _} = Recovery.reconcile(~U[2026-10-15 12:00:10.000000Z])
    assert {:ok, recovered} = Synchronization.get_run(run.id)
    assert recovered.state == "succeeded"
    assert length(recovered.attempts) == 1
    assert recovered.outcome["status"] == "accepted_with_changes"
  end

  test "orphaned begun attempt is interrupted and cannot fabricate success" do
    assert {:ok, accepted} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    run = Repo.get!(Run, accepted.run_id)

    assert {:ok, {_, _, _}} =
             Store.claim(run.id, run.delivery_id, ~U[2026-10-15 12:00:00.000000Z])

    assert {:ok, _} = Recovery.reconcile(~U[2026-10-15 12:00:10.000000Z])
    assert {:ok, recovered} = Synchronization.get_run(run.id)
    assert recovered.state == "retry_wait"
    assert recovered.next_retry_at == ~U[2026-10-15 12:01:10.000000Z]
    assert [attempt] = recovered.attempts
    assert attempt.status == "interrupted"
    assert recovered.outcome["status"] == "interrupted"
  end

  test "invalid schedule configuration cannot prevent recovery of already accepted work" do
    assert {:ok, accepted} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    run = Repo.get!(Run, accepted.run_id)

    assert {:ok, {_, _, _}} =
             Store.claim(run.id, run.delivery_id, ~U[2026-10-15 12:00:00.000000Z])

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source()},
      enabled: true,
      schedules: [{"invalid", %{scope: Fixtures.scope(), source_ref: "missing"}}]
    )

    assert {:error, _} = FootballMarket.Synchronization.Dispatcher.tick()
    assert {:ok, recovered} = Synchronization.get_run(run.id)
    assert recovered.state == "retry_wait"
    assert hd(recovered.attempts).status == "interrupted"
  end

  test "global disabled scheduling admits no occurrence and retains accepted pending work" do
    assert {:ok, accepted} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    assert {:ok, _} =
             FootballMarket.Synchronization.Scheduler.configure("disabled", %{
               enabled: true,
               recurrence: "* * * * *",
               scope: Fixtures.scope(),
               source_ref: "fixture"
             })

    assert {:ok, []} = FootballMarket.Synchronization.Dispatcher.tick()
    assert Repo.aggregate(FootballMarket.Synchronization.Occurrence, :count) == 0
    assert {:ok, %{state: "queued"}} = Synchronization.get_run(accepted.run_id)
  end

  test "interrupted third attempt exhausts the same durable budget without a fourth import" do
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    for {start, detected} <- [
          {~U[2026-10-15 12:00:00.000000Z], ~U[2026-10-15 12:00:10.000000Z]},
          {~U[2026-10-15 12:01:10.000000Z], ~U[2026-10-15 12:01:20.000000Z]},
          {~U[2026-10-15 12:06:20.000000Z], ~U[2026-10-15 12:06:30.000000Z]}
        ] do
      run = Repo.get!(Run, accepted.run_id)
      assert {:ok, {_, _, _}} = Store.claim(run.id, run.delivery_id, start)
      assert {:ok, _} = Recovery.reconcile(detected)
    end

    assert {:ok, result} = Synchronization.get_run(accepted.run_id)
    assert result.state == "failed"
    assert result.reason == "exhausted_unconfirmed"
    assert Enum.map(result.attempts, & &1.number) == [1, 2, 3]
    run = Repo.get!(Run, accepted.run_id)
    assert {:ok, :ignored} = Store.claim(run.id, run.delivery_id, ~U[2026-10-15 13:00:00.000000Z])
    assert Repo.aggregate(FootballMarket.Catalog.Ingestion.Observation, :count) == 0
  end

  test "lost guard connection revokes an escaped delayed publisher fence before recovery" do
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    run = Repo.get!(Run, accepted.run_id)
    {:ok, {_, _, context}} = Store.claim(run.id, run.delivery_id, ~U[2026-10-15 12:00:00.000000Z])
    parent = self()

    {owner, ref} =
      spawn_monitor(fn ->
        {:ok, guard} = FootballMarket.Synchronization.ExecutionGuard.acquire(Fixtures.scope())
        send(parent, {:guard_ready, guard})

        receive do
          :stop -> :ok
        end
      end)

    assert_receive {:guard_ready, guard}, 5000
    token = make_ref()
    candidate = FootballMarket.IngestionFixtures.candidate("PL", 2090)

    options =
      FootballMarket.IngestionFixtures.options(candidate)
      |> Keyword.put(
        :provider,
        {FootballMarket.IngestionFixtureAdapter, {:barrier, self(), token, candidate}}
      )
      |> Keyword.put(:delivery_context, context)

    publisher =
      Task.async(fn ->
        FootballMarket.Catalog.Ingestion.import_catalog(Fixtures.scope(), options)
      end)

    assert_receive {^token, publisher_pid, _backend}, 5000
    connection = :sys.get_state(guard).connection
    GenServer.stop(connection)
    assert_receive {:DOWN, ^ref, :process, ^owner, :killed}, 5000
    assert {:ok, _} = Recovery.reconcile(~U[2026-10-15 12:00:10.000000Z])
    send(publisher_pid, {token, :go})
    assert {:error, outcome} = Task.await(publisher, 5000)
    assert outcome.status == :reconciliation_conflict
    assert outcome.reason == :invalid_delivery_context
    assert Repo.aggregate(FootballMarket.Catalog.Ingestion.Observation, :count) == 0
  end

  test "repairing an unbegun completed transport preserves its fence without inventing an attempt" do
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    run = Repo.get!(Run, accepted.run_id)
    old_job = Repo.get!(Oban.Job, run.job_id)

    Repo.update!(
      Ecto.Changeset.change(old_job,
        state: "completed",
        completed_at: ~U[2026-10-15 12:00:01.000000Z]
      )
    )

    assert {:ok, _} = Recovery.reconcile(~U[2026-10-15 12:00:10.000000Z])
    repaired = Repo.get!(Run, run.id)
    assert repaired.job_id != run.job_id
    assert repaired.delivery_id == run.delivery_id
    assert {:ok, %{state: "queued", attempts: []}} = Synchronization.get_run(run.id)
    assert Repo.get!(Oban.Job, repaired.job_id).args == old_job.args
  end

  test "malformed schedule collections report explicit configuration errors without admission" do
    for schedules <- [[:invalid], [{123, %{}}], :invalid] do
      Application.put_env(:football_market, Synchronization,
        sources: %{"fixture" => Fixtures.source()},
        enabled: true,
        schedules: schedules
      )

      assert {:error, :invalid_schedule_configuration} =
               FootballMarket.Synchronization.Dispatcher.tick()
    end

    assert Repo.aggregate(Run, :count) == 0
  end
end

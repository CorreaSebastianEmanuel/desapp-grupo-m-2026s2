defmodule FootballMarket.Synchronization.StatisticsTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import Ecto.Query
  alias FootballMarket.{Repo, Synchronization}
  alias FootballMarket.Synchronization.Run
  alias FootballMarket.Synchronization.Attempt
  alias FootballMarket.Synchronization.{Clock, Store}
  alias FootballMarket.Statistics.Ingestion.{Check, FactProvenance}
  alias FootballMarket.StatisticsIngestion.{Case, Fixtures}
  alias FootballMarket.StatisticsIngestion.RuntimeProbe

  test "trusted statistics requests execute through the durable Oban worker and preserve catalog compatibility" do
    scope = Fixtures.scope(2050)
    Case.seed_catalog!(scope)
    candidate = Case.candidate(Fixtures.request(scope))
    old = Application.get_env(:football_market, Synchronization)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(old, :sources, %{"statistics_fixture" => Case.source(candidate)})
    )

    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)

    assert {:ok, admitted} =
             Synchronization.request_statistics(scope, source_ref: "statistics_fixture")

    assert admitted.status == :queued

    assert {:ok, coalesced} =
             Synchronization.request_statistics(scope, source_ref: "statistics_fixture")

    assert coalesced.run_id == admitted.run_id
    assert coalesced.disposition == :coalesced

    assert {:error, %{category: :scope_busy, run_id: run_id}} =
             Synchronization.request_statistics(scope,
               source_ref: "statistics_fixture",
               fixture_ref: "different-fixture"
             )

    assert run_id == admitted.run_id

    assert {:ok, catalog_run} =
             Synchronization.request_catalog(scope, source_ref: "statistics_fixture")

    assert catalog_run.run_id != admitted.run_id
    run = Repo.get!(Run, admitted.run_id)
    assert run.operation == "statistics"

    catalog = Repo.get!(Run, catalog_run.run_id)
    assert catalog.operation == "catalog"

    assert {:ok, :ignored} = Store.claim(run.id, catalog.delivery_id, Clock.now())

    catalog_job = Repo.get!(Oban.Job, catalog.job_id)

    assert catalog_job.worker == "FootballMarket.Workers.CatalogSync"
    assert catalog_job.args == %{"run_id" => catalog.id, "delivery_id" => catalog.delivery_id}

    Process.put(:synchronization_failpoint, {:after_publication, run.id})
    drain_until_run_state!(run.id, "executing", 50)
    Process.delete(:synchronization_failpoint)
    assert Repo.get!(Run, run.id).state == "executing"

    {:ok, dispatcher} =
      FootballMarket.Synchronization.Dispatcher.start_link(automatic: false, name: nil)

    assert {:ok, _} = FootballMarket.Synchronization.Dispatcher.tick(dispatcher)
    GenServer.stop(dispatcher)

    finished = Repo.get!(Run, run.id)
    assert finished.state == "succeeded"
    assert finished.outcome["status"] == "accepted_changes"
    assert Repo.aggregate(from(a in Attempt, where: a.run_id == ^run.id), :count) == 1
    assert Repo.aggregate(from(c in Check, where: c.run_id == ^run.id), :count) == 1
    assert Repo.aggregate(from(p in FactProvenance, where: p.run_id == ^run.id), :count) == 2
  end

  defp drain_until_run_state!(_run_id, _state, 0),
    do: flunk("Oban did not execute the targeted statistics import")

  defp drain_until_run_state!(run_id, state, remaining) do
    if Repo.get!(Run, run_id).state == state do
      :ok
    else
      result =
        Oban.drain_queue(queue: :statistics_import, with_limit: 1, with_scheduled: true)

      assert Enum.sum(Map.values(result)) > 0
      drain_until_run_state!(run_id, state, remaining - 1)
    end
  end

  test "killed worker after confirmed publication is finalized without a second attempt" do
    scope = Fixtures.scope(DateTime.utc_now() |> DateTime.to_unix())

    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      Case.seed_catalog!(scope)
    end)

    candidate = Case.candidate(Fixtures.request(scope))
    old = Application.get_env(:football_market, Synchronization)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(old, :sources, %{"statistics_crash_fixture" => Case.source(candidate)})
    )

    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)

    parent = self()

    probe =
      RuntimeProbe.start(fn ->
        Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
          Process.put(:synchronization_failpoint, {:pause_after_publication, parent})

          assert {:ok, admitted} =
                   Synchronization.request_statistics(scope,
                     source_ref: "statistics_crash_fixture",
                     policy: %{attempt_limit: 1, waits: []}
                   )

          admitted_run = Repo.get!(Run, admitted.run_id)

          send(parent, {:statistics_admitted, admitted})

          assert :ok =
                   FootballMarket.Workers.StatisticsImport.perform(%Oban.Job{
                     args: %{
                       "run_id" => admitted.run_id,
                       "delivery_id" => admitted_run.delivery_id
                     }
                   })
        end)
      end)

    worker = probe.pid

    assert_receive {:statistics_admitted, admitted}, 5000
    assert_receive {:statistics_published, run_id, ^worker}, 10_000
    assert run_id == admitted.run_id
    RuntimeProbe.kill!(probe)
    assert :ok = RuntimeProbe.await_exit!(probe, :killed)

    assert Repo.get!(Run, run_id).state == "executing"
    assert Repo.aggregate(from(c in Check, where: c.run_id == ^run_id), :count) == 1
    assert Repo.aggregate(from(p in FactProvenance, where: p.run_id == ^run_id), :count) == 2

    {:ok, dispatcher} =
      FootballMarket.Synchronization.Dispatcher.start_link(automatic: false, name: nil)

    assert {:ok, _} = FootballMarket.Synchronization.Dispatcher.tick(dispatcher)
    GenServer.stop(dispatcher)
    finished = Repo.get!(Run, run_id)
    assert finished.state == "succeeded"
    assert Repo.aggregate(from(a in Attempt, where: a.run_id == ^run_id), :count) == 1
    assert Repo.aggregate(from(c in Check, where: c.run_id == ^run_id), :count) == 1
    assert Repo.aggregate(from(p in FactProvenance, where: p.run_id == ^run_id), :count) == 2
  end

  test "independent statistics admission coalesces duplicates and fences incompatible input" do
    year = DateTime.utc_now().year + rem(System.unique_integer([:positive]), 1000)
    scope = Fixtures.scope(year)
    candidate = Case.candidate(Fixtures.request(scope))
    old = Application.get_env(:football_market, Synchronization)

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(old, :sources, %{"statistics_admission_fixture" => Case.source(candidate)})
    )

    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)

    results =
      FootballMarket.Synchronization.Case.race(8, fn ->
        Synchronization.request_statistics(scope, source_ref: "statistics_admission_fixture")
      end)

    assert Enum.all?(results, &match?({:ok, %{status: :queued}}, &1))
    admissions = Enum.map(results, fn {:ok, result} -> result end)
    assert length(Enum.uniq_by(admissions, & &1.run_id)) == 1
    assert Enum.count(admissions, &(&1.disposition == :created)) == 1

    accepted = hd(admissions)

    assert {:error, %{category: :scope_busy, run_id: run_id}} =
             Synchronization.request_statistics(scope,
               source_ref: "statistics_admission_fixture",
               fixture_ref: "changed-input"
             )

    assert run_id == accepted.run_id

    assert {:ok, distinct_scope} =
             Synchronization.request_statistics(
               %{scope | start_year: year + 1, end_year: year + 2},
               source_ref: "statistics_admission_fixture"
             )

    assert distinct_scope.run_id != accepted.run_id
  end
end

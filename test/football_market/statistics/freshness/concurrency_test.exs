defmodule FootballMarket.Statistics.Freshness.ConcurrencyTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.{FreshnessCase, Repo}
  alias FootballMarket.Statistics.Freshness
  alias FootballMarket.StatisticsIngestion.Case
  alias FootballMarket.Synchronization.{Run, Store, Trigger}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    sync = Application.get_env(:football_market, FootballMarket.Synchronization)
    freshness = Application.get_env(:football_market, Freshness)

    on_exit(fn ->
      Application.put_env(:football_market, FootballMarket.Synchronization, sync)
      Application.put_env(:football_market, Freshness, freshness)
    end)

    :ok
  end

  test "committed concurrent reads of different players share one run job receipt and trigger" do
    Case.with_statistics_store(fn repo ->
      Sandbox.unboxed_run(Repo, fn ->
        f = FreshnessCase.fixture()

        other =
          Repo.insert!(%FootballMarket.Catalog.Player{
            team_id: f.player.team_id,
            season_id: f.player.season_id,
            position_id: f.player.position_id,
            catalog_identity: "another-local-player",
            display_name: "Another player"
          })

        {:ok, other} = FootballMarket.Catalog.get_player_detail(other.id)

        results =
          1..12
          |> Task.async_stream(
            fn n ->
              Repo.put_dynamic_repo(repo)

              Sandbox.unboxed_run(Repo, fn ->
                Freshness.for_player(if rem(n, 2) == 0, do: other, else: f.player)
              end)
            end,
            max_concurrency: 12,
            timeout: 10_000
          )
          |> Enum.map(fn {:ok, result} -> result end)

        assert Enum.all?(results, &(&1.refresh.state in ~w(queued busy)))
        assert Repo.aggregate(Run, :count) == 1
        assert Repo.aggregate(Trigger, :count) == 1
        assert Repo.aggregate(FootballMarket.Synchronization.DeliveryReceipt, :count) == 1
        assert Repo.aggregate(Oban.Job, :count) == 1
        id = Repo.one!(Run).id
        assert Freshness.for_player(f.player).refresh.run_id == id
        assert Freshness.for_player(other).refresh.run_id == id
      end)
    end)
  end

  test "an admission lock held by another connection does not block local detail" do
    Case.with_statistics_store(fn repo ->
      Sandbox.unboxed_run(Repo, fn ->
        f = FreshnessCase.fixture()
        parent = self()

        task =
          Task.async(fn ->
            Repo.put_dynamic_repo(repo)

            Sandbox.unboxed_run(Repo, fn ->
              Repo.transaction(fn ->
                Store.lock_scope(f.scope)
                send(parent, :locked)

                receive do
                  :release -> :ok
                after
                  5_000 -> raise "lock release timeout"
                end
              end)
            end)
          end)

        assert_receive :locked, 5_000

        try do
          started = System.monotonic_time(:millisecond)
          result = Freshness.for_player(f.player)
          assert result.refresh.state == "busy"
          assert result.last_checked_at == nil
          assert System.monotonic_time(:millisecond) - started < 1_000
          assert Repo.aggregate(Run, :count) == 0
        after
          send(task.pid, :release)
          Task.await(task, 5_000)
        end

        assert Freshness.for_player(f.player).refresh.state == "queued"
      end)
    end)
  end

  test "confirmed import remains readable while its worker is waiting to finish" do
    Case.with_statistics_store(fn repo ->
      Sandbox.unboxed_run(Repo, fn ->
        f = FreshnessCase.fixture()
        status = Freshness.for_player(f.player)
        run = Repo.get!(Run, status.refresh.run_id)
        job = Repo.get!(Oban.Job, run.job_id)
        parent = self()

        task =
          Task.async(fn ->
            Repo.put_dynamic_repo(repo)
            Process.put(:synchronization_failpoint, {:pause_after_publication, parent})

            Sandbox.unboxed_run(Repo, fn ->
              FootballMarket.Workers.StatisticsImport.perform(job)
            end)
          end)

        assert_receive {:statistics_published, id, worker}, 5_000
        assert id == run.id

        try do
          status = Freshness.for_player(f.player)
          assert status.freshness == "fresh"
          assert status.refresh.state == "executing"
          assert status.valuation.state == "pending"
          assert Repo.aggregate(Trigger, :count) == 1
        after
          send(worker, :continue)
          Task.await(task, 5_000)
        end

        assert Repo.get!(Run, id).state == "succeeded"
      end)
    end)
  end
end

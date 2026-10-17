defmodule FootballMarket.Statistics.Ingestion.RecoveryTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  import Ecto.Query
  alias FootballMarket.{Repo, Synchronization}
  alias FootballMarket.Catalog.Season
  alias FootballMarket.Statistics.Match
  alias FootballMarket.Statistics.Ingestion.Check
  alias FootballMarket.StatisticsIngestion.Case
  alias FootballMarket.StatisticsIngestion.RuntimeProbe
  alias FootballMarket.Synchronization.{Attempt, Clock, Recovery, Run}

  test "worker killed during provider read is interrupted before any statistics commit" do
    baseline = Application.get_env(:football_market, Synchronization)

    on_exit(fn -> Application.put_env(:football_market, Synchronization, baseline) end)

    Case.with_statistics_store(fn store_repo ->
      year =
        DateTime.utc_now().year +
          rem(System.unique_integer([:positive]) + System.os_time(:millisecond), 7_000)

      scope = %{league_code: "PL", start_year: year, end_year: year + 1}

      Case.seed_catalog!(scope)

      parent = self()
      token = make_ref()
      candidate = Case.candidate(FootballMarket.StatisticsIngestion.Fixtures.request(scope))
      source = Case.source(candidate)

      source = %{
        source
        | provider: {FootballMarket.IngestionFixtureAdapter, {:barrier, parent, token, candidate}}
      }

      Application.put_env(
        :football_market,
        Synchronization,
        Keyword.put(
          Application.get_env(:football_market, Synchronization, []),
          :sources,
          %{"statistics_kill_fixture" => source}
        )
      )

      probe =
        RuntimeProbe.start(fn ->
          FootballMarket.Repo.put_dynamic_repo(store_repo)

          Ecto.Adapters.SQL.Sandbox.unboxed_run(FootballMarket.Repo, fn ->
            assert {:ok, admitted} =
                     Synchronization.request_statistics(scope,
                       source_ref: "statistics_kill_fixture"
                     )

            admitted_run = Repo.get!(Run, admitted.run_id)
            send(parent, {:statistics_admitted, admitted})

            FootballMarket.Workers.StatisticsImport.perform(%Oban.Job{
              args: %{
                "run_id" => admitted_run.id,
                "delivery_id" => admitted_run.delivery_id
              }
            })
          end)
        end)

      worker = probe.pid

      assert_receive {:statistics_admitted, admitted}, 5000
      assert_receive {^token, ^worker, backend}, 10_000
      assert is_integer(backend)
      RuntimeProbe.kill!(probe)
      assert :ok = RuntimeProbe.await_exit!(probe, :killed)

      assert {:ok, _} = Recovery.reconcile(Clock.now())
      recovered = Repo.get!(Run, admitted.run_id)
      assert recovered.state == "retry_wait"
      assert [attempt] = Repo.all(from a in Attempt, where: a.run_id == ^admitted.run_id)
      assert attempt.status == "interrupted"
      assert Repo.aggregate(from(c in Check, where: c.run_id == ^admitted.run_id), :count) == 0

      season = Repo.one!(from s in Season, where: s.start_year == ^scope.start_year)
      assert Repo.aggregate(from(m in Match, where: m.season_id == ^season.id), :count) == 0
    end)
  end
end

defmodule FootballMarket.Catalog.ScoutingTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration

  import Ecto.Query
  alias FootballMarket.{Catalog, Repo, Synchronization}
  alias FootballMarket.Catalog.ScoutRun
  alias FootballMarket.Synchronization.Fixtures
  alias FootballMarket.Workers.{CatalogScout, CatalogSync}

  setup do
    FootballMarket.IngestionFixtures.positions!()
    old = Application.get_env(:football_market, Synchronization)
    source = Fixtures.source()

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.merge(old || [],
        sources: %{"fixture" => source},
        scouting_scopes: [
          %{league_code: "PL", start_year: 2090, end_year: 2091, source_ref: "fixture"}
        ]
      )
    )

    on_exit(fn ->
      if old,
        do: Application.put_env(:football_market, Synchronization, old),
        else: Application.delete_env(:football_market, Synchronization)
    end)

    :ok
  end

  test "a valid miss is admitted immediately, imported through catalog synchronization, then published" do
    before = financial_snapshot()

    assert {:ok, [], %{state: :queued, configured_scope_count: 1}} =
             Catalog.search_players("Alex")

    scout = Repo.one!(from s in ScoutRun, where: s.normalized_name == "alex")

    assert {:snooze, 5} = CatalogScout.perform(%Oban.Job{args: %{"scout_id" => scout.id}})
    scout = Repo.get!(ScoutRun, scout.id)
    assert scout.state == "scouting"
    assert length(scout.synchronization_run_ids) == 1
    assert scout.request_count == 1

    sync = Repo.get!(FootballMarket.Synchronization.Run, hd(scout.synchronization_run_ids))

    :ok =
      CatalogSync.perform(%Oban.Job{
        args: %{"run_id" => sync.id, "delivery_id" => sync.delivery_id}
      })

    assert {:ok, completed_sync} = Synchronization.get_run(sync.id)
    assert completed_sync.state == "succeeded", inspect(completed_sync)

    Phoenix.PubSub.subscribe(FootballMarket.PubSub, "catalog_scouts")
    assert :ok = CatalogScout.perform(%Oban.Job{args: %{"scout_id" => scout.id}})
    assert_receive {:catalog_scout_changed, "alex"}

    assert Repo.get!(ScoutRun, scout.id).state == "found"
    assert {:ok, [player], nil} = Catalog.search_players("alex")
    assert player.display_name == "Alex"

    assert financial_snapshot() == before
  end

  test "catalog misses deduplicate, negative-cache fruitless runs, and reject invalid names" do
    assert {:ok, [], %{state: :queued}} = Catalog.search_players("Messi")
    scout = Repo.one!(from s in ScoutRun, where: s.normalized_name == "messi")
    assert {:ok, [], %{state: :scouting}} = Catalog.search_players("  MESSI ")

    assert {:snooze, 5} = CatalogScout.perform(%Oban.Job{args: %{"scout_id" => scout.id}})
    scout = Repo.get!(ScoutRun, scout.id)
    sync = Repo.get!(FootballMarket.Synchronization.Run, hd(scout.synchronization_run_ids))

    :ok =
      CatalogSync.perform(%Oban.Job{
        args: %{"run_id" => sync.id, "delivery_id" => sync.delivery_id}
      })

    assert {:ok, completed_sync} = Synchronization.get_run(sync.id)
    assert completed_sync.state == "succeeded", inspect(completed_sync)

    assert :ok = CatalogScout.perform(%Oban.Job{args: %{"scout_id" => scout.id}})

    assert Repo.get!(ScoutRun, scout.id).state == "not_found"

    assert {:ok, [], %{state: :cached_miss, next_attempt_at: %DateTime{}}} =
             Catalog.search_players("messi")

    assert {:ok, [], %{state: :rejected}} = Catalog.search_players("12345")
    refute Repo.exists?(from s in ScoutRun, where: s.normalized_name == "12345")
  end

  test "hourly admission is capped at ten distinct normalized names" do
    for name <- [
          "Alpha",
          "Bravo",
          "Charlie",
          "Delta",
          "Echo",
          "Foxtrot",
          "Golf",
          "Hotel",
          "India",
          "Juliet"
        ] do
      assert {:ok, [], %{state: :queued}} = Catalog.search_players("#{name} Player")
    end

    assert {:ok, [], %{state: :rate_limited, next_attempt_at: %DateTime{}}} =
             Catalog.search_players("Another Unique Player")

    assert Repo.aggregate(ScoutRun, :count) == 10
  end

  test "unconfigured sources leave local reads available and do not create scout jobs" do
    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.put(Application.get_env(:football_market, Synchronization), :scouting_scopes, [])
    )

    assert {:ok, [], %{state: :unavailable}} = Catalog.search_players("Messi")
    assert Repo.aggregate(ScoutRun, :count) == 0
  end

  test "provider failure leaves local search available and defers the same name until nightly" do
    failed_source = %{
      Fixtures.source()
      | provider:
          {FootballMarket.IngestionFixtureAdapter, {:error, %{category: :invalid_response}}}
    }

    Application.put_env(
      :football_market,
      Synchronization,
      Keyword.merge(Application.get_env(:football_market, Synchronization),
        sources: %{"fixture" => failed_source}
      )
    )

    assert {:ok, [], %{state: :queued}} = Catalog.search_players("Messi")
    scout = Repo.one!(from s in ScoutRun, where: s.normalized_name == "messi")
    assert {:snooze, 5} = CatalogScout.perform(%Oban.Job{args: %{"scout_id" => scout.id}})
    scout = Repo.get!(ScoutRun, scout.id)
    sync = Repo.get!(FootballMarket.Synchronization.Run, hd(scout.synchronization_run_ids))

    assert :ok =
             CatalogSync.perform(%Oban.Job{
               args: %{"run_id" => sync.id, "delivery_id" => sync.delivery_id}
             })

    assert {:ok, finished_sync} = Synchronization.get_run(sync.id)
    assert finished_sync.state == "failed", inspect(finished_sync)

    assert :ok = CatalogScout.perform(%Oban.Job{args: %{"scout_id" => scout.id}})

    assert {:ok, [], %{state: :provider_failure, next_attempt_at: %DateTime{}}} =
             Catalog.search_players("Messi")
  end

  defp financial_snapshot do
    schemas = [
      FootballMarket.Accounts.User,
      FootballMarket.Market.Quote,
      FootballMarket.Market.Holding,
      FootballMarket.Market.Purchase,
      FootballMarket.Market.Sale,
      FootballMarket.Statistics.Performance
    ]

    Map.new(schemas, &{&1, Repo.aggregate(&1, :count)})
  end
end

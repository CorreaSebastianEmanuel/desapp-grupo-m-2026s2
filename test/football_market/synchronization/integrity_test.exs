defmodule FootballMarket.Synchronization.IntegrityTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  alias FootballMarket.Synchronization
  alias FootballMarket.Synchronization.{Fixtures, Run}

  setup do
    old = Application.get_env(:football_market, Synchronization)

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source()}
    )

    on_exit(fn -> Application.put_env(:football_market, Synchronization, old) end)
    FootballMarket.IngestionFixtures.positions!()
    :ok
  end

  test "stable-reference configuration drift fails without retrieval or domain/financial mutation" do
    assert {:ok, request} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    before = snapshot()

    Application.put_env(:football_market, Synchronization,
      sources: %{
        "fixture" => %{
          Fixtures.source()
          | provider: {FootballMarket.IngestionFixtureAdapter, {:error, %{category: :timeout}}}
        }
      }
    )

    run = Repo.get!(Run, request.run_id)

    assert :ok =
             FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
               args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
             })

    assert {:ok, failed} = Synchronization.get_run(run.id)
    assert failed.state == "failed"
    assert failed.reason == "input_drift"
    assert snapshot() == before
    refute inspect(failed) =~ "exception"
  end

  test "missing configuration fails closed while local reads and financial facts remain intact" do
    %{players: [local]} = FootballMarket.CatalogCase.insert_catalog!(["Existing local player"])

    assert {:ok, request} =
             Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    before = snapshot()
    Application.put_env(:football_market, Synchronization, sources: %{})
    run = Repo.get!(Run, request.run_id)

    assert :ok =
             FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
               args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
             })

    assert {:ok, failed} = Synchronization.get_run(run.id)
    assert failed.reason == "missing_configuration"
    assert snapshot() == before
    assert {:ok, readable} = FootballMarket.Catalog.get_player(local.id)
    assert readable.display_name == "Existing local player"
  end

  test "accepted fixture bytes are pinned across stable-reference edits" do
    path = Path.join(System.tmp_dir!(), "sync-fixture-" <> Ecto.UUID.generate())
    File.write!(path, File.read!("test/fixtures/synchronization/expected.exs"))
    on_exit(fn -> File.rm(path) end)

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => %{Fixtures.source() | fixture_path: path}}
    )

    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    before = snapshot()
    File.write!(path, "changed trusted fixture or reconciliation material")
    run = Repo.get!(Run, accepted.run_id)

    :ok =
      FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
        args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
      })

    assert {:ok, %{reason: "input_drift", state: "failed"}} = Synchronization.get_run(run.id)
    assert snapshot() == before
  end

  test "every trigger rechecks current scraper access without authorizing retrieval" do
    alias FootballMarket.Providers.ScrapingFixtureData, as: Data
    case_data = Data.case!("access-scoped")
    {:ok, assessment} = Agent.start_link(fn -> Data.assessment(case_data) end)
    reader = fn -> Agent.get(assessment, & &1) end
    state = Data.state(case_data, %{assessment_reader: reader})

    source = %{
      provider: {FootballMarket.Providers.Scraping, state},
      runtime: {FootballMarket.Providers.FixtureRuntime, %{}},
      fixture_path: "test/fixtures/scraping/documents.exs"
    }

    Application.put_env(:football_market, Synchronization, sources: %{"scraping" => source})

    for {code, name} <- Data.positions() do
      unless Repo.get_by(FootballMarket.Catalog.Position, code: code),
        do: FootballMarket.Catalog.create_position(%{code: code, name: name})
    end

    for trigger <- [:initial, :manual, :scheduled] do
      Agent.update(assessment, fn _ -> Data.assessment(case_data) end)

      {:ok, input} =
        FootballMarket.Synchronization.Input.normalize(Data.request(case_data),
          source_ref: "scraping",
          trigger: trigger
        )

      {:ok, accepted} = FootballMarket.Synchronization.Store.admit(input)
      Agent.update(assessment, &%{&1 | withdrawn: true})
      run = Repo.get!(Run, accepted.run_id)

      :ok =
        FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
          args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
        })

      assert {:ok, result} = Synchronization.get_run(run.id)
      assert result.state == "failed"
      assert result.outcome["category"] == "unsupported_capability"
      assert length(result.attempts) == 1
      refute_receive {:scraping_fetch, _, _}, 0
    end

    assert Repo.aggregate(FootballMarket.Catalog.Ingestion.Observation, :count) == 0
  end

  test "successful catalog publication preserves nonempty financial, quote, balance and statistics state exactly" do
    old = Application.get_env(:football_market, :initial_issuance_recipients)
    on_exit(fn -> Application.put_env(:football_market, :initial_issuance_recipients, old) end)
    market = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = FootballMarket.Market.initialize_player(market.player.id)
    stats = FootballMarket.StatisticsCase.fixture("PL", 2030)

    {:ok, match} =
      FootballMarket.Statistics.record_match(FootballMarket.StatisticsCase.match_attrs(stats))

    metrics = Map.new(FootballMarket.StatisticsCase.metrics(), &{&1, 0})

    assert {:ok, _} =
             FootballMarket.Statistics.record_performance(
               Map.merge(FootballMarket.StatisticsCase.performance_attrs(stats, match), metrics)
             )

    before = snapshot()
    assert before["market_quotes"] != []
    assert before["player_match_performances"] != []
    assert before["balance_sentinels"] != []

    for trigger <- [:initial, :manual, :scheduled] do
      {:ok, input} =
        FootballMarket.Synchronization.Input.normalize(Fixtures.scope(),
          source_ref: "fixture",
          trigger: trigger
        )

      {:ok, accepted} = FootballMarket.Synchronization.Store.admit(input)
      run = Repo.get!(Run, accepted.run_id)

      :ok =
        FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
          args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
        })

      assert {:ok, %{state: "succeeded"}} = Synchronization.get_run(run.id)
      assert snapshot() == before
    end

    source = %{
      Fixtures.source()
      | provider: {FootballMarket.IngestionFixtureAdapter, {:error, %{category: :unavailable}}}
    }

    Application.put_env(:football_market, Synchronization, sources: %{"fixture" => source})
    Process.put(:synchronization_now, ~U[2026-10-15 12:00:00.000000Z])
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")

    for now <- [
          ~U[2026-10-15 12:00:00.000000Z],
          ~U[2026-10-15 12:01:00.000000Z],
          ~U[2026-10-15 12:06:00.000000Z]
        ] do
      Process.put(:synchronization_now, now)
      run = Repo.get!(Run, accepted.run_id)

      :ok =
        FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
          args: %{"run_id" => run.id, "delivery_id" => run.delivery_id}
        })

      assert snapshot() == before
    end

    assert {:ok, %{state: "failed", reason: "exhausted"}} =
             Synchronization.get_run(accepted.run_id)

    %{rows: [[supply]]} =
      Repo.query!("SELECT sum(quantity) FROM market_holdings WHERE player_id=$1", [
        Ecto.UUID.dump!(market.player.id)
      ])

    assert supply == 100
  end

  test "raw source content and credentials never enter job arguments, errors or inspection" do
    sentinel = "credential-material-" <> Ecto.UUID.generate()

    source = %{
      Fixtures.source()
      | provider:
          {FootballMarket.Synchronization.ScriptAdapter,
           %{owner: self(), outcome: {:ok, %{password: sentinel, payload: sentinel}}}}
    }

    Application.put_env(:football_market, Synchronization, sources: %{"fixture" => source})
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    run = Repo.get!(Run, accepted.run_id)
    job = Repo.get!(Oban.Job, run.job_id)
    assert Map.keys(job.args) |> Enum.sort() == ["delivery_id", "run_id"]
    refute inspect(job) =~ sentinel
    :ok = FootballMarket.Workers.CatalogSync.perform(job)
    assert {:ok, result} = Synchronization.get_run(run.id)
    assert result.state == "failed"
    refute inspect(result) =~ sentinel
    assert Repo.get!(Oban.Job, job.id).errors == []
  end

  defp snapshot do
    tables =
      ~w(market_initial_recipients market_quotes market_holdings market_issuances matches player_match_performances)

    %{rows: [[sentinel]]} = Repo.query!("SELECT to_regclass('balance_sentinels')::text", [])
    tables = if sentinel, do: tables ++ ["balance_sentinels"], else: tables

    for table <- tables, into: %{} do
      {table,
       Ecto.Adapters.SQL.query!(
         Repo,
         "SELECT row_to_json(t)::text FROM #{table} t ORDER BY row_to_json(t)::text",
         []
       ).rows}
    end
  end
end

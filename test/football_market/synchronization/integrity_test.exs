defmodule FootballMarket.Synchronization.IntegrityTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration

  setup do
    restore = FootballMarket.IngestionFixtures.setup_primary_account!()
    on_exit(restore)
    :ok
  end

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
      assert_existing_financial_state(before, snapshot())
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

      assert_existing_financial_state(before, snapshot())
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

  test "later team-resource 503 retains retry metadata and cannot replace the accepted catalog" do
    {:ok, accepted} = Synchronization.request_catalog(Fixtures.scope(), source_ref: "fixture")
    accepted_run = Repo.get!(Run, accepted.run_id)

    :ok =
      FootballMarket.Workers.CatalogSync.perform(%Oban.Job{
        args: %{"run_id" => accepted_run.id, "delivery_id" => accepted_run.delivery_id}
      })

    before = snapshot()
    before_players = Repo.aggregate(FootballMarket.Catalog.Player, :count)
    scope = %{Fixtures.scope() | end_year: 2091}

    source = %{
      provider:
        {FootballMarket.Providers.FootballDataOrg,
         %{
           token: "runtime-only-retry-token",
           get: fn url, token, _timeout ->
             assert token == "runtime-only-retry-token"

             if URI.parse(url).path =~ "/competitions/" do
               body =
                 Jason.encode!(%{
                   "count" => 1,
                   "competition" => %{"code" => "PL"},
                   "season" => %{
                     "id" => 2090,
                     "startDate" => "2090-08-01",
                     "endDate" => "2091-05-30"
                   },
                   "teams" => [%{"id" => 65, "name" => "Arsenal"}]
                 })

               {:ok, 200, [], body}
             else
               {:ok, 503, [{"retry-after", "90"}], "{}"}
             end
           end
         }},
      identity: %{api: "football-data.org", version: "v4", season_rule: "utc-july"}
    }

    Application.put_env(:football_market, Synchronization,
      sources: %{"fixture" => Fixtures.source(), "football-data-org" => source}
    )

    assert {:ok, requested} =
             Synchronization.request_catalog(scope,
               source_ref: "football-data-org",
               policy: %{attempt_limit: 3, waits: [1, 2], worker_timeout_ms: 30_000}
             )

    run = Repo.get!(Run, requested.run_id)
    job = Repo.get!(Oban.Job, run.job_id)
    :ok = FootballMarket.Workers.CatalogSync.perform(job)

    assert {:ok, result} = Synchronization.get_run(run.id)
    assert result.state == "retry_wait"
    assert result.attempts |> hd() |> Map.get(:outcome) |> Map.get("category") == "unavailable"
    assert hd(result.attempts).outcome["retry_after_ms"] == 90_000
    assert DateTime.diff(result.next_retry_at, DateTime.utc_now(), :second) > 80
    assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == before_players
    assert snapshot() == before
    refute inspect(result) =~ "runtime-only-retry-token"
  end

  test "missing or invalid Football-Data.org credentials fail before durable admission" do
    valid = %{
      provider: {FootballMarket.Providers.FootballDataOrg, %{token: "valid-token"}},
      identity: %{api: "football-data.org", version: "v4"}
    }

    for token <- [nil, "  invalid token  "] do
      source = put_in(valid, [:provider, Access.elem(1), :token], token)

      Application.put_env(:football_market, Synchronization,
        sources: %{"football-data-org" => source}
      )

      before_jobs = Repo.aggregate(Oban.Job, :count)

      assert {:error, _} =
               Synchronization.request_catalog(Fixtures.scope(), source_ref: "football-data-org")

      assert Repo.aggregate(Oban.Job, :count) == before_jobs
    end
  end

  test "Football-Data.org initial, replay, and update publish through durable synchronization" do
    old_recipients = Application.get_env(:football_market, :initial_issuance_recipients)

    on_exit(fn ->
      Application.put_env(:football_market, :initial_issuance_recipients, old_recipients)
    end)

    market = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = FootballMarket.Market.initialize_player(market.player.id)
    statistics = FootballMarket.StatisticsCase.fixture("BL1", 2090)

    {:ok, match} =
      FootballMarket.Statistics.record_match(
        FootballMarket.StatisticsCase.match_attrs(statistics)
      )

    metrics = Map.new(FootballMarket.StatisticsCase.metrics(), &{&1, 0})

    assert {:ok, _} =
             FootballMarket.Statistics.record_performance(
               Map.merge(
                 FootballMarket.StatisticsCase.performance_attrs(statistics, match),
                 metrics
               )
             )

    unrelated_players = Enum.map(statistics.players, &{&1.id, &1.display_name})
    baseline_player_count = Repo.aggregate(FootballMarket.Catalog.Player, :count)

    {:ok, version} = Agent.start_link(fn -> 1 end)
    token = "source-only-secret-" <> Ecto.UUID.generate()

    get = fn url, received_token, _timeout ->
      assert received_token == token

      case URI.parse(url).path do
        "/v4/competitions/PL/teams" ->
          {:ok, 200, [],
           Jason.encode!(%{
             "count" => 1,
             "competition" => %{"code" => "PL"},
             "season" => %{
               "id" => 2093,
               "startDate" => "2093-08-01",
               "endDate" => "2094-05-30"
             },
             "teams" => [%{"id" => 65, "name" => "Alpha"}]
           })}

        "/v4/teams/65" ->
          squad =
            case Agent.get(version, & &1) do
              1 ->
                [
                  %{"id" => 9001, "name" => "New Catalog Player", "position" => "Goalkeeper"},
                  %{"id" => 9002, "name" => "Retained Catalog Player", "position" => "Goalkeeper"}
                ]

              2 ->
                [%{"id" => 9001, "name" => "Updated Catalog Player", "position" => "Goalkeeper"}]

              3 ->
                [
                  %{"id" => 9001, "name" => "Updated Catalog Player", "position" => "Goalkeeper"},
                  %{"id" => 9003, "name" => "Legacy Conflict Player", "position" => "Goalkeeper"}
                ]
            end

          {:ok, 200, [],
           Jason.encode!(%{"id" => 65, "name" => "Alpha", "tla" => "ALP", "squad" => squad})}
      end
    end

    source = %{
      provider: {FootballMarket.Providers.FootballDataOrg, %{token: token, get: get}},
      identity: %{api: "football-data.org", version: "v4", season_rule: "utc-july"}
    }

    Application.put_env(:football_market, Synchronization,
      sources: %{"football-data-org" => source}
    )

    scope = %{league_code: "PL", start_year: 2093, end_year: 2094}
    before_external_state = snapshot()
    assert before_external_state["market_quotes"] != []
    assert before_external_state["player_match_performances"] != []
    assert before_external_state["balance_sentinels"] != []

    {:ok, initial} =
      Synchronization.request_catalog(scope,
        source_ref: "football-data-org",
        trigger: :initial
      )

    initial_run = Repo.get!(Run, initial.run_id)
    initial_job = Repo.get!(Oban.Job, initial_run.job_id)
    assert Enum.sort(Map.keys(initial_job.args)) == ["delivery_id", "run_id"]
    refute inspect(initial_job) =~ token
    :ok = FootballMarket.Workers.CatalogSync.perform(initial_job)

    assert {:ok, %{state: "succeeded", attempts: [%{number: 1}]}} =
             Synchronization.get_run(initial_run.id)

    assert Repo.get_by!(FootballMarket.Catalog.Player, display_name: "New Catalog Player")

    player_binding =
      Repo.get_by!(FootballMarket.Catalog.Ingestion.SourceBinding,
        provider: "football-data.org-v4",
        kind: "player",
        source_id: "9001"
      )

    assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == baseline_player_count + 2
    imported_state = snapshot()
    assert_existing_financial_state(before_external_state, imported_state)

    assert length(imported_state["market_issuances"]) ==
             length(before_external_state["market_issuances"]) + 2

    refute inspect(Synchronization.get_run(initial_run.id)) =~ token

    :ok = FootballMarket.Workers.CatalogSync.perform(initial_job)
    assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == baseline_player_count + 2

    Agent.update(version, fn _ -> 2 end)

    {:ok, update} =
      Synchronization.request_catalog(scope,
        source_ref: "football-data-org",
        trigger: :manual,
        fixture_ref: "provider-update"
      )

    update_run = Repo.get!(Run, update.run_id)

    :ok =
      FootballMarket.Workers.CatalogSync.perform(Repo.get!(Oban.Job, update_run.job_id))

    assert {:ok, %{state: "succeeded"}} = Synchronization.get_run(update_run.id)
    assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == baseline_player_count + 2

    assert Repo.get_by!(FootballMarket.Catalog.Ingestion.SourceBinding,
             provider: "football-data.org-v4",
             kind: "player",
             source_id: "9002"
           )

    assert Repo.get!(FootballMarket.Catalog.Player, player_binding.player_id).display_name ==
             "Updated Catalog Player"

    assert snapshot() == imported_state
    refute inspect(Synchronization.get_run(update_run.id)) =~ token

    player = Repo.get!(FootballMarket.Catalog.Player, player_binding.player_id)

    assert {:ok, legacy} =
             FootballMarket.Catalog.create_player(%{
               team_id: player.team_id,
               position_id: player.position_id,
               catalog_identity: "unbound-legacy-player",
               display_name: "Legacy Conflict Player"
             })

    Agent.update(version, fn _ -> 3 end)

    {:ok, conflict} =
      Synchronization.request_catalog(scope,
        source_ref: "football-data-org",
        trigger: :manual,
        fixture_ref: "provider-conflict"
      )

    conflict_run = Repo.get!(Run, conflict.run_id)
    :ok = FootballMarket.Workers.CatalogSync.perform(Repo.get!(Oban.Job, conflict_run.job_id))

    assert {:ok, failed} = Synchronization.get_run(conflict_run.id)
    assert failed.state == "failed"
    assert failed.outcome["status"] == "reconciliation_conflict"

    refute Repo.get_by(FootballMarket.Catalog.Ingestion.SourceBinding,
             provider: "football-data.org-v4",
             kind: "player",
             source_id: "9003"
           )

    assert Repo.get!(FootballMarket.Catalog.Player, player_binding.player_id).display_name ==
             "Updated Catalog Player"

    assert Repo.get!(FootballMarket.Catalog.Player, legacy.id).display_name ==
             "Legacy Conflict Player"

    assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == baseline_player_count + 3
    assert snapshot() == imported_state

    assert Enum.map(statistics.players, fn player ->
             persisted = Repo.get!(FootballMarket.Catalog.Player, player.id)
             {persisted.id, persisted.display_name}
           end) == unrelated_players

    refute inspect(failed) =~ token
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

  defp assert_existing_financial_state(before, after_state) do
    market_tables = ~w(market_quotes market_holdings market_issuances)

    for table <- market_tables do
      preserved = MapSet.new(before[table])
      assert Enum.all?(preserved, &(&1 in after_state[table]))
    end

    assert Map.drop(after_state, market_tables) == Map.drop(before, market_tables)
  end
end

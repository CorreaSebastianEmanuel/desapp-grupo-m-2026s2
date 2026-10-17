defmodule FootballMarket.StatisticsIngestion.Case do
  @moduledoc "Owned committed statistics rows live only in short-lived per-test owner schema."
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.Ingestion
  alias FootballMarket.Synchronization.{Run, Attempt}
  alias FootballMarket.Catalog.Ingestion.DeliveryReceipt

  def candidate(request, options \\ []) do
    catalog = FootballMarket.IngestionFixtures.candidate("PL", request.scope.start_year)

    matches =
      Keyword.get(options, :matches, [
        %{
          ref: "match-1",
          scope: Map.take(request.scope, [:league_code, :start_year, :end_year]),
          season_ref: "season-ref",
          status: :completed,
          kickoff_at: ~U[2026-01-01 12:00:00Z],
          home_team_ref: "team-a",
          away_team_ref: "team-b"
        }
      ])

    performances =
      Keyword.get(options, :performances, [
        %{
          ref: "performance-1",
          match_ref: "match-1",
          player_ref: "player-a",
          team_ref: "team-a",
          position_ref: "GK",
          minutes_played: 90,
          counts: %{goals: 0, assists: nil}
        }
      ])

    %{
      operation: :performances,
      scope: request.scope,
      fixture_id: Keyword.get(options, :fixture_id),
      facts: Map.merge(catalog.facts, %{matches: matches, performances: performances}),
      bindings:
        catalog.bindings ++ Enum.map(matches, &%{kind: :match, ref: &1.ref, source_id: &1.ref}),
      completeness: %{
        version: 1,
        scope: request.scope,
        full_scope: true,
        terminal_witness: "test-terminal-v1",
        eligible_match_identities: Enum.map(matches, & &1.ref),
        detail_coverage: Enum.map(matches, & &1.ref),
        assessment_revision: "test-assessment-v1",
        assessment_reference: "test-fixture-source-v1",
        complete_empty: matches == []
      }
    }
  end

  def seed_catalog!(scope) do
    FootballMarket.IngestionFixtures.positions!()
    provider_scope = Map.take(scope, [:league_code, :start_year, :end_year])
    candidate = FootballMarket.IngestionFixtures.candidate(scope.league_code, scope.start_year)

    {:ok, _} =
      Ingestion.import_catalog(
        provider_scope,
        FootballMarket.IngestionFixtures.options(candidate)
      )
  end

  def provider_options(candidate) do
    [
      provider: {FootballMarket.IngestionFixtureAdapter, candidate},
      runtime: {FootballMarket.IngestionFixtureRuntime, %{instant: ~U[2026-10-16 12:00:00Z]}}
    ]
  end

  def source(candidate) do
    [provider: provider, runtime: runtime] = provider_options(candidate)

    %{
      provider: provider,
      runtime: runtime,
      fixture_path: "test/fixtures/statistics_ingestion/documents.exs"
    }
  end

  def delivery_context!(scope, options \\ []) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    active_runs =
      Repo.all(
        from r in Run,
          where:
            r.league_code == ^scope.league_code and r.start_year == ^scope.start_year and
              r.end_year == ^scope.end_year and r.state in ["queued", "executing", "retry_wait"],
          select: r.id
      )

    if active_runs != [] do
      Repo.update_all(from(a in Attempt, where: a.run_id in ^active_runs),
        set: [status: "failed", finished_at: now]
      )

      Repo.update_all(from(r in Run, where: r.id in ^active_runs),
        set: [
          state: "failed",
          reason: "fixture_replaced",
          recovery: "inspect_run",
          finished_at: now
        ]
      )
    end

    ids = %{
      run: Ecto.UUID.generate(),
      receipt: Ecto.UUID.generate(),
      attempt: Ecto.UUID.generate(),
      fence: Ecto.UUID.generate()
    }

    input = %{
      "version" => 2,
      "operation" => "statistics",
      "timeout_ms" => 5000,
      "scope" => Map.take(scope, [:league_code, :start_year, :end_year]),
      "instructions" => %{"mappings" => [], "new_players" => []}
    }

    run =
      Repo.insert!(%Run{
        id: ids.run,
        operation: "statistics",
        league_code: scope.league_code,
        start_year: scope.start_year,
        end_year: scope.end_year,
        source_ref: "fixture",
        input: input,
        input_digest: "test",
        policy: %{"attempt_limit" => 3, "waits" => [60, 300], "worker_timeout_ms" => 30_000},
        original_trigger: "manual",
        state: Keyword.get(options, :run_state, "executing"),
        requested_at: now,
        delivery_id: ids.receipt
      })

    Repo.insert!(%DeliveryReceipt{
      id: ids.receipt,
      operation: "statistics",
      fence: ids.fence,
      run_id: run.id,
      league_code: scope.league_code,
      start_year: scope.start_year,
      end_year: scope.end_year,
      state: "prepared"
    })

    Repo.insert!(%Attempt{
      id: ids.attempt,
      run_id: run.id,
      number: 1,
      delivery_id: ids.receipt,
      started_at: now,
      status: "executing"
    })

    %{receipt_id: ids.receipt, fence: ids.fence, attempt_id: ids.attempt}
  end

  @doc """
  Runs the given function against a fully migrated per-test owner schema with an
  isolated Oban instance. Committed statistics/catalog rows never touch the
  shared test database; the schema is dropped after the test. This mirrors the
  Synchronization.Case owned-store pattern and adds the full statistics
  migration chain. Spawned processes must opt into the store with
  `Repo.put_dynamic_repo(store_repo)` before using the main repo alias.
  """
  def with_statistics_store(fun) when is_function(fun, 1) do
    schema = "statistics_ingestion_store_" <> String.replace(Ecto.UUID.generate(), "-", "")

    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      Repo.query!("CREATE SCHEMA " <> schema, [])
    end)

    options =
      Repo.config()
      |> Keyword.merge(
        name: nil,
        pool: Ecto.Adapters.SQL.Sandbox,
        pool_size: 20,
        parameters: [search_path: schema]
      )

    {:ok, repo} = Repo.start_link(options)
    previous = Repo.get_dynamic_repo()

    try do
      Repo.put_dynamic_repo(repo)
      migrate_statistics_store!(schema)

      {:ok, oban} =
        Oban.start_link(
          name: FootballMarket.StatisticsIngestion.TestOban,
          repo: Repo,
          prefix: schema,
          testing: :manual,
          queues: [statistics_import: 1],
          plugins: [],
          get_dynamic_repo: fn -> repo end
        )

      sync_config = Application.get_env(:football_market, FootballMarket.Synchronization, [])

      try do
        Application.put_env(
          :football_market,
          FootballMarket.Synchronization,
          Keyword.merge(sync_config, oban_name: FootballMarket.StatisticsIngestion.TestOban)
        )

        fun.(repo)
      after
        Application.put_env(:football_market, FootballMarket.Synchronization, sync_config)
        Supervisor.stop(oban)
      end
    after
      Repo.put_dynamic_repo(previous)
      if Process.alive?(repo), do: Supervisor.stop(repo)

      Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
        Repo.query!("DROP SCHEMA " <> schema <> " CASCADE", [])
      end)
    end
  end

  defp migrate_statistics_store!(schema) do
    for {version, path} <- migrations() do
      require_migration_once!(path)
      Ecto.Migrator.up(Repo, version, module(path), prefix: schema, log: false)
    end
  end

  defp require_migration_once!(path) do
    key = {__MODULE__, :required_migrations}
    required = MapSet.new(:persistent_term.get(key, []))

    unless path in required do
      Code.require_file("priv/repo/migrations/" <> path)
      :persistent_term.put(key, MapSet.put(required, path))
    end
  end

  defp migrations do
    for path <- Path.wildcard("priv/repo/migrations/*.exs") |> Enum.sort() do
      base = Path.basename(path)
      [version, _underscore] = String.split(base, "_", parts: 2)
      {String.to_integer(version), base}
    end
  end

  defp module(path) do
    base = path |> Path.basename(".exs")
    [_version, underscore] = String.split(base, "_", parts: 2)

    String.to_existing_atom(
      "Elixir.FootballMarket.Repo.Migrations." <> Macro.camelize(underscore)
    )
  end
end

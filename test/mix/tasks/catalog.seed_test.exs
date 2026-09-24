defmodule Mix.Tasks.Catalog.SeedTest do
  use FootballMarket.DataCase, async: false

  setup do
    previous = Application.get_env(:football_market, :development_seed_enabled)
    previous_env = System.get_env("DEVELOPMENT_SEED_ENABLED")

    on_exit(fn ->
      Mix.Task.reenable("catalog.seed")

      if is_nil(previous),
        do: Application.delete_env(:football_market, :development_seed_enabled),
        else: Application.put_env(:football_market, :development_seed_enabled, previous)

      if is_nil(previous_env),
        do: System.delete_env("DEVELOPMENT_SEED_ENABLED"),
        else: System.put_env("DEVELOPMENT_SEED_ENABLED", previous_env)
    end)

    :ok
  end

  test "denies the command from checked-in capability configuration" do
    Application.put_env(:football_market, :development_seed_enabled, false)
    Mix.Task.reenable("catalog.seed")

    assert_raise Mix.Error,
                 "catalog seed failed: category=disabled entity=seed identity=development-seed",
                 fn ->
                   Mix.Tasks.Catalog.Seed.run([])
                 end
  end

  test "an operator environment variable cannot enable the command" do
    Application.put_env(:football_market, :development_seed_enabled, false)
    System.put_env("DEVELOPMENT_SEED_ENABLED", "true")
    Mix.Task.reenable("catalog.seed")

    assert_raise Mix.Error,
                 "catalog seed failed: category=disabled entity=seed identity=development-seed",
                 fn ->
                   Mix.Tasks.Catalog.Seed.run([])
                 end
  end

  test "runs explicitly and prints stable automation-oriented totals" do
    Mix.shell(Mix.Shell.Process)
    Mix.Task.reenable("catalog.seed")

    assert :ok = Mix.Tasks.Catalog.Seed.run([])

    assert_received {:mix_shell, :info,
                     [
                       "catalog seed complete: total=44 created=44 reused=0 leagues=5 seasons=5 teams=10 positions=4 players=20"
                     ]}
  end

  test "is absent from normal setup and application startup" do
    setup_alias = Mix.Project.config() |> Keyword.fetch!(:aliases) |> Keyword.fetch!(:setup)
    refute Enum.any?(setup_alias, &String.contains?(to_string(&1), "catalog.seed"))

    assert Repo.aggregate(FootballMarket.Catalog.Player, :count) == 0
  end

  test "nil and false capabilities deny unknown and production-like environments before querying" do
    test_pid = self()
    handler_id = "catalog-seed-denial-#{System.unique_integer([:positive])}"

    :telemetry.attach(
      handler_id,
      [:football_market, :repo, :query],
      fn _, _, _, _ ->
        send(test_pid, :repo_query)
      end,
      nil
    )

    on_exit(fn -> :telemetry.detach(handler_id) end)

    for denied <- [nil, false] do
      if is_nil(denied),
        do: Application.delete_env(:football_market, :development_seed_enabled),
        else: Application.put_env(:football_market, :development_seed_enabled, denied)

      Mix.Task.reenable("catalog.seed")

      assert_raise Mix.Error,
                   "catalog seed failed: category=disabled entity=seed identity=development-seed",
                   fn ->
                     Mix.Tasks.Catalog.Seed.run([])
                   end
    end

    refute_received :repo_query
  end

  test "conflict failures are nonzero, identity-aware, and redact stored and configured values" do
    alias FootballMarket.Catalog.{DevelopmentSeed, Player, Season}

    assert {:ok, _summary} = DevelopmentSeed.run()
    {:ok, league} = FootballMarket.Catalog.get_league_by_code("PL")
    season = Repo.get_by!(Season, league_id: league.id, start_year: 2026, end_year: 2027)

    {:ok, player} =
      FootballMarket.Catalog.get_player(season.id, "demo-2026-27-pl-gk")

    sentinel =
      "postgres://demo:secret@example.invalid/db 00000000-0000-0000-0000-000000000000 2026-09-23T00:00:00Z raw stacktrace"

    Repo.update_all(from(p in Player, where: p.id == ^player.id), set: [display_name: sentinel])
    Mix.Task.reenable("catalog.seed")

    error =
      assert_raise Mix.Error, fn ->
        Mix.Tasks.Catalog.Seed.run([])
      end

    assert error.message ==
             "catalog seed failed: category=conflict entity=player identity=demo-2026-27-pl-gk cause=attribute_mismatch"

    refute String.contains?(error.message, "secret")
    refute String.contains?(error.message, "example.invalid")
    refute String.contains?(error.message, "00000000")
    refute String.contains?(error.message, "2026-09-23")
    refute String.contains?(error.message, "stacktrace")
  end

  test "formats every public failure class through the explicit allowlist" do
    cases = [
      {%{category: :disabled, entity: :seed, identity: "development-seed"},
       "category=disabled entity=seed identity=development-seed"},
      {%{
         category: :validation,
         entity: :manifest,
         identity: "development-seed",
         cause: :invalid_manifest
       }, "category=validation entity=manifest identity=development-seed cause=invalid_manifest"},
      {%{category: :conflict, entity: :league, identity: "PL", cause: :alternate_identity},
       "category=conflict entity=league identity=PL cause=alternate_identity"},
      {%{
         category: :conflict,
         entity: :team,
         identity: "PL:2026-2027:DEMO-PL-A",
         cause: :misplaced_relationship
       },
       "category=conflict entity=team identity=PL:2026-2027:DEMO-PL-A cause=misplaced_relationship"},
      {%{
         category: :conflict,
         entity: :player,
         identity: "demo-2026-27-pl-gk",
         cause: :attribute_mismatch
       }, "category=conflict entity=player identity=demo-2026-27-pl-gk cause=attribute_mismatch"},
      {%{
         category: :conflict,
         entity: :player,
         identity: "demo-2026-27-pl-gk",
         cause: :relationship_mismatch
       },
       "category=conflict entity=player identity=demo-2026-27-pl-gk cause=relationship_mismatch"},
      {%{
         category: :persistence,
         entity: :player,
         identity: "demo-2026-27-fl1-fwd",
         cause: :database
       }, "category=persistence entity=player identity=demo-2026-27-fl1-fwd cause=database"},
      {%{
         category: :persistence,
         entity: :team,
         identity: "PL:2026-2027:DEMO-PL-A",
         cause: :write_failed
       }, "category=persistence entity=team identity=PL:2026-2027:DEMO-PL-A cause=write_failed"},
      {%{
         category: :persistence,
         entity: :league,
         identity: "PL",
         cause: :concurrent_write
       }, "category=persistence entity=league identity=PL cause=concurrent_write"},
      {%{
         category: :persistence,
         entity: :seed,
         identity: "development-seed",
         cause: :database_unavailable
       }, "category=persistence entity=seed identity=development-seed cause=database_unavailable"}
    ]

    for {error, expected} <- cases do
      assert Mix.Tasks.Catalog.Seed.format_error(error) == "catalog seed failed: " <> expected
    end
  end

  test "maps unknown internal failures to one safe public error" do
    sentinel = "postgres://user:secret@example.invalid/private"

    for error <- [
          %{category: :internal, entity: :player, identity: sentinel, cause: :unexpected},
          %{category: :conflict, entity: :player, identity: sentinel, cause: :unexpected},
          %{
            category: :conflict,
            entity: :player,
            identity: sentinel,
            cause: :attribute_mismatch
          },
          %{raw_exception: sentinel}
        ] do
      assert Mix.Tasks.Catalog.Seed.format_error(error) ==
               "catalog seed failed: category=persistence entity=seed identity=development-seed cause=write_failed"
    end
  end
end

defmodule Mix.Tasks.Catalog.SeedProcessTest do
  use ExUnit.Case, async: false

  alias Ecto.Adapters.SQL.Sandbox
  alias FootballMarket.Catalog.{League, Player, Position, Season, Team}
  alias FootballMarket.Repo

  setup do
    owner = Sandbox.start_owner!(Repo, shared: false, sandbox: false)
    clear_catalog()

    on_exit(fn ->
      Sandbox.stop_owner(owner)
      Sandbox.unboxed_run(Repo, &clear_catalog/0)
    end)

    :ok
  end

  test "the complete real CLI output contains no SQL values or internal identifiers" do
    database = Application.fetch_env!(:football_market, Repo) |> Keyword.fetch!(:database)

    {output, status} =
      System.cmd("mix", ["catalog.seed"],
        cd: File.cwd!(),
        env: [{"MIX_ENV", "dev"}, {"POSTGRES_DB", database}],
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "catalog seed complete: total=44 created=44 reused=0"
    refute output =~ "INSERT INTO"

    refute output =~
             ~r/\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\b/i

    refute output =~ "demo-2026-27-pl-gk"
  end

  test "an unknown MIX_ENV fails with the capability error instead of a config file error" do
    {output, status} =
      System.cmd("mix", ["catalog.seed"],
        cd: File.cwd!(),
        env: [{"MIX_ENV", "unknown"}],
        stderr_to_stdout: true
      )

    assert status != 0
    assert output =~ "category=disabled entity=seed identity=development-seed"
    refute output =~ "File.Error"
    refute output =~ "unknown.exs"
  end

  test "production fails with the capability error before runtime secrets or database startup" do
    {output, status} =
      System.cmd("mix", ["catalog.seed"],
        cd: File.cwd!(),
        env: [{"MIX_ENV", "prod"}],
        stderr_to_stdout: true
      )

    assert status != 0
    assert output =~ "category=disabled entity=seed identity=development-seed"
    refute output =~ "DATABASE_URL"
    refute output =~ "SECRET_KEY_BASE"
  end

  test "an unreachable database returns only a sanitized allowlisted Mix error" do
    {output, status} =
      System.cmd("mix", ["catalog.seed"],
        cd: File.cwd!(),
        env: [
          {"MIX_ENV", "dev"},
          {"POSTGRES_HOST", "127.0.0.1"},
          {"POSTGRES_PORT", "1"},
          {"POSTGRES_USER", "sentinel-user"},
          {"POSTGRES_PASSWORD", "sentinel-password"},
          {"POSTGRES_DB", "sentinel-database"}
        ],
        stderr_to_stdout: true
      )

    assert status != 0

    assert output =~
             "catalog seed failed: category=persistence entity=seed identity=development-seed cause=database_unavailable"

    refute output =~ "127.0.0.1"
    refute output =~ "sentinel"
    refute output =~ "connection refused"
    refute output =~ "DBConnection"
    refute output =~ "Postgrex"
    refute output =~ "stacktrace"
    refute output =~ "lib/mix/tasks/catalog.seed.ex"
    refute output =~ "inotify-tools"
    refute output =~ "You don't need to worry"
  end

  defp clear_catalog do
    Repo.delete_all(Player)
    Repo.delete_all(Team)
    Repo.delete_all(Season)
    Repo.delete_all(Position)
    Repo.delete_all(League)
  end
end

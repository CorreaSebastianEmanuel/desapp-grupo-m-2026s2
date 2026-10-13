defmodule FootballMarket.ValuationConfigurationCase do
  @moduledoc "Explicit fixtures and committed private-schema/fresh-runtime probes."
  import ExUnit.Assertions
  alias FootballMarket.{Repo, ValuationCase}
  alias FootballMarket.Valuation.Evidence

  def inventory do
    [
      "lib/football_market/valuation/configurations.ex",
      "lib/football_market/valuation/configurations/registry.ex",
      "lib/football_market/valuation/configurations/rules.ex",
      "lib/football_market/valuation/configurations/codec.ex",
      "lib/football_market/valuation/configurations/version.ex",
      "lib/football_market/valuation/configurations/selection_lock.ex",
      "lib/football_market/valuation/configurations/selection_change.ex",
      "lib/football_market/valuation/configurations/store.ex",
      "lib/football_market/valuation/managed.ex",
      "lib/football_market/valuation/managed_types.ex",
      "priv/repo/migrations/20261013000000_create_valuation_configurations.exs",
      "lib/football_market/valuation.ex",
      "lib/football_market/valuation/request.ex",
      "test/support/valuation_configuration_case.ex",
      "test/football_market/valuation/configurations/rules_test.exs",
      "test/football_market/valuation/configurations/codec_test.exs",
      "test/football_market/valuation/configurations/storage_test.exs",
      "test/football_market/valuation/configurations/activation_test.exs",
      "test/football_market/valuation/configurations/concurrency_test.exs",
      "test/football_market/valuation/configurations/durability_test.exs",
      "test/football_market/valuation/configurations/immutability_test.exs",
      "test/football_market/valuation/configurations/managed_test.exs",
      "test/football_market/valuation/configurations/outcomes_test.exs",
      "test/football_market/valuation/configurations/replay_test.exs",
      "test/football_market/valuation/configurations/canonical_test.exs",
      "test/football_market/valuation/configurations/scope_test.exs",
      "test/football_market/catalog/constraints_test.exs",
      "test/football_market/accounts/persistence_test.exs",
      "test/football_market/catalog/player_catalog_index_test.exs",
      "test/football_market/catalog/ingestion/publication_test.exs",
      "test/football_market/valuation/scope_test.exs",
      "test/football_market/statistics/scope_test.exs",
      "test/football_market/providers/scope_test.exs"
    ]
  end

  def rules(position, strategy \\ "balanced", weights \\ %{goals: 2}, refs \\ %{goals: 2}) do
    weights =
      if strategy == "position_aware",
        do: Map.new([:goalkeeper, :defender, :midfielder, :forward], &{&1, weights}),
        else: weights

    %{
      strategy_id: strategy,
      formula_version: "1",
      config: %{weights: weights},
      references: refs,
      position_mapping: [{position, :defender}]
    }
  end

  def subject(f),
    do: Map.take(ValuationCase.request(f), [:player_id, :season_id, :week_start, :week_end])

  def canonical(value), do: Evidence.canonical(value)

  # The inherited trim_identity utility explicitly targets the default Repo.
  # Private-schema fixtures use the same Input/changeset/DB acceptance rules
  # directly, so every read/write remains on the owned namespace connection.
  def record(f, identity, attrs \\ %{}) do
    alias FootballMarket.Statistics.{Input, Match, Performance}
    alias FootballMarket.StatisticsCase

    {:ok, {match, performance}} =
      Repo.transaction(fn ->
        {:ok, input} =
          Input.match(
            StatisticsCase.match_attrs(f, %{
              match_identity: identity,
              kickoff_at: "2026-10-06T12:00:00Z"
            })
          )

        match = input |> Match.changeset(f.season) |> Repo.insert!()
        {:ok, input} = Input.performance(StatisticsCase.performance_attrs(f, match, attrs))
        performance = input |> Performance.changeset(match) |> Repo.insert!()
        {match, performance}
      end)

    {match, performance}
  end

  def barrier(owner, ref, payload) do
    send(owner, {ref, self(), payload})

    receive do
      {^ref, :go} -> :ok
    after
      5000 -> raise "valuation readiness barrier timed out"
    end
  end

  def private_schema do
    config = Repo.config()
    assert config[:database] == "football_market_test" <> System.get_env("MIX_TEST_PARTITION", "")
    schema = "valuation_test_" <> String.replace(Ecto.UUID.generate(), "-", "")

    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      Repo.query!("CREATE SCHEMA " <> schema)
    end)

    {:ok, pid} = client(schema)
    previous = Repo.put_dynamic_repo(pid)
    Ecto.Migrator.run(Repo, "priv/repo/migrations", :up, all: true, prefix: schema, log: false)

    ExUnit.Callbacks.on_exit(fn ->
      Repo.put_dynamic_repo(previous)
      if Process.alive?(pid), do: Supervisor.stop(pid)
    end)

    %{schema: schema, repo: pid}
  end

  def client(schema) do
    assert Regex.match?(~r/^valuation_test_[a-f0-9]+$/, schema)

    {:ok, pid} =
      Repo.start_link(
        name: nil,
        pool: DBConnection.ConnectionPool,
        pool_size: 4,
        parameters: [search_path: schema]
      )

    Process.unlink(pid)
    {:ok, pid}
  end

  def in_client(schema, fun) do
    {:ok, pid} = client(schema)
    previous = Repo.put_dynamic_repo(pid)

    try do
      fun.()
    after
      Repo.put_dynamic_repo(previous)
      Supervisor.stop(pid)
    end
  end

  def fresh(schema, code, payload \\ nil) do
    path = Path.join(System.tmp_dir!(), "valuation-envelope-" <> Ecto.UUID.generate())
    File.write!(path, :erlang.term_to_binary(payload))

    try do
      script = """
      import ExUnit.Assertions
      alias FootballMarket.{Repo, Valuation, ValuationCase, ValuationConfigurationCase}
      alias FootballMarket.Valuation.Configurations
      {:ok, client} = ValuationConfigurationCase.client(#{inspect(schema)})
      Repo.put_dynamic_repo(client)
      Application.put_env(:football_market, FootballMarket.Providers, provider: nil, positions: nil)
      Code.ensure_loaded!(FootballMarket.Valuation.Configurations.SelectionChange)
      Code.ensure_loaded!(Ecto.Schema.Metadata)
      for module <- [FootballMarket.Valuation.ManagedDescriptor, FootballMarket.Valuation.Descriptor,
        FootballMarket.Valuation.Request, FootballMarket.Valuation.Fact,
        FootballMarket.Valuation.ScopeInputs, FootballMarket.Valuation.Evidence] do
        Code.ensure_loaded!(module)
      end
      payload = :erlang.binary_to_term(File.read!(#{inspect(path)}), [:safe])
      #{code}
      IO.puts("VALUATION_FRESH_PASS")
      """

      {out, status} =
        System.cmd("mix", ["run", "--no-compile", "-e", script],
          env: [{"MIX_ENV", "test"}],
          stderr_to_stdout: true
        )

      assert status == 0, "fresh BEAM failed: " <> String.slice(out, -2500, 2500)
      assert out =~ "VALUATION_FRESH_PASS"
    after
      File.rm!(path)
    end
  end
end

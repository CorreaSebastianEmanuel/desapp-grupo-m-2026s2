defmodule FootballMarket.Providers.ScopeTest do
  use ExUnit.Case, async: false
  @moduletag :integration
  alias FootballMarket.Providers.{Request, Result, Player, Performance, Match}

  @production [
    "lib/football_market/providers.ex"
    | Enum.map(
        ~w(adapter types request instant error validator catalog performances provenance runner runtime),
        &"lib/football_market/providers/#{&1}.ex"
      )
  ]
  @scraping_production [
    "lib/football_market/providers/scraping.ex"
    | Enum.map(
        ~w(assessment source translator transport disabled_transport fixture_transport),
        &"lib/football_market/providers/scraping/#{&1}.ex"
      )
  ]
  test "FR-014 AST dependencies stay pure, read-only and within planned production paths" do
    for path <- @production ++ @scraping_production do
      source = File.read!(path)
      ast = Code.string_to_quoted!(source)

      Macro.prewalk(ast, fn
        {:__aliases__, _, [:FootballMarket | rest]} = node ->
          assert List.first(rest) == :Providers,
                 "#{path} leaks a domain/persistence/web dependency"

          node

        {:__aliases__, _, [module | _]} = node ->
          refute module in [
                   :Ecto,
                   :Repo,
                   :Phoenix,
                   :Req,
                   :HTTPoison,
                   :Finch,
                   :Redix,
                   :Postgrex,
                   :File,
                   :Port,
                   :Task
                 ],
                 "#{path} introduces a forbidden dependency"

          node

        {{:., _, [{:__aliases__, _, [:System]}, :cmd]}, _, _} ->
          flunk("external process in #{path}")

        node ->
          node
      end)

      refute source =~ ~r/\b(retry|backoff|fallback|score|quote|trade|ranking|cache)\s*\(/

      if Path.basename(path) != "runtime.ex",
        do: refute(source =~ ~r/\bspawn(?:_link|_monitor)?\(/)
    end

    {merge_head, merge_status} = System.cmd("git", ["rev-parse", "--verify", "MERGE_HEAD"])
    base = if merge_status == 0, do: String.trim(merge_head), else: "HEAD"
    {diff, 0} = System.cmd("git", ["diff", base, "--name-only"])
    {untracked, 0} = System.cmd("git", ["ls-files", "--others", "--exclude-standard"])
    changed = String.split(diff <> untracked, "\n", trim: true) |> Enum.uniq()

    production =
      Enum.filter(changed, fn path ->
        String.starts_with?(path, ["lib/", "config/", "priv/repo/migrations/"]) or
          path in ["mix.exs", "mix.lock"]
      end)

    active_feature = FootballMarket.WorkflowScope.active_feature()

    # This feature consumes Providers without modifying provider production.
    # Its independently planned catalog paths must not look like provider leaks.
    ingestion_paths =
      if active_feature == "specs/057-idempotent-catalog-ingestion" do
        [
          "lib/football_market/catalog/ingestion.ex",
          "lib/football_market/catalog/ingestion/canonical.ex",
          "lib/football_market/catalog/ingestion/reconciler.ex",
          "lib/football_market/catalog/ingestion/publisher.ex",
          "lib/football_market/catalog/ingestion/outcome.ex",
          "lib/football_market/catalog/ingestion/scope.ex",
          "lib/football_market/catalog/ingestion/source_binding.ex",
          "lib/football_market/catalog/ingestion/observation.ex",
          "lib/football_market/catalog/ingestion/observation_binding.ex",
          "priv/repo/migrations/20261008000000_create_catalog_ingestion_tables.exs",
          "priv/repo/migrations/20261008000100_make_team_business_keys_deferrable.exs"
        ]
      else
        []
      end

    assert is_nil(active_feature) or
             Enum.all?(
               production,
               &(&1 in (@production ++
                          @scraping_production ++
                          ingestion_paths ++
                          valuation_paths(active_feature) ++
                          market_paths(active_feature) ++
                          synchronization_paths(active_feature) ++
                          FootballMarket.BrowserSessionCase.shell_paths(active_feature)) or
                   &1 == "mix.exs" or
                   &1 == "config/credo_inventory.json" or
                   FootballMarket.WorkflowScope.allows_path?(active_feature, &1))
             )

    assert Enum.sort(
             Path.wildcard("lib/football_market/providers/**/*.ex") ++
               ["lib/football_market/providers.ex"]
           ) == Enum.sort(@production ++ @scraping_production)
  end

  test "league parity and plain DTO fields preserve catalog and financial boundaries" do
    assert Request.leagues() == Map.new(FootballMarket.Catalog.supported_leagues())

    for module <- [Result, Player, Performance, Match] do
      refute function_exported?(module, :__schema__, 1)
      keys = module.__struct__() |> Map.keys()

      refute Enum.any?(
               [
                 :id,
                 :catalog_identity,
                 :score,
                 :money,
                 :price,
                 :token_supply,
                 :rating,
                 :headers,
                 :url
               ],
               &(&1 in keys)
             )
    end
  end

  test "Mix changes preserve discovery and permit only the committed synchronization dependency" do
    expected = [
      "test/provider_contract_offline.exs",
      "test/scraping_adapter_offline.exs",
      "test/fixtures/scraping/cases.exs",
      "test/fixtures/scraping/documents.exs",
      "test/fixtures/scraping/expected.exs",
      "test/fixtures/scraping/inventory.exs",
      "test/fixtures/providers/cases.exs",
      "test/fixtures/providers/expected.exs",
      "test/fixtures/providers/source_a.exs",
      "test/fixtures/providers/source_b.exs",
      "test/fixtures/synchronization/expected.exs",
      "test/fixtures/statistics_ingestion/documents.exs",
      "test/fixtures/statistics_ingestion/expected.exs",
      "test/fixtures/statistics_ingestion/inventory.exs"
    ]

    assert Enum.sort(Mix.Project.config()[:test_ignore_filters] || []) == Enum.sort(expected)
    {original, 0} = System.cmd("git", ["show", "HEAD:mix.exs"])

    # The accepted dependency remains valid in CI and in later feature sessions.
    # Local session metadata is ignored by Git and cannot authorize a dependency.
    plan = File.read!("specs/063-scheduled-synchronization-jobs/plan.md")
    assert plan =~ "introduce open-source Oban `~> 2.24.2`"

    strip = fn text ->
      text
      |> strip_approved_application_coverage()
      |> Code.string_to_quoted!()
      |> Macro.prewalk(fn
        {:defp, meta, [{:deps, call_meta, args}, [do: deps]]} when is_list(deps) ->
          {:defp, meta, [{:deps, call_meta, args}, [do: strip_approved_dependencies(deps)]]}

        list when is_list(list) ->
          if Keyword.keyword?(list),
            do: list |> Keyword.delete(:test_ignore_filters) |> Keyword.delete(:"test.e2e"),
            else: list

        node ->
          node
      end)
      |> Macro.to_string()
    end

    current = File.read!("mix.exs")
    assert strip.(current) == strip.(original)

    assert {:oban, "~> 2.24.2"} in Mix.Project.config()[:deps]
    assert {:credo, "1.7.19", only: [:dev, :test], runtime: false} in Mix.Project.config()[:deps]

    for changed <- [
          String.replace(
            current,
            "application-coverage-conflicts-with-cp1",
            "missing-conflict-guard"
          ),
          String.replace(current, "summary: [threshold: 0]", "summary: [threshold: 99]"),
          String.replace(current, "\"1.7.19\"", "\"~> 1.7.19\""),
          String.replace(current, "runtime: false", "runtime: true"),
          String.replace(
            current,
            "{:credo, \"1.7.19\", only: [:dev, :test], runtime: false}",
            "{:credo, \"1.7.19\", only: [:dev], runtime: false}"
          ),
          String.replace(current, "{:oban, \"~> 2.24.2\"}", "{:oban, \"~> 2.25\"}"),
          String.replace(
            current,
            "{:oban, \"~> 2.24.2\"}",
            "{:oban, \"~> 2.24.2\"}, {:oban, \"~> 2.24.2\"}"
          ),
          String.replace(current, "{:ecto_sql, \"~> 3.13\"}", "{:ecto_sql, \"~> 3.14\"}")
        ] do
      refute changed == current
      refute strip.(changed) == strip.(original)
    end

    assert Enum.all?(
             Path.wildcard("test/football_market/providers/*_test.exs"),
             &(&1 not in expected)
           )
  end

  # Accept only the complete, exact TASK-067 output override and conflict guard.
  # All other Mix AST, including filters, threshold and dependencies, remains compared.
  defp strip_approved_application_coverage(text) do
    block =
      "    application_output = System.get_env(\"APPLICATION_COVERAGE_DIR\")\n\n    if application_output &&\n         (System.get_env(\"CP1_PROFILE_COVERAGE\") == \"1\" ||\n            System.get_env(\"CP1_COVERAGE_OUTPUT\")) do\n      raise \"application-coverage-conflicts-with-cp1\"\n    end\n\n"

    output =
      "      output: application_output || System.get_env(\"CP1_COVERAGE_OUTPUT\", \"cover/cp1/staging\"),"

    if length(:binary.matches(text, block)) == 1 and length(:binary.matches(text, output)) == 1 do
      text
      |> String.replace(block, "")
      |> String.replace(
        output,
        "      output: System.get_env(\"CP1_COVERAGE_OUTPUT\", \"cover/cp1/staging\"),"
      )
    else
      text
    end
  end

  defp strip_approved_dependencies(deps) do
    credo =
      Enum.find(
        deps,
        &match?({:{}, _, [:credo, "1.7.19", [only: [:dev, :test], runtime: false]]}, &1)
      )

    deps |> List.delete({:oban, "~> 2.24.2"}) |> List.delete(credo)
  end

  # Exact active TASK-022 inventory; all legacy constraints remain enforced.
  def valuation_paths(active_feature) do
    case active_feature do
      "specs/061-valuation-strategy-versioning" ->
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

      "specs/060-position-aware-valuation" ->
        [
          "lib/football_market/valuation/position_aware.ex",
          "test/support/position_aware_case.ex",
          "test/football_market/valuation/position_aware/config_test.exs",
          "test/football_market/valuation/position_aware/formula_test.exs",
          "test/football_market/valuation/position_aware/mixed_test.exs",
          "test/football_market/valuation/position_aware/outcomes_test.exs",
          "test/football_market/valuation/position_aware/arithmetic_test.exs",
          "test/football_market/valuation/position_aware/replay_test.exs",
          "test/football_market/valuation/position_aware/selection_test.exs",
          "test/football_market/valuation/position_aware/scope_test.exs",
          "test/football_market/valuation/scope_test.exs",
          "test/football_market/statistics/scope_test.exs",
          "test/football_market/providers/scope_test.exs"
        ]

      "specs/059-balanced-valuation-strategy" ->
        [
          "lib/football_market/valuation/balanced.ex",
          "lib/football_market/valuation/decimal_math.ex",
          "test/football_market/valuation/balanced/config_test.exs",
          "test/football_market/valuation/balanced/formula_test.exs",
          "test/football_market/valuation/balanced/outcomes_test.exs",
          "test/football_market/valuation/balanced/arithmetic_test.exs",
          "test/football_market/valuation/balanced/replay_test.exs",
          "test/football_market/valuation/balanced/scope_test.exs",
          "test/football_market/valuation/scope_test.exs",
          "test/football_market/statistics/scope_test.exs",
          "test/football_market/providers/scope_test.exs"
        ]

      "specs/058-valuation-contract-normalization" ->
        [
          "lib/football_market/valuation.ex",
          "lib/football_market/valuation/types.ex",
          "lib/football_market/valuation/error.ex",
          "lib/football_market/valuation/request.ex",
          "lib/football_market/valuation/week.ex",
          "lib/football_market/valuation/statistics_reader.ex",
          "lib/football_market/valuation/preparation.ex",
          "lib/football_market/valuation/position_groups.ex",
          "lib/football_market/valuation/decimal_math.ex",
          "lib/football_market/valuation/scorer.ex",
          "lib/football_market/valuation/scoring.ex",
          "lib/football_market/valuation/evidence.ex",
          "lib/football_market/valuation/replay.ex",
          "test/support/valuation_case.ex",
          "test/support/valuation_scorers.ex",
          "test/football_market/valuation/contract_test.exs",
          "test/football_market/valuation/week_test.exs",
          "test/football_market/valuation/normalization_test.exs",
          "test/football_market/valuation/history_test.exs",
          "test/football_market/valuation/missing_data_test.exs",
          "test/football_market/valuation/outcomes_test.exs",
          "test/football_market/valuation/position_groups_test.exs",
          "test/football_market/valuation/scoring_test.exs",
          "test/football_market/valuation/replay_test.exs",
          "test/football_market/valuation/canonical_test.exs",
          "test/football_market/valuation/matrix_test.exs",
          "test/football_market/valuation/scope_test.exs",
          "test/football_market/statistics/scope_test.exs",
          "test/football_market/providers/scope_test.exs"
        ]

      _ ->
        []
    end
  end

  def market_paths(active_feature) do
    if active_feature == "specs/062-initial-player-token-issuance" do
      [
        "config/config.exs",
        "lib/football_market/market.ex",
        "priv/repo/migrations/20261014000000_create_initial_player_issuance.exs",
        "test/support/market_case.ex",
        "test/football_market/statistics/scope_test.exs",
        "test/football_market/providers/scope_test.exs",
        "lib/football_market/market/input.ex",
        "lib/football_market/market/consistency.ex",
        "lib/football_market/market/error.ex",
        "lib/football_market/market/store.ex",
        "lib/football_market/market/initialization_lock.ex",
        "lib/football_market/market/initial_recipient.ex",
        "lib/football_market/market/holding.ex",
        "lib/football_market/market/quote.ex",
        "lib/football_market/market/issuance.ex",
        "test/football_market/market/input_test.exs",
        "test/football_market/market/consistency_test.exs",
        "test/football_market/market/issuance_test.exs",
        "test/football_market/market/storage_test.exs",
        "test/football_market/market/durability_test.exs",
        "test/football_market/market/retry_test.exs",
        "test/football_market/market/concurrency_test.exs",
        "test/football_market/market/rollback_test.exs",
        "test/football_market/market/rejection_test.exs",
        "test/football_market/market/scope_test.exs"
      ]
    else
      []
    end
  end

  def synchronization_paths(feature) do
    if feature == "specs/063-scheduled-synchronization-jobs" do
      [
        "lib/football_market/synchronization.ex",
        "lib/football_market/synchronization/input.ex",
        "lib/football_market/synchronization/policy.ex",
        "lib/football_market/synchronization/clock.ex",
        "lib/football_market/synchronization/run.ex",
        "lib/football_market/synchronization/attempt.ex",
        "lib/football_market/synchronization/trigger.ex",
        "lib/football_market/synchronization/schedule.ex",
        "lib/football_market/synchronization/occurrence.ex",
        "lib/football_market/synchronization/store.ex",
        "lib/football_market/synchronization/execution_guard.ex",
        "lib/football_market/synchronization/scheduler.ex",
        "lib/football_market/synchronization/recovery.ex",
        "lib/football_market/synchronization/dispatcher.ex",
        "lib/football_market/workers/catalog_sync.ex",
        "lib/football_market/catalog/ingestion/delivery_receipt.ex",
        "config/synchronization.exs",
        "priv/repo/migrations/20261015000000_add_oban.exs",
        "priv/repo/migrations/20261015000100_create_synchronization_ledgers.exs",
        "priv/repo/migrations/20261015000200_create_catalog_delivery_receipts.exs",
        "test/support/synchronization/case.ex",
        "test/support/synchronization/clock.ex",
        "test/support/synchronization/fixtures.ex",
        "test/support/synchronization/runtime_probe.ex",
        "test/fixtures/synchronization/expected.exs",
        "test/football_market/synchronization/input_test.exs",
        "test/football_market/synchronization/policy_test.exs",
        "test/football_market/synchronization/migration_test.exs",
        "test/football_market/synchronization/request_test.exs",
        "test/football_market/synchronization/inspection_test.exs",
        "test/football_market/synchronization/scheduler_test.exs",
        "test/football_market/synchronization/concurrency_test.exs",
        "test/football_market/synchronization/retry_test.exs",
        "test/football_market/synchronization/recovery_test.exs",
        "test/football_market/synchronization/integrity_test.exs",
        "test/football_market/synchronization/scope_test.exs",
        "test/football_market/catalog/ingestion/delivery_receipt_test.exs",
        "test/football_market/catalog/query_test.exs",
        "mix.exs",
        "mix.lock",
        "lib/football_market/application.ex",
        "config/runtime.exs",
        "config/test.exs",
        "lib/football_market/catalog/ingestion.ex",
        "lib/football_market/catalog/ingestion/publisher.ex",
        "test/football_market/providers/scope_test.exs",
        "test/football_market/statistics/scope_test.exs",
        "test/football_market/market/scope_test.exs"
      ]
    else
      []
    end
  end
end

defmodule FootballMarket.Statistics.ScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Statistics.{Input, Match, Performance}

  test "FR-013 context contract has no web provider cache or financial dependency" do
    files = [
      "lib/football_market/statistics.ex"
      | Path.wildcard("lib/football_market/statistics/*.ex")
        |> Enum.reject(&(&1 == "lib/football_market/statistics/ingestion.ex"))
    ]

    assert length(files) == 7

    for path <- files do
      source = File.read!(path)

      refute Regex.match?(
               ~r/FootballMarketWeb|FootballMarket\.(Providers|Valuation|Quotes|Trading|Cache)|\b(Finch|Req|Redix|HTTPoison)\b/,
               source
             ),
             path
    end

    project_root = Mix.Project.project_file() |> Path.dirname() |> Path.expand()

    contract_path =
      Path.join(project_root, "specs/054-player-match-statistics/contracts/statistics-context.md")

    assert File.read!(contract_path) =~ "No HTTP route"

    forbidden = [:score, :weight, :price, :money, :provider_id, :rating, :provenance]

    for module <- [Match, Performance], field <- forbidden do
      refute field in module.__schema__(:fields)
    end

    for field <- forbidden do
      assert {:error, %{reason: :unsupported_field}} = Input.performance(%{field => 1})
      assert {:error, %{reason: :unsupported_field}} = Input.match(%{field => 1})
    end
  end

  test "product edits stay within plan boundary" do
    changed =
      product_change_lines(["lib", "priv", "test", ".github/workflows"])

    allowed = [
      "lib/football_market/statistics.ex",
      "lib/football_market/statistics/",
      "priv/repo/migrations/20261003000000_create_match_statistics.exs",
      "priv/repo/migrations/20261004000000_align_statistics_identity_whitespace.exs",
      "lib/football_market/catalog/team.ex",
      "lib/football_market/catalog/season.ex",
      "lib/football_market/catalog/position.ex",
      "test/support/statistics_case.ex",
      "test/support/catalog_concurrency_case.ex",
      "test/football_market/catalog/constraints_test.exs",
      "test/football_market/statistics/"
    ]

    active_feature = FootballMarket.WorkflowScope.active_feature()

    # TASK-016 adds an independent read-only provider boundary. Retain this
    # task's original allowlist and permit only that active plan's exact files.
    provider_paths =
      if active_feature == "specs/016-external-football-provider-contract" do
        [
          "lib/football_market/providers.ex",
          "test/provider_contract_offline.exs",
          "test/support/provider_contract_case.ex"
        ] ++
          Enum.map(
            ~w(adapter types request instant error validator catalog performances provenance runner runtime),
            &"lib/football_market/providers/#{&1}.ex"
          ) ++
          Enum.map(
            ~w(fixture_data fixture_source_a fixture_source_b fixture_runtime fact_oracle),
            &"test/support/providers/#{&1}.ex"
          ) ++
          Enum.map(~w(cases source_a source_b expected), &"test/fixtures/providers/#{&1}.exs") ++
          Enum.map(
            ~w(request catalog_contract performance_contract deadline error_safety equivalence fixture_matrix fixture_preservation catalog_isolation scope),
            &"test/football_market/providers/#{&1}_test.exs"
          )
      else
        []
      end

    scraper_paths =
      if active_feature == "specs/056-football-scraping-adapter" do
        [
          "lib/football_market/providers/scraping.ex",
          "lib/football_market/providers/adapter.ex",
          "lib/football_market/providers/runner.ex",
          "test/scraping_adapter_offline.exs",
          "test/support/providers/scraping_fixture_data.ex",
          "test/support/providers/fixture_source_a.ex",
          "test/scripts/workflow_artifact_probe_test.py",
          "test/ci/coverage_report_contract_test.exs",
          ".github/workflows/quality-baseline.yml",
          "test/football_market/providers/scope_test.exs"
        ] ++
          Enum.map(
            ~w(assessment source translator transport disabled_transport fixture_transport),
            &"lib/football_market/providers/scraping/#{&1}.ex"
          ) ++
          Enum.map(~w(cases documents expected inventory), &"test/fixtures/scraping/#{&1}.exs") ++
          Enum.map(
            ~w(assessment catalog performances safety deadline matrix equivalence isolation),
            &"test/football_market/providers/scraping/#{&1}_test.exs"
          )
      else
        []
      end

    # The active catalog ingestion plan has an independent domain/persistence
    # boundary. Only its exact paths are added; statistics ownership is unchanged.
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
          "priv/repo/migrations/20261008000100_make_team_business_keys_deferrable.exs",
          "test/support/ingestion_fixtures.ex",
          "test/football_market/catalog/ingestion/canonical_test.exs",
          "test/football_market/catalog/ingestion/reconciliation_test.exs",
          "test/football_market/catalog/ingestion/publication_test.exs",
          "test/football_market/catalog/ingestion/identity_test.exs",
          "test/football_market/catalog/ingestion/replay_test.exs",
          "test/football_market/catalog/ingestion/concurrency_test.exs",
          "test/football_market/catalog/ingestion/retention_test.exs",
          "test/football_market/catalog/ingestion/outcome_test.exs",
          "test/football_market/catalog/ingestion/isolation_test.exs",
          "test/football_market/catalog/ingestion/matrix_test.exs",
          "test/football_market/providers/scope_test.exs"
        ]
      else
        []
      end

    statistics_ingestion_paths =
      if active_feature == "specs/065-statistics-ingestion-pipeline" do
        [
          "docs/adr/0028-atomic-statistics-ingestion-and-position-evidence.md",
          "lib/football_market/catalog/ingestion/delivery_receipt.ex",
          "lib/football_market/synchronization.ex",
          "lib/football_market/synchronization/delivery_receipt.ex",
          "lib/football_market/valuation/calculation_requests.ex",
          "lib/football_market/workers/calculation_dispatch.ex",
          "lib/football_market/workers/statistics_import.ex",
          "priv/repo/migrations/20261016000100_extend_statistics_position_evidence.exs",
          "priv/repo/migrations/20261016000200_create_statistics_ingestion.exs",
          "priv/repo/migrations/20261016000300_extend_synchronization_operations.exs",
          "test/support/ingestion_fixtures.ex",
          "test/support/statistics_ingestion/",
          "test/football_market/providers/ingestion_contract_test.exs",
          "test/football_market/valuation/scope_test.exs",
          "test/football_market/synchronization/",
          "test/support/synchronization/",
          "test/ci/test_profile_audit_test.exs",
          "test/ci/test_profile_runner_contract_test.exs",
          "test/support/test_profile_audit.ex",
          "test/scripts/agentflow_evidence_test.py",
          "test/football_market/synchronization/statistics_test.exs"
        ] ++
          Enum.map(
            ~w(documents inventory expected),
            &"test/fixtures/statistics_ingestion/#{&1}.exs"
          ) ++
          Enum.map(
            ~w(ingestion ingestion/publisher ingestion/reconciler ingestion/canonical ingestion/input ingestion/positions ingestion/metrics ingestion/check ingestion/outcome ingestion/provenance ingestion/receiver ingestion/worker ingestion/recovery ingestion/retention ingestion/integrity ingestion/isolation ingestion/replay ingestion/concurrency ingestion/acceptance ingestion/calculation),
            &"test/football_market/statistics/#{&1}_test.exs"
          ) ++
          Enum.map(
            ~w(statistics.ex performance.ex ingestion.ex ingestion/),
            &"lib/football_market/statistics/#{&1}"
          ) ++
          Enum.map(
            ~w(delivery_receipt.ex dispatcher.ex execution_guard.ex input.ex recovery.ex run.ex scheduler.ex store.ex),
            &"lib/football_market/synchronization/#{&1}"
          ) ++
          Enum.map(
            ~w(error.ex performances.ex validator.ex types.ex scraping/assessment.ex scraping/source.ex scraping/translator.ex),
            &"lib/football_market/providers/#{&1}"
          ) ++
          [
            "lib/football_market/catalog/ingestion/delivery_receipt.ex",
            "lib/football_market/workers/catalog_sync.ex",
            "test/football_market/synchronization/input_test.exs",
            "test/football_market/statistics/scope_test.exs",
            "test/support/providers/fact_oracle.ex",
            "test/football_market/providers/scraping/assessment_test.exs",
            "test/football_market/providers/scraping/source_test.exs",
            "test/football_market/providers/scraping/translator_test.exs"
          ]
      else
        []
      end

    allowed_ci_paths = [
      ".github/workflows/quality-baseline.yml",
      "test/ci/quality_baseline_contract_test.exs",
      "test/ci/fixtures/quality-baseline.sha256"
    ]

    for line <- changed, not is_nil(active_feature) do
      path = String.slice(line, 3..-1//1)

      assert path in provider_paths or path in scraper_paths or path in ingestion_paths or
               path in valuation_paths(active_feature) or path in market_paths(active_feature) or
               path in synchronization_paths(active_feature) or
               Enum.any?(FootballMarket.WorkflowScope.paths(active_feature), fn planned ->
                 if String.ends_with?(planned, "/"),
                   do: String.starts_with?(path, planned),
                   else: path == planned
               end) or
               path in FootballMarket.BrowserSessionCase.shell_paths(active_feature) or
               path in FootballMarket.WorkflowScope.paths(active_feature) or
               path in allowed_ci_paths or path in statistics_ingestion_paths or
               Enum.any?(statistics_ingestion_paths, fn prefix ->
                 String.ends_with?(prefix, "/") and String.starts_with?(path, prefix)
               end) or
               Enum.any?(allowed, &String.starts_with?(path, &1)),
             "outside plan: #{path}"
    end
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

  defp product_change_lines(paths) do
    case System.cmd("git", ["rev-parse", "--verify", "MERGE_HEAD"]) do
      {_merge_head, 0} ->
        {changed, 0} = System.cmd("git", ["diff", "--name-only", "MERGE_HEAD", "--" | paths])

        {untracked, 0} =
          System.cmd("git", ["ls-files", "--others", "--exclude-standard", "--" | paths])

        Enum.map(String.split(changed, "\n", trim: true), &(" M " <> &1)) ++
          Enum.map(String.split(untracked, "\n", trim: true), &("?? " <> &1))

      _ ->
        {out, 0} =
          System.cmd("git", ["status", "--porcelain", "--untracked-files=all", "--" | paths])

        String.split(out, "\n", trim: true)
    end
  end
end

defmodule FootballMarket.Statistics.ScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Statistics.{Input, Match, Performance}

  test "FR-013 context contract has no web provider cache or financial dependency" do
    files = [
      "lib/football_market/statistics.ex" | Path.wildcard("lib/football_market/statistics/*.ex")
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

    assert File.read!("specs/054-player-match-statistics/contracts/statistics-context.md") =~
             "No HTTP route"

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
    {out, 0} =
      System.cmd("git", [
        "status",
        "--porcelain",
        "--untracked-files=all",
        "--",
        "lib",
        "priv",
        "test",
        ".github/workflows"
      ])

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

    active_feature =
      case File.read(".specify/feature.json") do
        {:ok, json} -> Jason.decode!(json)["feature_directory"]
        {:error, _} -> nil
      end

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

    allowed_ci_paths = [
      "test/ci/quality_baseline_contract_test.exs",
      "test/ci/fixtures/quality-baseline.sha256"
    ]

    for line <- String.split(out, "\n", trim: true) do
      path = String.slice(line, 3..-1//1)

      assert path in provider_paths or path in scraper_paths or path in ingestion_paths or
               path in valuation_paths(active_feature) or path in market_paths(active_feature) or
               path in allowed_ci_paths or
               Enum.any?(allowed, &String.starts_with?(path, &1)),
             "outside plan: #{path}"
    end
  end

  # Exact active TASK-022 inventory; all legacy constraints remain enforced.
  def valuation_paths(active_feature) do
    if active_feature == "specs/061-valuation-strategy-versioning" do
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
    else
      if active_feature == "specs/060-position-aware-valuation" do
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
      else
        if active_feature == "specs/059-balanced-valuation-strategy" do
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
        else
          if active_feature == "specs/058-valuation-contract-normalization" do
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
          else
            []
          end
        end
      end
    end
  end

  # Exact active TASK-028 inventory; unknown features receive no allowance.
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
end

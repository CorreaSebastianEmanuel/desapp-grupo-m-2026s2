defmodule FootballMarket.WorkflowScopeTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.WorkflowScope

  test "ordinary maintenance branches have no workflow owner while numbered claims fail closed" do
    previous = System.get_env("GITHUB_HEAD_REF")

    try do
      for head <- ["main", "repo-review-fixes", "fix/sign-in"] do
        System.put_env("GITHUB_HEAD_REF", head)
        assert WorkflowScope.active_feature() == nil
      end

      for head <- ["999-missing-task", "064-wrong-owner", "064"] do
        System.put_env("GITHUB_HEAD_REF", head)

        assert_raise RuntimeError, ~r/Cannot resolve durable workflow scope/, fn ->
          WorkflowScope.active_feature()
        end
      end
    after
      if previous,
        do: System.put_env("GITHUB_HEAD_REF", previous),
        else: System.delete_env("GITHUB_HEAD_REF")
    end
  end

  test "durable owner resolves without session metadata" do
    {branch, 0} = System.cmd("git", ["branch", "--show-current"])

    if String.starts_with?(String.trim(branch), "064-") do
      assert WorkflowScope.active_feature() == "specs/064-proportional-agentflow-delivery"
    end
  end

  test "pull request head ref resolves task scope from a detached checkout" do
    previous = System.get_env("GITHUB_HEAD_REF")

    System.put_env(
      "GITHUB_HEAD_REF",
      "064-proportional-agentflow-delivery-and-measurable-efficiency"
    )

    try do
      assert WorkflowScope.active_feature() == "specs/064-proportional-agentflow-delivery"
    after
      if previous,
        do: System.put_env("GITHUB_HEAD_REF", previous),
        else: System.delete_env("GITHUB_HEAD_REF")
    end
  end

  test "workflow allowance is exact and excludes application behavior" do
    paths = WorkflowScope.paths("specs/064-proportional-agentflow-delivery")
    assert "test/support/workflow_scope.ex" in paths
    assert length(paths) == length(Enum.uniq(paths))
    refute "lib/football_market/market.ex" in paths
    refute "test/scripts/unplanned_test.py" in paths
    assert WorkflowScope.paths(nil) == []
    assert WorkflowScope.paths("specs/unknown") == []

    for feature <- [
          "specs/065-separate-unit-and-end-to-end-test-profiles",
          "specs/065-statistics-ingestion-pipeline",
          "specs/068-atomic-idempotent-token-purchase",
          "specs/069-verify-sonarcloud-external-elixir-report-compatibility"
        ] do
      assert WorkflowScope.allows_path?(feature, "test/support/workflow_scope.ex")
    end

    probe_feature = "specs/069-verify-sonarcloud-external-elixir-report-compatibility"
    assert WorkflowScope.allows_path?(probe_feature, ".github/workflows/sonarcloud.yml")
    assert WorkflowScope.allows_path?(probe_feature, "test/ci/sonarcloud_contract_test.exs")
    refute WorkflowScope.allows_path?(probe_feature, "lib/football_market/statistics.ex")
    refute WorkflowScope.allows_path?(probe_feature, ".github/workflows/unplanned.yml")

    assert WorkflowScope.allows_path?(
             "specs/065-statistics-ingestion-pipeline",
             "lib/football_market/statistics/ingestion/publisher.ex"
           )

    refute WorkflowScope.allows_path?(
             "specs/065-separate-unit-and-end-to-end-test-profiles",
             "lib/football_market/statistics/ingestion/publisher.ex"
           )

    player_card_feature =
      "specs/077-advance-cp2-product-ui-player-card-trading-actions-and-active-ranking"

    player_card_paths = WorkflowScope.paths(player_card_feature)
    assert length(player_card_paths) == length(Enum.uniq(player_card_paths))

    for path <- [
          "lib/football_market/catalog.ex",
          "lib/football_market/statistics/query.ex",
          "lib/football_market_web/live/workspace_live.ex",
          "test/support/e2e/fixtures.ex",
          "tools/openapi/e2e_market.mjs"
        ] do
      assert WorkflowScope.allows_path?(player_card_feature, path)
    end

    for path <- [
          "lib/football_market/market/purchase_transaction.ex",
          "lib/football_market/valuation/balanced.ex",
          "priv/repo/migrations/unplanned.exs",
          ".github/workflows/unplanned.yml",
          "tools/openapi/unplanned.mjs"
        ] do
      refute WorkflowScope.allows_path?(player_card_feature, path)
    end
  end

  test "TASK-029 verification recovery and compatibility allowance is limited to named paths" do
    feature = "specs/068-atomic-idempotent-token-purchase"

    for path <- [
          "scripts/test_profile_runner.py",
          "scripts/agentflow_check.py",
          "scripts/agentflow_stage_checks.py",
          "scripts/agentflow_verification.py",
          "docs/AGENT_VERIFICATION.md",
          "docs/WORKFLOW_LESSONS.md",
          "docs/adr/0034-check-environment-retry-identity.md",
          "test/scripts/test_profile_runner_test.py",
          "test/scripts/agentflow_evidence_test.py",
          "scripts/agentflow_codex.py",
          "scripts/ci_unit_tests.sh",
          "scripts/profile_safe_diagnostics.py",
          "scripts/application_coverage.py",
          "scripts/test_profile_components.py",
          "test/scripts/application_coverage_test.py",
          "test/scripts/agentflow_models_test.py",
          "test/scripts/agentflow_branch_test.py",
          "test/scripts/agentflow_stage_checks_test.py",
          "test/scripts/agentflow_dedup_test.py",
          "test/scripts/ci_unit_tests_test.sh",
          "test/scripts/profile_safe_diagnostics_test.py",
          "agentflow",
          "docs/adr/0035-effective-sandbox-check-identity.md",
          "test/football_market/market/scope_test.exs",
          "test/football_market/synchronization/scope_test.exs",
          "test/football_market_web/openapi_browser_test.exs",
          "test/football_market_web/openapi_contract_test.exs",
          "test/mix/tasks/catalog.seed_test.exs",
          "tools/openapi/browser.mjs"
        ] do
      assert WorkflowScope.allows_path?(feature, path), "expected authorized path #{path}"
    end

    for path <- [
          "scripts/test_inventory.py",
          "scripts/application_coverage_native.exs",
          "scripts/agentflow_unknown.py",
          "docs/adr/0036-unplanned.md",
          "test/scripts/unplanned_test.py",
          "test/scripts/unplanned_stage_checks_test.py",
          "test/scripts/unplanned_profile_safe_diagnostics_test.py",
          "test/scripts/unplanned_coverage_test.py",
          "test/mix/tasks/unplanned_test.exs",
          "lib/football_market/not_planned.ex",
          "priv/repo/migrations/unplanned.exs"
        ] do
      refute WorkflowScope.allows_path?(feature, path), "unexpected path allowance #{path}"
    end
  end

  test "active strategy ranking allowance matches its bounded implementation plan" do
    feature = "specs/069-active-strategy-player-ranking"
    paths = WorkflowScope.paths(feature)

    assert length(paths) == length(Enum.uniq(paths))

    for path <- [
          "lib/football_market/ranking/reader.ex",
          "lib/football_market_web/controllers/ranking_controller.ex",
          "priv/static/openapi.json",
          "scripts/verify_ranking_runtime.exs",
          "test/football_market/ranking/selection_test.exs",
          "test/support/ranking_case.ex"
        ] do
      assert WorkflowScope.allows_path?(feature, path)
    end

    for path <- [
          "test/football_market_web/openapi_contract_test.exs",
          "tools/openapi/browser.mjs",
          "test/football_market/synchronization/scope_test.exs"
        ] do
      assert WorkflowScope.allows_path?(feature, path)
    end

    refute WorkflowScope.allows_path?(feature, "priv/repo/migrations/unplanned.exs")
    refute WorkflowScope.allows_path?(feature, "lib/football_market/unplanned.ex")
  end

  test "Credo cleanup allowance is finite and rejects unknown production and CI paths" do
    feature = "specs/066-credo-remediation"
    paths = WorkflowScope.paths(feature)
    assert paths != []
    assert length(paths) == length(Enum.uniq(paths))
    assert WorkflowScope.allows_path?(feature, "test/ci/credo_remediation_contract_test.exs")
    assert WorkflowScope.allows_path?(feature, "config/test_profiles.json")
    assert WorkflowScope.allows_path?(feature, "test/scripts/local_services_failure_test.sh")
    assert WorkflowScope.allows_path?(feature, "test/scripts/ci_unit_tests_test.sh")
    assert WorkflowScope.allows_path?(feature, ".github/workflows/quality-baseline.yml")
    assert WorkflowScope.allows_path?(feature, "test/ci/test_profiles_quality_contract_test.exs")
    assert WorkflowScope.allows_path?(feature, "test/ci/fixtures/quality-baseline.sha256")
    assert WorkflowScope.allows_path?(feature, "test/football_market/market/consistency_test.exs")

    for path <- [
          "lib/football_market/unplanned.ex",
          "test/scripts/unplanned_test.sh",
          ".github/workflows/unplanned.yml",
          "priv/repo/migrations/unplanned.exs"
        ] do
      refute WorkflowScope.allows_path?(feature, path)
    end

    assert WorkflowScope.paths("specs/unknown") == []
  end

  test "Credo inventory enforcement allowance is limited to the implementation plan" do
    feature = "specs/065-elixir-source-inventory-and-required-credo-ci"
    paths = WorkflowScope.paths(feature)

    assert paths != []
    assert length(paths) == length(Enum.uniq(paths))

    for path <- [
          ".github/workflows/quality-baseline.yml",
          "README.md",
          "config/credo_inventory.json",
          "config/test_profiles.json",
          "scripts/credo_ci.sh",
          "scripts/credo_inventory.exs",
          "test/ci/credo_inventory_test.exs",
          "test/ci/credo_ci_contract_test.exs",
          "test/ci/quality_baseline_contract_test.exs",
          "test/ci/test_profiles_quality_contract_test.exs",
          "test/ci/fixtures/quality-baseline.sha256",
          "test/support/workflow_scope.ex"
        ] do
      assert WorkflowScope.allows_path?(feature, path), "expected planned path #{path}"
    end

    for path <- [
          "lib/football_market/unplanned.ex",
          "priv/repo/migrations/unplanned.exs",
          ".github/workflows/unplanned.yml",
          "scripts/unplanned.sh",
          "test/ci/unplanned_test.exs"
        ] do
      refute WorkflowScope.allows_path?(feature, path), "unexpected path allowance #{path}"
    end
  end

  test "application coverage scope is finite and excludes production and hosted workflow edits" do
    feature = "specs/067-whole-application-elixir-coverage-and-report-reconciliation"
    assert WorkflowScope.allows_path?(feature, "scripts/application_coverage.py")
    assert WorkflowScope.allows_path?(feature, "test/test_helper.exs")
    refute WorkflowScope.allows_path?(feature, "lib/football_market.ex")
    refute WorkflowScope.allows_path?(feature, ".github/workflows/quality-baseline.yml")
    refute WorkflowScope.allows_path?(feature, "test/ci/unplanned_test.exs")
    paths = WorkflowScope.paths(feature)
    assert length(paths) == length(Enum.uniq(paths))
  end
end

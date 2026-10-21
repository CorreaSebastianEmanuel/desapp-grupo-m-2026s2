defmodule FootballMarket.WorkflowScopeTest do
  use ExUnit.Case, async: false
  @moduletag :unit
  alias FootballMarket.WorkflowScope

  test "durable owner resolves without session metadata" do
    {branch, 0} = System.cmd("git", ["branch", "--show-current"])

    if String.starts_with?(String.trim(branch), "064-") do
      assert WorkflowScope.active_feature() == "specs/064-proportional-agentflow-delivery"
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
          "specs/065-statistics-ingestion-pipeline"
        ] do
      assert WorkflowScope.allows_path?(feature, "test/support/workflow_scope.ex")
    end

    assert WorkflowScope.allows_path?(
             "specs/065-statistics-ingestion-pipeline",
             "lib/football_market/statistics/ingestion/publisher.ex"
           )

    refute WorkflowScope.allows_path?(
             "specs/065-separate-unit-and-end-to-end-test-profiles",
             "lib/football_market/statistics/ingestion/publisher.ex"
           )
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

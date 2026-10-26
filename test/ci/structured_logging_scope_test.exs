defmodule FootballMarket.StructuredLoggingScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.WorkflowScope

  test "production coverage roles reconcile with every maintained Elixir source" do
    script = """
    import sys
    sys.path.insert(0, 'scripts')
    from application_coverage import source_inventory
    source_inventory()
    """

    assert {"", 0} = System.cmd("python3", ["-c", script], stderr_to_stdout: true)
  end

  test "logging plan permits its exact adapter integration and test files only" do
    feature = "specs/036-correlation-ids-and-structured-logging"

    for path <- [
          "lib/football_market/observability/context.ex",
          "lib/football_market_web/request_logger.ex",
          "lib/football_market/synchronization/store.ex",
          "priv/repo/migrations/20261026000100_add_synchronization_correlation.exs",
          "test/e2e/correlated_logging_test.exs",
          "config/test_profiles.json"
        ] do
      assert WorkflowScope.allows_path?(feature, path)
    end

    for path <- [
          "lib/football_market/accounts.ex",
          "lib/football_market/observability/unplanned.ex",
          ".github/workflows/quality-baseline.yml",
          "scripts/agentflow_feature.py",
          "backlog/TASK-029-atomic-idempotent-token-purchase.md"
        ] do
      refute WorkflowScope.allows_path?(feature, path)
    end
  end
end

defmodule FootballMarket.PortfolioAnalyticsScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.WorkflowScope

  test "analytics runtime test retains the required high-risk application checks" do
    script = """
    from pathlib import Path
    from scripts.thinflow import select
    result = select(Path.cwd(), ['test/e2e/portfolio_analytics_test.exs'])
    assert result['tier'] == 'high'
    assert result['blocked_paths'] == []
    assert set(result['checks']) == {'format', 'compile', 'unit-profile'}
    """

    assert {"", 0} = System.cmd("python3", ["-c", script], stderr_to_stdout: true)
  end

  test "analytics scope retains exact integration files and rejects unrelated changes" do
    feature = "specs/057-portfolio-analytics-and-historical-valuation-api"

    for path <- [
          "lib/football_market/market/analytics/store.ex",
          "test/e2e/portfolio_analytics_test.exs",
          ".agentflow/thinflow.json"
        ] do
      assert WorkflowScope.allows_path?(feature, path)
    end

    for path <- [
          "lib/football_market/market/analytics/unplanned.ex",
          "lib/football_market/market/purchase_transaction.ex",
          "backlog/TASK-072-practical-frontend.md",
          ".github/workflows/quality-baseline.yml"
        ] do
      refute WorkflowScope.allows_path?(feature, path)
    end
  end
end

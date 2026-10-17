defmodule FootballMarket.WorkflowScope do
  @moduledoc "Resolve scope from durable branch ownership, never a private session pointer."

  def active_feature(root \\ File.cwd!()) do
    python = """
    import subprocess
    from pathlib import Path
    from scripts.workflow_artifact_probe import active_feature
    root=Path.cwd().resolve()
    branch=subprocess.check_output(['git','branch','--show-current'],text=True).strip()
    if branch not in ('main','master',''):
        print(active_feature(root).relative_to(root).as_posix())
    """

    case System.cmd("python3", ["-c", python], cd: root, stderr_to_stdout: true) do
      {output, 0} ->
        if String.trim(output) == "", do: nil, else: String.trim(output)

      {_output, _} ->
        raise "Cannot resolve durable workflow scope; validate branch/task/spec ownership"
    end
  end

  def paths("specs/064-proportional-agentflow-delivery") do
    [
      ".github/workflows/quality-baseline.yml",
      "test/ci/quality_baseline_contract_test.exs",
      "test/ci/fixtures/quality-baseline.sha256",
      "test/ci/workflow_scope_test.exs",
      "test/support/workflow_scope.ex",
      "test/football_market/market/scope_test.exs",
      "test/football_market/statistics/scope_test.exs",
      "test/football_market/providers/scope_test.exs",
      "test/scripts/ci_unit_tests_test.sh",
      "test/scripts/support/agentflow_delivery_fixtures.py",
      "test/scripts/agentflow_policy_test.py",
      "test/scripts/agentflow_ci_check_test.py",
      "test/scripts/agentflow_clean_checkout_test.py",
      "test/scripts/agentflow_artifacts_test.py",
      "test/scripts/agentflow_evidence_test.py",
      "test/scripts/agentflow_feedback_test.py",
      "test/scripts/agentflow_models_test.py",
      "test/scripts/agentflow_metrics_test.py",
      "test/scripts/workflow_artifact_probe_test.py",
      "test/scripts/agentflow_completion_test.py",
      "test/scripts/agentflow_branch_test.py",
      "test/scripts/agentflow_feature_test.py",
      "test/scripts/task_feature_binding_acceptance_test.py"
    ]
  end

  def paths("specs/065-statistics-ingestion-pipeline") do
    [
      "config/synchronization.exs",
      "lib/football_market/catalog/ingestion/delivery_receipt.ex",
      "lib/football_market/providers/error.ex",
      "lib/football_market/providers/performances.ex",
      "lib/football_market/providers/scraping/",
      "lib/football_market/providers/types.ex",
      "lib/football_market/providers/validator.ex",
      "lib/football_market/statistics.ex",
      "lib/football_market/statistics/",
      "lib/football_market/synchronization.ex",
      "lib/football_market/synchronization/",
      "lib/football_market/valuation/calculation_requests.ex",
      "lib/football_market/workers/catalog_sync.ex",
      "lib/football_market/workers/calculation_dispatch.ex",
      "lib/football_market/workers/statistics_import.ex",
      "priv/repo/migrations/20261016000100_extend_statistics_position_evidence.exs",
      "priv/repo/migrations/20261016000200_create_statistics_ingestion.exs",
      "priv/repo/migrations/20261016000300_extend_synchronization_operations.exs",
      "test/football_market/providers/ingestion_contract_test.exs",
      "test/football_market/providers/scope_test.exs",
      "test/football_market/market/scope_test.exs",
      "test/football_market/catalog/constraints_test.exs",
      "test/football_market/statistics/",
      "test/football_market/valuation/scope_test.exs",
      "test/football_market/synchronization/",
      "test/support/synchronization/",
      "test/fixtures/statistics_ingestion/",
      "test/ci/test_profile_audit_test.exs",
      "test/ci/test_profile_runner_contract_test.exs",
      "test/support/ingestion_fixtures.ex",
      "test/support/providers/fact_oracle.ex",
      "test/support/statistics_ingestion/",
      "test/support/test_profile_audit.ex",
      "test/scripts/agentflow_evidence_test.py",
      "test/support/workflow_scope.ex"
    ]
  end

  def paths(_), do: []

  def allows_path?(feature, path) do
    Enum.any?(paths(feature), fn planned ->
      if String.ends_with?(planned, "/"),
        do: String.starts_with?(path, planned),
        else: path == planned
    end)
  end
end

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

  def paths("specs/065-separate-unit-and-end-to-end-test-profiles") do
    [
      ".github/workflows/quality-baseline.yml",
      "config/test_profiles.json",
      "test/football_market/catalog/constraints_test.exs",
      "test/football_market/statistics/concurrency_test.exs",
      "test/ci/test_profile_audit_test.exs",
      "test/ci/fixtures/quality-baseline.sha256",
      "test/football_market/providers/scope_test.exs",
      "test/ci/coverage_report_contract_test.exs",
      "test/ci/cp1_coverage_inventory_test.exs",
      "test/ci/e2e_runtime_contract_test.exs",
      "test/ci/e2e_supervisor_cleanup_test.exs",
      "test/ci/quality_baseline_contract_test.exs",
      "test/ci/test_profile_runner_contract_test.exs",
      "test/ci/test_profiles_quality_contract_test.exs",
      "test/ci/test_profiles_scope_test.exs",
      "test/integration/infrastructure_verify_test.sh",
      "test/integration/redis_disposability_test.sh",
      "test/e2e/browser_shell_test.exs",
      "test/e2e/catalog_sync_test.exs",
      "test/scripts/ci_unit_tests_test.sh",
      "test/scripts/compose_contract_test.sh",
      "test/scripts/consecutive_lifecycle_acceptance_test.sh",
      "test/scripts/database_isolation_test.sh",
      "test/scripts/local_services_failure_test.sh",
      "test/scripts/local_services_lifecycle_test.sh",
      "test/scripts/support/profile_events.sh",
      "test/scripts/task_002_acceptance_test.sh",
      "test/scripts/task_002_scope_security_test.sh",
      "test/scripts/test_inventory_test.py",
      "test/scripts/test_profile_components_test.py",
      "test/scripts/test_profile_runner_test.py",
      "test/scripts/verify_foundation_test.sh",
      "test/support/e2e/fixture_adapter.ex",
      "test/support/e2e/fixtures.ex",
      "test/support/e2e/runtime.ex",
      "test/support/e2e/interrupted_runtime.exs",
      "test/support/e2e/supervisor_probe.py",
      "test/support/test_profile_audit.ex",
      "test/support/test_profile_formatter.ex",
      "test/support/workflow_scope.ex",
      "test/test_helper.exs"
    ]
  end

  def paths(_), do: []
end

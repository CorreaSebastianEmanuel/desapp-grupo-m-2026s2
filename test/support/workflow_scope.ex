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

  def paths(_), do: []
end

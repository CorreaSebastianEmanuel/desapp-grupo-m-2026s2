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

  def paths("specs/066-credo-remediation") do
    [
      ".credo.exs",
      "config/test_profiles.json",
      "lib/football_market/accounts.ex",
      "lib/football_market/accounts/browser_sessions.ex",
      "lib/football_market/accounts/user.ex",
      "lib/football_market/catalog/development_seed.ex",
      "lib/football_market/catalog/ingestion.ex",
      "lib/football_market/catalog/ingestion/observation.ex",
      "lib/football_market/catalog/ingestion/publisher.ex",
      "lib/football_market/catalog/ingestion/reconciler.ex",
      "lib/football_market/catalog/query.ex",
      "lib/football_market/infrastructure/verification.ex",
      "lib/football_market/market/consistency.ex",
      "lib/football_market/market/store.ex",
      "lib/football_market/providers/instant.ex",
      "lib/football_market/providers/performances.ex",
      "lib/football_market/providers/runner.ex",
      "lib/football_market/providers/scraping/assessment.ex",
      "lib/football_market/providers/scraping/fixture_transport.ex",
      "lib/football_market/providers/scraping/source.ex",
      "lib/football_market/providers/scraping/translator.ex",
      "lib/football_market/statistics.ex",
      "lib/football_market/statistics/count.ex",
      "lib/football_market/statistics/error.ex",
      "lib/football_market/statistics/ingestion/canonical.ex",
      "lib/football_market/statistics/ingestion/positions.ex",
      "lib/football_market/statistics/ingestion/publisher.ex",
      "lib/football_market/statistics/input.ex",
      "lib/football_market/statistics/query.ex",
      "lib/football_market/synchronization/dispatcher.ex",
      "lib/football_market/synchronization/execution_guard.ex",
      "lib/football_market/synchronization/input.ex",
      "lib/football_market/synchronization/policy.ex",
      "lib/football_market/synchronization/recovery.ex",
      "lib/football_market/synchronization/scheduler.ex",
      "lib/football_market/synchronization/store.ex",
      "lib/football_market/valuation/balanced.ex",
      "lib/football_market/valuation/calculation_requests.ex",
      "lib/football_market/valuation/configurations/store.ex",
      "lib/football_market/valuation/evidence.ex",
      "lib/football_market/valuation/managed.ex",
      "lib/football_market/valuation/managed_types.ex",
      "lib/football_market/valuation/position_aware.ex",
      "lib/football_market/valuation/position_groups.ex",
      "lib/football_market/valuation/replay.ex",
      "lib/football_market/valuation/request.ex",
      "lib/football_market/valuation/scoring.ex",
      "lib/football_market/valuation/statistics_reader.ex",
      "lib/football_market/valuation/types.ex",
      "lib/football_market/valuation/week.ex",
      "lib/football_market/workers/catalog_sync.ex",
      "lib/football_market_web/components/workspace_components.ex",
      "lib/football_market_web/controllers/player_controller.ex",
      "lib/football_market_web/controllers/session_controller.ex",
      "lib/football_market_web/live/browser_auth.ex",
      "lib/football_market_web/plugs/browser_auth.ex",
      "lib/mix/tasks/catalog.seed.ex",
      "lib/mix/tasks/infrastructure.database.ex",
      "lib/mix/tasks/infrastructure.verify.ex",
      "mix.exs",
      "mix.lock",
      "test/ci/credo_remediation_contract_test.exs",
      "test/ci/e2e_runtime_contract_test.exs",
      "test/ci/profile_integration_sentinel_test.exs",
      "test/ci/profile_unit_sentinel_test.exs",
      "test/ci/workflow_scope_test.exs",
      "test/scripts/ci_unit_tests_test.sh",
      "test/scripts/local_services_failure_test.sh",
      "test/football_market/accounts/authentication_test.exs",
      "test/football_market/catalog/ingestion/concurrency_test.exs",
      "test/football_market/market/concurrency_test.exs",
      "test/football_market/market/consistency_test.exs",
      "test/football_market/providers/scope_test.exs",
      "test/football_market/statistics/concurrency_test.exs",
      "test/football_market/statistics/input_test.exs",
      "test/football_market/statistics/scope_test.exs",
      "test/football_market/valuation/balanced/arithmetic_test.exs",
      "test/football_market/valuation/balanced/scope_test.exs",
      "test/football_market/valuation/position_aware/arithmetic_test.exs",
      "test/football_market/valuation/position_aware/scope_test.exs",
      "test/support/accounts_case.ex",
      "test/support/browser_session_case.ex",
      "test/support/catalog_case.ex",
      "test/support/catalog_concurrency_case.ex",
      "test/support/data_case.ex",
      "test/support/e2e/fixtures.ex",
      "test/support/infrastructure_case.ex",
      "test/support/ingestion_fixtures.ex",
      "test/support/openapi_case.ex",
      "test/support/position_aware_case.ex",
      "test/support/providers/fact_oracle.ex",
      "test/support/providers/fixture_runtime.ex",
      "test/support/providers/fixture_source_a.ex",
      "test/support/providers/fixture_source_b.ex",
      "test/support/providers/scraping_fixture_data.ex",
      "test/support/statistics_case.ex",
      "test/support/synchronization/case.ex",
      "test/support/test_profile_audit.ex",
      "test/support/valuation_case.ex",
      "test/support/valuation_scorers.ex",
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

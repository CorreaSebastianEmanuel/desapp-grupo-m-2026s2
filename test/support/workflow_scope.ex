defmodule FootballMarket.WorkflowScope do
  @moduledoc "Resolve scope from durable branch ownership, never a private session pointer."

  def active_feature(root \\ File.cwd!()) do
    python = """
    import os
    import re
    import subprocess
    from pathlib import Path
    from scripts.agentflow_feature import task_id_from_head, task_for_id, resolve_feature
    root=Path.cwd().resolve()
    branch=subprocess.check_output(['git','branch','--show-current'],text=True).strip()
    head=os.environ.get('GITHUB_HEAD_REF','').strip() or branch
    # Only numbered task branches claim Agentflow plan ownership.
    # Ordinary maintenance branches still run every architecture assertion.
    if re.match(r'^[0-9]{3}(?:-|$)', head):
        task=task_for_id(root,task_id_from_head(head))
        print(resolve_feature(root,task,head_ref=head).feature.relative_to(root).as_posix())
    """

    case System.cmd("python3", ["-c", python], cd: root, stderr_to_stdout: true) do
      {output, 0} ->
        if String.trim(output) == "", do: nil, else: String.trim(output)

      {_output, _} ->
        raise "Cannot resolve durable workflow scope; validate branch/task/spec ownership"
    end
  end

  def paths("specs/036-correlation-ids-and-structured-logging") do
    [
      "README.md",
      "config/application_coverage_inventory.json",
      "config/config.exs",
      "config/credo_inventory.json",
      "config/runtime.exs",
      "config/test_profiles.json",
      "lib/football_market/application.ex",
      "lib/football_market/observability.ex",
      "lib/football_market/observability/context.ex",
      "lib/football_market/observability/job_context.ex",
      "lib/football_market/observability/job_logger.ex",
      "lib/football_market/observability/json_formatter.ex",
      "lib/football_market/providers/runtime.ex",
      "lib/football_market/quotes/membership.ex",
      "lib/football_market/quotes/recovery.ex",
      "lib/football_market/synchronization/dispatcher.ex",
      "lib/football_market/synchronization/recovery.ex",
      "lib/football_market/synchronization/run.ex",
      "lib/football_market/synchronization/store.ex",
      "lib/football_market_web/endpoint.ex",
      "lib/football_market_web/request_logger.ex",
      "priv/repo/migrations/20261026000100_add_synchronization_correlation.exs",
      "test/ci/e2e_runtime_contract_test.exs",
      "test/ci/structured_logging_scope_test.exs",
      "test/e2e/correlated_logging_test.exs",
      "test/football_market/market/scope_test.exs",
      "test/football_market/observability/context_test.exs",
      "test/football_market/observability/job_context_test.exs",
      "test/football_market/observability/job_logger_test.exs",
      "test/football_market/observability/json_formatter_test.exs",
      "test/football_market_web/request_logger_test.exs",
      "test/support/e2e/runtime.ex",
      "test/support/observability_worker.ex",
      "test/support/synchronization/case.ex",
      "test/support/workflow_scope.ex"
    ]
  end

  def paths("specs/068-agentflow-preflight-recovery") do
    [
      "test/scripts/agentflow_artifacts_test.py",
      "test/scripts/agentflow_branch_test.py",
      "test/scripts/agentflow_dedup_test.py",
      "test/scripts/agentflow_evidence_test.py",
      "test/scripts/agentflow_feedback_test.py",
      "test/scripts/agentflow_models_test.py",
      "test/scripts/agentflow_policy_test.py",
      "test/scripts/agentflow_preflight_test.py",
      "test/scripts/agentflow_providers_test.py",
      "test/scripts/agentflow_recovery_test.py",
      "test/scripts/agentflow_stage_checks_test.py",
      "test/scripts/agentflow_workflow_gate_test.py",
      "test/scripts/ci_unit_tests_test.sh",
      "test/scripts/profile_safe_diagnostics_test.py",
      "test/scripts/support/agentflow_delivery_fixtures.py",
      "test/scripts/test_profile_runner_test.py",
      "test/ci/quality_baseline_contract_test.exs",
      "test/ci/test_profile_runner_contract_test.exs",
      "test/ci/test_profile_audit_test.exs",
      "test/scripts/test_inventory_test.py",
      "config/test_profiles.json",
      "test/mix/tasks/catalog.seed_test.exs",
      "test/football_market/quotes/outcomes_test.exs",
      "test/support/test_profile_audit.ex",
      "test/football_market/synchronization/scope_test.exs",
      "test/support/workflow_scope.ex"
    ]
  end

  def paths("specs/067-whole-application-elixir-coverage-and-report-reconciliation") do
    [
      "mix.exs",
      "config/application_coverage_inventory.json",
      "config/credo_inventory.json",
      "config/test_profiles.json",
      "scripts/application_coverage.py",
      "scripts/application_coverage_native.exs",
      "scripts/test_profile_runner.py",
      "test/scripts/application_coverage_test.py",
      "test/ci/application_coverage_native_test.exs",
      "test/ci/application_coverage_contract_test.exs",
      "test/football_market/providers/scope_test.exs",
      "test/test_helper.exs",
      "test/support/workflow_scope.ex",
      "test/ci/workflow_scope_test.exs"
    ]
  end

  def paths("specs/064-proportional-agentflow-delivery") do
    [
      ".github/workflows/quality-baseline.yml",
      "test/ci/quality_baseline_contract_test.exs",
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

  def paths("specs/026-quote-recalculation-and-immutable-history") do
    [
      "lib/football_market/quotes.ex",
      "lib/football_market/quotes/",
      "lib/football_market/market/quote.ex",
      "lib/football_market/statistics/ingestion/publisher.ex",
      "lib/football_market/valuation.ex",
      "lib/football_market/valuation/managed.ex",
      "lib/football_market/valuation/statistics_reader.ex",
      "lib/football_market/valuation/calculation_requests.ex",
      "lib/football_market/workers/calculation_dispatch.ex",
      "lib/football_market/workers/quote_calculation.ex",
      "lib/football_market/application.ex",
      "config/runtime.exs",
      "config/synchronization.exs",
      "config/test_profiles.json",
      "priv/repo/migrations/20261018000000_create_quote_calculations.exs",
      "priv/repo/migrations/20261018000100_add_quote_import_snapshots.exs",
      "priv/repo/migrations/20261018000200_add_explicit_quote_requests.exs",
      "priv/repo/migrations/20261018000300_reconcile_quote_import_snapshot_schema.exs",
      "priv/repo/migrations/20261018000400_reconcile_quote_import_snapshot_facts.exs",
      "priv/repo/migrations/20261018000500_reconcile_quote_mapping_schema.exs",
      "priv/repo/migrations/20261018000600_reconcile_quote_calculation_requests.exs",
      "priv/repo/migrations/20261018000700_reconcile_quote_calculation_attempts.exs",
      "priv/repo/migrations/20261018000800_reconcile_quote_request_requested_mapping.exs",
      "priv/repo/migrations/20261018000900_reconcile_legacy_quote_admission.exs",
      "priv/repo/migrations/20261018001000_protect_quote_evaluation_deletion.exs",
      "priv/repo/migrations/20261018001100_require_successful_quote_confirmation.exs",
      "scripts/verify_quote_runtime.exs",
      "test/football_market/quotes/",
      "test/football_market/valuation/configurations/managed_test.exs",
      "test/football_market/statistics/ingestion/calculation_test.exs",
      "test/support/quotes/",
      "test/support/valuation_configuration_case.ex",
      "test/support/market_case.ex",
      "test/football_market/market/retry_test.exs",
      "test/football_market/market/concurrency_test.exs",
      "test/football_market/market/storage_test.exs",
      "test/football_market/market/rejection_test.exs",
      "test/support/test_profile_audit.ex",
      "test/ci/test_profile_audit_test.exs",
      "test/scripts/agentflow_models_test.py",
      "test/scripts/agentflow_workflow_gate_test.py",
      "test/support/workflow_scope.ex",
      "test/football_market/statistics/scope_test.exs",
      "test/football_market/providers/scope_test.exs",
      "test/football_market/market/scope_test.exs",
      "test/football_market/synchronization/scope_test.exs"
    ]
  end

  def paths("specs/066-credo-remediation") do
    [
      ".credo.exs",
      ".github/workflows/quality-baseline.yml",
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
      "test/ci/test_profiles_quality_contract_test.exs",
      "test/ci/fixtures/quality-baseline.sha256",
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

  def paths("specs/065-elixir-source-inventory-and-required-credo-ci") do
    [
      ".github/workflows/quality-baseline.yml",
      "README.md",
      "config/credo_inventory.json",
      "config/test_profiles.json",
      "scripts/credo_ci.sh",
      "scripts/credo_inventory.exs",
      "test/ci/credo_inventory_test.exs",
      "test/ci/credo_ci_contract_test.exs",
      "test/ci/quality_baseline_contract_test.exs",
      "test/ci/workflow_scope_test.exs",
      "test/ci/test_profiles_quality_contract_test.exs",
      "test/ci/fixtures/quality-baseline.sha256",
      "test/support/workflow_scope.ex"
    ]
  end

  def paths("specs/068-atomic-idempotent-token-purchase") do
    [
      "config/credo_inventory.json",
      "config/test_profiles.json",
      "docs/AGENT_VERIFICATION.md",
      "docs/WORKFLOW_LESSONS.md",
      "docs/adr/0034-check-environment-retry-identity.md",
      "docs/adr/0035-effective-sandbox-check-identity.md",
      "lib/football_market/market.ex",
      "lib/football_market/market/credit_balance.ex",
      "lib/football_market/market/credit_entry.ex",
      "lib/football_market/market/purchase.ex",
      "lib/football_market/market/purchase_input.ex",
      "lib/football_market/market/purchase_store.ex",
      "lib/football_market/market/purchases.ex",
      "lib/football_market/market/token_transfer.ex",
      "lib/football_market_web/controllers/error_json.ex",
      "lib/football_market_web/controllers/purchase_controller.ex",
      "lib/football_market_web/controllers/purchase_json.ex",
      "lib/football_market_web/router.ex",
      "priv/repo/migrations/20261023000000_create_market_purchases.exs",
      "priv/static/openapi.json",
      "scripts/agentflow_check.py",
      "scripts/agentflow_stage_checks.py",
      "agentflow",
      "scripts/agentflow_codex.py",
      "scripts/agentflow_verification.py",
      "scripts/application_coverage.py",
      "scripts/ci_unit_tests.sh",
      "scripts/profile_safe_diagnostics.py",
      "scripts/test_profile_components.py",
      "scripts/test_profile_runner.py",
      "test/scripts/agentflow_branch_test.py",
      "test/ci/workflow_scope_test.exs",
      "test/football_market/market/scope_test.exs",
      "test/football_market/market/purchases/concurrency_test.exs",
      "test/football_market/market/purchases/duplicate_race_test.exs",
      "test/football_market/market/purchases/idempotency_test.exs",
      "test/football_market/market/purchases/input_test.exs",
      "test/football_market/market/purchases/quote_order_test.exs",
      "test/football_market/market/purchases/rejection_test.exs",
      "test/football_market/market/purchases/rollback_test.exs",
      "test/football_market/market/purchases/storage_test.exs",
      "test/football_market/market/purchases/transfer_test.exs",
      "test/football_market_web/controllers/purchase_controller_test.exs",
      "test/football_market/synchronization/scope_test.exs",
      "test/football_market_web/openapi_browser_test.exs",
      "test/football_market_web/openapi_contract_test.exs",
      "test/mix/tasks/catalog.seed_test.exs",
      "test/runtime/purchase_http.exs",
      "test/scripts/agentflow_evidence_test.py",
      "test/scripts/agentflow_stage_checks_test.py",
      "test/scripts/agentflow_dedup_test.py",
      "test/scripts/ci_unit_tests_test.sh",
      "test/scripts/profile_safe_diagnostics_test.py",
      "test/scripts/agentflow_models_test.py",
      "test/scripts/application_coverage_test.py",
      "test/scripts/test_profile_runner_test.py",
      "test/support/purchases/case.ex",
      "test/support/purchases/runtime_probe.ex",
      "test/support/workflow_scope.ex",
      "tools/openapi/browser.mjs"
    ]
  end

  def paths("specs/069-active-strategy-player-ranking") do
    [
      "config/application_coverage_inventory.json",
      "config/credo_inventory.json",
      "config/test_profiles.json",
      "lib/football_market/ranking.ex",
      "lib/football_market/ranking/reader.ex",
      "lib/football_market_web/controllers/ranking_controller.ex",
      "lib/football_market_web/controllers/ranking_json.ex",
      "lib/football_market_web/router.ex",
      "priv/static/openapi.json",
      "scripts/verify_ranking_runtime.exs",
      "test/ci/workflow_scope_test.exs",
      "test/football_market/ranking/order_test.exs",
      "test/football_market/ranking/safety_test.exs",
      "test/football_market/ranking/selection_test.exs",
      "test/football_market/ranking/snapshot_test.exs",
      "test/football_market_web/controllers/ranking_controller_test.exs",
      "test/support/ranking_case.ex",
      "test/support/workflow_scope.ex",
      "test/football_market_web/openapi_contract_test.exs",
      "tools/openapi/browser.mjs",
      "test/football_market/synchronization/scope_test.exs"
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

# Develop — final correction and existing-tooling regression closure

Claim discovery uses the strict parser's `splitlines()` boundaries and normalizes case-insensitive task claims. The shared cross-file matrix covers control/Unicode line boundaries and case variants through enumeration, start, delivery, completion and real CLI review/done retries. The targeted enumeration regression failed before the correction and passed afterward.

Adapted only fixture preconditions in tests/test_agentflow.py and tests/test_agentflow_delivery.py: reviewed dependency reports, canonical probe task/spec/Git ownership, and an owned history specification. All original assertions remain. Both previously failing suites now pass (20 and 21 tests). Their two files are explicitly included in the plan and narrow scope allowlist; legacy-tooling and legacy-delivery extend the manifest to 12 checks. No production guard was weakened.

Executed all 12 verification.json checks through python3 scripts/agentflow_check.py CHECK_ID: each exited 0 with source_changed false. This covers 114 tests, syntax and scoped whitespace. Canonical receipts: handoffs/check-*.json. The preserved line_identity_probe.py and provider_control_probe.py under /tmp/task054-review-feedback3/ exited 0 unchanged; competing identities refuse without copied-file changes. The unchanged new-task root probe also exited 0. Pinned TASK-017 snapshots, real files, application code and Actions permissions remain preserved.

Developer readiness: python3 scripts/workflow_artifact_probe.py develop --readiness exited 0 with valid: true after completing T026/T027. T028/T029 require fresh independent sessions; prior reports are stale.

QA: independently execute all 12 manifest argv, verify the two legacy fixtures retain their assertions, rerun the unchanged review probes, and check actual-provider completion/idempotence and source isolation. Final review must use fresh QA and current source/receipt evidence. No additional product scope, dependencies or publication behavior was introduced.

Existing PR #29 remains a draft. Update its current branch only after both terminal PASS gates; humans merge #29 before #28. No real TASK-017 completion, commit, push or merge occurred during implementation.

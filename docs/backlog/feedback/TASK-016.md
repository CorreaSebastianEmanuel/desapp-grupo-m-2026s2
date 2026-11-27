# Feedback — TASK-016

## Feedback 1

- Time: 2026-10-06T03:49:35+00:00
- Author: sebo
- Restart from: develop

Independent QA blockers B1/B2 from specs/016-external-football-provider-contract/qa-report.md and handoffs/qa.md; this is implementation correction, not new product scope. B1: production runtime raises ErlangError :timeout_value for accepted timeout_ms values 4294968000 and 10000000000000 in both operations, even with immediate not-found adapters. Preserve FR-003/FR-010 positive-integer timeout acceptance; handle VM receive timeout limits without imposing a new request ceiling, preserve the absolute deadline and cancellation/mailbox guarantees, and add real production-runtime regressions including both operations and immediate error/success paths. B2: valid PL/2025-2026 scope is lost when timeout_ms is 0, -1, nil or true. Preserve independently validated football scope in invalid-request errors while never reflecting malformed scope, per FR-009/SC-005; correct the contradictory fixture oracle and test both operations, invalid timeout types and invalid scope. Reuse /tmp/qa-task016-20261006/adversarial.exs and repro.exs as evidence. Keep specification and plan boundaries, retain all prior behavior and independent fixtures, rerun every stale/current manifest check and the readiness gate, then obtain fresh independent QA and final review PASS before publication.

## Feedback 2

- Time: 2026-10-06T15:21:58+00:00
- Author: sebo
- Restart from: develop

User authorizes a reversible fixture refactor of TASK-016 on its existing feature branch and PR. Preserve production behavior and every one of the 217 stable cases, both independent source representations, explicit independent expected outcomes, all scenario/FR/SC mappings and every existing assertion; do not delete cases or relax checks in this iteration. Replace repeated complete fixture structures with readable test-only bases and declarative overrides, without computing expectations through production validators or hiding data in binary/encoded blobs. Keep the four named fixture files and the pure offline bootstrap working; account for any new test-support paths in the plan/scope/bootstrap rather than weakening boundaries. Reconcile canonical design/tasks/verification documentation where needed, add meaningful fixture-preservation verification, and rerun all applicable manifest checks and readiness. Baseline commit 7a0e115 is protected by local branch backup/task-016-before-fixture-refactor-20261006. Immutable expanded baseline terms for cases/expected/source_a/source_b are saved under /tmp/task016-fixture-baseline-20261006; elixir /tmp/task016-fixture-parity.exs compare must prove exact term equality for all four files. QA should independently compare against the baseline commit as well, and final review should assess readability and reduction, not just test pass. Obtain fresh independent QA and final review Verdict: PASS before updating the existing PR. Report measured before/after line counts. Keep the backup reference and human merge authority; do not reset, delete, force-push or merge.

## Feedback 3

- Time: 2026-10-06T15:33:00+00:00
- Author: sebo
- Restart from: develop

Implementation correction to the authorized fixture refactor: current fixture_preservation_test.exs requires git show 7a0e115, but .github/workflows/quality-baseline.yml uses default shallow actions/checkout. The historical commit will be unavailable after publication, so do not publish this dependency or widen CI fetch/history just for this refactor. Keep the already-refactored fixtures (root independently verified exact equality of all four expanded terms) and replace the persistent preservation oracle with fixed, independently captured SHA-256 fingerprints of deterministic Erlang term serialization, or an equally portable independent oracle. Baseline fingerprints from the pre-change captured terms using :crypto.hash(:sha256, :erlang.term_to_binary(term, [:deterministic])) |> Base.encode16(case: :lower) are: cases adc0d7caca4748cf03fb82a915e83d6347b991f2b8100baee98550de810e4d74; expected bcbac94460cfe9df135a2306ae871c45de1b635c787f61219fdb58bcc8ccfc2c; source_a 1274e05b86794c0297a1b7f2d77d4b232bfc6e2aa40937cd1897be9b53d782b7; source_b 850be3ac0b7217f63d75cb679b8c90f61b260d77b308341df70355571da7d26f. Expected fingerprints must remain literal and cannot be computed from current fixtures at test setup. Keep 217 entries per file and all existing assertions. Reconcile plan/contracts/quickstart/manifest to remove historical Git as a test prerequisite. Demonstrate the dedicated offline preservation selector works with Git unavailable (for example a failing Git shim) while the full original-commit equality remains separate local QA evidence. Rerun every stale manifest check and readiness, then fresh independent QA and final review. Preserve the backup branch and production code; this fixes CI portability within existing scope.


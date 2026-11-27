# Product challenge — TASK-067

## Material findings for architecture

- **Bind reports to one source snapshot.** Spec §FR-007 requires exports to be attributable to the report snapshot, but Assumptions says the binding mechanism may only be specified during planning. If the two audited profile receipts do not already expose a shared revision or source fingerprint, the architect should define one and make absent or mismatched identity fail closed. Otherwise a valid-looking aggregate could combine coverage from different code states. This is an evidence integrity gap, not a change to coverage scope.
- **Define the reconciliation oracle precisely.** FR-002/003 and SC-001 require every TASK-065 inventory entry exactly once and classify maintained `lib/` application implementation as included. The architect should bind the checker to the canonical inventory and explicit path/role mapping, not infer eligibility solely from a broad directory prefix; otherwise a future helper or generated file under `lib/` could silently enter the denominator. Preserve the explicit exclusions required by feedback.
- **Make failed publication distinguishable from stale success.** The spec prohibits presenting a partial report as complete, but does not say what happens to a previously generated report after a failed run. Retain the last successful artifact only if it remains clearly identified with its source snapshot and run status; otherwise a stale success can be mistaken for current evidence.

No unresolved product-scope or coverage-threshold decision is indicated: current feedback and spec consistently exclude tests/support from both totals and exclude a minimum threshold and SonarCloud import.

# Task-generation delta — TASK-028

26 unchecked tasks: US1 7, US2 5, US3 4, shared/final 10. T025/T026 alone map to qa/review in verification.json; T001–T024 must finish before QA.

Story test files may be drafted in parallel after their prerequisites, but one implementation owner retains shared Store/migration/helper changes. US1 is an internal demo MVP only; all three stories and boundary checks are required for acceptance. Tests precede implementation, including failure injection and actual committed race/restart assertions.

Use traceability.md's 16 numbered scenarios and edge/critic matrix to audit completeness, beyond the manifest's 20 canonical FR/SC mappings. Feature tests run in the existing audited unit/integration profiles; do not also add a standalone full feature run or historical CP1 report to final checks. Development may use narrow red/green probes before final source stabilization.

The fixture helper must keep protected audit rows outside shared cleanup, capture exact balance sentinels without adding production balances, and validate distinct PostgreSQL backend identities. Do not introduce production fault callbacks to drive failure tests. Legacy corruption fixtures are test-owned; production constraints remain active.

Finish source/design edits before final receipts. Every named task artifact must exist before marking completion; the implementation handoff is the only new developer summary. QA independently reruns checks without reuse; final review resolves uncovered risks using fresh QA evidence.

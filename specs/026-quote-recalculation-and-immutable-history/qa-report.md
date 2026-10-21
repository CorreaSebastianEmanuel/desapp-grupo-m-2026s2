# Independent QA — TASK-026

Scope: active `.specify/feature.json`, current working tree on `026-quote-recalculation-and-immutable-history`. Read canonical spec/plan/tasks, architecture/develop handoffs, all current TASK-026 feedback, verification manifest, internal contract and quickstart. No developer receipts were reused; no implementation changed. Evidence below is relative to `qa-evidence/20261021-independent/`.

## Executed checks

All Mix commands used `MIX_ENV=test MIX_OS_CONCURRENCY_LOCK=0`.

| Manifest check / command | Evidence | Result |
|---|---|---|
| `mix infrastructure.verify` | `preflight.log`: PostgreSQL OK, Redis OK | PASS |
| `mix format --check-formatted` | `format.log`, exit 0 | PASS |
| `mix compile --warnings-as-errors` | `compile.log`, exit 0 | PASS |
| `sh scripts/test_profile.sh unit` | `unit.log`: expected/executed/passed=438, complete | PASS |
| `sh scripts/test_profile.sh integration` | `integration-1.log`: browser-prerequisite, exit 1 | BLOCKED |
| Direct reproduction of runner Chromium launch | `browser.log`: `bootstrap_check_in ... MachPortRendezvousServer ... Permission denied (1100)` | FAIL, same prerequisite |
| Runtime manifest command | Not executed after second unchanged Chromium failure | BLOCKED |
| `mix test --no-compile /private/tmp/task026-qa-current/conflict_test.exs` | Retained `conflict_test.exs`, `conflict.log`: 0/1 passed, exit 2 | FAIL |

Chromium attempts failed before integration acceptance cases ran. The direct reproduction took under one second; the first integration attempt completed within the approximately 40-second interval before collection. Exact first-attempt elapsed time was not captured. No further retry or workaround was attempted after the second unchanged prerequisite failure. PostgreSQL/Redis readiness does not establish browser readiness. No changed HTTP endpoint exists in the feature production diff; HTTP acceptance is inapplicable.

## Acceptance evidence matrix

A manifest mapping names a suite, not proof of its assertions. “Unverified” means no passing independent integration/runtime execution in this stage.

| Acceptance criteria | Inspected assertions / evidence | Assessment |
|---|---|---|
| US1.1, US1.3; FR-001/003 | calculation_test active configuration and history_test explicit inactive configuration; existing managed evaluator reused | Unverified |
| US1.2; FR-002 | calculation_test:59 changes selection after initial calculation completes; no controlled in-flight barrier | Coverage gap |
| US1.4; FR-004/012; SC-001/002 | calculation/history/replay tests inspect retained membership and fresh-process replay | Unverified; missing-original failure case absent from feature tests |
| US1.5; FR-006; SC-006 | conversion_test exact 2×1.25=2.50, 1.005→1.01, tiny/negative values, invalid scales/context | Unit PASS; persisted zero/negative score cases absent |
| US2.1/2.3; FR-005 | history_test same-price new configuration and late-fact original replay | Unverified; no fresh recalculation assertion after late facts |
| US2.2; FR-010; SC-003 | calculation retry, concurrent distinct IDs; independent conflict probe | FAIL: terminal request reused with changed selector/mapping returns old mapping error |
| US2.4; FR-007/011; SC-007 | outcomes_test empty week/tiny conversion/no-quote restart | Unverified; unsupported/invalid/missing originals and complete financial snapshots not covered |
| US3.1/3.2; FR-008; SC-005 | import_test single membership/replay; ingestion calculation_test independent pending/validation status | Unverified; multi-player/week, two acceptances before dispatch and legacy intent cases absent |
| US3.3; FR-009; SC-004 | quote/event transaction and deferred guards inspected; runtime fresh processes | Unverified; pre-commit rollback assertion absent |
| US3.4 | followup_test repeats acknowledgement with one receipt | Unverified; no fake-consumer effective-work deduplication assertion |
| US3.5; FR-013 | recovery_test seeds future 60/300 schedules and third expired reservation; immutability_test stale fence | Unverified; does not drive transient failures through both backoffs/exhaustion |
| FR-014/015 | Scope unit test passes; feature diff includes internal contexts/migrations plus workflow tooling | Full acceptance matrix incomplete |

## Blockers and development guidance

1. **Request identity conflict:** `quotes.ex:25–34` returns retained terminal errors before `explicit_request_matches?/4`. The probe first records a missing mapping, then reuses the UUID with an existing mapping and explicit configuration. Expected `request_conflict`; actual `mapping_unavailable`. Validate request identity before retained return and commit a regression, preserving identical retry semantics.
2. **Required integration/runtime evidence missing:** resolve Chromium environment denial through the authorized execution environment, then run fresh manifest checks. Runtime remains unexecuted; do not infer success from earlier receipts.
3. **Required coverage absent:** close the matrix gaps above, including feedback 8–11. Runtime driver lacks late-fact/strategy-switch setup, independent expected persisted price and full fixture financial comparison; its shared issuance check precedes fixture creation.
4. **Readiness inconsistency:** tasks T027/T029 are checked, but current develop handoff records two integration failures and runtime/readiness not run. Reconcile only after actual passing evidence. Diff review was interrupted by the mandated failure stop; complete remaining file-sized review before a PASS.

Return through development feedback; QA performed no remediation.

Verdict: FAIL

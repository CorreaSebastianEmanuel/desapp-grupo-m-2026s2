# Independent QA — TASK-026

2026-10-18. Reviewed active binding, complete spec/plan/tasks, architecture/develop handoffs, current feedback, manifest, tracked diff and new quote modules, migrations, tests and runtime driver. No implementation changes, agents, workflow invocation or historical reports/log inspection.

## Executed evidence

Commands below use `python3 scripts/agentflow_check.py CHECK_ID --stage qa`, without reuse. Receipt identifiers are the command's returned evidence references, not developer receipts. Service access required execution outside the sandbox.

| Check | Independent outcome |
|---|---|
| preflight | Initial sandbox failure, 7.215 s (`384a3511`); direct diagnostic reported PostgreSQL TCP `:eperm` and Redis unavailable. Outside sandbox PASS, 1.390 s (`28c07a02`). |
| format | PASS, 1.244 s (`030fc79a`). |
| compile | PASS, 0.627 s (`87a21d27`). |
| unit | PASS, 33.205 s (`4d0978ad`). |
| integration | FAIL before tests, 0.198 s (`7d2beeaa`). Direct rerun `MIX_OS_CONCURRENCY_LOCK=0 MIX_ENV=test sh scripts/test_profile.sh integration` also failed: `CP1_PROFILE_OUTCOME profile=integration status=failed category=node-runtime`. Evidence: `/tmp/task026-qa-integration-diagnostic.log`. `node --version` returned `v20.18.1`; script requires `^v24\.`. Two unchanged failures: stopped, no bypass. |
| runtime | NOT RUN after retry-limit stop; required runtime acceptance remains blocked. |

Recorded manifest elapsed time: 43.879 s, including failed sandbox preflight. No affected HTTP controller/router/web files exist in the diff; internal contract explicitly excludes HTTP. HTTP requests are therefore inapplicable, not a substitute for the blocked fresh-process runtime check.

## Acceptance evidence matrix

“Unverified” means no fresh passing integration/runtime acceptance evidence, regardless of developer claims.

| Spec criteria | Evidence inspected and assessment |
|---|---|
| US1.1/1.3; FR-001/003; SC-001 | `calculation_test.exs` checks accepted facts, active selection and exact 1.25 price; `history_test.exs` uses explicit saved version. Unverified execution. |
| US1.2; FR-002 | Calculation test changes selection **after completion**, then retries. No controlled concurrent selection barrier as T007 requires. Unverified concurrency criterion. |
| US1.4; US2.1/2.3; FR-004/005/012; SC-002 | History/replay tests retain membership after late facts; fresh-process replay exists. No missing-original failure or no-quote restart assertions there. Unverified execution; incomplete adversarial coverage. |
| US1.5; FR-006; SC-006 | Unit checks exact 2 × 1.25, 1.005 tie, tiny rounded zero, negative score, invalid scales, monotonicity/context independence. PASS at unit level. Integration no-quote persistence remains unverified; zero-score case absent from conversion test. |
| US2.2; FR-010; SC-003 | Sequential duplicate and two-client canonical dedup tests exist. No pre-commit failure/lost-ack interruption injection. Unverified execution. |
| US2.4; FR-007/011; SC-007 | Outcomes test covers empty week and rounded-zero only. Unsupported/invalid/unreproducible/exhausted paths and full financial snapshots are not established. Unverified. |
| US3.1/3.2; FR-008; SC-005 | Import test asserts one-member snapshot and replay dedup. Does not establish prior accepted members, two imports before dispatch, multiple scopes or legacy intent failure. Unverified. |
| US3.3/3.4; FR-009; SC-004 | Followup/recovery tests assert key, duplicate acknowledgement and delivery lease fencing. No quote-confirmation crash/rollback or fake-consumer effective-work dedup proof. Unverified. |
| US3.5; FR-007/013/015 | **Blocker:** recovery selects only pending/running (`recovery.ex:12`). `retry_request` sets retrying and returns `:ok`, completing the Oban job; cron never selects that request again. 60/300-second retry and exhaustion have no tests in `recovery_test.exs`. Static defect, not runtime-proven. |
| FR-014 | Web/provider/formula scope preserved by inspected application diff. Additional workflow changes inspected; scope unit test passed. |

## Blockers and required development feedback

1. Restore Node 24 execution context, then independently complete integration and runtime checks. No acceptance PASS is justified now.
2. Repair and test retry scheduling/recovery described above. Also classify missing active/configuration as terminal validation: `quotes.ex:222–230` forwards lookup errors into generic retry at lines 173–174, contrary to the outcome contract.
3. Close the matrix's missing deterministic failure/race/crash coverage. Runtime driver merely selects an existing successful `valuation_test_*` fixture and replays/retries it; it never produces an import, interrupts dispatch, recovers it, or switches strategy. Its manifest expectation is therefore unsupported even if it exits zero. Confirmation also lacks the planned caller-transaction rejection and lease-fence validation before quote insertion; fence checking occurs only afterwards in `finish_request`.

Return to development through feedback; QA performed no remediation.

Verdict: FAIL

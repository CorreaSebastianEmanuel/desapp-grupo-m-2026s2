# Independent QA — TASK-026

2026-10-21; source HEAD `3d783f10f062fcb61c05c20018c25ba070384321`. Read active feature pointer, canonical spec/plan/tasks, architecture/develop handoffs, all current TASK-026 human feedback, manifest, internal contract, and relevant branch diff against `origin/main`. No implementation changes or developer receipt reuse.

Commands below ran from repository root with `MIX_ENV=test`, `MIX_OS_CONCURRENCY_LOCK=0`; profiles/runtime also used `TMPDIR=$PWD/tmp`. Evidence directory: `tmp/qa-task026/`.

| Independent command | Evidence/result |
|---|---|
| `mix infrastructure.verify` | `preflight.log`: PostgreSQL OK; Redis OK; exit 0, ~2 s. |
| `mix format --check-formatted` | `format.log`: exit 0. |
| `mix compile --warnings-as-errors` | `compile.log`: exit 0. |
| `sh scripts/test_profile.sh unit` | `unit.log`: expected/discovered/executed/passed **495**, status complete; exit 0, 388 s. |
| `sh scripts/test_profile.sh integration` | `integration.log`: exit 1, browser-prerequisite, 54 s. Direct launch diagnosis (`browser.log`) identifies Chromium MachPortRendezvous `Permission denied (1100)` with Node v24.21.0. One retry outside sandbox passed: `integration-retry.log`, **469/469**, status complete, exit 0, 807 s. No further retry. |
| `sh -c 'mix infrastructure.verify && mix run scripts/verify_quote_runtime.exs'` | `runtime.log`: `QUOTE_RUNTIME_ASSERTIONS_PASS`; exit 0, 20 s. Real import, stranded work, fresh-BEAM recovery/replay, later facts/strategy switch, exact 1.005→1.01, two quote-keyed events and original issuance/100 holdings assertions executed. |
| `mix test --no-compile tmp/qa-task026/adversarial_test.exs` | `adversarial.log`: **0/2 passed**, exit 2; 10.9 s ExUnit, 15 s overall. Both expected-behavior assertions failed. No unchanged repetition. |

Manifest structurally maps all 22 FR/SC IDs; this does not establish acceptance coverage. No web source or HTTP endpoint is changed, so HTTP requests are inapplicable. Runtime services/application processes started successfully.

| Acceptance criteria | Independent evidence and disposition |
|---|---|
| US1.1, US1.3; FR-001/003; SC-001 | Runtime establishes local accepted facts, saved configuration, explicit scale and independently expected late-result score/price. Integration passes the active/inactive-version assertions in calculation/history tests. |
| US1.2; FR-002 | **Coverage gap:** quote calculation test switches activation only after the first calculation completes. Existing managed-scorer barrier tests another entrypoint. No controlled in-flight Quotes/import-binding assertion establishes the full requirement. |
| US1.4; US2.1/3; FR-004/005/012; SC-002 | Runtime passes original replay across fresh processes, late facts and activation changes, preserving initial/history records. **Gap:** no quote-level missing-original replay failure assertion. |
| US1.5; FR-006; SC-006 | Unit conversion cases and runtime independently establish exact multiplication, ties-away rounding, invalid scales, negative score and rounded-zero no-quote. Zero raw score and complete persisted failure-class coverage remain absent. |
| US2.2; FR-010; SC-003 | **FAIL B1:** different unavailable mapping UUIDs reuse one request identity without conflict. Existing concurrency tests cover successful canonical deduplication, not this admission collision. |
| US2.4; FR-011; SC-007 | No-quote/outcome tests exist; runtime preserves issuance/holdings on success. **Gap:** absent/insufficient/unsupported/inconsistent inputs and complete financial snapshots for every failure category are not all asserted. |
| US3.1/2; FR-007/008; SC-005 | Runtime establishes independent accepted import/pending calculation and restart recovery. **FAIL B2:** explicit admitted calculation cannot recover from an actual precommit persistence failure through the scheduled worker path. Multi-player/week and two imports before first dispatch remain uncovered. |
| US3.3; FR-009; SC-004 | Runtime confirms persistent paired quote/events and duplicate redelivery suppression. **Gap:** no committed quote/event rollback assertion for an injected precommit failure in the committed suite. |
| US3.4 | Followup test checks repeated acknowledgement; **gap:** no fake-consumer effective-work deduplication assertion. |
| US3.5; FR-013/015 | **B2 plus coverage gaps:** recovery tests preload retry dates/counts; they do not exercise actual 60/300-second transition generation, repeated interrupted attempts, and recovery to success. Legacy intent unreproducibility and full safe error matrix are missing. |
| FR-014 | Source review confirms reuse of valuation and internal orchestration, without public APIs/UI/provider changes. |

Blockers:

- **B1:** `quotes.ex:87` discards the supplied unavailable mapping UUID and compares only scope/selector. Probe line 14 expects `request_conflict` for a different UUID; actual result is `mapping_unavailable`. This also leaves the original missing mapping identity uninspectable.
- **B2:** Probe lines 16–26 inject a failing INSERT trigger inside an isolated fixture schema, observe a durable pending explicit request, remove the failure, then execute the worker context. Expected successful; actual `retrying/temporarily_unavailable`. `process_import_request/1` always calls `Membership.snapshots(req.intent_id)` although explicit requests have nil intent IDs and retained explicit facts. Automatic recovery cannot use those facts.
- **B3:** Acceptance gaps above violate FR-015 and the checked tasks' claimed coverage. Passing broad suites cannot replace the missing assertions.

Return to development through classified Agentflow feedback; QA performed no remediation.

Verdict: FAIL

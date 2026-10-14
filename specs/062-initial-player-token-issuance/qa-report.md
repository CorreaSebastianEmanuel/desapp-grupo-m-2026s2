# Independent QA — TASK-028

Reviewed the active 062 binding, complete spec/plan/tasks, required architecture/development handoffs, all current human feedback, verification manifest, and the 25-file implementation/test diff against `2bc973f`. Current HEAD is `fad17e5`; the configuration-boundary correction is a working-tree change. No implementation changes or developer-receipt reuse occurred.

Fresh evidence: [directory](qa-evidence/independent-20261014-current/). `results.json` records exact manifest argv, environments, exits and timings; `manifest-snapshot.json`, `source-fingerprint.json`, and retained command logs identify the checked inputs. All 11 checks have passing independent executions. One failed CI attempt preceded its successful unchanged retry; total manifest execution time, including that retry, was **414.018 seconds**.

| Check / command | Fresh result and evidence |
|---|---|
| toolchain: `sh scripts/check_toolchain.sh` | Exit 0; Elixir 1.20.3 / OTP 29.0.6. |
| format: `mix format --check-formatted` | Exit 0. |
| compile: `MIX_ENV=test mix compile --warnings-as-errors` | Exit 0. |
| database_prepare: `mix infrastructure.database.test_prepare` | Exit 0; migrations current. |
| service_preflight: `mix infrastructure.verify` | Exit 0; PostgreSQL and Redis both OK. |
| prefix_regression: `mix test test/football_market/market/storage_test.exs --warnings-as-errors --only prefix_regression` | Exit 0; 1 passed. Target lock `[[1]]`; source search_path, lock rows and snapshots unchanged. |
| scope_regression: `mix test test/football_market/market/scope_test.exs --warnings-as-errors` | Exit 0; 3 passed, including six configuration negative controls. |
| committed_scope_regression: manifest Python argv | Exit 0; `shallow=true commits=1 approved_config=committed correction=scope_test_only`; 3 passed. Only corrected test overlaid; no commit created. |
| unit_profile: `sh scripts/test_profile.sh unit` | Exit 0; `audit_count=49 status=complete`. |
| integration_profile: `sh scripts/test_profile.sh integration` | Exit 0; `audit_count=87 status=complete`. Both audited profiles include performance cases and reject skipped/incomplete discovery. |
| ci_unit_tests: `MIX_ENV=test sh scripts/ci_unit_tests.sh` | First exit 2: 468/469 passed. Second exit 0: **469 passed, 4 excluded**, discovery sentinel present. See `ci_unit_tests-attempt2.json`. |

Acceptance matrix: filenames abbreviate `test/football_market/market/`; all named assertions executed through the audited profiles and complete CI suite. All 37 feature tests passed. U=unit, I=integration.

| Criterion | Executed acceptance evidence | Result |
|---|---|---|
| US1.1; FR-001–004; SC-001 | I `issuance_test`: 100 integer tokens, sole designated owner, Decimal price 1/value 100. | PASS |
| US1.2; FR-003/009; SC-005 | I `issuance_test`, `durability_test`: linked IDs, dates/version and exact facts after Repo reconnect and fresh BEAM. | PASS |
| US1.3; FR-007 | I `issuance_test`: three distinct player/season identities, independent supply and common recipient. | PASS |
| US1.4; FR-005 | I `issuance_test`: complete account/credential/API-key and Decimal balance-sentinel snapshots unchanged; scope excludes financial writes. | PASS |
| US2.1; FR-008; SC-002 | I `retry_test`: same issuance, already_completed, identical snapshots on repeated calls. | PASS |
| US2.2; FR-007; SC-002 | I `concurrency_test`: distinct backend IDs, real blocking, one issued outcome and identical successful evidence. | PASS |
| US2.3; FR-006; SC-003 | I `rollback_test`: faults at four write boundaries, sequence-confirmed execution, zero effects, successful retry. | PASS |
| US2.4; FR-008; SC-004 | I `retry_test`, `concurrency_test`: 80/20 and 0/100 fixtures; both transfer/retry lock orders preserve original facts. | PASS |
| US2.5; FR-008/009; SC-004 | I `retry_test`: later 7.15 quote and complete history retained, original quote unchanged. | PASS |
| US3.1; FR-010; SC-006 | I `rejection_test`: missing player distinctly rejected without writes. | PASS |
| US3.2; FR-010 | U `input_test`, I `rejection_test`: absent, duplicate, ambiguous and nonexistent recipients rejected before first/retry success. | PASS |
| US3.3; FR-002/004/010 | U/I input/rejection tests: wrong recipient/quantity/price, floats and unknown assertions rejected unchanged. | PASS |
| US3.4; FR-011; SC-006 | U `consistency_test`, I `rejection_test`/`storage_test`: orphan history, bad totals/missing facts/contradictory links rejected without repair. | PASS |
| US3.5; FR-001/010 | I `rejection_test`: changed recipient cannot reassign initialized player. | PASS |
| US3.6; FR-001/010 | I rejection/concurrency tests: different-player sequential/concurrent recipient conflict, only one market recipient. | PASS |
| US3.7; FR-008/011 | I `rejection_test`: invalid designation/corruption overrides already_completed. | PASS |

Additional edge evidence: rename/season identity and uninitialized getter (`issuance_test`); conflicting captured designations and both quote/issuance lock orders (`concurrency_test`); lost acknowledgement (`rollback_test`); append-only/null/FK/conservation guards (`storage_test`); negative offset holdings and contradictory original facts (`consistency_test`). FR-012–014 are covered by provider-independent issuance/restart and exact scope/profile assertions.

Independent supplemental command: `MIX_ENV=test mix run --no-compile specs/062-initial-player-token-issuance/qa-evidence/independent-20261014-current/adversarial_probe.exs`: **1 passed**. Its log confirms empty statistics/configuration, disabled provider, DB timestamp bounds, absent original-owner holding with supply 100, unchanged snapshots, and rejected nonfinite money assertions. No HTTP endpoints changed; diff and web-boundary assertions confirm HTTP runtime acceptance is inapplicable.

Blockers: none. Residual risk: initial CI run hit PostgreSQL `40P01` in existing `CatalogConcurrencyTest` concurrent team creation (`constraints_test.exs:222/279`); unchanged retry passed. `ci_failure_excerpt.txt` preserves the failure. This is outside the feature diff and remains an intermittent baseline risk, not a repaired race. Balance evidence uses sentinels because production balances are outside scope.

Verdict: PASS

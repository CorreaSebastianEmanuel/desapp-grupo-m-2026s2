Independent QA — TASK-028, 2026-10-14, current Feedback 1 (R1/P2).

Resolved `.specify/feature.json`; read the canonical specification, plan, tasks, architecture/development handoffs and current feedback. Inspected each changed implementation/test file, tracked diff and untracked inventory. Implementation remains within the 25-file plan boundary. No implementation changes, developer receipt reuse, Agentflow invocation or delegation.

Evidence directory: [independent-feedback-20261014](qa-evidence/independent-feedback-20261014/). Each check's `.json` records exact argv/environment, UTC start, exit status, duration and log hash. `summary.json` records aggregate results; `source-snapshot.json` verifies 404 source/check inputs remained unchanged through completion.

| Direct manifest command | Independent result |
|---|---|
| `sh scripts/check_toolchain.sh` | PASS; pinned Elixir/OTP/ERTS; 1.699s |
| `mix format --check-formatted` | PASS; 1.375s |
| `MIX_ENV=test mix compile --warnings-as-errors` | PASS; 1.361s |
| `MIX_ENV=test mix infrastructure.database.test_prepare` | PASS; database/migrations current; 1.918s |
| `MIX_ENV=test mix infrastructure.verify` | PASS; PostgreSQL and Redis `OK`; 2.082s |
| `MIX_ENV=test mix test test/football_market/market/storage_test.exs --warnings-as-errors --only prefix_regression` | PASS; `Result: 1 passed, 6 excluded`; 4.475s |
| `MIX_ENV=test sh scripts/test_profile.sh unit` (U) | PASS; `audit_count=49 status=complete`; 33.886s |
| `MIX_ENV=test sh scripts/test_profile.sh integration` (I) | PASS; `audit_count=87 status=complete`; 215.559s |

All eight checks ran independently, totaling 262.355s. Audited profiles enforce membership, completed execution and zero skips; the targeted prefix check intentionally excludes other storage cases, which execute in I. The initial sandbox compile failed once on Mix's TCP lock (`eperm`, 1.189s); execution with approved local-service permissions passed. No unchanged check failed twice. Logs retain this environmental failure separately as `compile-sandbox.*`.

Acceptance matrix: paths below abbreviate `test/football_market/market/`; evidence is executed assertions in U/I, inspected against spec.md rather than accepted from traceability claims.

| Acceptance criterion | Independently executed evidence |
|---|---|
| US1.1 | I `issuance_test:14`: issued outcome, integer 100, only original owner, exact Decimal price 1. |
| US1.2 | I `issuance_test:14`, `durability_test:7`: retained IDs/recipient/quantity, exact value 100, matching effective/completion dates and rule `initial_issuance/1`; reconnect and fresh BEAM retrieval. |
| US1.3 | I `issuance_test:14`: three independent player/season identities, each supply 100, same recipient. |
| US1.4 | I `issuance_test:14`: unchanged hashed account/credential/API-key and Decimal balance-sentinel snapshots. Scope test rejects account/financial writes; production has no balance model. |
| US2.1 | I `retry_test:12`: three retries return identical original issuance and unchanged complete snapshots. |
| US2.2 | I `concurrency_test:51`: distinct backends and blocking barriers; one issued, one already_completed, identical issuance, one initial quote. |
| US2.3 | I `rollback_test:7`: faults after recipient, quote, holding and final issuance writes; sequence proves fault reached; zero surviving effects and exactly one resolved retry. |
| US2.4 | I `retry_test:12`: 80/20 redistribution preserved with accounts/balances and original evidence unchanged. |
| US2.5 | I `retry_test:12`: later 7.15 quote and complete quote history preserved, original link unchanged. |
| US3.1 | I `rejection_test:12`: nonexistent player yields player_not_found, no effects. |
| US3.2 | U `input_test:6`; I `rejection_test:12`: absent, duplicate/ambiguous and nonexistent designation rejected before first/retry success; snapshots unchanged. |
| US3.3 | U `input_test:28`; I `rejection_test:12`: wrong recipient, quantity, price, floats and unsupported assertions rejected unchanged. |
| US3.4 | U `consistency_test:75,101`; I `rejection_test:59,82`: orphan history, missing/contradictory facts and invalid totals rejected without repair. |
| US3.5 | I `rejection_test:48`: changed recipient cannot reassign initialized player. |
| US3.6 | I `rejection_test:48`, `concurrency_test:65,182`: sequential/concurrent different-player recipient conflict; one market recipient. |
| US3.7 | I `rejection_test:12,82`: invalid designation/corruption overrides already_completed; state unchanged. |

Additional edge/invariant evidence: issuance tests cover rename/stable identity and unissued-not-zero semantics; durability/scope tests establish provider/statistics/strategy independence. Concurrency tests cover conflicting same-player recipients and both transfer/quote lock orders using `pg_blocking_pids`. Storage tests reject inflation, fractional/negative holdings, wrong first owner, invalid linkage, null facts and history mutation; rollback tests distinguish pre-commit interruption from lost acknowledgement.

QA-authored [adversarial_test.exs](qa-evidence/independent-feedback-20261014/adversarial_test.exs) runs via `MIX_ENV=test mix test …/adversarial_test.exs --warnings-as-errors`: two passes, 6.624s. `adversarial.log` records `QA_PREFIX_POPULATED_PASS` and `QA_ABSENT_OWNER_PASS`: explicit-prefix migration/guards preserve populated source history and search_path; absent original-owner holding remains absent with supply 100. Permanent prefix regression also passes in I. Migration line 12 explicitly qualifies the seed INSERT.

FR-001–014 and SC-001–006 are satisfied by the matrix and invariant checks. No affected HTTP endpoint exists: web/router inventory is unchanged and Market exposes only the trusted internal contract; real committed PostgreSQL/restart checks fulfill applicable runtime evidence. No blockers found.

Verdict: PASS

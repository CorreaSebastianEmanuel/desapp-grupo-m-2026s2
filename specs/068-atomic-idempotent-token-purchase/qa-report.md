# Independent QA — TASK-029

2026-10-26. Fresh QA execution and independent acceptance review support all 15 FR and six SC requirements. No blockers identified.

Reviewed PRODUCT, ARCHITECTURE, CHECKPOINTS, WORKFLOW_LESSONS, the constitution, verify skill, AGENT_VERIFICATION, current TASK-029 feedback 1–11, and canonical spec, plan, tasks, verification manifest, contracts, data model, architecture/develop handoffs and relevant implementation/tests. Prior QA/review reports were not read. Run directories were neither listed nor inspected; execution status/evidence came exclusively through the authorized stage summary.

## Fresh execution

Executed once, without receipt reuse or developer evidence substitution:

```sh
env -u MIX_BUILD_PATH   TMPDIR=/private/tmp/desapp-task029-final/tmp/qa-final   CHROMIUM_PATH='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'   AGENTFLOW_CODEX_SANDBOX_MODE=danger-full-access   python3 scripts/agentflow_stage_checks.py --stage qa
```

The selected session actually used danger-full-access. The runner exited 0: 13 passed, zero failed/blocked, 1,439,968 ms total. Reviewed the completed `python3 scripts/agentflow_stage_checks.py --stage qa --summary`; every check had a distinct QA evidence path in workspace namespace `e55955bcc8c8461d893ab47334e43451`.

| Check | Result | Seconds |
| --- | --- | ---: |
| toolchain | PASS | 2.516 |
| prepare | PASS | 2.488 |
| services | PASS | 2.364 |
| format | PASS | 2.372 |
| compile | PASS | 1.620 |
| credo | PASS | 19.130 |
| openapi | PASS | 1.583 |
| inventory | PASS | 51.264 |
| unit | PASS | 277.458 |
| integration | PASS | 981.857 |
| assets | PASS | 9.046 |
| e2e | PASS | 80.907 |
| purchase-runtime | PASS | 7.278 |

## Independent acceptance findings

**Atomicity, arithmetic and rollback.** PurchaseStore owns a READ COMMITTED transaction and rejects nesting. PostgreSQL NUMERIC multiplication and balance increments avoid Decimal context truncation; fresh transfer tests cover both buyer and recipient balances at 1e40. Finite-cent/nonnegative constraints, conserved holdings and equal immutable debit/credit evidence support exact transfer without credit creation. Rollback tests inject immediate and deferred failures across every mutated table, compare complete snapshots, and then reuse the failed key successfully. Deferred completeness/linkage and UPDATE/DELETE/TRUNCATE guards protect retained financial evidence.

**Quote, account and key races.** Reviewed separate committed connections and explicit barriers, rather than shared-sandbox timing. Both quote-first and purchase-first orderings assert the retained price and quote identity. Buyer/key advisory locking precedes completed-result lookup; matching replay bypasses changed market eligibility, conflicts preserve the original result, and unique buyer/key storage backs deduplication. Concurrent duplicate/conflicting deliveries, independent buyers sharing a key, cross-player buyer spending and competing inventory purchases are covered. Player locking shared with quote/holding writers and sorted user/balance locks support these outcomes. Fresh-process retrieval and replay preserve original evidence after later activity.

**HTTP and boundaries.** Protected routing preserves authenticated JWT/API-key identity; the controller delegates financial work. Tests reject authority overrides, malformed UUID/JSON, invalid quantities and NUL keys without effects. Domain refusals and controller mappings distinguish 400/401/404/409/503 safely. The fresh real HTTP runner asserts readiness, exact decimal-string success, identical replay, conflict, insufficient funds, malformed JSON/NUL refusal, unauthenticated challenge, unchanged rejection snapshots and persisted supply/balance/evidence counts.

**Authorized tooling scope and diagnostics.** The combined application_coverage diff changes publication containment only: reject symlinked roots/descendants, permit external symlink ancestors when resolved containment holds, and validate resolved report paths. Exact-path positive/negative scope assertions and existing unit regressions cover feedback 11; no coverage report or extra profile was added. Browser producer/supervisor/consumer tests preserve closed causes, executable selection, privacy and failure outcomes. Launcher tests retain policy conflict refusal, mode-bound identity and retry limits.

Additional independent inline checks passed: 55 diagnostic boundary/type/privacy controls; generated Node producer probes covering all five causes, Playwright missing-executable/host-dependency messages and configured executable forwarding; strict supervisor sentinel rejection; and in-memory stage recovery rejecting invalid direct fields while retaining complete valid recovered case/event details and failed status. Synthetic I/O was mocked; these probes accessed no run files. Actual CI parity also passed with zero additional native profile runs.

No acceptance gaps remain within TASK-029. Future writers must preserve documented lock ordering; no throughput SLA or deferred funding/sales/chart behavior is claimed.

Verdict: PASS

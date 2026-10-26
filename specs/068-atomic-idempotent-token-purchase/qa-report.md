# Independent semantic QA — TASK-029

2026-10-26. No blocking acceptance findings. Reviewed the current specification, plan, tasks, purchase and diagnostic contracts, data model, feedback 1–11, architecture decisions, implementation and behavioral tests against PRODUCT, ARCHITECTURE, CHECKPOINTS, WORKFLOW_LESSONS and the constitution.

The ordered QA stage summary reports all 13 manifest checks passed. Independently validated all 13 current QA receipts using `current_receipt(..., stage="qa")`: workspace/stage, zero exit status, source before/after, canonical inputs, command/environment identity and output hashes match. Validation used the documented system Chrome path and the actual danger-full-access mode; the initial validation without CHROMIUM_PATH correctly refused integration identity. No developer receipts were substituted and no historical run directories were manually inspected. This semantic session accepts the completed fresh QA stage; it did not rerun the full manifest.

| Check | Outcome | Evidence |
|---|---|---|
| `toolchain` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/toolchain/1a78d30ac8b34fa2bc855f6f59c40d23.log |
| `prepare` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/prepare/7ebc75a929ef4ff2a6b6f2680bf69868.log |
| `services` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/services/b5e9f5be552448e9ba511debb6ed3049.log |
| `format` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/format/3ca44910432e422dbbe15c32f5279966.log |
| `compile` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/compile/cfa77f254f5d42578a7ab4fb910a172a.log |
| `credo` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/credo/83fbd44129b2499b815e5d49962ebe4a.log |
| `openapi` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/openapi/de462988f74e475fa5bb5298720d7783.log |
| `inventory` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/inventory/5360e39df9f94aea8e6479d6c0cb05cf.log |
| `unit` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/unit/553390ef397748f581c8506d1f8e4405.log |
| `integration` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/integration/c09f7e65675b465aae66d7a2fda91e96.log |
| `assets` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/assets/f0731a617351412db49aff6c29017bab.log |
| `e2e` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/e2e/40e5f1105dcf4ae6b436361261bfaa97.log |
| `purchase-runtime` | passed | .agentflow/runs/checks/e55955bcc8c8461d893ab47334e43451/068-atomic-idempotent-token-purchase/qa/purchase-runtime/f181107540e1414ea732efd6e895007b.log |

## Independent acceptance

- **US1 / FR-001–009 / SC-001,004,005:** authenticated actor identity and strict input prevent caller price, seller or buyer overrides. Market owns orchestration and persistence; the controller only adapts input/output. Purchases source the fixed recipient's inventory, preserve each player's 100-token supply and move existing credits equally. PostgreSQL NUMERIC multiplication and balance updates preserve exact cents, including the committed 1e40 buyer/recipient regressions. The retained quote ID and effective/version facts match the price used. No funding, fees or token creation is introduced.
- **US2 / FR-010–011,013 / SC-002:** buyer/key advisory locking precedes completed-result lookup, with database uniqueness as a backstop. Matching replay returns original immutable evidence before mutable eligibility; changed player/quantity conflicts. Committed duplicate/conflict tests use separate connections, and the same key is independent across buyers. Fresh-BEAM retrieval, replay after later activity and lost-acknowledgement behavior are covered.
- **US3 / FR-006–008,012–014 / SC-003,006:** rejection snapshots cover absent/invalid quotes, missing/uninitialized players, insufficient funds/inventory, self-purchase and inconsistent supply. Input/HTTP tests cover quantity, UUID, Unicode key bounds, NUL bytes, authentication and authority fields. Failed keys remain reusable. Immediate and deferred fault injection across every mutated table proves rollback; nested transactions are refused before premature success. Deferred evidence guards and ordinary UPDATE/DELETE/TRUNCATE refusal preserve append-only history.
- **Concurrency:** inspected the committed-connection helpers and explicit database barriers. Quote-first and purchase-first cases prove distinct lock orders and the precise retained quote. The shared player lock coordinates quote confirmation and holdings; sorted user/balance locks serialize cross-player spending and recipient credit changes. Inventory races, cross-player double spending and concurrent key deliveries assert one allowed outcome and conserved state.
- **FR-014–015 and checkpoint boundary:** the manifest maps all 15 FR and six SC requirements to the existing unit/integration/E2E and real HTTP checks. The live HTTP probe asserts PostgreSQL/Redis/endpoint readiness, exact money strings, authenticated success, replay/conflict, malformed JSON/NUL rejection, insufficient funds, 401 challenge, unchanged rejection snapshots and persisted ledger/transfer/balance/supply counts. Charts, sales, conditional orders and funding remain outside this implementation.
- **Authorized tooling:** reviewed the bounded browser-cause protocol, registered discrepancy/event summaries, effective sandbox and retry identity, nested Mix environment isolation, exact-path scope assertions and publication containment. Narrow regressions exercise malformed/secret output refusal, configured/default browser selection, valid summary recovery and unsafe symlink publication refusal. Existing full QA profiles provide the launcher, inventory and scope checks; CI parity independently confirms the actual unit/integration pair without launching another full profile.

## Additional checks executed in this semantic session

- `MIX_ENV=test ERL_FLAGS='+S 4:4' MIX_TEST_PARTITION=_task029_20261023 mise exec -- mix test test/football_market/market/purchases test/football_market_web/controllers/purchase_controller_test.exs`: **29 passed**, 100.5 seconds. Expected injected database errors and migration-module redefinition warnings occurred; the command exited zero.
- Targeted `mise exec -- python3 -m unittest` selections: **8 passed** across safe diagnostic privacy/registration, generated Playwright closed causes, strict supervisor forwarding, configured/default Chromium, publication containment, complete stage-summary preservation and safe-evidence recovery.
- `python3 scripts/agentflow_stage_checks.py --ci-parity`: **passed**, workflow copies match, wrapper contract passed, zero additional native profile runs.
- Current QA receipt validation with documented CHROMIUM_PATH: **13/13 passed**. Evidence references are retained in the table above.

Residual obligation: future financial writers must preserve ADR-0032 lock ordering; no throughput SLA is claimed. T035 final review remains independent and pending. This QA changed no implementation or task checkboxes and grants no merge authorization.

Verdict: PASS

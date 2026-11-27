# Independent QA — TASK-059

2026-10-27. Active feature: `.specify/feature.json`; branch contract: `059-conditional-buy-order-domain-and-api`. Read canonical policy, spec, plan, tasks, architecture/develop handoffs, all current TASK-059 feedback, manifest and implementation/test diff. No implementation changes, agents, verify skill or Agentflow CLI invocation.

Fresh ordered execution: `python3 scripts/agentflow_stage_checks.py --stage qa` (no reuse), exit 0: **21 passed, 0 failed, 0 blocked**, 1097.497s. No retries. Browser execution used the per-command escalation authorized by feedback 3. PostgreSQL/Redis prerequisites and actual listener checks passed.

Check evidence: `python3 scripts/agentflow_stage_checks.py --stage qa --summary`; captured in `tmp/qa-task059/manifest-summary.json`, linking each fresh QA receipt/output. Commands are the exact argv in `verification.json`.

| Check | Outcome | Seconds |
|---|---|---:|
| toolchain | PASS | 1.576 |
| preflight | PASS | 2.018 |
| format | PASS | 1.469 |
| compile | PASS | 1.227 |
| credo | PASS | 11.990 |
| openapi | PASS | 0.726 |
| inventory | PASS | 30.676 |
| ci-parity | PASS | 2.027 |
| handoff-contract | PASS | 0.393 |
| unit | PASS | 185.300 |
| integration | PASS | 694.859 |
| assets | PASS | 1.489 |
| e2e | PASS | 47.041 |
| http | PASS | 4.855 |
| purchase-focused | PASS | 20.493 |
| orders-unit-focused | PASS | 1.787 |
| orders-focused | PASS | 31.878 |
| evaluator-focused | PASS | 29.784 |
| cancel-focused | PASS | 24.234 |
| scope-focused | PASS | 1.859 |
| artifacts | PASS | 0.311 |

Acceptance matrix: test filenames below refer to `test/football_market/market/conditional_orders/`; controller refers to `test/football_market_web/controllers/conditional_order_controller_test.exs`. Each cited suite was freshly executed above.

| Acceptance / requirements | Evidence and observed result |
|---|---|
| US1.1,.4; FR-001/002/010/015 | input, creation, storage, controller: exact immutable terms, future UTC expiry, integer 1–100, finite cents; forged/missing/invalid inputs rejected; creation leaves financial snapshots unchanged. |
| US1.2; US3.5; FR-013; SC-005 | reads/controller plus extra HTTP: two actual order owners see only their own lists; mutual foreign/absent/malformed detail/cancel return indistinguishable 404; anonymous requests return 401 without mutation. |
| US1.3; US2.2; FR-005 | evaluation: above-limit, absent, zero, negative, NaN/Infinity quotes remain pending with no effects. |
| US1.5–.7; US3.2; FR-012/019/022; SC-007 | projection: all five statuses at expiry −1/0/+1 microsecond; reads: unchanged order/job snapshots before/after expiry and persisted expiration. Extra HTTP crosses natural expiry without editing terms: pending/true, unchanged snapshots, then cancellation persists expired. |
| US2.1,.3,.5; FR-006/007/014; SC-001 | evaluation/controller/HTTP: equality and below-limit execute full quantity at authoritative 1.00, total 3.00 and matching completion; both insufficiencies expose distinct reasons without partial writes. |
| US2.4; FR-009; SC-002 | concurrency: four committed evaluations and ambiguous-ack replay produce one conditional purchase; colliding arbitrary direct keys retain separate replay identities. |
| US2.6; FR-020; SC-008 | quote_order: independent connections/barriers force both serialization orders; newer 1.25 quote prevents old 1.00 authorization; evaluation-first retains its original quote. Lock wait crossing expiry expires without purchase. |
| US3.1,.3,.4; FR-003/011; SC-004 | cancellation/cancellation_race: both forced winners produce identical terminal outcomes for both callers; terminal retries preserve evidence and financial cardinalities. |
| FR-008/016/018; SC-003/006 | rollback: 18 immediate/deferred fault boundaries preserve complete snapshots, then retry succeeds. storage verifies legacy-row upgrade, reciprocal linkage and append-only guards. contention covers shared balance/direct trades. Extra stock test: concurrent 60+60 requests yield executed/rejected, one purchase, buyer 60 tokens/940 credits, supply 100. |
| FR-017 | scope plus source/diff review: separated web/domain/persistence; no workers, UI, funding, reservations, partial fills or external adapters introduced. |
| US2.7; FR-004/021 | handoff and handoff-contract PASS for transaction-composable create rollback and complete pending/due/no-quote candidate traversal. Durable dispatch, missed-delivery replay and expiry recovery remain explicitly assigned to TASK-060; future worker correctness is not established here. TASK-061 owns UI. |

Additional independent commands (exit 0):

- `MIX_ENV=test ERL_FLAGS='+S 4:4' mise exec -- mix run tmp/qa-task059/http_extra.exs`
- `MIX_ENV=test ERL_FLAGS='+S 4:4' mise exec -- mix test tmp/qa-task059/inventory_contention_test.exs` — `Result: 1 passed`.

The HTTP extension uses the delivered owned-schema/listener harness and adds QA assertions. All 66 captured responses include `Content-Type: application/json; charset=utf-8`; structured evidence: `tmp/qa-task059/http-responses.jsonl`.

| Real HTTP surface | Status / headers / response evidence |
|---|---|
| POST collection | 201 + Location resource path; pending, exact terms, no reservation. Invalid JSON/null/array/empty/money/expiry/owner: 400 invalid_request; missing player 404; uninitialized/self 409. |
| GET collection/detail | 200 owner data; pending/expiry_reached, terminal execution/rejection facts; foreign/missing/malformed detail 404 not_found; unsupported queries 400. |
| POST detail/cancel | 200 cancelled/expired or unchanged terminal outcome; empty body accepted; injected terms/query 400; foreign/missing/malformed 404. |
| All four operations | Anonymous 401 unauthenticated + `WWW-Authenticate: Bearer realm="api"`; unavailable storage 503 temporarily_unavailable, independently exercised on every route. |

Response totals: 200×24, 201×4, 400×16, 401×4, 404×11, 409×2, 503×5. Unsupported PUT also returned 404. Row/job/financial snapshots and SQL invariants passed. Implementation diff hash remained unchanged across supplemental QA.

Blockers: none within TASK-059. CP2 automated execution/recovery and UI remain downstream obligations.

Verdict: PASS

# Authenticated conditional order contracts

Reuse AuthenticateAPI (JWT or API key), JSON envelope/security/error definitions and route metadata authentication_policy: api_protected. Identity always comes from authenticated actor. No caller-selected owner/seller/execution quote/total/status. No update or evaluation HTTP interface. Publish exact operations in priv/static/openapi.json; this document is the implementation contract.

| Method and route | Input | Success | Failure |
| --- | --- | --- | --- |
| POST /api/conditional-orders | JSON object with exactly player_id UUID, quantity integer 1..100, maximum_unit_price decimal string, expires_at RFC3339 UTC timestamp | 201, data order; Location /api/conditional-orders/{id} | 400 invalid_request; 404 player_not_found; 409 not_initialized/self_purchase; 503 temporarily_unavailable |
| GET /api/conditional-orders | No filters selecting another owner | 200, data array ordered created_at/id ascending, including empty [] | 503 temporarily_unavailable |
| GET /api/conditional-orders/{id} | UUID path | 200, data order | 404 not_found for absent/malformed/foreign ID; 503 temporarily_unavailable |
| POST /api/conditional-orders/{id}/cancel | Empty object or empty body; reject nonempty terms | 200, data existing terminal outcome or new cancelled/expired outcome | 400 invalid_request; 404 not_found for absent/malformed/foreign ID; 503 temporarily_unavailable |

All operations require authentication: 401 error.code unauthenticated plus existing WWW-Authenticate challenge; fail without mutation. Responses have application/json. Errors use {error:{code:...}}, no resource details for non-owner. Unknown create keys, owner_id, float money, default/missing expiry, invalid timestamps/precision/quantities and unsupported immutable-term update requests fail safely; no PATCH/PUT route. Reject unsupported nonempty query parameters with 400 rather than offering owner selection.

Order data: id, player_id, quantity, maximum_unit_price (fixed two-place string), created_at/expires_at UTC RFC3339, status, expiry_reached boolean, completed_at (null until terminal), rejection_reason (null unless rejected), execution (null unless executed). Execution: purchase_id, quote_id, unit_price, total, completed_at using actual immutable purchase facts. No other owner's details, internal keys or credentials. Limit supports exact cents, finite >0; expires_at explicit UTC (`Z` or `+00:00`) with at most six fractional places, no silent rounding. Creation response has persisted pending status; scheduling/execution is TASK-060.

GET/list never updates status or enqueues evaluation, including at expiry. Terminal result is immutable; expiry_reached may still change with time. Cancel before expiry returns cancelled; due pending cancellation returns expired; already terminal returns same outcome. Insufficient funds/inventory during evaluation are order outcomes, not HTTP create errors, because creation reserves nothing.

## Internal Market integration

- create validates authenticated owner and commits pending terms only. Transaction-local creation participant supports TASK-060 composing order plus job in a future single transaction; it must not return a public success before commit.
- evaluate(order_id) is trusted internal, owns its transaction and ignores/rejects event-price authorization. Returns committed order outcome, unchanged pending/terminal outcome, or retryable temporarily_unavailable error; never silently rejects an infrastructure failure.
- pending_candidates(player_id, after_id, limit <=100) returns read-only bounded persisted pending rows, including due expiries, so recovery can revisit them. No claim/enqueue side effects or priority guarantee.
- TASK-060 is responsible for durable create dispatch, quote-confirmation atomic handoff and missed delivery/expiry sweeps; see task060-handoff.json. Existing row replayability is not proof that a worker performs recovery.

## Runtime assertions to implement

Invocation-owned schema/fixtures and real Endpoint/Bandit HTTP. Await service/HTTP readiness with deadlines; fail unavailable services. Assert 201/Location/body and unchanged balances/holdings on create; list and detail 200 plus exact terms; invalid 400 and uninitialized 409; anonymous 401/challenge; foreign/missing detail and cancellation identical 404; cancel 200 terminal, repeat identical; read/list before and after expiry, persisted expiry transition and no new jobs; manually call trusted evaluator for executed/rejected fixtures and verify GET actual quote/total/reason. Compare financial/job snapshots around every rejected/read request. Probe unsupported updates for no mutation. Verify SQL invariant totals and one purchase/transfer/debit-credit pair after repeated evaluation. Always stop server and clean only owned fixtures. Exact-at-expiry projection is tested with deterministic time in unit/integration tests, not a flaky wall-clock HTTP equality assertion.

# Implementation Plan: Conditional Buy Orders

**Branch**: `059-conditional-buy-order-domain-and-api` | **Date**: 2026-10-27 | **Spec**: [spec.md](spec.md)
**Input**: TASK-059, `specs/070-conditional-buy-orders/spec.md`; current `backlog/feedback/TASK-059.md`.

## Summary

Add owner-scoped conditional buy instructions to Market and authenticated REST access. Reuse the authoritative purchase calculation and financial writes in a single transaction with order completion. No reservations, partial fills, funding, scheduling workers or UI. TASK-060 adds durable dispatch/recovery; TASK-061 adds presentation. ADR-0036 resolves the critic and purchase composition; ADR-0032 remains the lock/evidence baseline.

## Technical Context

**Language/Version**: Elixir 1.20.3 / OTP 29.0.6, as `.tool-versions`.
**Primary Dependencies**: Existing Phoenix 1.8, Ecto SQL/Postgrex, Decimal, Jason; existing Oban integration is consumed in TASK-060 only. No new dependency.
**Storage**: PostgreSQL 17.6 authoritative; unconstrained NUMERIC with finite-positive and exact cents constraints. Redis remains existing local infrastructure, never order authority.
**Testing**: ExUnit unit/integration with reviewed native inventory, actual HTTP through Bandit and :httpc, existing browser E2E regression profile. Node 24 and locked Playwright/Chromium per `docs/TEST_PROFILES.md`.
**Target Platform / Type**: Local Linux modular Phoenix web service.
**Performance Goals**: No new latency, throughput, fairness or real-time guarantee; one order decision per transaction, indexed owner and pending-player queries, bounded candidate pages.
**Constraints**: Supply 100, exact cents, nonnegative balances, append-only financial evidence and immutable quotes. Explicit UTC expiry; no default duration. Existing provisioned funds only.
**Scale/Scope**: Three P1 stories, one order relation, a narrow purchase-origin extension, four REST operations. No cache, external adapter, worker, browser feature or funding change.

## Constitution Check

Before design: PASS — complete behavioral spec and approved feedback; modular monolith, existing financial/quote authority and no technology unknown requiring outside research. Independent challenge is available in handoffs/product-challenge.md; no human choice remains.
After design: PASS — each changed behavior receives test-first work; database constraints and transactions preserve domain invariants; web only authenticates/parses/renders, Market owns commands, persistence owns SQL. Independent QA/review remain downstream tasks. No violation or complexity exemption. This stage creates design only and makes no implementation/test-success claim.

## Design and implementation boundary

### Ownership and public domain surface

`FootballMarket.Market.ConditionalOrders` exposes create(actor, terms), list(actor), get(actor, id), cancel(actor, id), evaluate(id). Creation accepts only player_id, quantity, maximum_unit_price and expires_at; identity comes from AuthenticatedActor. Evaluate is trusted internal API, never an HTTP operation. Query every read/cancel by owner as well as ID; use identical not_found for absent, malformed or foreign IDs after authentication. Lists contain only that owner's rows, ordered created_at/id ascending. Terminal evidence is stable except derived expiry_reached.

Creation validates initialized player, integer 1..100, finite positive cents, explicit future UTC timestamp with microsecond precision and immutable key allowlist. Use current database wall clock for creation/expiry comparison; no float coercion or rounding. Unknown player returns not_found; uninitialized returns not_initialized; preserve existing self-purchase exclusion at creation. No funds/inventory availability precondition or mutation. New public creates are distinct instructions; create-request deduplication is not added.

`ConditionalOrderStore` owns command transactions and side-effect-free queries. A module-private transaction participant allows TASK-060 to compose creation with durable enqueue later; ordinary create owns commit and rejects caller transactions. Candidate reads filter persisted pending rows, including due rows, using player/id cursor with bounded 100-row pages; no claim leases, dispatch or updates. TASK-060 owns sweeps and progress cursors, including expiry independent of quote availability. Reads never invoke the candidate seam or publish work.

### Transaction and lifecycle

Follow ADR-0036: terminal shortcut under order FOR UPDATE; conditional identity; player; sorted users/balances. Public purchase keeps its existing transaction ownership and errors; extract shared locked purchase preparation/write primitives into `market/purchase_transaction.ex`. Reject opening nested public purchase transactions. Direct idempotency lookup filters conditional_order_id IS NULL and retains all accepted key strings. Conditional uniqueness is order_id, independent of client request_key.

Separate lock acquisition from quote lookup and resource eligibility in the extracted participant: no missing-quote or insufficiency early return may precede the evaluator expiry check. After blocking locks sample clock_timestamp(), then expiry, then one Quotes.latest decision under the player lock. A due order becomes expired even with no quote, high quote or insufficient resources. Absent/invalid/nonpositive/high current quote leaves an unexpired order pending. Qualifying quote plus insufficient funds/inventory commits distinguishable rejected reason before financial writes. Other business/integrity errors fail closed and roll back; do not misclassify transient storage errors as business rejection. All successful financial effects and executed evidence commit together. Rollback injection at every write boundary must leave neither terminal execution nor purchase/ledger/transfer/projection deltas. Terminal evaluation preserves original outcome across retries and ambiguous acknowledgements.

Cancel locks the owner-scoped order. If terminal, return its existing outcome; if due, persist expired; otherwise persist cancelled. Competing cancellation/execution chooses one lock winner. A qualifying decision made before expiry may commit afterward: the eligibility point is after locks and before writes, not transaction start or HTTP arrival. Tests must hold a blocking lock until expiry to prove an earlier transaction timestamp cannot authorize purchase.

GET/list selects persisted status plus one database-clock-derived expiry_reached boolean for every state. No mutation, expiry persistence, job insertion or PubSub. Domain projection tests sample deterministic before/equal/after instants; persistence tests inspect both order and job tables. Read exactly-at-expiry is a projection unit boundary; real HTTP tests bracket it and persisted post-expiry state without relying on scheduler timing.

### Persistence and interfaces

See data-model.md and contracts/orders.md. Add order schema, indexes, immutable-terms/terminal triggers and commit-time reciprocal purchase integrity. Existing balance, transfer, ledger, supply and quote guards remain enforced. Add conditional_order_id with nullable deferred FK and unique index, update buyer/key unique constraint and evidence guards without rewriting historical purchases. Validate migrations against existing direct rows, rollback attempts and new conditional evidence. No financial history UPDATE/DELETE/TRUNCATE is permitted.

Web adds the four protected routes, JSON serializer and OpenAPI definitions/security/error schemas. Reuse AuthenticateAPI and its JWT/API-key policy. Update exact route/OpenAPI assertions and inherited scope guards deliberately; never weaken them to permit arbitrary additions. No authorization from request owner fields. Contract tests cover unknown keys, missing terms, unsupported updates, storage 503, 401 challenges, 404 anti-enumeration, terminal cancellation and JSON exact amounts.

### Critic resolutions and durable decisions

ADR-0036 records: expiry precedes all other outcomes; creation eligibility has no execution deadline; contention has no promised global winner; reads are pure; defaults/order priority proposed in ADR-0017 are superseded by accepted spec. Quote race tests use independent committed connections and barriers proving both serialization orders, not sequential calls or shared Sandbox connections. Stale event hints cannot authorize execution; evaluate takes an ID, not a price.

Research resolves only the concrete composition and identity unknowns in local source; see research.md. Spec's former FR-004a is renumbered FR-022 solely for the numeric identifier validator; its complete behavioral text is unchanged.

## Checkpoint and acceptance coverage

TASK-059 contributes domain/API groundwork to the CP2 additional feature. CP2's full worker/UI demo requires TASK-060/061 and remains undelivered here. Existing separate unit/integration and actual browser E2E checks are preserved; regression E2E does not claim conditional-order UI coverage. No historical CP1 coverage report or application-coverage profile rerun is added. CI retains its coverage/Sonar obligations.

verification.json maps all 30 numeric FR/SC identifiers, including FR-022. Acceptance scenarios are numbered within stories rather than AC identifiers; their concrete mapping is below. FR-004 and FR-021 include a TASK-060 obligation: this task verifies eligibility/candidate seams and the executable downstream contract declaration, not future durable-worker correctness. `handoff-contract` checks the owner and exact required recovery scenarios; independent QA must explicitly retain the external obligation. It must not report full scheduling/recovery delivered based on this declaration. TASK-060 must implement and independently execute those integration scenarios. TASK-059 is not expanded to implement workers just to make the mapping appear complete.

| Spec scenarios / invariant | Executable assertion location and manifest check |
| --- | --- |
| US1.1, .2, .4 | input_test, creation_test, controller test; unit/integration/http |
| US1.3; US2.2 | evaluation_test: above limit, absent/invalid/nonpositive quote, no effects; integration |
| US1.5–.7; US3.2; FR-019/022 | projection_test and reads_test: before/equal/after/durably expired plus no updates/jobs; unit/integration/http |
| US2.1, .3, .5; SC-001/003 | evaluation_test: equality/below, actual quote/total, both insufficiencies; integration/http |
| US2.4; SC-002 | concurrency_test: repeated, simultaneous, ambiguous acknowledgement, direct-key collision; integration |
| US2.6; SC-008 | quote_order_test: both committed lock orders, stale event, no mixed eligibility/price; integration |
| US2.7; FR-004/021 | handoff_test verifies replayable pending/due candidates and composable create rollback; handoff-contract validates TASK-060 test obligations; future durable delivery proof remains TASK-060 |
| US3.1, .3–.5; SC-004/005 | cancellation_test, cancellation_race_test, controller test and http |
| FR-008/016/018; SC-006 | rollback_test, storage_test, contention_test and existing purchases tests: no partial effects, 100 supply, exact/nonnegative balances, immutable evidence/quotes; integration |
| FR-017 and boundaries | scope_test plus diff review: no workers/UI/funding/cache/providers or extra trade types; unit and independent review |

## Verification execution

Implement the planned preflight and runtime scripts before developer checks. `preflight` verifies configured test PostgreSQL SELECT 1 and Redis PONG with bounded timeouts and restores configuration; it must not start/reset shared services or print secrets. HTTP check itself repeats readiness, provisions an invocation-owned schema and deterministic fixtures, starts actual Endpoint/Bandit on a dynamic loopback port, waits with a deadline and asserts every affected route's status/header/JSON plus database effects. Always stop its server and release owned resources. Unavailable services fail, never skip. `test/runtime/conditional_orders_http.exs` follows existing test/runtime/purchase_http.exs isolation.

Unit and integration profile checks run once each after all source/design edits; focused tests during red/green development do not substitute final profiles. e2e is the existing actual-browser regression, built assets first. Use the exact mise profile commands for CI parity. Input/projection/scope modules carry the unit tag; storage/domain/HTTP/controller/committed-concurrency modules carry integration. Runtime .exs runners and test/support helpers are classified with explicit inventory reasons and are not silently discovered as duplicate profile cases. Inventory tracks new cases, helpers and source roles; update config/test_profiles.json, config/credo_inventory.json and config/application_coverage_inventory.json without adding coverage report execution. No CI or test assertion weakening. Backend-only scope means no new browser journey is invented here.

Developer executes ordered manifest with `python3 scripts/agentflow_stage_checks.py --stage develop --reuse`, then readiness; QA repeats independently without reuse. Runtime/preflight always fresh; failure blocks dependent checks. No parallel/shared-database execution is declared safe. Static independent checks have explicit empty state effects where warranted. Preserve failure budgets in docs/AGENT_VERIFICATION.md. Only QA/review tasks can remain unchecked after development.

## Project Structure

Feature artifacts: plan.md, research.md, data-model.md, contracts/orders.md, contracts/task060-handoff.json, quickstart.md, verification.json, tasks.md and delta handoffs. Downstream qa-report.md/review-report.md belong to independent gates.

Source boundary (repository-relative):
- lib/football_market/market/conditional_orders.ex, conditional_order.ex, conditional_order_input.ex, conditional_order_store.ex, conditional_order_projection.ex
- lib/football_market/market/purchase_transaction.ex; narrow edits to purchase_store.ex, purchase.ex and market.ex
- lib/football_market_web/controllers/conditional_order_controller.ex, conditional_order_json.ex; router.ex
- priv/repo/migrations/20261027000000_create_conditional_buy_orders.exs; priv/static/openapi.json
- test/football_market/market/conditional_orders/*_test.exs; test/support/conditional_orders/case.ex and runtime_probe.ex
- test/football_market_web/controllers/conditional_order_controller_test.exs; inherited route/scope/contract tests where exact contracts change
- scripts/verify_conditional_orders_preflight.exs; test/runtime/conditional_orders_http.exs
- config/test_profiles.json, config/credo_inventory.json, config/application_coverage_inventory.json for new sources/cases/helpers.

Inherited compatibility changes also cover ErrorJSON for malformed order JSON, exact OpenAPI browser discovery and the literal WorkflowScope allowance; these introduce no additional product surface. Focused development checks in verification.json retain the direct-purchase, input/projection, create/read/storage/handoff, evaluator, cancellation and scope regressions alongside final profiles.

Other application changes require a concrete dependency within this boundary. No quote-confirmation scheduling changes in TASK-059; current quote-lock behavior is regression tested through its existing API.

## Complexity Tracking

No constitutional deviation. ADR-0036 records the necessary transaction refactor and durable differences from earlier proposals.

## Artifact applicability

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve concrete existing purchase composition and direct-key collision risks from local source."},
  "data_model": {"required": true, "reason": "New lifecycle relation and reciprocal purchase-origin linkage."},
  "contracts": {"required": true, "reason": "Four authenticated REST operations and TASK-060 integration seam."},
  "quickstart": {"required": true, "reason": "Feature-specific HTTP/runtime fixtures and owner/evaluator demo with no workers."}
}
```

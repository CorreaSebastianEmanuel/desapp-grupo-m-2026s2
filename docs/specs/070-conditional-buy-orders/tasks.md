# Tasks: Conditional Buy Orders

**Input**: `specs/070-conditional-buy-orders/`; TASK-059 on `059-conditional-buy-order-domain-and-api`.
**Prerequisites**: spec.md, plan.md, verification.json and the four applicable supporting artifacts. ADR-0036 controls composition and lifecycle authority.
**Tests**: Required by FR-018/019/020 and repository rules. Write each behavior test first, run it and establish the expected failure before corresponding implementation; fixture/setup failures are not a valid red assertion. All tasks start unchecked. A single implementation owner executes the whole list; [P] indicates independent file work, not permission to run shared-database checks concurrently.

## Phase 1: Setup

- [X] T001 Verify pinned toolchain and existing configured PostgreSQL/Redis prerequisites using `.tool-versions`, `docs/TEST_PROFILES.md` and `scripts/check_toolchain.sh`; record any blocker without resetting shared services in `specs/070-conditional-buy-orders/handoffs/develop.md`.
- [X] T002 Create `scripts/verify_conditional_orders_preflight.exs` following `test/runtime/purchase_http.exs` configuration access: bounded test-database SELECT 1 and Redis PONG, nonzero on failure, no credential output, no shared lifecycle mutation; keep `specs/070-conditional-buy-orders/verification.json` commands synchronized.

## Phase 2: Foundational — preserve direct purchase behavior

Blocks all stories. Existing public direct transaction ownership and arbitrary request-key replay must remain stable.

- [X] T003 Add regression assertions before refactoring in `test/football_market/market/purchases/idempotency_test.exs`, `test/football_market/market/purchases/rollback_test.exs` and `test/football_market/market/purchases/quote_order_test.exs`: public caller-transaction refusal, arbitrary direct keys, committed replay and unchanged financial cardinalities; run current direct controls as the baseline.
- [X] T004 Extract shared locked preparation and financial-write primitives to `lib/football_market/market/purchase_transaction.ex` from `lib/football_market/market/purchase_store.ex`, preserving direct transaction ownership, authoritative quote selection, lock order and safe errors; rerun T003 controls before order work.
- [X] T005 Add isolated conditional fixtures and committed-connection barrier utilities in `test/support/conditional_orders/case.ex` and `test/support/conditional_orders/runtime_probe.ex`, reusing `test/support/purchases/runtime_probe.ex`; helpers restore absent configuration correctly, never provision real users, and own their schemas/connections.

## Phase 3: US1 — Place and Track (P1, first MVP increment)

**Goal**: Persist immutable owned instructions without reservations and return accurate pure read projections.
**Independent test**: Create below-limit order, retrieve owned terms, exclude other users, cross expiry before evaluation and verify persisted pending plus correct expiry_reached with zero financial/job/row mutations. Persisted post-evaluation expiry is added and verified in US2.

- [X] T006 [US1] Write storage/creation tests in `test/football_market/market/conditional_orders/storage_test.exs` and `test/football_market/market/conditional_orders/creation_test.exs`: existing direct-row upgrade, required/FK/quantity/price/status constraints, immutable terms/terminal evidence, no reservation, explicit UTC expiry, self-purchase exclusion and no effects for invalid/uninitialized player; include reciprocal purchase-link and direct-key collision storage assertions for US2.
- [X] T007 [P] [US1] Write deterministic unit validation and projection tests in `test/football_market/market/conditional_orders/input_test.exs` and `test/football_market/market/conditional_orders/projection_test.exs`: exact cents/no floats/NaN/Infinity/rounding, 1/100 bounds, forged immutable fields, omitted/default/invalid expiry, before/equal/after expiry for every status; inspect pending reads without implying persistence.
- [X] T008 [P] [US1] Write REST create/list/detail contract and pure-query tests in `test/football_market_web/controllers/conditional_order_controller_test.exs` and `test/football_market/market/conditional_orders/reads_test.exs`: owner-only scope, 201/Location, exact JSON strings, 400/401/404/409/503, unsupported term updates, identical foreign/absent responses; snapshots prove no row or Oban enqueue changes across expiry reads/lists.
- [X] T009 [US1] Create `priv/repo/migrations/20261027000000_create_conditional_buy_orders.exs` and `lib/football_market/market/conditional_order.ex` per data-model.md; extend `lib/football_market/market/purchase.ex`, retaining old direct rows, adding conditional_order_id/partial direct-key uniqueness, immutable term/terminal guards and deferred reciprocal execution integrity without weakening financial append-only guards.
- [X] T010 [US1] Implement `lib/football_market/market/conditional_order_input.ex`, `lib/football_market/market/conditional_order_projection.ex`, `lib/football_market/market/conditional_order_store.ex` and `lib/football_market/market/conditional_orders.ex` under that same directory, with `lib/football_market/market.ex` delegates: authenticated create, initialized-player/future database-time validation, commit-owned public response, owner-scoped pure list/detail and one database-clock sample per response.
- [X] T011 [US1] Add protected routes in `lib/football_market_web/router.ex`, thin adapters in `lib/football_market_web/controllers/conditional_order_controller.ex` and `lib/football_market_web/controllers/conditional_order_json.ex`, and create/list/detail definitions in `priv/static/openapi.json`; preserve direct serializer fields and update exact affected authentication/OpenAPI assertions, including `test/football_market_web/router_authentication_policy_test.exs`.
- [X] T012 [US1] First write `test/football_market/market/conditional_orders/handoff_test.exs`, then expose transaction-local creation and bounded side-effect-free pending/due candidate reads in `lib/football_market/market/conditional_order_store.ex`: outer rollback leaves no order, candidate traversal is complete/no duplicates across pages and includes due/no-quote rows, ordinary reads never invoke work; retain `specs/070-conditional-buy-orders/contracts/task060-handoff.json` without implementing jobs.
- [X] T013 [US1] Run focused tests in `test/football_market/market/conditional_orders/input_test.exs`, `test/football_market/market/conditional_orders/projection_test.exs`, `test/football_market/market/conditional_orders/creation_test.exs`, `test/football_market/market/conditional_orders/reads_test.exs` and `test/football_market_web/controllers/conditional_order_controller_test.exs`; require all US1 assertions green and record the focused outcome in `specs/070-conditional-buy-orders/handoffs/develop.md`; add evaluator-dependent read assertions in T020 rather than blocking US1 on unfinished US2.

## Phase 4: US2 — Execute Once (P1)

**Goal**: Atomically fulfill one instruction against one locked authoritative quote or retain/reject it correctly.
**Independent test**: Qualifying evaluation executes exact full quantity once; retries/concurrent delivery preserve evidence; insufficiency and rollback produce no partial effects; both quote race orders select the correct quote.

- [X] T014 [US2] Write `test/football_market/market/conditional_orders/evaluation_test.exs`: equality/below-limit success at current quote, high/missing/invalid/nonpositive pending, both distinct resource rejections, stored actual quote/total/completion, expiry dominating no/high quote or insufficient resources, and terminal repeat/no effects.
- [X] T015 [P] [US2] Write `test/football_market/market/conditional_orders/quote_order_test.exs` with independent committed connections/barriers: quote commit first while evaluation waits forbids stale cheap-event authorization; evaluation first excludes confirmation through commit and records its original quote; a blocking-lock wait crossing expiry must become expired using post-lock wall clock.
- [X] T016 [P] [US2] Write `test/football_market/market/conditional_orders/rollback_test.exs`: inject failure at each order/purchase/balance/holding/transfer/ledger write boundary, assert total rollback with pending order, then safe retry; transient database failures never persist business rejection.
- [X] T017 [P] [US2] Write `test/football_market/market/conditional_orders/concurrency_test.exs` and `test/football_market/market/conditional_orders/contention_test.exs`: duplicate/ambiguous acknowledgement evaluations, preoccupied matching and conflicting direct request keys, multiple orders and direct trades competing on one player and across players/shared buyer; assert one financial result per order, exact nonnegative balances, balanced immutable evidence and 100 supply without a prescribed winner.
- [X] T018 [US2] Extend shared participant in `lib/football_market/market/purchase_transaction.ex` and direct lookup in `lib/football_market/market/purchase_store.ex`: partition direct versus conditional identity, return typed resource insufficiency before writes, retain direct arbitrary-key replay and financial calculation/evidence shape; conditional execution may use only the order's locked terms and the participant's single current quote.
- [X] T019 [US2] Implement evaluate-by-ID in `lib/football_market/market/conditional_order_store.ex` and `lib/football_market/market/conditional_orders.ex`: READ COMMITTED, order/identity/player/sorted account locks, terminal shortcut, post-lock clock expiry first, one quote for limit and execution, atomic rejected/expired/executed outcomes, rollback on infrastructure/integrity errors and no scheduler.
- [X] T020 [US2] Complete terminal execution/rejection projection in `lib/football_market/market/conditional_order_projection.ex` and `lib/football_market_web/controllers/conditional_order_json.ex`; first extend `test/football_market/market/conditional_orders/reads_test.exs` and `test/football_market_web/controllers/conditional_order_controller_test.exs` with reads/lists after persisted evaluator expiry, execution and rejection; then fetch actual immutable linked purchase facts, enforce owner scope and keep expiry_reached time-derived for all terminal states.
- [X] T021 [US2] Complete and run reciprocal linkage/immutability/direct-origin upgrade assertions in `test/football_market/market/conditional_orders/storage_test.exs` and affected legacy `test/football_market/market/purchases/storage_test.exs`; prove old append-only and exact-cardinality guards still reject malformed evidence after the new origin field.
- [X] T022 [US2] Run all focused evaluator/race/rollback/contention tests in `test/football_market/market/conditional_orders/` and legacy `test/football_market/market/purchases/`; reconcile both quote lock orders and every US2 scenario in `specs/070-conditional-buy-orders/handoffs/develop.md`, retaining TASK-060 delivery/recovery as an explicit external obligation.

## Phase 5: US3 — Cancel or Expire (P1)

**Goal**: Serialize cancellation with execution, expose persisted expiry and preserve terminal outcomes.
**Independent test**: Cancel before expiry, evaluate exactly at/after expiry, race both lock winners, and retry all terminal states with no new financial effects; foreign cancel never discloses or mutates.

- [X] T023 [US3] Write `test/football_market/market/conditional_orders/cancellation_test.exs` and `test/football_market/market/conditional_orders/cancellation_race_test.exs`: before/equal/after expiry, due cancellation becomes expired, terminal repeats for all four statuses, separate committed connections forcing both cancellation/execution winners, and unchanged unauthorized rows/financial/job snapshots.
- [X] T024 [P] [US3] Extend `test/football_market_web/controllers/conditional_order_controller_test.exs` for POST cancel: owner success/repeat, terminal execution/rejection preservation, due expiry, foreign/absent/malformed indistinguishable 404, anonymous 401/challenge, injected terms 400 and transient 503 without effects.
- [X] T025 [US3] Implement owner-scoped cancel in `lib/football_market/market/conditional_order_store.ex` and `lib/football_market/market/conditional_orders.ex`, add cancel adapter in `lib/football_market_web/controllers/conditional_order_controller.ex`, and route/OpenAPI operation in `lib/football_market_web/router.ex` and `priv/static/openapi.json`; use shared order lock, current wall clock and immutable outcome semantics.
- [X] T026 [US3] Run focused cancellation/read/controller/race assertions from `test/football_market/market/conditional_orders/cancellation_test.exs`, `test/football_market/market/conditional_orders/cancellation_race_test.exs`, `test/football_market/market/conditional_orders/reads_test.exs` and `test/football_market_web/controllers/conditional_order_controller_test.exs`; require complete US1–US3 boundary outcomes before cross-cutting verification.

## Phase 6: Polish and developer verification

All implementation and applicable tests must finish before QA. No full-profile duplication: final unit/integration each once, existing browser E2E once; no extra historical CP1 report.

- [X] T027 Write unit scope assertions in `test/football_market/market/conditional_orders/scope_test.exs` for web/domain/persistence separation and no workers/UI/funding/providers/cache/partial fills; update affected inherited exact scope/contract guards and new-source roles in `config/credo_inventory.json`, `config/application_coverage_inventory.json` and reviewed case/helper assignments in `config/test_profiles.json` using explicit profile updates then inventory check.
- [X] T028 Implement `test/runtime/conditional_orders_http.exs` as an assertion runner per contracts/orders.md, reusing owned-schema runtime helpers: service/readiness deadlines, real Endpoint/Bandit HTTP for every affected method/route, 201/Location/200/400/401/challenge/404/409/503 where deterministically injectable, content-type and exact JSON, unsupported updates, pure expiry reads, manual trusted evaluator success/rejection, one purchase/cardinality/supply assertions and guaranteed owned-resource cleanup; do not rely on a preflight-only service check.
- [X] T029 Reconcile `specs/070-conditional-buy-orders/verification.json`, `quickstart.md`, `specs/070-conditional-buy-orders/contracts/orders.md` and `specs/070-conditional-buy-orders/contracts/task060-handoff.json` against delivered paths, all FR/SC/scenario assertions and actual HTTP behavior; update no behavioral contract silently, retain explicit TASK-060 recovery test ownership, run artifact probes and CI wrapper parity without running duplicate profiles.
- [X] T030 Finish source/design edits, then execute every manifest check using `python3 scripts/agentflow_stage_checks.py --stage develop --reuse` against `specs/070-conditional-buy-orders/verification.json`; require toolchain/preflight, format, warnings-as-errors, Credo, OpenAPI, inventory, parity, handoff contract, unit, integration, assets, E2E and HTTP success; report bounded command evidence/failures under the documented retry policy in `specs/070-conditional-buy-orders/handoffs/develop.md`.
- [X] T031 Finalize only `specs/070-conditional-buy-orders/handoffs/develop.md` under 400 words with deltas, command outcomes/evidence references, TASK-060/061 limitations and QA guidance; reconcile completed checkboxes against named files and execute `python3 scripts/workflow_artifact_probe.py develop --readiness` before independent QA. Do not commit/push/publish.

## Phase 7: Independent acceptance gates

- [ ] T032 [gate:qa] Independent QA reruns all `specs/070-conditional-buy-orders/verification.json` checks fresh without reuse, independently challenges every scenario and the external recovery limitation, exercises actual HTTP, and writes `specs/070-conditional-buy-orders/qa-report.md` plus `handoffs/qa.md` under the feature directory, ending PASS only when this task's obligations are complete.
- [ ] T033 [gate:review] Final review inspects source/diff, `specs/070-conditional-buy-orders/qa-report.md`, architecture/security/invariants/checkpoint boundaries and targeted uncovered risks; writes `specs/070-conditional-buy-orders/review-report.md` with one Backlog impact entry and `handoffs/review.md` under the feature directory, ending with Verdict: PASS only when ready for human merge.

## Dependencies and execution order

```text
T001 -> T002 -> T003 -> T004 -> T005
 -> US1 (T006..T013)
 -> US2 (T014..T022)
 -> US3 (T023..T026)
 -> T027 -> T028 -> T029 -> T030 -> T031 -> T032 -> T033
```

Within US1, T006/T007/T008 can be authored in parallel after T005, before T009/T010/T011 implementations respectively. T012 tests precede its seam implementation. US1 domain/API creation and pure projection is the first demonstrable increment. Post-evaluation expired-state read assertions are authored and satisfied in T020, avoiding a dependency cycle. No test task with unresolved required assertions may be marked done.

US2 uses US1 persistence and foundation purchase participant. T014–T017 test files can be authored independently; T018 precedes T019; T020 depends on committed outcome design, T021/T022 require completed evaluator. US3 requires order creation and evaluation to prove its execution race; T023/T024 test authoring is independent, T025 follows red assertions. Do not run financial race suites concurrently against shared test state. T027 scope tests precede any remediation they expose. No [P] declaration allows bypassing predecessors.

## Parallel examples

- US1: write input/projection assertions (T007) alongside REST/read assertions (T008), then join before implementation.
- US2: write quote barriers (T015), rollback fault assertions (T016) and financial contention cases (T017) in distinct files after fixture support is available.
- US3: write domain cancellation races (T023) alongside controller cancellation cases (T024), then join before T025.

These are optional file-work opportunities for one owner; no extra agent/session is required.

## Implementation strategy

Deliver US1 as an internal MVP demonstration of explicit instructions and accurate pure reads, then add all-or-nothing US2 execution, then US3 cancellation. All three P1 stories are mandatory for TASK-059 completion. Do not ship pending-only instructions as a completed conditional trading feature. TASK-060 and TASK-061 deliver automated execution/recovery and UI, with contracts/task060-handoff.json prescribing independent durable integration tests. Review checkpoint completeness accordingly. Only T032/T033 may remain unchecked at developer readiness, mapped to qa/review in verification.json; no implementation or developer-check task is a gate deferral.

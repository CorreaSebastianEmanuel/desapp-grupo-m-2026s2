# Outcome specification: CP2 integration and end-to-end suite

**Feature Branch**: `034-cp2-integration-and-end-to-end-suite`  
**Task**: `TASK-034`

## Outcome

Provide distinct unit and actual end-to-end profiles that demonstrate CP2 market behavior through domain, persistence, HTTP, and browser journeys. Cover valuation and immutable quote history; concurrent and idempotent trades; portfolio, transaction history, ranking, and authenticated charts; conditional-order lifecycle and recovery; nightly quote closing; and bounded asynchronous catalog scouting. Bundle the requested CP2 architecture presentation update, interactive diagram, and reading guide as companion documentation owned by this task.

## Acceptance

- [ ] Unit and E2E profiles remain distinct: unit runs isolated checks; E2E starts Phoenix with PostgreSQL and Oban active and exercises real HTTP and browser paths. **Evidence:** profile contract — `integration`, `test/ci/test_profiles_quality_contract_test.exs`, `test mandatory E2E job preserves existing CI and independent local profiles`; real browser — `e2e`, `test/e2e/browser_shell_test.exs`, `real sign-in connected shell logout and expired authority`.
- [ ] Valuation demonstrates configured strategy calculation, replay, and immutable dated history. Accepted daytime facts persist without publishing a quote until close; repeated close admission is safe. **Evidence:** `integration`, `test/football_market/quotes/calculation_test.exs`, `calculates from the fixed saved strategy and accepted local facts`; `test/football_market/quotes/replay_test.exs`, `successful calculation replays after a fresh application restart`; `test/football_market/quotes/history_test.exs`, `a fresh same-price calculation keeps both immutable quote records`; `test/football_market/statistics/ingestion/calculation_test.exs`, `accepted import creates a durable idempotent request without writing quotes`; `test/football_market/quotes/import_test.exs`, `two accepted imports before dispatch retain multi-player and multi-week memberships` (repeated close admission); `test/football_market/quotes/recovery_test.exs`, `nightly TTL admission handles database timestamps and repeats safely`.
- [ ] Trading uses independent database connections to demonstrate serialization and idempotency while preserving exact supply, balances, and transaction evidence. **Evidence:** `integration`, `test/football_market/market/purchases/concurrency_test.exs`, `different players cannot double spend one buyer balance`; `test/football_market/market/purchases/duplicate_race_test.exs`, `concurrent identical deliveries return one immutable operation`; `test/football_market/market/purchases/transfer_test.exs`, `purchase conserves credits and supply with durable exact evidence`; and corresponding `test/football_market/market/sales/duplicate_race_test.exs` and `transfer_test.exs` cases.
- [ ] Portfolio and ranking demonstrate persisted holdings, historical transaction effects, active-strategy ordering, and owner scoping. Authenticated HTTP and browser checks demonstrate charts and persisted state without mutating or duplicating financial facts. **Evidence:** `integration`, `test/football_market/market/portfolio/positions_test.exs`, `portfolio values current holdings from completed purchases and sales with owner scoping`; `test/football_market/ranking/selection_test.exs`, `only successful performance quotes for the active saved configuration are returned`; `test/football_market_web/live/portfolio_live_test.exs`, `portfolio chart marks missing quote data as a gap, not zero`; `e2e`, `test/e2e/portfolio_analytics_test.exs`, `real authenticated HTTP reports persisted trading value and flows without mutating state` and `real browser searches creates an executed order sells tokens and reads active ranking`.
- [ ] Conditional-order checks cover pending, executed, cancelled, expired, and rejected states; execution/cancellation races; retry after failed financial commit; duplicate delivery; and reconnect recovery. Failed, repeated, or terminal work creates no duplicate purchase. **Evidence:** `integration`, `test/football_market/market/conditional_orders/evaluation_test.exs`, `equal and below limits execute entirely at the single current quote once` and `qualifying insufficiencies reject distinctly without partial effects`; `cancellation_test.exs`, `owner cancels before expiry and due cancellation persists expired with no purchase`; `cancellation_race_test.exs`, `committed connections force either cancellation or execution to win exclusively`; `rollback_test.exs`, `every financial and order write including deferred commit rolls back and safely retries`; `concurrency_test.exs`, `concurrent and ambiguous deliveries execute once despite preoccupied direct identities`; `test/football_market_web/controllers/conditional_order_controller_test.exs`, `GET terminal expiry execution and rejection retains immutable linked facts`; `test/football_market_web/live/conditional_orders_live_test.exs`, `reload hints and reconnect recover committed owner-scoped states and outcomes`; `e2e`, `test/e2e/browser_reconnect_test.exs`, `real browser reconnect recovers a committed order purchase exactly once`.
- [ ] Search scouting demonstrates normalized-name deduplication, bounded admission, negative caching, catalog-only effects, and local search availability while provider work is pending or fails. **Evidence:** `integration`, `test/football_market/catalog/scouting_test.exs`, `catalog misses deduplicate, negative-cache fruitless runs, and reject invalid names`, `hourly admission is capped at ten distinct normalized names`, and `provider failure leaves local search available and defers the same name until nightly`; `e2e`, `test/e2e/catalog_scouting_test.exs`, `real browser search returns immediately and receives the imported catalog result`.
- [ ] Every criterion above has an identified automated case in its stated profile; assertions use deterministic fixtures and do not depend on external providers or wall-clock timing. **Evidence:** `unit` / `integration` / `e2e` cases are registered in `config/test_profiles.json` and discovered by `python3 scripts/test_inventory.py check`.

## Scope

- Add or repair only automated coverage, fixtures, and profile registration directly needed for the acceptance criteria.
- Reuse existing domain, HTTP, and browser boundaries; use deterministic provider fixtures.
- Preserve distinct unit and actual E2E profiles and their existing safety and cleanup contracts.
- Register the browser reconnect test in `config/application_coverage_inventory.json` and `config/test_profiles.json`; keep its fixture and scope resolver within the declared TASK-034 paths.
- Include `test/football_market/statistics/ingestion/calculation_test.exs`, `test/e2e/browser_reconnect_test.exs`, `test/support/e2e/fixtures.ex`, `test/support/workflow_scope.ex`, and `tools/openapi/e2e_market_reconnect.mjs` as focused regression coverage and support.
- Include these requested companion presentation files on this branch: `docs/presentations/cp2_architectura_completa.md`, `docs/presentations/arquitectura_interactiva.html`, and `docs/presentations/arquitectura_interactiva.md`.

## Non-goals

- Changing product behavior or business rules, adding product features, replacing provider adapters, running the full regression suite, or changing workflow policy.
- Manual presentation/demo preparation and unrelated refactors.

## Risk

- High: the task exercises financial invariants, concurrency, persistent job recovery, and actual runtime boundaries. Focused checks use isolated owned test data and verify exact persisted state.

## Decisions

- Reuse the product and lifecycle contracts in [CP2 architecture](../../docs/CP2_ARCHITECTURE.md), [ADR-0017](../../docs/adr/0017-cp2-charts-and-conditional-orders.md), and dependent task specs. This test task introduces no new observable behavior or product rule.

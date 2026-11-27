# Outcome specification: Required full-system scenarios

**Feature Branch**: `051-required-full-system-scenarios`

**Task**: `TASK-051`

## Outcome

Implement and automate full-system integration scenarios proving idempotent
catalog and statistics ingestion, dated immutable quotes across all five
supported leagues (`PL`, `BL1`, `PD`, `SA`, `FL1`), four authenticated users
trading across five players, consistent current portfolios, cached active
ranking, and administrator business metrics.

## Acceptance

- [x] Idempotent catalog ingestion populates all five leagues (`PL`, `BL1`, `PD`, `SA`, `FL1`), seasons, teams, and five issued players (100 tokens each).
- [x] Idempotent statistics ingestion and quote publication produce multiple dated immutable quotes per player across all five leagues; historical `/api/players/:player_id/quotes/at` reads preserve earlier quotes without overwriting them.
- [x] Four authenticated users purchase tokens across all five players via `/api/purchases` (with idempotent replay protection) and execute a sale via `/api/sales`, preserving the fixed 100-token supply invariant for every player.
- [x] Current portfolio allocation (`/api/portfolio/allocation`), portfolio history (`/api/portfolio/history`), and transaction history (`/api/transactions`) match exact Decimal holdings, average cost, market value, and realized/unrealized P&L for all four users.
- [x] Active-strategy ranking (`/api/ranking`) ranks all five players consistently across repeated reads, and administrator business metrics (`/api/business-metrics`) reflects the retained quotes, purchases, sales, and performance records.
- [x] No automated checkpoint acceptance workflow or evidence generator is added; the team performs manual demonstrations separately.

## Scope

- Add `test/full_system_scenarios_test.exs` under the `integration` profile exercising real PostgreSQL, Redis, HTTP controllers, domain contexts, and OpenAPI-backed responses.
- Register the new test file in the maintained Credo, application coverage, and test profile inventories.

## Non-goals

- Automated checkpoint acceptance workflows, evidence generators, live external network scraping, or changes to production business rules.

## Risk

Low: test-only behavioral verification with inventory updates; uses deterministic local fixtures without external network dependencies.

## Decisions

- Keep the full-system scenario under `@moduletag :integration` so it executes in `Quality baseline` with real PostgreSQL and Redis alongside the existing Playwright E2E journey in `test/e2e/market_journey_test.exs`.
- Pin deterministic historical match timestamps relative to `Date.utc_today()` (days `-2` and `-1`) so `/api/players/:player_id/quotes/at` and `/api/portfolio/history` never drift after calendar rollover.

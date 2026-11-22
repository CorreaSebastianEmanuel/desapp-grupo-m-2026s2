# Architecture baseline

Use one modular Elixir/Phoenix application with LiveView, REST/OpenAPI, Ecto/PostgreSQL, Oban jobs, Redis cache, structured logging, and Telemetry/Prometheus.

```text
Controllers / LiveViews -> domain contexts -> Ecto repositories -> PostgreSQL
Workers                 -> domain contexts
External adapters       -> football providers
Redis                    -> read optimization; PostgreSQL stays authoritative
```

Keep business rules out of controllers and LiveViews. Do not leak provider payloads into domain types. Trading uses database transactions and locking. Jobs must be retry-safe. Record durable deviations in an ADR.


## Agreed local deployment and CP2 delivery

Run one modular Phoenix application locally with PostgreSQL and Redis. Oban persists durable jobs in PostgreSQL and runs workers in the application; Redis is a disposable read cache, not the job broker or processed-state ledger. Catalog searches use local data and never scrape arbitrary names. Scoped statistics freshness uses a configurable TTL since the last complete accepted check, with asynchronous deduplicated refresh and stale local reads.

Statistics may refresh on demand during the day. Accepted facts are persisted and visible immediately, while quote-calculation requests remain pending. A player without any performance quote can publish its first positive quote asynchronously from accepted snapshots when an administrator-selected strategy and valid mapping are available; issuance alone is not a performance quote. Recovery admits initial-only requests, and confirmation rechecks eligibility under the player/request locks. Competing initial work waits for close after the first publication. Subsequent market quotes are recalculated only by the nightly close, independently per configured league/season; completed matches do not trigger recalculation. The close admits pending fact requests to the existing Oban calculation queue, with a TTL backstop measured from the latest quote and scoped to the latest accepted facts for that player/season. Player detail returns the current quote value and last valuation time beside statistics freshness.

The merged TASK-016 contract is authoritative and must be reused; no duplicate provider boundary is introduced. TASK-017/PR #28 is an optional current-catalog Football-Data.org adapter and cannot satisfy player-performance coverage. TASK-055 owns the scraper and its access/coverage gates.

CP2 now includes user portfolio charts and an additional product feature: conditional buy orders evaluated by Oban after confirmed quotes. LiveView displays order and valuation states; PostgreSQL remains authoritative for financial execution and chart history. Redis optimizations and advanced observability remain CP3.

See [the search workflow](PLAYER_SEARCH_WORKFLOW.md), [ADR-0016](adr/0016-local-search-and-background-refresh.md), [CP2 architecture and workflow](CP2_ARCHITECTURE.md) and [ADR-0017](adr/0017-cp2-charts-and-conditional-orders.md). These documents define target scope, not completed implementation.

## Responsibility and directory map

See [the Codebase Guide](CODEBASE_GUIDE.md) for a newcomer-friendly Elixir/Phoenix glossary and feature lookup table.

The modular monolith keeps a compact, readable 31-file `lib/` layout where each domain owns its Ecto schemas and business logic in one file (and `market/` uses four cohesive files):

- **Core & domains (`lib/football_market/`)**:
  - `application.ex`, `repo.ex`, `observability.ex`
  - `accounts.ex` (users, credentials, JWTs, API keys, browser sessions)
  - `catalog.ex` (leagues, seasons, teams, positions, players, cursors, scouting, idempotent import) and `catalog_seed.ex`
  - `statistics.ex` (matches, performances, freshness TTLs, scope checks, idempotent import)
  - `valuation.ex` (deterministic `Decimal` scoring for `balanced` and `position_aware`, strategy configurations, presets, activation)
  - `quotes.ex` (score-to-quote mappings, cent rounding, atomic confirmation, history, nightly close)
  - `ranking.ex` (read-only market ranking for active strategy)
  - `market/`: `schemas.ex`, `trading.ex` (facade, 100-token issuance, atomic/idempotent buy & sell), `portfolio.ex` (holdings, credit balance, history, allocation weights, valuation series), `orders.ex` (conditional orders CRUD & Oban evaluation)
  - `providers.ex` (read-only FotMob scraper & Football-Data.org adapters), `sync.ex` (sync coordination & local ops snapshot), and `workers.ex` (all 9 Oban workers preserving persisted `FootballMarket.Workers.*` module names)
- **Web layer (`lib/football_market_web/`)**:
  - `endpoint.ex`, `router.ex`, `auth.ex`, `telemetry.ex`, `gettext.ex`
  - `controllers/`: `api_controller.ex` (all `/api/*` endpoints & JSON views), `pages.ex` (docs, home & error views), `session_controller.ex`
  - `live/`: `workspace_live.ex` (+ `workspace/pages/*.html.heex`) and `admin_live.ex`
  - `components/`: `core_components.ex`, `app_components.ex` (+ `layouts/root.html.heex`)
- **CLI & tests**:
  - `lib/mix/tasks/tasks.ex` (`catalog.seed` and `infrastructure.*`)
  - `test/` holds 17 focused Elixir test suites (unit, integration, e2e), shared `test/support/` helpers, and `test/scripts/` + `test/integration/` harness verification. `scripts/`, `tools/openapi/`, `config/`, `assets/`, `priv/` and root setup/release entrypoints retain their existing external paths.

Financial command transaction owners retain lock order, idempotency, and PostgreSQL trigger invariants. Historical migrations, specs, ADRs, and evidence are preserved.

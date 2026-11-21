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

The modular monolith keeps context APIs at `lib/football_market/<context>.ex` and
1-file-per-module implementations under each context directory, grouping related
Ecto schemas into `<context>/schemas.ex`:

- `accounts/`: `schemas.ex`, `authentication.ex`, `browser_sessions.ex`.
- `catalog/`: `schemas.ex`, `query.ex` (including batched profiles), `player_cursor.ex`,
  `scouting.ex`, `development_seed.ex`, `development_seed_manifest.ex`, and
  `ingestion/{schemas,canonical,reconciler,publisher,records}.ex`.
- `market/`: `schemas.ex`, `settlement.ex`, `initialization.ex`, `trading.ex` (unified
  purchase/sale execution), `portfolio.ex` (positions, credit balance, initial inventory),
  `transaction_history.ex`, `analytics.ex`, `conditional_orders.ex`, `order_evaluation.ex`.
- `quotes/`: `schemas.ex`, `mappings.ex` (including cent conversion), `evidence_codec.ex`,
  `store.ex`, `reader.ex` (including replay), `admission.ex`, `import_requests.ex`,
  `engine.ex`, `closing.ex`, `recovery.ex`, `membership.ex`.
- `valuation/`: `schemas.ex`, `types.ex`, `request.ex`, `preparation.ex`,
  `statistics_reader.ex`, `evidence.ex`, `decimal_math.ex`, `scoring.ex` (including replay),
  `balanced.ex`, `position_aware.ex`, `managed.ex`, `calculation_requests.ex`,
  `configurations.ex` (pure registry/rules/codec/presets), `configuration_store.ex`
  (sole Repo boundary for configs).
- `statistics/`: `schemas.ex`, `input.ex`, `query.ex`, `freshness.ex`, `ingestion.ex`,
  and `ingestion/{schemas,canonical,provenance,fotmob_binding,observations,publisher,records}.ex`.
- `synchronization/`: `schemas.ex`, `input.ex`, `policy.ex`, `clock.ex`, `store.ex`,
  `scheduler.ex`, `dispatcher.ex`, `execution.ex`, `runtime.ex` (`ExecutionGuard` & `Recovery`).
- `providers/`: `contract.ex`, `types.ex`, `request.ex`, `validator.ex`,
  `catalog.ex`, `performances.ex`, `runtime.ex` (deadline runner), `player_identity.ex`
  (with `TeamIdentity`), `football_data_org.ex`, `scraping.ex`, and
  `scraping/{transport,budget,assessment,document,source,translator,player_profile,http_transport}.ex`.
- `ranking.ex`, `observability.ex`, `infrastructure/{configuration,adapters,local_operations}.ex`,
  and `workers/{sync_workers,quote_workers,order_workers}.ex` (unchanged persisted
  `FootballMarket.Workers.*` module identities).
- `football_market_web/`: `controllers/{api_json,market_controllers,pages,player_controller,conditional_order_controller,session_controller}.ex`,
  `plugs/{authenticate_api,browser_auth}.ex`, `live/{browser_auth,administration_live,local_admin_live,workspace_live}.ex`,
  `live/workspace/{helpers,orders,players,portfolio,trading}.ex` + `pages/*.html.heex`,
  and `components/{core_components,layouts,portfolio_components,workspace_components}.ex`.
- `test/football_market/` and `test/football_market_web/` mirror owners;
  `test/support/` contains shared fixtures/runtime support; `test/scripts/` and
  `tests/` preserve harness/checkpoint contracts. `scripts/`, `tools/openapi/`,
  `config/`, `assets/`, `priv/` and root setup/release entrypoints retain their
  existing external paths. Generated inventories enumerate real source ownership.

Financial command transaction owners retain lock order and idempotency. Stateless
extractions use functions, and implementation dependencies never introduce new
processes or cross-layer cycles. Historical specs, ADRs and evidence are preserved.

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

Statistics may refresh on demand during the day. Accepted facts are persisted and visible immediately, while quote-calculation requests remain pending. The market quote is recalculated only by the nightly close, independently per configured league/season; completed matches do not trigger recalculation. The close admits pending fact requests to the existing Oban calculation queue, with a TTL backstop measured from the latest quote and scoped to the latest accepted facts for that player/season. Player detail returns the current quote value and last valuation time beside statistics freshness.

The merged TASK-016 contract is authoritative and must be reused; no duplicate provider boundary is introduced. TASK-017/PR #28 is an optional current-catalog Football-Data.org adapter and cannot satisfy player-performance coverage. TASK-055 owns the scraper and its access/coverage gates.

CP2 now includes user portfolio charts and an additional product feature: conditional buy orders evaluated by Oban after confirmed quotes. LiveView displays order and valuation states; PostgreSQL remains authoritative for financial execution and chart history. Redis optimizations and advanced observability remain CP3.

See [the search workflow](PLAYER_SEARCH_WORKFLOW.md), [ADR-0016](adr/0016-local-search-and-background-refresh.md), [CP2 architecture and workflow](CP2_ARCHITECTURE.md) and [ADR-0017](adr/0017-cp2-charts-and-conditional-orders.md). These documents define target scope, not completed implementation.

## Responsibility and directory map (TASK-090)

The modular monolith keeps context APIs at `lib/football_market/<context>.ex` and
implementation under the matching context directory. Accounts owns identities and
sessions; Catalog owns local catalog/search/ingestion; Market owns issuance,
settlement, orders and portfolio; Quotes owns quote admission/confirmation/history;
Valuation owns pure scoring, evidence replay and versioned configuration;
Statistics owns immutable facts and freshness; Synchronization owns durable import
execution. Providers owns external documents and translation, Infrastructure owns
operational adapters, and Observability owns correlation and logging.

- `quotes/{admission,import_requests,engine,replay}.ex` separate explicit input,
  leased execution, atomic confirmation and historical reproduction. `store.ex`
  supplies player/lease locks and clocks; `reader.ex` supplies inspections;
  `recovery.ex` owns event delivery. Dependencies point from the facade to these
  owners, never back from an implementation to the facade.
- `catalog/ingestion/records.ex` and
  `statistics/ingestion/{records,observations}.ex` participate in publisher-owned
  transactions. Publishers retain receipt/scope/season locks and acceptance;
  participants neither commit independently nor call providers.
- `providers/scraping/player_profile.ex` interprets player documents;
  `source.ex` orchestrates assessed acquisition/completeness; `document.ex` checks
  each portion and deadline, `budget.ex` supplies shared lease accounting and
  `http_transport.ex` owns HTTPS allowlisting/bounded streaming.
- `synchronization/execution.ex` owns shared import execution. Oban adapters stay
  under `workers/`, with one file per worker and unchanged persisted worker names.
  Ecto schemas live under their owning namespace; related pure DTO families may
  share `types.ex`.
- `football_market_web/live/workspace/` owns destination loading/events and HEEx
  pages. WorkspaceLive owns callbacks, navigation and subscriptions; web projection
  stays here. LocalAdminLive calls `Infrastructure.LocalOperations` for operational
  IO and a web projection for labels. Controllers/plugs/components retain their
  framework roles; no web module queries Repo or starts Redis clients.
- `test/football_market/` and `test/football_market_web/` mirror owners;
  `test/support/` contains shared fixtures/runtime support; `test/scripts/` and
  `tests/` preserve harness/checkpoint contracts. `scripts/`, `tools/openapi/`,
  `config/`, `assets/`, `priv/` and root setup/release entrypoints retain their
  existing external paths. Generated inventories enumerate real source ownership.

Financial command transaction owners retain lock order and idempotency. Stateless
extractions use functions, and implementation dependencies never introduce new
processes or cross-layer cycles. Historical specs, ADRs and evidence are preserved.

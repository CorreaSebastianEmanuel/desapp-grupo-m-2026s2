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

The merged TASK-016 contract is authoritative and must be reused; no duplicate provider boundary is introduced. TASK-017/PR #28 is an optional current-catalog Football-Data.org adapter and cannot satisfy player-performance coverage. TASK-055 owns the scraper and its access/coverage gates.

CP2 now includes user portfolio charts and an additional product feature: conditional buy orders evaluated by Oban after confirmed quotes. LiveView displays order and valuation states; PostgreSQL remains authoritative for financial execution and chart history. Redis optimizations and advanced observability remain CP3.

See [the search workflow](PLAYER_SEARCH_WORKFLOW.md), [ADR-0016](adr/0016-local-search-and-background-refresh.md), [CP2 architecture and workflow](CP2_ARCHITECTURE.md) and [ADR-0017](adr/0017-cp2-charts-and-conditional-orders.md). These documents define target scope, not completed implementation.

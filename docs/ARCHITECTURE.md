# Architecture baseline

Use one modular Elixir/Phoenix application with LiveView, REST/OpenAPI, Ecto/PostgreSQL, Oban jobs, Redis cache, structured logging, and Telemetry/Prometheus.

```text
Controllers / LiveViews -> domain contexts -> Ecto repositories -> PostgreSQL
Workers                 -> domain contexts
External adapters       -> football providers
Redis                    -> read optimization; PostgreSQL stays authoritative
```

Keep business rules out of controllers and LiveViews. Do not leak provider payloads into domain types. Trading uses database transactions and locking. Jobs must be retry-safe. Record durable deviations in an ADR.


# Contract: Local Environment

## Lifecycle

Repository-root commands cover configure, start, inspect, readiness, prepare, migrate, application connectivity, stop, restart, and explicit reset. Routine actions preserve volumes. Reset is separately named, states that it destroys this repository's PostgreSQL/Redis volumes, and is never a side effect.

## Readiness

- Evaluate PostgreSQL and Redis independently and finish within 30 seconds.
- Print safe host/port (and PostgreSQL DB) plus `ready` or `failed` for each.
- Exit 0 only when both are ready.
- Never print passwords, full URLs, or secret-bearing options.

## Application connectivity

Canonical command: `mix infrastructure.verify`.

- Use normal application configuration and application-owned Repo/Redis clients.
- Attempt both probes even when one fails.
- Require a real PostgreSQL query and Redis command.
- Print one sanitized result per dependency and one aggregate result.
- Exit 0 only if both succeed; otherwise nonzero.
- Expose no HTTP endpoint.

## Test safety

Before test Repo startup, preparation, migration, or verification, require `football_market_test` plus only optional partition, and inequality with dev. Violation fails before mutation, names the unsafe category, and hides credentials.

## Compose

Exactly PostgreSQL and Redis; official images by immutable digest; `127.0.0.1` published ports; deterministic project/volumes; finite health retries within the readiness bound; local credentials labeled unsuitable elsewhere.


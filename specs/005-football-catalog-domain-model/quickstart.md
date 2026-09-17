# Quickstart: Validate the Football Catalog Domain Model

## Prerequisites

- Elixir/Erlang versions required by the repository.
- TASK-002 PostgreSQL service running with the test database safety configuration.
- Dependencies already fetched (`mix deps.get` if needed).

## Prepare and migrate

```sh
mix ecto.create
mix ecto.migrate
MIX_ENV=test mix test.prepare
```

Expected: the catalog migration creates all five tables, checks, foreign keys, uniqueness enforcement, and lookup indexes without modifying Redis or web routes.

## Focused validation

```sh
MIX_ENV=test mix test test/football_market/catalog
```

Expected coverage:

- all five exact league pairs succeed; unsupported and mismatched pairs fail;
- blank values, invalid seasons, missing relations, and all exact/case/whitespace duplicates fail;
- concurrent duplicate attempts persist only one record;
- parent deletion is restricted and failed writes leave no partial state;
- same-season player reassignment succeeds, cross-season reassignment fails, and no roster-history entity is created;
- singular business lookups and zero-or-more AND filters return the contractually ordered records.

## Query-plan evidence

Run the catalog query test tagged for representative scale:

```sh
MIX_ENV=test mix test test/football_market/catalog/query_test.exs --only query_plan
```

Expected: representative league, season, team, position, and combined queries have index-capable plans. This is not an SC-007 latency certification; TASK-043 owns a reproducible SLA benchmark.

## Regression gate

```sh
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
MIX_ENV=test mix test
```

Expected: all commands exit zero. The implementation must not add catalog controllers, routes, provider adapters, seed data, Redis writes, statistics, or financial behavior.
# Implementation Evidence (2026-09-17)

## Catalog boundary and decisions

`FootballMarket.Catalog` is the sole application-facing persistence boundary. Its five supported pairs are `PL` / Premier League, `BL1` / Bundesliga, `PD` / La Liga, `SA` / Serie A, and `FL1` / Ligue 1. Display values are trimmed; PostgreSQL `lower(btrim(...))` expression indexes are the comparison oracle. Foreign keys use restrictive deletion. A player may move to another team only inside the same season; the player UUID and catalog identity remain stable.

This feature deliberately excludes HTTP, authentication, seeds, provider identifiers/adapters, ingestion, statistics, valuation, tokens, trading, Redis/cache behavior, pagination, and UI. It introduces no speculative multi-record command; each concrete write is one atomic repository operation.

## Red-to-green and command outcomes

- Before implementation, `MIX_ENV=test mix test test/football_market/catalog/constraints_test.exs test/football_market/catalog/catalog_test.exs test/football_market/catalog/query_test.exs` produced the expected 9 missing-context failures.
- Migration preparation is performed by the existing test alias (`infrastructure.database.test_prepare`); the first focused green run applied `20260917090000_create_catalog_tables.exs` and passed 9 tests.
- `mix format --check-formatted`: PASS (final run).
- `MIX_ENV=test mix compile --warnings-as-errors`: PASS.
- `MIX_ENV=test mix test test/football_market/catalog`: PASS, 14 tests.
- `MIX_ENV=test mix test test/football_market/catalog/query_test.exs --only query_plan`: PASS, 1 test and 3 excluded. It distributes 100,000 players so the target league, season, team, position, and combined paths are selective, analyzes the table, and confirms index/bitmap-capable `EXPLAIN` plans for every path without forcing planner settings. Percentile SLA certification remains TASK-043.
- `python3 -m unittest test/scripts/workflow_artifact_probe_test.py`: PASS, 6 tests covering exact files, matching and unmatched globs, unchecked tasks, and repository-boundary rejection.
- `MIX_ENV=test mix test`: PASS, 39 tests.
- `git diff --check`: PASS. Scope search found no web, provider, seed, Redis, statistics, valuation, token, trading, or cache dependency in implementation files.

## Requirements traceability

| Requirement/outcome | Automated evidence |
|---|---|
| FR-001–FR-013, SC-001–SC-005 | `catalog_test.exs`, `constraints_test.exs`, and the catalog migration cover records, exact pairs, validation, normalized uniqueness, relationships, restrictive deletion, concurrent conflicts, and same-season reassignment. No concrete multi-write command exists. |
| FR-014–FR-016, SC-003, SC-005–SC-006 | `query_test.exs` covers UUID and business identities for every entity, every filter, AND composition, hierarchy preloads, cross-season boundaries, not-found behavior, UUID order, and representative correctness across all five leagues, ten seasons, twenty teams, and three configured positions. |
| FR-017–FR-018, SC-001–SC-004 | Context and persistence tests assert changeset errors and authoritative named database constraints, including separate-connection concurrent writes. |
| FR-019 | Final scope audit above. |
| FR-020 | `workflow_artifact_probe_test.py` covers repository-relative glob matches, unmatched globs, and a matching glob that escapes the repository boundary. |
| SC-007 | Tagged 100,000-player query-plan test; latency certification deferred to TASK-043. |

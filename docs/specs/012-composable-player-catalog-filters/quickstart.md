# Quickstart: Validate Composable Player Filters

## Prerequisites and setup

Use the repository's Elixir/OTP toolchain with dependencies fetched and a reachable local PostgreSQL service. Prepare the isolated test database through the existing task:

```bash
MIX_ENV=test mix test.prepare
```

The required behavior is in the [filter contract](contracts/player-catalog-filters.md); entity and cursor meanings are in [data-model.md](data-model.md).

## Automated acceptance

After implementation, run:

```bash
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
MIX_ENV=test mix test test/football_market/catalog/player_cursor_test.exs test/football_market/catalog/player_pagination_test.exs test/football_market/catalog/query_test.exs test/football_market_web/controllers/player_controller_test.exs test/football_market_web/controllers/player_catalog_auth_precedence_test.exs test/football_market_web/controllers/player_catalog_security_test.exs
MIX_ENV=test mix test
```

The focused tests should use IDs read from actual unfiltered player representations. They must prove the seven nonempty filter combinations, all five leagues, multiple seasons, same-name teams, every position, unknown/conflicting IDs, exact response shapes, and complete bounded traversal. Test duplicate/structured/malformed values and fixed error precedence, legacy unfiltered cursor fixture, filtered cursor mismatches, case and parameter-order invariance, page-size changes, authentication short circuit, and zero provider/cache calls. Existing TASK-011 detail and unfiltered tests remain part of the full suite.

The pre-change v1 token is preserved at `test/fixtures/player_catalog_v1_cursor.txt`; its unchanged-encoder command and anchor are recorded in `player_cursor_test.exs`. The migration test consumes the literal and rejects an added filter.

## SC-006 latency measurement

Run the isolated tagged performance test after implementation:

```bash
MIX_ENV=test mix test --include performance test/football_market_web/controllers/player_catalog_performance_test.exs
```

If port 5432 is occupied, use the pinned database on another local port:

```bash
POSTGRES_PORT=5433 docker compose up -d postgres
POSTGRES_PORT=5433 MIX_ENV=test mix test.prepare
POSTGRES_PORT=5433 MIX_ENV=test mix test --include performance test/football_market_web/controllers/player_catalog_performance_test.exs
```

Command outcomes and all twelve p95 results are recorded in [verification.md](verification.md).

Use an otherwise idle machine with at least four available CPU cores and 8 GiB RAM, the local PostgreSQL image pinned in `compose.yaml`, a migrated isolated test database, a warm connection pool, and concurrency one. Seed exactly 100,000 players: five leagues × two seasons each × ten teams per season × 1,000 players per team. Assign 250 players per team to each configured position (GK, DEF, MID, FWD), with deterministic IDs and names. Record actual cardinalities and expected matches.

The tagged test must allow the complete measurement to finish; its former five-minute timeout is too short for the required 12 cases at the two-second acceptance limit, even before fixture setup.

At page size 100, exercise league (20,000 matches), position (25,000), team (1,000), league+position (5,000), team+position (250), and league+team+position (250), measuring first and continuation pages for each. Use 10 warm-ups followed by 100 sequential in-process Phoenix requests per case. Sort durations and report sample 95 as p95. Each case passes only if p95 is at most 2,000 ms. Record command, host CPU/RAM/OS, Elixir/OTP/PostgreSQL versions, database location, fixture seed/counts, and each p95. Inspect query plans for slow cases. These requests traverse the Phoenix pipeline but exclude network transit. Report any failing case without changing the stated threshold or matrix.

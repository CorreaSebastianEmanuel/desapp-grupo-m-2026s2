# TASK-012 implementation verification

## Commands and outcomes

- `mix deps.get`: passed after sandbox escalation; dependencies fetched before the legacy fixture was generated.
- `MIX_ENV=test mix run -e 'anchor = %{name: "alice", id: "00000000-0000-4000-8000-000000000011"}; IO.puts(FootballMarket.Catalog.PlayerCursor.encode(anchor))'`: passed against unchanged TASK-011 code. Literal output is in `test/fixtures/player_catalog_v1_cursor.txt`.
- Initial focused tests: failed as intended on missing filtered cursor API and ignored filters.
- `mix format --check-formatted`: passed.
- `POSTGRES_PORT=5433 MIX_ENV=test mix compile --warnings-as-errors`: passed.
- `POSTGRES_PORT=5433 MIX_ENV=test mix test test/football_market/catalog/player_cursor_test.exs test/football_market/catalog/player_pagination_test.exs test/football_market/catalog/query_test.exs test/football_market_web/controllers/player_controller_test.exs test/football_market_web/controllers/player_catalog_auth_precedence_test.exs test/football_market_web/controllers/player_catalog_security_test.exs`: 38 passed.
- `POSTGRES_PORT=5433 MIX_ENV=test mix test`: 168 passed, 4 excluded tagged performance tests.
- `git diff --check`: passed.

## SC-006 latency gate

Exact command: `POSTGRES_PORT=5433 MIX_ENV=test mix test --include performance test/football_market_web/controllers/player_catalog_performance_test.exs`. Result: 1 passed.

Host: Arch Linux, kernel 7.2.6-arch2-1, x86_64; 16 available CPU cores and 31 GiB RAM. Elixir 1.20.3, Erlang/OTP 29. Database: pinned `postgres:17.6-alpine` container from `compose.yaml`, local host port 5433 mapped to container port 5432, migrated isolated `football_market_test` database. Another local service occupied port 5432. No concurrent test workload was run.

Seed 12012 gives deterministic IDs and names. Actual fixture: 5 leagues, 10 seasons, 100 teams, 4 positions, 100,000 players; each team has 1,000 players, 250 per position. Each case had 10 warm-ups and 100 sequential Phoenix requests at page size 100, concurrency one. p95 is sorted sample 95; values are milliseconds:

| Filter | Matches | First | Continuation |
|---|---:|---:|---:|
| League | 20,000 | 25.965 | 45.142 |
| Position | 25,000 | 38.085 | 76.219 |
| Team | 1,000 | 6.075 | 7.159 |
| League + position | 5,000 | 10.160 | 17.960 |
| Team + position | 250 | 4.821 | 5.441 |
| League + team + position | 250 | 5.334 | 5.595 |

All twelve p95 values are under 2,000 ms. No slow case required a query plan or index migration. This in-process result excludes network latency and is not a production capacity claim.

## Acceptance review

- FR-001–FR-005: HTTP tests cover singles, intersections, exact team identity across seasons, UUID normalization, validation, unknown and conflicting IDs, and empty-page bodies.
- FR-006–FR-010: bounded SQL query, independent order oracle, full traversal, replay, exact final and after-final pages, cursor filter identity, literal v1 compatibility, and mutation tests.
- FR-011–FR-014: authentication and validation precedence, no catalog SQL after mismatch, Redis call probe, opaque cursor and log checks, unchanged representation, and ignored unknown keys. There is no provider adapter in the current catalog read path.
- FR-015–FR-016: focused and full suites pass. Changed production files are limited to the existing list controller, catalog context, ordered query, and cursor module. No detail, OpenAPI, provider, cache, UI, or schema change was made.
- SC-001–SC-005 and SC-007: covered by the fixture and focused tests above. SC-006: passed under the stated local conditions. No acceptance gate remains unmet.

Independent QA should rerun the quickstart commands and review the literal cursor fixture, raw query validation, joined predicates, encrypted v2 shape, and the isolated latency gate.

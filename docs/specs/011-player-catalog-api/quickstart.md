# Quickstart: Validate Player Catalog API

## Prerequisites

- PostgreSQL test infrastructure available through the repository's standard setup.
- Dependencies already fetched.
- TASK-005 catalog and TASK-010 authentication migrations applied.

## Automated validation

Run formatting and compilation:

```bash
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
```

Run focused feature tests (paths are created during implementation):

```bash
MIX_ENV=test mix test \
  test/football_market/catalog/player_cursor_test.exs \
  test/football_market/catalog/player_catalog_index_test.exs \
  test/football_market/catalog/player_pagination_test.exs \
  test/football_market/catalog/player_detail_test.exs \
  test/football_market_web/controllers/player_controller_test.exs \
  test/football_market_web/controllers/player_detail_controller_test.exs \
  test/football_market_web/controllers/player_catalog_security_test.exs \
  test/football_market_web/controllers/player_catalog_auth_precedence_test.exs
```

Run the full suite:

```bash
MIX_ENV=test mix test
```

## End-to-end evidence

The focused suite must establish the exact [HTTP contract](contracts/player-catalog-api.md) and [data model](data-model.md):

1. Authenticate once with JWT and once with API key; traverse a catalog larger than 100 by following cursors and prove exact-once ordered coverage.
2. Exercise default, 1, and 100 sizes plus all malformed/out-of-range/repeated forms; prove authentication precedes validation.
3. Prove empty, exact-boundary, final, and after-final metadata; replay a cursor and change page size.
4. Include duplicate/case-variant names, insertions before/after an anchor, and anchor deletion; assert documented non-snapshot behavior.
5. Fetch existing, absent, and malformed detail IDs; compare exact fields, types, nullability, hierarchy, and error bodies.
6. Configure provider/cache probes to fail on invocation and prove every route outcome remains local-only.
7. Tamper with and cross-scope a cursor; assert only `invalid_cursor` and no plaintext anchor values in the token or response.

## Performance diagnostic

Run the tagged diagnostic explicitly:

```bash
MIX_ENV=test mix test --include performance \
  test/football_market_web/controllers/player_catalog_performance_test.exs
```

The harness seeds exactly 100,000 deterministic players. After 10 warm-up requests per case, it measures 100 sequential full HTTP requests for a first page (100), a continuation page (100), and existing detail. Record each printed p95 separately with machine/runtime/database context. The target is under two seconds per case; the result is diagnostic, not a CP1 release gate or concurrency-capacity claim.

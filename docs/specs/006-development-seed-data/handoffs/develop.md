# Development Handoff

## Changes

- Centralized the public seed-error boundary in `lib/football_market/catalog/development_seed.ex`. Only documented category/cause/entity combinations and identities from the fixed manifest cross the boundary; malformed or unknown internal failures collapse to `persistence/seed/development-seed/write_failed`.
- Aligned invalid-manifest, attribute, relationship, alternate-identity, misplaced-team, database, write, concurrency, unavailable-database, and disabled-capability results with that boundary.
- Updated `lib/mix/tasks/catalog.seed.ex` so disabled, startup/database, service, and unknown failures all use the sanitizer before rendering.
- Added command-contract coverage for every public failure class and hostile unknown values in `test/mix/tasks/catalog.seed_test.exs`.
- Documented the exact public taxonomy and fallback in `README.md` and `specs/006-development-seed-data/quickstart.md`.

## Decisions

- Public identities are enumerated from `Manifest.definition/0`, not accepted as arbitrary strings.
- Unknown internal failures intentionally lose entity detail to guarantee non-disclosure.
- No dependency, migration, route, startup hook, provider/cache coupling, update, or delete path was added.

## Command outcomes

- Catalog baseline: 14 passed.
- Focused seed/domain/CLI suite: 31 passed.
- `mix format --check-formatted`: passed.
- `MIX_ENV=test mix compile --warnings-as-errors`: passed.
- Full `MIX_ENV=test mix test`: 84 passed.
- Dedicated database `football_market_seed_validation_20260924_0102`: fresh seed 44 created/0 reused in 1.08s; repeat 0 created/44 reused; catalog visibility PASS.
- Scope search found seed references only in the explicit Mix task, dev/test capability configuration, implementation/tests, and documentation.

## Residual risks

- Concurrent runs intentionally allow one sanitized `concurrent_write`; retry must converge.
- The dedicated validation database remains local for QA inspection.

## Exact QA guidance

Run the focused and full commands in `specs/006-development-seed-data/quickstart.md`. Recheck real-process output for fresh/repeat, unreachable PostgreSQL, production, and unknown `MIX_ENV`. Exercise each table-driven public cause plus unknown category, cause, entity, identity, and malformed error data; only the documented strings or generic `write_failed` fallback may appear.

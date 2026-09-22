# Development Handoff: TASK-007

## Changes

- Added the internal `FootballMarket.Accounts` context, `User` and private `PasswordCredential` schemas, plus an atomic PostgreSQL migration for UUID users and one credential per user.
- Added email normalization/validation, unchanged password validation, Argon2id hashing/boolean verification, safe public user projections, and safe error changesets.
- Added Accounts tests for registration, validation, non-disclosure, duplicates, named-index presence, and credential-write rollback; updated the contract and quickstart evidence.

## Decisions

- The library's `m_cost` is an exponent: production `m_cost: 16` encodes the planned 65,536 KiB profile. Test `m_cost: 8` follows the dependency's documented low-cost setting.
- No router, controller, UI, login, token, or API-key code was added.

## Command outcomes

- `mix.bat deps.get`: passed; lockfile contains `argon2_elixir` 4.1.3 and `comeonin` 5.5.1.
- `mix.bat format`, focused Accounts tests, and full tests: blocked before execution because `argon2_elixir` requires `nmake`, absent from this Windows environment.
- Elixir syntax parsing passed for all added Accounts source, migration, support, and test files.

## Residual risk and QA guidance

Install/enable Visual Studio C++ Build Tools so `nmake` is on `PATH` (or use an equivalent supported build environment), then run `mix deps.compile argon2_elixir --force`, `mix format`, `mix test test/football_market/accounts`, and `mix test`. Confirm the migration applies to the isolated test database and specifically exercise the functional-index, rollback-trigger, public-projection, and credential-redaction tests. T013, T023, and T026 remain unchecked pending those successful checks.

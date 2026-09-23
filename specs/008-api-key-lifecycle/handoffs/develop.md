# Development handoff: API key lifecycle

## Changes and decisions

- Added the private `ApiKey` schema, owner foreign key, 32-byte digest check, and digest uniqueness across active and revoked rows in `lib/football_market/accounts/api_key.ex` and `priv/repo/migrations/20260923000000_create_api_keys.exs`.
- Added trusted internal issuance, identification, and owner-scoped idempotent revocation in `lib/football_market/accounts.ex`. Secrets use 32 random bytes encoded as canonical Base64URL; only the SHA-256 digest persists. Confirmed insert rejection returns `{:error, :issuance_failed}`. Credential queries use `log: false`.
- Added lifecycle, database-failure/collision, security, and opt-in timing tests under `test/football_market/accounts/`. `test/test_helper.exs` excludes timing from the default suite. Updated `quickstart.md`, the internal contract, data model, and ADR-0004. No route, UI, audit emitter, dependency, or cache was added.

## Command outcomes

- Baseline: `./scripts/check_toolchain.sh` failed because local Elixir is 1.20.4 rather than pinned 1.20.3; `./scripts/local_services.sh start` failed because port 5432 was already bound. `mix deps.get` succeeded. The existing PostgreSQL template had a collation-version mismatch; refreshing `template1` metadata let `mix infrastructure.database.setup` pass. Baseline Accounts tests passed (5).
- Red phases observed missing schema/context functions before implementation. Final focused lifecycle suite: 16 passed. Opt-in timing: 40/40 issues and 40/40 identifications under one second.
- `mix format --check-formatted`, `mix compile --warnings-as-errors`, and `mix test` passed; full suite: 69 passed, 1 timing test excluded. No key-management route appears in `FootballMarketWeb.Router`; configured telemetry metrics expose duration without credential parameter tags.

## Residual risks and QA guidance

- The pinned toolchain and local service wrapper still disagree with this environment, though all Mix checks completed against the existing PostgreSQL service. Timing is machine dependent; keep the 38/40 threshold.
- QA: run the commands in `quickstart.md`, including the opt-in timing command. Review collision triggers in `api_key_persistence_test.exs` for rollback isolation; verify active and revoked digest collisions, same-owner repeat revocation, other-owner nondisclosure, secret/digest absence from captured debug logs, and no public route. Recheck credential query telemetry if a reporter is later added.

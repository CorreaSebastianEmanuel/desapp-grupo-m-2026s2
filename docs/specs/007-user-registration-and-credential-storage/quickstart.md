# Quickstart: Validate User Registration and Credential Storage

## Prerequisites

- Use the repository-pinned Elixir/Erlang toolchain and a running local PostgreSQL instance.
- Fetch the newly declared locked dependencies and run the new migration through the existing database workflow.

```bash
./scripts/check_toolchain.sh
mix deps.get --locked
./scripts/local_services.sh start
mix infrastructure.database.setup
```

## Run focused verification

```bash
mix test test/football_market/accounts
mix test
```

Expected outcomes:

1. A valid unused email/password creates one user whose email is trimmed and lowercase, as specified in the [Accounts contract](contracts/accounts-context.md).
2. Blank/malformed email and short, long, or whitespace-only password cases return field errors and add no rows, per [the data model](data-model.md).
3. Exact, case-only, and surrounding-whitespace duplicates fail while retaining the original account and credential.
4. A correct submitted password verifies, a distinct password does not, and public registration/retrieval values disclose no credential data.
5. A forced credential-write failure and competing registrations both leave only the permitted committed state.

No Phoenix server, HTTP request, UI test, token, or login flow is expected for this feature.

## Verification evidence (2026-09-22)

| Command | Outcome |
|---|---|
| `mix deps.get` | Passed in the WSL2 verification environment; resolved the locked dependencies and compiled Argon2's native component. |
| `mix format --check-formatted` | Passed in a WSL2-native temporary checkout containing the same TASK-007 files as the Windows checkout (content compared ignoring CRLF only). |
| `POSTGRES_PORT=5433 MIX_ENV=test mix compile --warnings-as-errors` | Passed. |
| `POSTGRES_PORT=5433 MIX_ENV=test mix test test/football_market/accounts` | Passed: 14 tests. This includes registration, password verification, validation, normalized-email conflicts, index expression, and transactional rollback. |
| `POSTGRES_PORT=5433 MIX_ENV=test mix test` | Passed: 53 tests. |

The WSL2 environment uses Elixir 1.20.3 with Erlang/OTP 29.0.6, native build tools, Ruby for existing CI-contract tests, and the healthy local PostgreSQL service on port 5433. The test database remains the configured `football_market_test` database.

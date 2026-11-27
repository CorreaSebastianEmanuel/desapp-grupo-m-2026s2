# Quickstart: Validate JWT Login and Validation

## Prerequisites

- Elixir 1.20.3/OTP 29 and project dependencies installed.
- Local PostgreSQL running with the isolated test database available.
- No production JWT secret is needed for tests; `config/test.exs` supplies an explicit test-only configuration.
- Run `mix deps.get` to install Joken 2.7 and its resolved JOSE dependency.
- Production requires non-empty `JWT_ISSUER` and `JWT_AUDIENCE` plus `JWT_SIGNING_KEY_BASE64` containing at least 32 decoded bytes.

## Automated validation

```bash
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
MIX_ENV=test mix test test/football_market/accounts/authentication_test.exs
MIX_ENV=test mix test test/football_market/accounts/authentication_security_test.exs
MIX_ENV=test mix test
```

Expected outcomes:

- Normalized email plus the exact password returns one token; every login failure returns the contract's one generic error.
- Claims and UUID formats match `data-model.md`; 1,000 fixed-clock issuances have unique JTIs.
- A valid token resolves only to its account ID and JTI.
- malformed, unsigned, altered, wrong-key/method/issuer/audience, missing-claim, non-integer-time, future `iat`, future `nbf`, and expired tokens all return one generic invalid-token error.
- Controlled-clock cases pass at `exp - 1` and fail at `exp`; `exp - iat` is exactly 900.
- Missing/invalid trusted configuration fails closed without exposing values.
- Sentinel capture finds no password, signing key, or complete token in application-owned errors, Logger output, inspected structures, or authentication telemetry; the token appears only in successful `access_token` output.
- Scope inspection finds no controller, router, plug, migration, revocation, authorization, refresh, lockout, API-key authentication, or UI change.

## Manual local performance evidence

Run the tagged benchmark explicitly (it must not be a default CI correctness gate):

```bash
MIX_ENV=test mix test test/football_market/accounts/authentication_performance_test.exs --include performance
```

The benchmark must seed one fixed account, use local PostgreSQL and the documented test Argon2 cost, execute sequentially, discard 10 warm-ups, measure 100 valid-login operations and 1,000 validations with monotonic time, and report nearest-rank p95 plus OS/CPU/OTP/configuration. Expected p95 is below one second for each operation. Preserve the output as verification evidence; a failure prompts investigation but does not replace deterministic correctness checks.

This feature exposes only the internal `FootballMarket.Accounts.login/1` and `validate_access_token/1` contracts. It intentionally adds no route, credential transport, refresh token, logout, revocation, authorization, lockout, or throttling behavior.

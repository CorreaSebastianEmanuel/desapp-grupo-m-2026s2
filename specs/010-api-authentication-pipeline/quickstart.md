# Quickstart: Validate API Authentication Pipeline

## Prerequisites

- Elixir/OTP versions accepted by `mix.exs`
- Project dependencies already fetched
- Local PostgreSQL available through the repository configuration
- Test JWT configuration from `config/test.exs`

The actor shape and policy states are in [data-model.md](data-model.md); exact HTTP behavior is in [contracts/api-authentication.md](contracts/api-authentication.md).

## Prepare the test database

```bash
MIX_ENV=test mix test.prepare
```

Expected: the test database exists and all migrations are current.

## Run focused functional and security validation

```bash
MIX_ENV=test mix test \
  test/football_market_web/api_authentication_test.exs \
  test/football_market_web/api_authentication_security_test.exs \
  test/football_market_web/router_authentication_policy_test.exs
```

Expected: JWT and API-key success produce the contracted actor; expiry, revocation, malformed/repeated/ambiguous credentials produce identical `401` responses; protected code does not run on failure; public behavior ignores credentials; route and disclosure audits pass.

## Run the opt-in latency regression

```bash
MIX_ENV=test mix test --include performance test/football_market_web/api_authentication_performance_test.exs
```

Expected: after 5 warm-ups, at least 38 of 40 full decisions complete below one second for JWT and independently for API key. Output records per-method counts and p95; the API-key path includes PostgreSQL lookup.

## Run repository quality checks

```bash
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
MIX_ENV=test mix test
```

Expected: formatting and compilation pass and the default suite passes with the performance test excluded unless explicitly included.

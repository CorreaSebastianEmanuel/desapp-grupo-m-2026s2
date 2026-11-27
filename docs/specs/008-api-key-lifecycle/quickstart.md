# Quickstart: Validate API Key Lifecycle

## Prerequisites and setup

Use the repository-pinned Elixir/Erlang toolchain and local PostgreSQL. Apply the new migration through the existing database workflow.

```bash
./scripts/check_toolchain.sh
./scripts/local_services.sh start
mix infrastructure.database.setup
```

## Functional validation

```bash
mix test test/football_market/accounts/api_keys_test.exs test/football_market/accounts/api_key_persistence_test.exs test/football_market/accounts/api_key_security_test.exs
mix format --check-formatted
mix compile --warnings-as-errors
mix test
```

Expected outcomes, corresponding to the [internal contract](contracts/api-keys-context.md) and [data model](data-model.md):

1. Two successful issues for one account return distinct identifiers and secrets, and each secret identifies the correct account and key.
2. The table contains only distinct digests; missing owner, forced insert failure, and deliberate digest collision return no secret and leave no partial key.
3. Malformed, empty, non-text, altered, unknown, identifier-only, and revoked inputs all fail identification safely.
4. Owner revocation affects one key after commit, repeated revocation is harmless, and unknown/other-owner IDs have one nondisclosing failure result.
5. Public results, errors, inspection, debug logs, and configured telemetry metrics reveal no raw secret or digest except the successful issuance result; router inspection finds no public key-management action.

## Local timing sample

Run the separately tagged performance test after the functional checks on an otherwise idle local database:

```bash
mix test --include performance test/football_market/accounts/api_keys_performance_test.exs
```

The `:performance` tag is excluded from the default suite in `test/test_helper.exs`; the command above includes it explicitly. The test warms the runtime and database, then measures 40 completed issuances and 40 active identifications separately with monotonic time. It includes database work, reports both counts within one second, and passes only with at least 38/40 for each operation. It uses an existing account so password registration cost is excluded. This is local evidence for SC-005, not an additional CP1 CI gate.

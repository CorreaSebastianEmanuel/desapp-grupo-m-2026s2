# Independent QA: TASK-008 API key lifecycle

## Environment and executed checks

Verification ran with the pinned Elixir 1.20.3, OTP 29.0.6, and ERTS 17.0.6 toolchain. PostgreSQL and Redis were healthy. The repository PostgreSQL container used host port 15432 because port 5432 was occupied; all database commands below used `POSTGRES_PORT=15432`.

| Check | Observed result |
|---|---|
| `./scripts/check_toolchain.sh` | Passed with the pinned versions. |
| `mix infrastructure.database.setup` | Passed; the API key migration applied. |
| Focused key tests: `mix test test/football_market/accounts/api_keys_test.exs test/football_market/accounts/api_key_persistence_test.exs test/football_market/accounts/api_key_security_test.exs` | 16 passed. |
| `mix format --check-formatted` | Passed. |
| `mix compile --warnings-as-errors` | Passed. |
| `mix test` | 69 passed, 1 excluded (`:performance`). |
| `mix test --include performance test/football_market/accounts/api_keys_performance_test.exs` | 1 passed; 40/40 issuances and 40/40 identifications completed under one second. |
| `git diff --check` | Passed. |
| Read-only PostgreSQL catalog inspection | Confirmed five API key columns, an owner foreign key, a 32-byte digest check, and a global unique digest index. |

## Acceptance evidence

| Spec coverage | Evidence and result |
|---|---|
| US1; FR-001–005, FR-010; SC-001 | Tests issue two distinct UUID keys for one existing account, verify independently generated 32-byte Base64URL secrets and persisted SHA-256 digests, and reject absent/malformed owners. A forced insert rejection and active/revoked digest collisions return `{:error, :issuance_failed}` with no added row. Passed. |
| US2; FR-006–007; SC-002 | Tests identify each active secret with only its account and key ID; identifier-only, altered, unknown, incomplete, padded, empty, non-text, and revoked inputs all return `{:error, :invalid_key}`. Canonical decode and re-encode checks in `Accounts.identify_api_key/1` also reject noncanonical encodings. Passed. |
| US3; FR-008–009; SC-003 | Tests show owner-scoped revocation invalidates one secret on the next lookup, preserves the other, and keeps the original timestamp on repeat. Unknown, malformed, and other-owner IDs share `{:error, :not_found}`. Passed. |
| FR-011–012; SC-004 | Tests inspect public results, account projections, schema inspection, errors, captured debug logs, and configured metric tags. Code inspection confirms credential queries use `log: false`, no feature audit emitter exists, and no ordinary key read returns a persistence struct. The catalog contains no raw-secret column. Passed for the observed boundaries. |
| FR-013; SC-006 | Router inspection and route tests found no public key-management action. No JWT login, API authorization, expiry policy, or key UI was added. Passed. |
| SC-005 | The opt-in local timing sample passed its 38/40 threshold for both operations with 40/40 each. Passed for this local sample. |

Automated samples support the specified outcomes; they cannot prove all future random outputs or operating conditions.

Verdict: PASS

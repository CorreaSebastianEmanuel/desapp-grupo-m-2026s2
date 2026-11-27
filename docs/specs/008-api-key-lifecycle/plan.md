# Implementation Plan: API Key Lifecycle

**Branch**: `008-api-key-lifecycle` | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/008-api-key-lifecycle/spec.md`; product challenge and decision handoffs; no current `backlog/feedback/TASK-008.md` exists.

## Summary

Extend the internal `FootballMarket.Accounts` context to issue, identify, and revoke account-bound API keys. Generate each secret from 32 cryptographically random bytes, store only its SHA-256 digest in PostgreSQL, and disclose the raw secret solely after a successful insert. Identify against authoritative database state and revoke with an owner-scoped update. This task adds no public route, caller authentication, key expiry, or UI. [ADR-0004](../../docs/adr/0004-api-key-storage-and-revocation.md) records the durable credential and consistency decisions.

## Technical Context

**Language/Version**: Elixir `~> 1.20.3`; OTP 29.0.6 baseline

**Primary Dependencies**: Existing Phoenix 1.8, Ecto SQL 3.13, Postgrex, and OTP `:crypto`; no new dependency

**Storage**: PostgreSQL through `FootballMarket.Repo`; no Redis or process cache

**Testing**: ExUnit and Ecto SQL Sandbox; focused Accounts tests, database constraint tests, router boundary check, and separately invoked local timing test

**Target Platform**: Existing Phoenix modular monolith on the BEAM

**Project Type**: Web application with an internal domain contract for this feature

**Performance Goals**: In a 40-operation local sample per operation, at least 38 successful issuances and 38 active-key identifications finish within one second each, including persistence; measured separately after warmup

**Constraints**: One-time disclosure; no raw secret or digest in normal results, errors, inspection, logs, or audit output; committed revocation is authoritative for later lookups; no public key-management surface

**Scale/Scope**: Extend one context, add one private schema and one PostgreSQL table/migration, add focused tests; multiple keys per account

## Constitution Check

*GATE: Must pass before Phase 0 research; rechecked after Phase 1 design.*

### Pre-design gate: PASS

| Principle | Evidence / decision |
|---|---|
| Specification before implementation | FR-001 through FR-013 and the three acceptance stories define the contract; the critic's concurrency, trust, failure, and measurement findings are resolved below. |
| Domain integrity | Accounts owns key rules; PostgreSQL foreign key and unique digest index enforce owner and uniqueness; owner-scoped updates prevent cross-account revocation. |
| Modular simplicity | Reuse the existing modular monolith, Repo, and OTP crypto. No service, cache, public adapter, or new dependency. |
| Evidence-based quality | Test valid/invalid lifecycle paths, database collision, rollback/failure, output redaction, route exclusion, and a reproducible local timing sample. |
| Independent verification | The product decision says no human check is required; no TASK-008 feedback record exists. QA and final review remain separate later workflow gates. |

### Post-design gate: PASS

The [research](research.md), [data model](data-model.md), [internal contract](contracts/api-keys-context.md), [quickstart](quickstart.md), and ADR retain the same scope and boundaries. No constitution exception or unresolved clarification remains.

## Design

### Internal boundary and issuance

1. Extend `FootballMarket.Accounts` with `issue_api_key/1`, `identify_api_key/1`, and `revoke_api_key/2`. Only trusted application code may supply a user ID to issue or revoke. A later web adapter must derive that owner from authenticated context; it must not pass through a caller-supplied owner ID. Do not add a router action or LiveView here.
2. Generate 32 independent bytes with `:crypto.strong_rand_bytes(32)` and encode as unpadded Base64URL. Use a separately generated opaque UUID as the management identifier. Hash the complete secret with SHA-256 and insert only the 32-byte digest, user ID, and lifecycle metadata. Generate no secret from account data, identifier, timestamps, or a counter.
3. Persist with a foreign key to `users` and a unique index on `secret_hash` across **all** keys, including revoked ones. The insert is the atomic issuance boundary. Return `%{id: key_id, secret: secret}` only after it succeeds. Map absent/deleted owner, unique collision, and confirmed failed inserts to a safe error without a secret; no partial row remains. Do not rescue an ambiguous post-insert failure and falsely claim that no key was committed. A rare collision fails closed rather than retrying, which is the smallest compliant behavior. Force collision coverage with a test-only database trigger that substitutes an existing digest during a normal `issue_api_key/1` insert; never add a raw-secret or digest override to the public context function.
4. Keep the schema and digest access internal to Accounts. Do not add an ordinary key list/get result carrying persistence structs. Redact `secret_hash` from schema inspection, and construct explicit public result maps. Never include secret or digest in returned changesets, exception messages, application logs, custom telemetry, or audit output. Suppress SQL parameter logging for credential inserts/lookups and review existing query telemetry handlers for export of sensitive parameters.

### Identification and revocation

1. Accept only a complete canonical 43-character unpadded Base64URL secret that decodes to 32 bytes and re-encodes identically. Invalid types and formats return the same safe failure as an unknown key. Hash the presented secret and query PostgreSQL for a matching digest with `revoked_at IS NULL`; return only `%{account_id: user_id, key_id: id}`. An identifier alone never matches.
2. Validate/cast management and owner UUIDs before Ecto queries so malformed values return the contracted safe result without `Ecto.Query.CastError`. Use one owner-scoped conditional `UPDATE` of the requested ID and user ID, setting `revoked_at` only when currently null. If no row was updated, check for a row with that **same owner and ID** to make repeat revocation return `:ok`; unknown and other-owner IDs both return `{:error, :not_found}`. No operation reactivates a row or changes another key.
3. PostgreSQL is authoritative. Identification uses a fresh database statement at the default read-committed isolation level and no stale cache. Once revocation commits, a lookup begun afterward rejects the former secret. A lookup whose database read precedes that commit may complete successfully; its observation is ordered before revocation. No stronger in-flight cancellation guarantee is claimed.
4. Identification failures return one `{:error, :invalid_key}` shape for malformed, unknown, and revoked secrets. Revocation returns one `{:error, :not_found}` shape for unknown and other-owner IDs. Errors and recorded output contain no record-existence details. Timing parity is not promised or tested.

### Verification plan

- Exercise two distinct keys for one account, immediate identification, management ID rejection, and correct owner/key attribution. Inspect database rows to prove only digests persist and the digest has a unique constraint across active/revoked records.
- Test malformed, empty, non-text, altered, unknown, and revoked presentations through the same public context result. Test revoking one of two keys, repeated revocation, other-account and unknown IDs, and post-commit rejection on the next lookup.
- Test missing account and a confirmed pre-commit database rejection without returned secret or key. Use a test-only database trigger to substitute an existing digest during a normal issuance insert; prove the unique index rejects it, the context maps the conflict to a safe error, and no second usable key appears. Keep any deterministic secret/digest injection out of the public issuance function. Representative random-key tests plus the database invariant provide bounded evidence for SC-001/SC-002; tests cannot prove every possible random outcome.
- Inspect ordinary account/key projections, safe result and error values, schema inspection, and captured logs/telemetry for secret/digest disclosure. Verify no public key-management route was added.
- Run a separately tagged local performance sample: warm the runtime and database, then measure 40 successful issues and 40 active identifications with `System.monotonic_time`, each call including its database work. Record per-operation counts within one second and require at least 38/40 for each. Use one existing account to avoid measuring TASK-007 password hashing. Exclude the `:performance` tag in `test/test_helper.exs` by default and invoke it explicitly through the quickstart command; this is not a CP1 CI gate.

## Project Structure

### Documentation (this feature)

```text
specs/008-api-key-lifecycle/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── api-keys-context.md
└── handoffs/
    └── architecture.md
docs/adr/
└── 0004-api-key-storage-and-revocation.md
```

### Source Code (repository root)

```text
lib/football_market/
├── accounts.ex
├── accounts/
│   └── api_key.ex
└── repo.ex

priv/repo/migrations/
└── *_create_api_keys.exs

test/football_market/accounts/
├── api_keys_test.exs
├── api_key_persistence_test.exs
├── api_key_security_test.exs
└── api_keys_performance_test.exs
test/test_helper.exs
```

**Structure Decision**: Extend the existing Accounts domain and Ecto persistence layout. Tests use the existing Accounts/DataCase support; the performance test is opt-in. The existing router is inspected for scope but does not receive a feature route.

## Complexity Tracking

No constitution violation requires an exception. A new table and index are necessary for durable multiple-key ownership and collision safety. Rejected larger designs and their tradeoffs are recorded in the [research](research.md) and [ADR-0004](../../docs/adr/0004-api-key-storage-and-revocation.md).

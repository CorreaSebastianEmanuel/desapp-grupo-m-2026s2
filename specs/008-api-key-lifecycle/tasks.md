# Tasks: API Key Lifecycle

**Input**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/api-keys-context.md`, and `quickstart.md` in `specs/008-api-key-lifecycle/`; `docs/PRODUCT.md`, `docs/CHECKPOINTS.md`, and the SDD constitution govern the feature.

**Tests**: Required by FR-012 and the constitution. Write each phase's tests first, run them to observe failure, then implement and rerun them. Keep database fixtures deterministic; never add a public entropy override.

**Scope**: Trusted internal `FootballMarket.Accounts` lifecycle only. No HTTP/LiveView route, caller authentication, JWT, expiration, Redis, or UI. PostgreSQL remains authoritative for active-key state.

## Phase 1: Setup

**Purpose**: Confirm the existing TASK-007 account and database baseline before extending it; this feature needs no new dependency or project scaffold.

- [X] T001 Run `./scripts/check_toolchain.sh`, `./scripts/local_services.sh start`, `mix infrastructure.database.setup`, and `mix test test/football_market/accounts/accounts_test.exs` per `specs/008-api-key-lifecycle/quickstart.md`; record any baseline failure before changing `lib/football_market/accounts.ex`.

## Phase 2: Foundational Database Boundary

**Purpose**: Establish a durable, private key record and database constraints shared by all three stories.

- [X] T002 Write and run failing PostgreSQL constraint and schema-inspection tests in `test/football_market/accounts/api_key_persistence_test.exs` for a required owner, 32-byte digest, unique digest across active and revoked rows, creation time, and redacted digest inspection; use `FootballMarket.AccountsCase` and the SQL Sandbox.
- [X] T003 Add `priv/repo/migrations/20260923000000_create_api_keys.exs` with UUID primary/owner foreign keys, non-null 32-byte `bytea` digest, UTC microsecond `inserted_at`, nullable `revoked_at`, a digest-length check, and a unique digest index covering revoked rows; rerun T002's database assertions.
- [X] T004 Add private `FootballMarket.Accounts.ApiKey` Ecto schema and changeset in `lib/football_market/accounts/api_key.ex`, with independent UUID ID generation, `secret_hash` excluded from `Inspect`, and no raw-secret field or public projection; rerun all T002 tests.

**Checkpoint**: A key row can be stored only with an existing account and a unique 32-byte digest. No key lifecycle context function is required yet.

## Phase 3: User Story 1 — Issue a Key for an Existing Account (P1) 🎯 MVP

**Goal**: Issue multiple independent account-bound secrets, reveal each only after its insert succeeds, and return safe failures.

**Independent Test**: Register an account, issue two keys, verify distinct IDs and canonical 43-character secrets, inspect durable rows for digests only, then force missing-owner, rejected-insert, and digest-collision failures with no returned secret or extra key.

### Tests — write and run red before T008

- [X] T005 [P] [US1] Add issuance contract tests in `test/football_market/accounts/api_keys_test.exs` for two active keys per account, distinct UUID IDs and canonical 43-character Base64URL secrets derived from 32 random bytes, one-time result projection, matching persisted digests for later identification, and no key association in `User.public_projection/1`.
- [X] T006 [P] [US1] Add failure tests in `test/football_market/accounts/api_key_persistence_test.exs` for absent/malformed owner, confirmed pre-commit database rejection, and a test-only trigger that substitutes an existing active or revoked digest during normal issuance; assert safe `{:error, :issuance_failed}`, no secret, and no additional row.
- [X] T007 [P] [US1] Add disclosure and scope tests in `test/football_market/accounts/api_key_security_test.exs`: inspect ordinary account/key results, schema, errors, captured application logs, configured metrics, and any feature audit output for raw secret/digest leakage; inspect `Phoenix.Router.routes(FootballMarketWeb.Router)` for no key-management route.

### Implementation

- [X] T008 [US1] Implement `Accounts.issue_api_key/1` in `lib/football_market/accounts.ex`: validate the trusted owner ID, generate independent 32-byte CSPRNG secret and UUID, encode canonical unpadded Base64URL, hash the complete secret with SHA-256, insert through the private schema with credential query logging disabled, return `%{id: id, secret: secret}` only on confirmed insert success, and map confirmed foreign-key/unique/insert rejection to a credential-free error without broad rescue of ambiguous post-insert failures; rerun T005–T007.

**Checkpoint**: US1 works through the internal context and can be tested without identification or revocation context functions; use stored-digest assertions for immediate readiness.

## Phase 4: User Story 2 — Identify an Active Key (P2)

**Goal**: Attribute a complete active secret to its owner and key without exposing credential material or using stale state.

**Independent Test**: Issue two keys, identify each by complete secret, then try key ID alone and invalid values; set one row revoked directly in the test fixture and verify its old secret has the same failure shape as an unknown secret.

### Tests — write and run red before T011

- [X] T009 [P] [US2] Add identification tests in `test/football_market/accounts/api_keys_test.exs` for correct account/key attribution, exact result keys, canonical 43-character Base64URL validation, and rejection of ID-only, altered, unknown, incomplete, empty, malformed, non-text, and directly fixture-revoked values as `{:error, :invalid_key}`.
- [X] T010 [P] [US2] Extend `test/football_market/accounts/api_key_security_test.exs` to assert successful/failed identification results, inspection, captured application logs, and configured telemetry metric tags disclose no presented secret, stored digest, or record-existence distinction; assert credential query logging is disabled and `lib/football_market_web/telemetry.ex` exports durations without credential parameters.

### Implementation

- [X] T011 [US2] Implement `Accounts.identify_api_key/1` in `lib/football_market/accounts.ex`: validate canonical unpadded Base64URL and 32 decoded bytes before hashing, query the digest and `revoked_at IS NULL` from PostgreSQL on every call with credential query logging disabled, and return only `%{account_id: user_id, key_id: id}` or `{:error, :invalid_key}`; rerun T009–T010.

**Checkpoint**: US2 can be tested with US1 issuance and a direct revoked fixture, independently of the US3 revocation operation.

## Phase 5: User Story 3 — Revoke an Owned Key (P3)

**Goal**: Revoke one owned key irreversibly while other keys remain usable and unknown/other-owner IDs reveal no ownership information.

**Independent Test**: Issue two keys to one account, revoke one by owner and ID, identify both afterward, repeat the revoke, then test an unrelated account, unknown ID, and malformed UUID without changing either key.

### Tests — write and run red before T014

- [X] T012 [P] [US3] Add revocation tests in `test/football_market/accounts/api_keys_test.exs` for one-key-only effect, committed post-revocation rejection on the next identification, unchanged other key, repeated owner revocation returning `:ok`, and identical `{:error, :not_found}` for unknown, malformed, and other-owner IDs; assert revoked state never returns to active through the context.
- [X] T013 [P] [US3] Extend `test/football_market/accounts/api_key_security_test.exs` to assert revocation results, errors, inspection, and captured application logs contain no secret/digest or other-owner existence details, and the router still has no public key-management route.

### Implementation

- [X] T014 [US3] Implement `Accounts.revoke_api_key/2` in `lib/football_market/accounts.ex`: cast owner/key UUIDs safely before Ecto, perform one owner-scoped conditional update from active to `revoked_at`, check only that same owner/key for idempotent repeat `:ok`, and return one `{:error, :not_found}` for unknown/other-owner/malformed IDs; use committed PostgreSQL state for subsequent identification and rerun T012–T013.

**Checkpoint**: All three internal lifecycle stories pass independently and together; no credential is reactivated or disclosed.

## Phase 6: Polish, Documentation, and Verification

- [X] T015 Write an opt-in local timing test in `test/football_market/accounts/api_keys_performance_test.exs` that warms the runtime/database and times 40 successful issuances and 40 active identifications separately with `System.monotonic_time`, includes persistence, reports counts, and requires at least 38 calls under one second for each operation using one existing account.
- [X] T016 Exclude `:performance` by default in `test/test_helper.exs`, then run `mix test --include performance test/football_market/accounts/api_keys_performance_test.exs`; keep this sample outside the default CP1 CI gate and document environmental failures rather than changing the threshold.
- [X] T017 Update `specs/008-api-key-lifecycle/quickstart.md` with the implemented validation commands and evidence expectations; reconcile `specs/008-api-key-lifecycle/contracts/api-keys-context.md`, `specs/008-api-key-lifecycle/data-model.md`, and `docs/adr/0004-api-key-storage-and-revocation.md` against the final internal signatures, database constraints, failure behavior, and no-route boundary.
- [X] T018 Run the focused lifecycle tests, `mix format --check-formatted`, `mix compile --warnings-as-errors`, and `mix test` from `specs/008-api-key-lifecycle/quickstart.md`; inspect `lib/football_market_web/router.ex` and `lib/football_market_web/telemetry.ex` for the CP1 key-creation, security, and no-public-surface obligations, and record actual command outcomes for independent QA.

## Dependencies and Execution Order

- **Setup → foundation**: T001 precedes T002–T004. T002 must fail before T003–T004; rerun it after each implementation step.
- **US1**: T005–T007 follow foundation and may be written in parallel because they touch separate test files. All must fail before T008. US1 is the smallest MVP.
- **US2**: T009–T010 follow US1 and may be written in parallel. Both must fail before T011. Revoked-key coverage uses a direct fixture, so US2 does not depend on US3.
- **US3**: T012–T013 follow US2 and may be written in parallel. Both must fail before T014.
- **Final verification**: T015 follows US2, and T016 follows T015 and US3. T017 follows implementation; T018 follows T016–T017. File-sharing tests in later phases start only after earlier edits to those files finish.

### Parallel examples by story

| Story | Tasks that may run together after their prerequisite phase | Separate files |
|---|---|---|
| US1 | T005, T006, T007 | `api_keys_test.exs`, `api_key_persistence_test.exs`, `api_key_security_test.exs` |
| US2 | T009, T010 | `api_keys_test.exs`, `api_key_security_test.exs` |
| US3 | T012, T013 | `api_keys_test.exs`, `api_key_security_test.exs` |

## Implementation Strategy

1. Complete T001–T004, then deliver US1 (T005–T008) as the internal issuance MVP and run its independent test.
2. Add US2 (T009–T011), verify active and revoked-fixture identification, then add US3 (T012–T014) and rerun prior story tests.
3. Finish opt-in timing evidence, documentation, full quality commands, and independent QA/review. CP1 also needs JWT, OpenAPI, and catalog work from other backlog tasks; this feature supplies the API-key creation portion only.

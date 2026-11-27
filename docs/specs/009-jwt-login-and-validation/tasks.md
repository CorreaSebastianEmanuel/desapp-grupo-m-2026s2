# Tasks: JWT Login and Validation

**Input**: Design documents from `specs/009-jwt-login-and-validation/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/authentication.md`, `quickstart.md`, and the governing product/checkpoint/constitution documents

**Tests**: Required by FR-014 and the constitution. In each user-story phase, write the listed tests first, run the focused file, and confirm the new assertions fail for the expected missing behavior before implementation.

**Organization**: Tasks are grouped by user story. Shared JWT dependency, trusted configuration, and deterministic test seams are foundational because issuance, validation, and expiration all use the same policy boundary.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it changes different files and does not depend on an incomplete task
- **[Story]**: Maps the task to the corresponding user story in `spec.md`
- Every task names its target file(s)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the approved JWT library and test-only trusted configuration needed to write executable authentication tests.

- [X] T001 Add the Joken 2.7 dependency and resolved JOSE transitive dependency in `mix.exs` and `mix.lock`
- [X] T002 Configure unmistakably test-only Base64 HS256 key material, issuer, audience, zero skew, and injectable clock/JTI providers in `config/test.exs`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish one safe configuration and cryptographic boundary shared by all three stories, without implementing a controller, plug, route, persistence schema, or authorization behavior.

**Critical**: Complete this phase before any user-story phase. These tasks provide seams and configuration parsing only; story behavior remains test-first in later phases.

- [X] T003 Define the authentication module boundary, 900-second lifetime, HS256-only signer construction, validated issuer/audience/key configuration access, and injectable clock/JTI seams without public login or validation behavior in `lib/football_market/accounts/authentication.ex`
- [X] T004 Add production-only parsing for required issuer, audience, and Base64 JWT key of at least 32 decoded bytes, raising safely on missing or invalid values without including secret material in `config/runtime.exs`
- [X] T005 [P] Add reusable fixed-clock, deterministic-JTI, and signed-token mutation helpers that expose no production secret in `test/support/authentication_helpers.ex`

**Checkpoint**: Tests can deterministically exercise the shared signer and time boundary; production startup fails on invalid trusted JWT configuration.

---

## Phase 3: User Story 1 - Log In with Account Credentials (Priority: P1) MVP

**Goal**: A registered user can log in with normalized email and an exact password and receive exactly one newly issued JWT, while every invalid submission has the same safe result.

**Independent Test**: Register a user, log in with a case/whitespace email variant and the exact password, inspect the signed token claims, then prove unknown email, wrong password, malformed input, and signing failure all return `{:error, :authentication_failed}` with no token or account-existence distinction.

### Tests for User Story 1

- [X] T006 [US1] Write failing login contract tests for normalized email, exact untrimmed password, one-token success shape, required `sub`/`jti`/`iat`/`exp`/`iss`/`aud` claims, UUID formats, and 900-second recorded lifetime in `test/football_market/accounts/authentication_test.exs`
- [X] T007 [P] [US1] Write failing security tests for identical blank/malformed/non-text/unknown-user/wrong-password/configuration-failure results, dummy Argon2 work on unknown users, and absence of passwords, hashes, keys, tokens, account IDs, JTIs, and cause-specific data from errors, inspection, logs, and telemetry in `test/football_market/accounts/authentication_security_test.exs`
- [ ] T008 [US1] Run `MIX_ENV=test mix test test/football_market/accounts/authentication_test.exs test/football_market/accounts/authentication_security_test.exs` and confirm the new assertions in those files fail for the expected missing US1 behavior before implementation

### Implementation for User Story 1

- [X] T009 [US1] Implement map-only credential orchestration, TASK-007 email normalization lookup, exact password verification, unknown-user `Argon2.no_user_verify/0`, generic failure mapping, and safe credential-query logging behavior in `lib/football_market/accounts.ex`
- [X] T010 [US1] Implement HS256 issuance from trusted configuration with one captured integer timestamp, `exp = iat + 900`, account UUID subject, a fresh unpredictable UUID JTI, fixed issuer/audience, and safe issuance failure in `lib/football_market/accounts/authentication.ex`
- [X] T011 [US1] Emit only operation/outcome/duration authentication telemetry and make the US1 focused tests pass without email, password, token, claims, key, account ID, JTI, or internal-cause metadata in `lib/football_market/accounts.ex` and `lib/football_market/accounts/authentication.ex`

**Checkpoint**: US1 independently passes and supplies the MVP login/token issuance contract; it introduces no transport or route behavior.

---

## Phase 4: User Story 2 - Validate an Access Token (Priority: P2)

**Goal**: Standalone validation returns only a verified account ID and token ID after checking structure, signature, fixed method/key, issuer, audience, required claims, formats, and time validity.

**Independent Test**: Validate an unchanged token issued by US1 and obtain its account/JTI, then mutate each trust dimension and verify every invalid class returns only `{:error, :invalid_token}` without a database lookup or actor identity.

### Tests for User Story 2

- [X] T012 [US2] Write failing validation contract tests for the success projection and rejection of non-binary, malformed, unsigned, altered, wrong-key, non-HS256, wrong-issuer, wrong-audience, missing-claim, malformed-UUID, and non-integer-time tokens in `test/football_market/accounts/authentication_test.exs`
- [X] T013 [P] [US2] Write failing mutation and leak tests proving algorithm confusion is rejected, unverified claims never escape, every invalid class has one public result, configuration failure is safe, validation performs no repository query, and logs/telemetry/inspection expose no complete token, key, claims, account ID, or JTI in `test/football_market/accounts/authentication_security_test.exs`
- [ ] T014 [US2] Run `MIX_ENV=test mix test test/football_market/accounts/authentication_test.exs test/football_market/accounts/authentication_security_test.exs` and confirm the new assertions in those files fail for the expected missing US2 behavior before implementation

### Implementation for User Story 2

- [X] T015 [US2] Implement HS256-only compact-token verification, trusted-key/issuer/audience matching, all-six-claim presence checks, integer NumericDate checks, UUID `sub`/`jti` checks, and terminal generic failures before projecting verified identity in `lib/football_market/accounts/authentication.ex`
- [X] T016 [US2] Expose `validate_access_token/1` through the Accounts context with only `{:ok, %{account_id: uuid, token_id: uuid}}` or `{:error, :invalid_token}`, no persistence lookup, and sanitized telemetry in `lib/football_market/accounts.ex`
- [X] T017 [US2] Make all US2 focused contract, mutation, no-query, configuration, and non-disclosure tests pass in `test/football_market/accounts/authentication_test.exs` and `test/football_market/accounts/authentication_security_test.exs`

**Checkpoint**: US1 and US2 pass independently; decoded content is never treated as identity until all verification succeeds.

---

## Phase 5: User Story 3 - Enforce Token Expiration (Priority: P3)

**Goal**: Tokens remain valid only before their exact expiration instant, use zero skew, and reject future issuance or optional not-before values.

**Independent Test**: Issue with a controlled integer-second clock, validate at `exp - 1`, reject at `exp` and later, and reject future `iat`/`nbf` while confirming validation never extends the original expiration.

### Tests for User Story 3

- [X] T018 [US3] Write failing controlled-clock boundary tests for exact 900-second lifetime, validity at `exp - 1`, rejection at `exp` and after, future `iat`, future optional `nbf`, zero skew, and non-extension across repeated validations in `test/football_market/accounts/authentication_test.exs`
- [ ] T019 [US3] Run `MIX_ENV=test mix test test/football_market/accounts/authentication_test.exs` and confirm the new assertions in that file fail for the expected missing US3 behavior before implementation

### Implementation for User Story 3

- [X] T020 [US3] Enforce `iat <= now`, optional `nbf <= now`, and exclusive `exp > now` using one injected integer-second clock read and no expiration leeway in `lib/football_market/accounts/authentication.ex`
- [X] T021 [US3] Make all controlled-time US3 tests pass while preserving the US1 issuance lifetime and US2 generic validation contract in `test/football_market/accounts/authentication_test.exs`

**Checkpoint**: All three user stories are independently functional and exact expiration behavior is deterministic.

---

## Phase 6: Polish & Cross-Cutting Verification

**Purpose**: Close uniqueness, performance, documentation, scope, and full-project quality obligations without turning host-dependent latency into a CI correctness gate.

- [X] T022 Write and pass the fixed-clock 1,000-issuance production-generator uniqueness test and cross-story regression assertions in `test/football_market/accounts/authentication_test.exs`
- [X] T023 [P] Add the excluded/tagged warm local benchmark with one seeded user, 10 discarded warm-ups, 100 sequential logins, 1,000 sequential validations, monotonic timing, nearest-rank p95, and environment/configuration reporting in `test/football_market/accounts/authentication_performance_test.exs`
- [X] T024 [P] Update dependency/configuration/benchmark usage and the explicit no-route/no-refresh/no-revocation boundary in `specs/009-jwt-login-and-validation/quickstart.md` and `docs/adr/0005-jwt-signing-and-validation-boundary.md`
- [X] T025 Run `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, both focused files under `test/football_market/accounts/authentication*_test.exs`, and `MIX_ENV=test mix test`; fix failures only in files authorized by `specs/009-jwt-login-and-validation/plan.md` and preserve command evidence for independent QA
- [X] T026 Run the tagged local performance command from `specs/009-jwt-login-and-validation/quickstart.md`, preserve nearest-rank login/validation p95 and environment output for independent QA, and investigate any p95 at or above one second without making it a default CI gate
- [X] T027 Verify the implementation diff against `specs/009-jwt-login-and-validation/tasks.md` and targeted-search `lib/football_market_web/router.ex` plus `priv/repo/migrations/` to prove no controller, plug, migration, UI, API-key authentication, authorization, role, refresh, logout, revocation, lockout, or throttling behavior was added; preserve the scope evidence for independent QA

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Starts immediately.
- **Foundational (Phase 2)**: Depends on T001-T002 and blocks all stories.
- **US1 (Phase 3)**: Depends on Foundation and supplies issued tokens used by later-story integration tests.
- **US2 (Phase 4)**: Depends on US1 for the canonical valid-token fixture; its invalid-token tests may be drafted once Foundation is complete.
- **US3 (Phase 5)**: Depends on US1 issuance and US2 validation, because it tightens their shared time policy.
- **Polish (Phase 6)**: Depends on all selected stories; T023 and T024 may run in parallel after behavior stabilizes.

### User Story Dependency Graph

```text
Setup -> Foundation -> US1 (MVP issuance) -> US2 (validation) -> US3 (expiration) -> Polish
```

The stories are independently testable as outcomes, but implementation order is intentionally sequential because one shared authentication policy issues, verifies, and expires the same token.

### Within Each User Story

1. Write contract/security/boundary tests.
2. Run them and confirm expected failure before implementation.
3. Implement only the behavior for that story.
4. Run the focused tests to the story checkpoint.
5. Preserve the two public generic error shapes and all non-disclosure constraints.

### Parallel Opportunities

- T005 can run in parallel with T004 after T003 defines the seams.
- T007 can run in parallel with T006; T013 can run in parallel with T012.
- T023 and T024 can run in parallel after T022.
- Test drafting for later invalid/boundary classes may proceed after Foundation, but implementation follows US1 -> US2 -> US3 to avoid conflicting edits to `authentication.ex`.

## Parallel Example: User Story 1

```text
Task T006: Login and issued-claim contract tests in test/football_market/accounts/authentication_test.exs
Task T007: Generic-failure and non-disclosure tests in test/football_market/accounts/authentication_security_test.exs
```

## Parallel Example: User Story 2

```text
Task T012: Validation contract and invalid-class tests in test/football_market/accounts/authentication_test.exs
Task T013: Mutation, no-query, and leak tests in test/football_market/accounts/authentication_security_test.exs
```

## Implementation Strategy

### MVP First

1. Complete Setup and Foundation.
2. Complete US1 test-first through T011.
3. Stop and validate the login/token-issuance independent test.
4. Treat this as the smallest demonstrable MVP; it is not route protection or production-hardened online-guessing defense.

### Incremental Delivery

1. US1 adds credential login and issuance.
2. US2 adds standalone, fully verified identity extraction.
3. US3 locks exact expiration boundaries.
4. Polish supplies uniqueness, performance, documentation, full-suite, and no-scope-creep evidence.

## Completion Checklist

- Every behavioral change is preceded by a failing automated test.
- Every public failure is generic and fail-closed.
- JWT algorithm, key, issuer, audience, time, subject, and JTI are never caller-selected.
- Passwords, hashes, signing material, complete tokens, unverified claims, account IDs, and JTIs do not leak through failure paths, logging, telemetry, or inspection.
- Validation does not query persistence and does not imply authorization or revocation.
- CP1 JWT coverage is demonstrated by focused tests plus the full test suite.

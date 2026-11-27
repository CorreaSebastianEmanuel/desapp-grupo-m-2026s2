# Tasks: User Registration and Credential Storage

**Input**: Design documents from `/specs/007-user-registration-and-credential-storage/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/accounts-context.md`, and `quickstart.md`

**Tests**: Required by FR-013. Write each story's tests first, run them to establish the expected failing state, then implement only enough to make them pass.

**Organization**: Tasks are grouped by user story. The only public feature boundary is the internal `FootballMarket.Accounts` context; no web, API, UI, login, token, or API-key work is in scope.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can be completed in parallel with other ready tasks because it changes a different file.
- **[Story]**: Maps the task to its user story. Setup, foundational, and polish tasks have no story label.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Declare the password-hashing dependency and isolated test configuration before compiling feature code.

- [X] T001 Add the locked `argon2_elixir` 4.1.3 dependency to `mix.exs` and record its resolved lock entry in `mix.lock`.
- [X] T002 [P] Configure the production Argon2id parameters from ADR-0003 and documented test-only lower-cost parameters in `config/config.exs` and `config/test.exs`.
- [X] T003 [P] Add Accounts-specific database-test setup that reuses SQL Sandbox conventions in `test/support/accounts_case.ex` and load it from `test/test_helper.exs`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the durable, private persistence boundary used by every registration outcome.

**Critical**: Complete this phase before implementing user-story behavior. PostgreSQL, not an application pre-check, is the final authority for normalized email uniqueness.

- [X] T004 Create failing persistence-boundary tests for UUID identity, the one-to-one credential relationship, the named `lower(btrim(email))` unique index, and transactional rollback in `test/football_market/accounts/persistence_test.exs`.
- [X] T005 Add the atomic user/credential schema migration, including UUID primary key, nonblank email, named functional unique index, credential primary/foreign key, non-null hash, and timestamps in `priv/repo/migrations/*_create_users_and_password_credentials.exs`.
- [X] T006 Implement the private persistence schemas with no password field on `User`, a hidden credential hash during inspection, and database constraint mappings in `lib/football_market/accounts/user.ex` and `lib/football_market/accounts/password_credential.ex`.

**Checkpoint**: The migration and schemas make it possible to test registration without exposing credential material or relying on application-only uniqueness.

---

## Phase 3: User Story 1 - Register a User Account (Priority: P1) MVP

**Goal**: Create one durable user and one private credential from valid input, then verify the submitted password through the internal context.

**Independent Test**: Register a valid unused mixed-case, space-padded email and valid password; confirm exactly one normalized user and one credential exist, the public result is only `id`/`email`, and only the submitted password verifies.

### Tests for User Story 1 — write and run first

- [X] T007 [P] [US1] Add failing valid-registration and public-result/non-disclosure tests, including correct and distinct-password verification, in `test/football_market/accounts/accounts_test.exs`.
- [X] T008 [P] [US1] Add failing pure email-normalization and valid-email tests in `test/football_market/accounts/user_test.exs`.
- [X] T009 [P] [US1] Add failing password-boundary, unchanged-whitespace, Argon2id verification, and safe-inspection tests in `test/football_market/accounts/password_credential_test.exs`.

### Implementation for User Story 1

- [X] T010 [US1] Implement normalized-email validation and a safe public user projection in `lib/football_market/accounts/user.ex`.
- [X] T011 [US1] Implement unchanged-password validation, configured Argon2id hashing/verification, and non-disclosing credential inspection in `lib/football_market/accounts/password_credential.ex`.
- [X] T012 [US1] Implement `register_user/1` and boolean-only `verify_password/2` with transient password handling and one `Ecto.Multi` transaction in `lib/football_market/accounts.ex`.
- [X] T013 [US1] Run the P1 test set and correct only feature code in `test/football_market/accounts/accounts_test.exs`, `test/football_market/accounts/user_test.exs`, and `test/football_market/accounts/password_credential_test.exs` until it passes.

**Checkpoint**: A valid account is registered and verifiable without exposing a plaintext password, hash, salt, credential struct, controller, route, or token.

---

## Phase 4: User Story 2 - Receive Clear Validation Feedback (Priority: P2)

**Goal**: Reject bad input with safe, field-specific feedback and no persisted state.

**Independent Test**: Submit each malformed/blank email and short, long, or whitespace-only password separately; receive only the corresponding `:email` or `:password` error and find no new user or credential rows.

### Tests for User Story 2 — write and run first

- [X] T014 [US2] Add failing field-error and no-partial-state cases for blank/malformed emails and short, long, and all-whitespace passwords in `test/football_market/accounts/accounts_test.exs`.
- [X] T015 [P] [US2] Add failing exact 12/128-character acceptance and unaltered leading/trailing/internal-space password tests in `test/football_market/accounts/password_credential_test.exs`.
- [X] T016 [P] [US2] Add failing conservative local-part/domain and whitespace email-validation cases in `test/football_market/accounts/user_test.exs`.

### Implementation for User Story 2

- [X] T017 [US2] Complete binary input, conservative email, and password validation without trimming or normalizing passwords in `lib/football_market/accounts/user.ex` and `lib/football_market/accounts/password_credential.ex`.
- [X] T018 [US2] Return safe field-only error changesets that never retain submitted password parameters, hashes, salts, or credential structs in `lib/football_market/accounts.ex`.
- [X] T019 [US2] Assert rejection before hashing/persistence and rollback on credential-write failure through the Accounts boundary in `test/football_market/accounts/accounts_test.exs`.

**Checkpoint**: Every specified invalid submission has actionable, credential-safe feedback and leaves both tables unchanged.

---

## Phase 5: User Story 3 - Prevent Duplicate Accounts (Priority: P3)

**Goal**: Keep one stable account per normalized email even when registrations race.

**Independent Test**: Register an address, retry exact, case-only, and surrounding-whitespace variants, then exercise a competing/database-conflict path; every retry receives an `:email` error and the original user and credential remain unchanged.

### Tests for User Story 3 — write and run first

- [X] T020 [US3] Add failing exact, case-only, and surrounding-whitespace duplicate tests that retain the original account and credential in `test/football_market/accounts/accounts_test.exs`.
- [X] T021 [US3] Add a failing concurrent or direct database-conflict test proving that the named functional index, rather than a pre-insert lookup, decides normalized-email uniqueness in `test/football_market/accounts/persistence_test.exs`.

### Implementation for User Story 3

- [X] T022 [US3] Map named functional-index conflicts to the same correctable `:email` error and retain atomic rollback behavior in `lib/football_market/accounts.ex`.
- [X] T023 [US3] Verify the migration's index name/expression and conflict behavior against PostgreSQL in `priv/repo/migrations/*_create_users_and_password_credentials.exs` and `test/football_market/accounts/persistence_test.exs`.

**Checkpoint**: PostgreSQL rejects all normalized-email collisions with no changed credential or second account.

---

## Phase 6: Polish, Documentation, and Verification

**Purpose**: Demonstrate CP1-relevant account creation evidence, document the boundary, and verify that implementation did not expand scope.

- [X] T024 Update runnable prerequisites and expected internal-only outcomes in `specs/007-user-registration-and-credential-storage/quickstart.md`.
- [X] T025 Update the implementation-facing safety notes for public projections and safe error changesets in `specs/007-user-registration-and-credential-storage/contracts/accounts-context.md`.
- [X] T026 Run formatter, focused Accounts tests, and the complete test suite; record the exact commands and outcomes in `specs/007-user-registration-and-credential-storage/quickstart.md`.
- [X] T027 Confirm CP1 registration/credential coverage and scope exclusion by reviewing `docs/CHECKPOINTS.md`, `lib/football_market/accounts.ex`, and `lib/football_market_web/router.ex`; add any missing automated scope/non-disclosure assertion in `test/football_market/accounts/accounts_test.exs`.

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 starts immediately. T001 must finish before dependency-backed compilation; T002 and T003 may proceed independently.
- Phase 2 follows setup; T004 is the red persistence test, then T005 and T006 establish the migration/schema boundary.
- US1 follows Phase 2 and is the MVP. T007–T009 are independently writable red tests; implement T010–T012 in order.
- US2 and US3 both require the US1 registration path. They may have their test files drafted in parallel after US1, but their context changes (T018 and T022) are sequential because they share `lib/football_market/accounts.ex`.
- Phase 6 follows all selected stories.

### User Story Dependencies

- **US1 (P1)**: Depends only on foundational persistence; delivers the MVP.
- **US2 (P2)**: Builds validation failure behavior on US1's registration path.
- **US3 (P3)**: Builds duplicate/conflict handling on US1's registration path and the Phase 2 unique index; it does not depend on US2.

### Parallel Opportunities

- T002 and T003 can proceed alongside one another after T001 is understood.
- T007, T008, and T009 are separate test files and can be written in parallel.
- T015 and T016 are separate test files and can be written in parallel after T014's shared scenario decisions are established.
- Documentation T024 and T025 can proceed in parallel after behavior is finalized.

## Parallel Example: User Story 1

```text
Task: "Add failing valid-registration and public-result tests in test/football_market/accounts/accounts_test.exs"
Task: "Add failing email normalization tests in test/football_market/accounts/user_test.exs"
Task: "Add failing credential tests in test/football_market/accounts/password_credential_test.exs"
```

## Implementation Strategy

### MVP First

1. Complete setup and the private migration/schema foundation.
2. Write and run US1's red tests.
3. Implement the smallest Accounts path that atomically registers and verifies a valid account.
4. Run the US1 independent test before proceeding.

### Incremental Delivery

1. Add US2 validation/no-state guarantees without widening the public surface.
2. Add US3 database-conflict guarantees, including a race-safe index test.
3. Finish documentation and full verification, keeping the CP1 boundary internal and testable.

## Notes

- All tasks use the required checkbox, sequential ID, optional `[P]`, story-label, and exact-path format.
- The safe-error task resolves a planning gap: an error `Ecto.Changeset` must be constructed without raw password parameters, so the contract's promise that no outcome contains the password remains true.
- Do not add endpoints, routing, LiveViews, OpenAPI operations, login, session/token/API-key behavior, password reset/change, roles, or profile work.

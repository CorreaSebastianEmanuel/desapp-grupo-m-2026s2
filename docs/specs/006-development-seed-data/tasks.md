---
description: "Dependency-ordered implementation tasks for development seed data"
---

# Tasks: Development Seed Data

**Input**: Design documents from `/specs/006-development-seed-data/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/development-seed.md`, and `quickstart.md`

**Tests**: Required by FR-019 and the project constitution. In every phase below, write the listed tests first, run them, and observe the expected failure before implementing the corresponding behavior.

**Organization**: Tasks are grouped by user story so each delivered behavior remains independently acceptance-testable, while implementation follows the shared reconciler dependencies explicitly called out below.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel after the phase prerequisites because it changes a different file and does not depend on another incomplete task
- **[Story]**: User story traceability label (`US1`, `US2`, or `US3`)
- Every task names the exact file or files it changes or verifies

## Phase 1: Setup (TASK-005 Baseline)

**Purpose**: Prove that the catalog dependency is healthy before adding seed behavior; this feature adds no dependency, migration, endpoint, worker, provider, or cache component.

- [X] T001 Run the existing normalized-identity, relationship, lookup, and concurrent-write baseline in `test/football_market/catalog/catalog_test.exs`, `test/football_market/catalog/query_test.exs`, and `test/football_market/catalog/constraints_test.exs`; stop and repair TASK-005 rather than masking any baseline failure in seed code

**Checkpoint**: Existing catalog rules and PostgreSQL constraints pass unchanged.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Lock down the immutable manifest and deny-by-default execution boundary used by every story.

**Critical**: Complete this phase before any user-story implementation.

- [X] T002 [P] Add failing manifest contract tests for the exact 5 leagues, 5 fixed 2026–2027 seasons, 10 fictional teams, 4 canonical positions, 20 stable players, relationship distribution, uniqueness, and invalid-manifest rejection in `test/football_market/catalog/development_seed_test.exs`
- [X] T003 [P] Add failing adapter safety tests proving a disabled capability is denied before application/Repo startup and cannot be enabled by an operator environment variable in `test/mix/tasks/catalog.seed_test.exs`
- [X] T004 Configure `:development_seed_enabled` as false by default, true only in checked-in development and isolated test configuration, and independent of environment variables in `config/config.exs`, `config/dev.exs`, and `config/test.exs`
- [X] T005 Implement the immutable manifest and pre-persistence validator, including deterministic dependency order and stable values from `data-model.md`, in `lib/football_market/catalog/development_seed/manifest.ex`
- [X] T006 Implement the service-level capability check and thin Mix-task denial shell so direct service calls fail before database access and denied tasks fail before `app.start` in `lib/football_market/catalog/development_seed.ex` and `lib/mix/tasks/catalog.seed.ex`

**Checkpoint**: Manifest and environment tests pass; no catalog write path exists yet.

---

## Phase 3: User Story 1 — Prepare a Representative Demonstration Catalog (Priority: P1) MVP

**Goal**: One explicit command populates an empty migrated development catalog with the complete fictional five-league dataset without network, provider, Redis, startup, or setup coupling.

**Independent Test**: Against an empty catalog, run the seed once and use public Catalog lookups to prove exact target totals, four positions in each league, two players on each target team, and correct player-to-team-to-season-to-league relationships; verify the command reports 44 created and exits successfully.

### Tests for User Story 1

- [X] T007 [P] [US1] Add and run failing domain integration tests for empty-catalog creation, exact target counts, stable manifest values, public league/season/team/position lookups, two players per team, four positions per league, and operation without provider/Redis/network access in `test/football_market/catalog/development_seed_test.exs`
- [X] T008 [P] [US1] Add and run failing Mix-task tests for the explicit `mix catalog.seed` success path, zero exit behavior, fixed totals, created/reused output, and absence from normal application/setup execution in `test/mix/tasks/catalog.seed_test.exs`

### Implementation for User Story 1

- [X] T009 [US1] Implement deterministic create-only reconciliation for leagues, seasons, teams, positions, and players in one named-step `Ecto.Multi`, returning the typed 44-created summary only after commit, in `lib/football_market/catalog/development_seed.ex`
- [X] T010 [US1] Complete the successful `Mix.Tasks.Catalog.Seed` adapter with application startup only after authorization and stable automation-oriented output in `lib/mix/tasks/catalog.seed.ex`

**Checkpoint**: User Story 1 passes independently and provides the demonstrable CP1 catalog dataset.

---

## Phase 4: User Story 2 — Repeat Seeding Safely (Priority: P2)

**Goal**: Repeated and matching-partial runs converge without duplicate rows, mutations, or identity churn.

**Independent Test**: Snapshot all seeded UUIDs, timestamps, literal values, and relationships; rerun unchanged and prove 0 created/44 reused with an identical snapshot, then seed representative matching partial hierarchies and normalized identity variants and prove only missing records are created.

### Tests for User Story 2

- [X] T011 [US2] Add and run failing tests for unchanged second-run snapshots, 0-created/44-reused reporting, partial convergence at every hierarchy level, and preservation/reuse of case- or whitespace-varied business identities under TASK-005 normalization in `test/football_market/catalog/development_seed_test.exs`

### Implementation for User Story 2

- [X] T012 [US2] Implement all alternate-key lookups before create/reuse, coherent dual-key resolution, literal-value/timestamp preservation, and missing-descendant creation without updates or deletes in `lib/football_market/catalog/development_seed.ex`

**Checkpoint**: User Story 2 passes independently against complete and matching-partial starting states.

---

## Phase 5: User Story 3 — Preserve Local Developer Data and Expose Conflicts (Priority: P3)

**Goal**: Unrelated data survives unchanged, every target conflict fails safely and diagnostically, and no failed or racing invocation commits a partial target.

**Independent Test**: Seed around unrelated valid data and prove it is unchanged; separately exercise split identities, wrong supported pairs, misplaced teams, player attribute/relationship mismatches, late validation/persistence failures, denied environments, and a database race, verifying sanitized identity-aware errors and exact rollback to each pre-run snapshot.

### Tests for User Story 3

- [X] T013 [P] [US3] Add and run failing domain tests for unrelated-data preservation, split/partial alternate identities, wrong league pairs, misplaced teams, exact player-name mismatches, wrong relationships, validation/persistence failures, named late-step rollback, and allowlisted typed errors in `test/football_market/catalog/development_seed_test.exs`
- [X] T014 [P] [US3] Add and run failing command tests for production/unknown-environment denial before database access, nonzero `Mix.Error` outcomes, entity/manifest-identity diagnostics, and redaction of sentinel credentials, URLs, UUIDs, timestamps, raw exceptions, stack traces, and arbitrary stored values in `test/mix/tasks/catalog.seed_test.exs`
- [X] T015 [US3] Add and run an unsandboxed separate-connection race test proving constraints prevent duplicates, a losing invocation rolls back fully, and a retry converges after the winner completes in `test/football_market/catalog/development_seed_test.exs`

### Implementation for User Story 3

- [X] T016 [US3] Implement conflict matrices, the wrong-season secondary team lookup, exact non-identity and relationship comparison, transaction-wide rollback, constraint/concurrency translation, and sanitized typed error mapping that discards `changes_so_far` in `lib/football_market/catalog/development_seed.ex`
- [X] T017 [US3] Complete safe nonzero command failure rendering with allowlisted causes and no raw exception or record inspection in `lib/mix/tasks/catalog.seed.ex`

**Checkpoint**: All three stories pass independently, including security, failure, rollback, and concurrency behavior.

---

## Phase 6: Documentation & Verification

**Purpose**: Make the supported workflow discoverable and produce checkpoint-quality evidence without widening the feature boundary.

- [X] T018 [P] Document the explicit development-only command, migrated-PostgreSQL prerequisite, expected first/second-run summaries, prohibition on production/automatic loading, and troubleshooting categories in `README.md`
- [X] T019 [P] Validate and, where necessary, correct the reproducible isolated-database, no-network, catalog-visibility, and 10.0-second measurement procedure in `specs/006-development-seed-data/quickstart.md`
- [X] T020 Run focused tests followed by `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, and the complete `MIX_ENV=test mix test` regression gate for `test/football_market/catalog/development_seed_test.exs` and `test/mix/tasks/catalog.seed_test.exs`; resolve every failure in the corresponding `lib/football_market/catalog/development_seed.ex`, `lib/football_market/catalog/development_seed/manifest.ex`, or `lib/mix/tasks/catalog.seed.ex`
- [X] T021 Inspect `config/`, `mix.exs`, `lib/football_market/application.ex`, `lib/football_market_web/router.ex`, `lib/mix/tasks/`, `priv/repo/migrations/`, and deployment/release files to verify no automatic seed call, production override, HTTP route, migration, provider/cache coupling, or unauthorized dependency exists, then execute the CP1 catalog visibility and command timing checks documented in `specs/006-development-seed-data/quickstart.md`

**Checkpoint**: Documentation is accurate, focused and full gates are green, CP1 catalog evidence is reproducible, and the implementation remains within the plan boundary.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 — Setup**: Starts immediately and verifies the TASK-005 dependency.
- **Phase 2 — Foundational**: Depends on T001 and blocks all story implementation.
- **Phase 3 — US1**: Depends on Phase 2 and creates the initial transactional reconciliation path.
- **Phase 4 — US2**: Depends on US1's create path, then adds reuse and partial convergence; its acceptance behavior remains independently testable.
- **Phase 5 — US3**: Depends on the create/reuse identity paths from US1 and US2, then closes preservation, conflict, failure, and race behavior; its acceptance behavior remains independently testable.
- **Phase 6 — Documentation & Verification**: Depends on every story selected for delivery; T020 and T021 are the final gates.

### User Story Dependency Graph

```text
TASK-005 baseline -> Manifest + safety foundation -> US1 create path -> US2 reuse/convergence -> US3 conflict/rollback
                                                                                \-> Documentation + full verification
```

### Within Each Story

1. Write the listed tests and run them to observe the intended failure.
2. Implement domain behavior before adapter behavior.
3. Run that story's focused tests to its checkpoint.
4. Preserve all earlier story checkpoints before moving forward.

## Parallel Opportunities

- T002 and T003 can run together because they establish separate domain and command test contracts.
- T007 and T008 can run together after Phase 2 because they modify separate test files.
- US2 has no safe intra-story parallel pair: T012 implements the behavior specified by T011 in the same domain seam.
- T013 and T014 can run together; T015 follows T013 because it extends the same domain test file.
- T018 and T019 can run together after story completion; final gates T020 and T021 remain sequential.

## Parallel Examples

### User Story 1

```text
Task T007: Empty-catalog domain and lookup tests in test/football_market/catalog/development_seed_test.exs
Task T008: Successful command contract tests in test/mix/tasks/catalog.seed_test.exs
```

### User Story 2

```text
No safe intra-story parallel execution: run test-first T011, then implementation T012.
```

### User Story 3

```text
Task T013: Preservation, conflict, and rollback tests in test/football_market/catalog/development_seed_test.exs
Task T014: Denial, exit, diagnostic, and redaction tests in test/mix/tasks/catalog.seed_test.exs
```

## Implementation Strategy

### MVP First

1. Complete the baseline and foundational phases.
2. Complete US1 tests and implementation.
3. Stop at the US1 checkpoint and demonstrate the five-league catalog through public lookups.
4. Do not treat the MVP as release-ready until the required US2, US3, and final safety gates are complete.

### Incremental Delivery

1. Establish immutable data and a fail-closed boundary.
2. Deliver empty-catalog creation as the demonstrable MVP.
3. Add repeat and partial-state convergence without changing the US1 contract.
4. Add preservation, safe conflict signaling, rollback, and race evidence.
5. Finish documentation, performance evidence, scope inspection, and full regression.

## Notes

- The exact manifest is durable contract data; changing it later is seed-version evolution and requires a separate specification.
- PostgreSQL `lower(btrim(...))` queries and indexes from TASK-005 are the only identity-normalization authority.
- The concurrency contract preserves integrity and retry convergence; it does not require both racing commands to succeed.
- The 10-second criterion is measured only at the `quickstart.md` boundary, never as a hardware-sensitive unit-test assertion.
- No task may add update/delete behavior, raw error rendering, automatic seed loading, network access, a migration, or a new dependency.

# Tasks: Local PostgreSQL and Redis Environment

**Input**: Design artifacts in `specs/002-local-postgresql-redis/`

**Tests**: Test-first ordering is mandatory for this feature. Each test task must be run and observed failing for the intended missing behavior before its implementation task begins.

**Organization**: Tasks are grouped by user story and preserve the boundary that PostgreSQL is authoritative while Redis is connectivity-only infrastructure.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Safe to execute in parallel because it touches different files and has no dependency on another unfinished task in the phase
- **[Story]**: Traceability to the corresponding user story in `spec.md`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add dependency and test scaffolding needed by all stories without introducing product behavior.

- [x] T001 Add the pinned Redix dependency and infrastructure test aliases to `mix.exs` and resolve the lock entry in `mix.lock`
- [x] T002 [P] Add shared shell assertion, cleanup, timeout, and secret-redaction helpers in `test/scripts/support/local_services_test_helpers.sh`
- [x] T003 [P] Add ExUnit support for starting temporary infrastructure clients without booting the application in `test/support/infrastructure_case.ex`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish one pure, sanitized configuration boundary before service, migration, or connectivity behavior is implemented.

**Critical resolution**: `mix infrastructure.verify` must use `@requirements []`, load application configuration without starting the supervision tree, and manage temporary Repo and Redis clients independently so PostgreSQL failure cannot suppress the Redis result. Test database validation must happen before every test-mode Repo startup or schema mutation.

- [x] T004 Write failing unit tests for environment parsing, fixed test-database identity, development/test inequality, safe target rendering, and credential redaction in `test/football_market/infrastructure/configuration_test.exs`
- [x] T005 Implement pure PostgreSQL/Redis configuration parsing, fail-closed test database validation, and sanitized diagnostics in `lib/football_market/infrastructure/configuration.ex`
- [x] T006 Wire environment-overridable development and test settings through the validated configuration boundary, with sensitive connection output disabled, in `config/dev.exs`, `config/test.exs`, and `config/runtime.exs`
- [x] T007 Add tracked local-only defaults and explicit non-production credential warnings in `.env.example`

**Checkpoint**: Invalid or unsafe configuration fails by category before connections or mutations and never renders passwords or full URLs.

---

## Phase 3: User Story 1 - Start Reproducible Local Services (Priority: P1) MVP

**Goal**: A clean checkout can start, inspect, verify, stop, restart, and explicitly reset deterministic PostgreSQL and Redis services.

**Independent Test**: With Docker and documented free loopback ports, run the repository lifecycle commands from absent project state; both services become independently ready within 30 seconds, routine cycles preserve a sentinel, and only the explicit reset removes scoped state.

### Tests for User Story 1

- [x] T008 [P] [US1] Write a failing static contract test for exactly two digest-pinned official images, loopback ports, fixed project/volumes, persistent storage, and finite health checks in `test/scripts/compose_contract_test.sh`
- [x] T009 [P] [US1] Write a failing lifecycle test for start, inspect, bounded independent readiness, stop, restart, persistence, and scoped reset in `test/scripts/local_services_lifecycle_test.sh`
- [x] T010 [P] [US1] Write a failing startup-error test covering occupied PostgreSQL and Redis ports and unready service timeout diagnostics in `test/scripts/local_services_failure_test.sh`

### Implementation for User Story 1

- [x] T011 [US1] Define exactly PostgreSQL and Redis with valid multi-architecture official image digests, `127.0.0.1` ports, named volumes, and bounded health checks in `compose.yaml`
- [x] T012 [US1] Implement deterministic start, inspect, ready, stop, restart, and separately confirmed repository-scoped reset actions in `scripts/local_services.sh`
- [x] T013 [US1] Make readiness report safe targets and each service independently, return nonzero unless both are ready, and enforce the 30-second bound in `scripts/local_services.sh`
- [x] T014 [US1] Document prerequisites, configure/start/inspect/readiness/stop/restart/reset commands, persistence semantics, port conflicts, and local-credential warnings in `README.md`
- [x] T015 [US1] Run and record the US1 automated commands and independent expected outcomes in `specs/002-local-postgresql-redis/quickstart.md`

**Checkpoint**: US1 is independently usable and testable without any database schema or application connectivity behavior.

---

## Phase 4: User Story 2 - Prepare and Migrate the Database (Priority: P2)

**Goal**: Empty development and isolated test databases can be safely prepared and migrated repeatedly without touching development data from tests.

**Independent Test**: Prepare empty development and test databases, rerun preparation/migration, verify the singleton probe and a preserved development sentinel, and confirm unsafe test identities fail before mutation.

### Tests for User Story 2

- [x] T016 [P] [US2] Write failing migration tests for the infrastructure-only singleton probe, rollback shape, and repeated current migration in `test/integration/infrastructure_migration_test.exs`
- [x] T017 [P] [US2] Write a failing black-box test proving test preparation preserves a development sentinel and rejects dev/non-test database overrides before mutation in `test/scripts/database_isolation_test.sh`
- [x] T018 [P] [US2] Write failing Mix alias tests for repeatable development/test create and migrate workflows and migration-identity failure output in `test/football_market/infrastructure/database_workflow_test.exs`

### Implementation for User Story 2

- [x] T019 [US2] Add the ordered reversible singleton `infrastructure_probe` migration with no product-domain tables in `priv/repo/migrations/20260913000000_create_infrastructure_probe.exs`
- [x] T020 [US2] Add guarded database create, migrate, and test preparation tasks that validate test identity before Repo startup or mutation in `lib/mix/tasks/infrastructure.database.ex`
- [x] T021 [US2] Route standard repeatable Ecto setup/migrate and test aliases through the pre-mutation guard in `mix.exs`
- [x] T022 [US2] Add `FootballMarket.Repo` to the normal application supervision tree while retaining the no-auto-start verification boundary in `lib/football_market/application.ex`
- [x] T023 [US2] Document ordered preparation, migration, rerun, rollback-check, and isolated test workflows in `README.md`
- [x] T024 [US2] Run the migration, repeatability, and test-isolation suite and reconcile its canonical commands in `specs/002-local-postgresql-redis/quickstart.md`

**Checkpoint**: US2 safely produces the same minimal schema in dev and test; no product entity exists and test commands cannot mutate dev.

---

## Phase 5: User Story 3 - Verify Application Connectivity (Priority: P3)

**Goal**: One application-owned command reports PostgreSQL and Redis independently, sanitizes failures, and succeeds only when both probes succeed.

**Independent Test**: Run `mix infrastructure.verify` with both services available, then with each service unavailable and each credential/config invalid; every run prints both dependency results, leaks no secret, and returns the correct aggregate status.

### Tests for User Story 3

- [x] T025 [P] [US3] Write failing unit tests for probe-result aggregation, deterministic per-service rendering, cleanup, and aggregate exit selection in `test/football_market/infrastructure/verification_test.exs`
- [x] T026 [P] [US3] Write failing Redis boundary tests for application configuration, real `PING`, safe target output, and sanitized errors in `test/football_market/infrastructure/redis_test.exs`
- [x] T027 [P] [US3] Write failing black-box integration tests for both-success, PostgreSQL-down, Redis-down, invalid PostgreSQL auth/config, and invalid Redis auth/config in `test/integration/infrastructure_verify_test.sh`
- [x] T028 [P] [US3] Write a failing regression test proving Redis loss/reset neither mutates PostgreSQL nor makes Redis authoritative in `test/integration/redis_disposability_test.sh`

### Implementation for User Story 3

- [x] T029 [P] [US3] Implement the narrow application-owned Redix configuration and connectivity boundary with no cache operations in `lib/football_market/infrastructure/redis.ex`
- [x] T030 [P] [US3] Implement probe result aggregation, sanitized rendering, and cleanup semantics in `lib/football_market/infrastructure/verification.ex`
- [x] T031 [US3] Implement `mix infrastructure.verify` with no automatic application start, independently managed temporary Repo/Redis clients, both probes attempted, and nonzero aggregate failure in `lib/mix/tasks/infrastructure.verify.ex`
- [x] T032 [US3] Document application connectivity success/failure commands, safe diagnostics, and the absence of a public health endpoint in `README.md`
- [x] T033 [US3] Run all five connectivity trials and Redis-disposability verification, then reconcile canonical commands in `specs/002-local-postgresql-redis/quickstart.md`

**Checkpoint**: US3 provides application-level evidence for both dependencies without short-circuiting, leaking secrets, adding cache behavior, or exposing HTTP health.

---

## Phase 6: Polish & Cross-Cutting Verification

**Purpose**: Prove checkpoint compatibility, security, reproducibility, and full acceptance behavior across all stories.

- [x] T034 [P] Add a tracked-file security/scope test for secrets, absolute paths, all-interface service ports, product-domain schema objects, and production assumptions in `test/scripts/task_002_scope_security_test.sh`
- [x] T035 [P] Add a three-cycle persistence and full ordered lifecycle acceptance runner with cleanup traps in `test/scripts/task_002_acceptance_test.sh`
- [x] T036 Update the nine lifecycle actions, supported platform, destructive-reset warning, troubleshooting, and TASK-001 compatibility instructions in `README.md`
- [x] T037 Run `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix test`, all `test/scripts/*_test.sh` TASK-002 suites, and `test/scripts/verify_foundation_test.sh`, fixing only TASK-002 regressions in their owning files
- [x] T038 Execute the clean-checkout manual protocol on a supported environment, verify the ten-minute and three-cycle success criteria, and retain uncommitted command evidence as prescribed by `specs/002-local-postgresql-redis/plan.md`
- [x] T039 Reconcile final implemented commands and expected outcomes across `README.md` and `specs/002-local-postgresql-redis/quickstart.md`, confirming all FR-001–FR-016 and SC-001–SC-008 evidence is locatable

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 starts immediately.
- Phase 2 depends on Phase 1 and blocks all stories.
- US1 starts after Phase 2 and is the MVP.
- US2 depends on US1 service availability and lifecycle commands.
- US3 depends on US2 configuration, Repo, and migration preparation.
- Phase 6 depends on all selected stories.

### User Story Completion Order

```text
Setup -> Foundation -> US1 (services) -> US2 (database) -> US3 (application connectivity) -> Cross-cutting verification
```

This ordering is required by observable prerequisites, while tests marked `[P]` within a phase may be authored concurrently before implementation.

### Within Each User Story

- Author every listed test first and confirm it fails for the intended missing behavior.
- Implement the smallest behavior needed to pass it, preserving layer boundaries.
- Run the story's full test set at its checkpoint before advancing.
- Documentation must use the exact commands and exit semantics verified by tests.

## Parallel Opportunities

- T002 and T003 can proceed in parallel after T001.
- T008–T010 can be authored in parallel before T011–T015.
- T016–T018 can be authored in parallel before T019–T024.
- T025–T028 can be authored in parallel; T029 and T030 can then proceed in parallel before T031.
- T034 and T035 can proceed in parallel before the final verification sequence.

## Parallel Examples

### User Story 1

```text
T008: compose contract test
T009: lifecycle/persistence test
T010: occupied-port/readiness failure test
```

### User Story 2

```text
T016: migration behavior test
T017: database isolation black-box test
T018: database workflow task test
```

### User Story 3

```text
T025: verification aggregation unit test
T026: Redis boundary unit test
T027: independent failure integration test
T028: Redis disposability regression test
```

## Implementation Strategy

### MVP First

1. Complete Setup and Foundational phases.
2. Complete US1 and run its independent test.
3. Stop for an MVP demonstration of reproducible, loopback-only service lifecycle.

### Incremental Delivery

1. Add US2 to prove deterministic migrations and fail-closed test isolation.
2. Add US3 to prove application-owned, independently reported connectivity.
3. Complete cross-cutting security, compatibility, timing, and acceptance verification.

## Scope Guardrails

- Do not add domain entities, seeds, cache reads/writes, public health routes, production orchestration, monitoring, authentication, or later-checkpoint behavior.
- PostgreSQL remains authoritative; Redis contains no durable or business state.
- Reset is explicit, destructive, repository-scoped, and never invoked by ordinary start/stop/restart or automated tests without isolated disposable state.
- Never print passwords, complete connection URLs, secret-bearing options, or sensitive driver errors.

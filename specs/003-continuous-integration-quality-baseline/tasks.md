---

description: "Dependency-ordered implementation tasks for the continuous integration quality baseline"
---

# Tasks: Continuous Integration Quality Baseline

**Input**: Design documents from `/specs/003-continuous-integration-quality-baseline/`

**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/quality-baseline.md`, `quickstart.md`, governing product/checkpoint/architecture documents, and current TASK-003 feedback

**Tests**: Required. Every behavior is introduced test-first, including parsed workflow-contract checks and controlled negative fixtures.

**Organization**: Tasks are grouped by user story. US1 establishes the positive gate, US2 proves each regression fails safely, and US3 documents and verifies local parity.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it changes a different file and has no incomplete dependency
- **[Story]**: Maps the task to its specification user story
- Every task names the exact file or files it reads or changes

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the inherited TASK-001 foundation before adding CI behavior.

- [X] T001 Verify the exact Elixir 1.20.3 / Erlang/OTP 29.0.6 pins, locked dependency workflow, PostgreSQL-backed default test alias, and existing toolchain/service helpers in `.tool-versions`, `mix.exs`, `mix.lock`, `scripts/check_toolchain.sh`, and `scripts/local_services.sh`; record any mismatch in `specs/003-continuous-integration-quality-baseline/handoffs/tasks.md` and stop rather than broadening the plan

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the test harnesses that all three stories use.

**CRITICAL**: Complete this phase before implementing any workflow, sentinel, runner script, or documentation.

- [X] T002 Create a shell-level test harness that uses isolated temporary fixtures and asserts command exit status, output, cleanup, and failure propagation in `test/scripts/ci_unit_tests_test.sh`
- [X] T003 [P] Create an ExUnit workflow-contract test harness that parses YAML before semantic assertions and safely handles YAML 1.1 interpretation of the `on` key in `test/ci/quality_baseline_contract_test.exs`

**Checkpoint**: Both harnesses execute and fail because the planned CI artifacts do not yet exist; no product/domain source or persistent data has changed.

---

## Phase 3: User Story 1 - Trust Every Proposed Change (Priority: P1) MVP

**Goal**: Every pull request to `main` and push to `main` receives one revision-bound job whose setup is followed by exactly three visible quality categories, and success requires all three categories to pass.

**Independent Test**: Parse the workflow, confirm its eligible triggers, revision-safe concurrency, least-privilege permissions, pinned environment, PostgreSQL service, single checkout/job, and exact three labelled commands; then run all three commands successfully on one conforming revision.

### Tests for User Story 1

- [X] T004 [US1] Add failing positive contract assertions for pull-request and `main` push triggers, PR/ref concurrency with cancellation, `contents: read`, one job/checkout, pinned Ubuntu and BEAM versions, PostgreSQL health configuration, setup sequence, and exactly three labelled category commands in `test/ci/quality_baseline_contract_test.exs`
- [X] T005 [US1] Add failing runner assertions that the unit-test wrapper invokes the unfiltered default `MIX_ENV=test mix test --warnings-as-errors`, preserves a nonzero Mix status, requires one unique discovery marker, streams useful diagnostics, and removes temporary output in `test/scripts/ci_unit_tests_test.sh`

### Implementation for User Story 1

- [X] T006 [P] [US1] Add a stable side-effect-free sentinel that emits the unique discovery marker from the normal ExUnit discovery scope in `test/ci/quality_baseline_discovery_test.exs`
- [X] T007 [US1] Implement the portable fail-closed unit-test wrapper, including signal-safe temporary-output cleanup and no stale/path/tag/exclusion filters, in `scripts/ci_unit_tests.sh`
- [X] T008 [US1] Implement the single GitHub Actions job with one checkout, exact toolchain verification, locked dependency setup, ephemeral PostgreSQL, least-privilege permissions, revision-safe concurrency, and the three fail-fast labelled commands in `.github/workflows/quality-baseline.yml`
- [X] T009 [US1] Run `ruby -e 'require "yaml"; YAML.parse_file(ARGV.fetch(0)) or abort("invalid YAML")' .github/workflows/quality-baseline.yml`, `MIX_ENV=test mix test test/ci/quality_baseline_contract_test.exs`, and `test/scripts/ci_unit_tests_test.sh`; fix only US1 contract failures in `.github/workflows/quality-baseline.yml`, `scripts/ci_unit_tests.sh`, `test/ci/quality_baseline_discovery_test.exs`, `test/ci/quality_baseline_contract_test.exs`, and `test/scripts/ci_unit_tests_test.sh`

**Checkpoint**: The parsed contract passes and the conforming local revision can pass formatting, warning-fatal compilation, and the complete non-empty ExUnit suite for the same checkout.

---

## Phase 4: User Story 2 - Detect Quality Regressions (Priority: P2)

**Goal**: Formatting drift, project-owned warnings, failing tests, incomplete discovery, and unsafe workflow shortcuts each produce an unambiguous nonzero result without mutating source or masking failures.

**Independent Test**: Apply each isolated controlled defect to a clean working tree, run the applicable category, verify the expected category and overall command fail with diagnostics, restore the defect, and confirm no fixture change remains.

### Tests for User Story 2

- [X] T010 [US2] Add failing workflow-contract negatives for mutating formatter commands, failure-masking constructs, narrowed test flags, secrets or write permissions, Redis/provider dependencies, mutable toolchain versions, and extra coverage/SonarCloud/deployment/E2E/architecture categories in `test/ci/quality_baseline_contract_test.exs`
- [X] T011 [US2] Add failing isolated runner negatives for a failing test command, absent or renamed sentinel marker, warning-fatal test compilation, misleading early success, and temporary-output leakage in `test/scripts/ci_unit_tests_test.sh`

### Implementation for User Story 2

- [X] T012 [US2] Harden fail-closed behavior until every runner negative passes while preserving the raw ExUnit failure diagnostics in `scripts/ci_unit_tests.sh`
- [X] T013 [US2] Harden the workflow until every prohibited-pattern contract passes while retaining non-mutating formatting, warning-fatal project/test compilation, exact category scope, and no secret or live-provider dependency in `.github/workflows/quality-baseline.yml`
- [X] T014 [US2] Exercise the unformatted-file, application/support warning, test-file warning, failing assertion, and missing-sentinel fixtures one at a time; record revision, toolchain, command, exit status, diagnostic, restoration, and clean-tree confirmation in `specs/003-continuous-integration-quality-baseline/verification.md`

**Checkpoint**: Every controlled defect fails in its intended category, source remains unmodified by checks, and the worktree contains no residual fixture changes.

---

## Phase 5: User Story 3 - Reproduce CI Locally (Priority: P3)

**Goal**: A contributor can reproduce the same three category outcomes locally with the exact supported toolchain and PostgreSQL, without hosted-only secrets or services.

**Independent Test**: Starting from the documented prerequisites, follow only `README.md`; verify its three commands and their order match the parsed workflow and produce matching outcomes for the conforming revision and controlled failures.

### Tests for User Story 3

- [X] T015 [US3] Add failing contract assertions that `README.md` names the exact toolchain check, locked dependency setup, PostgreSQL readiness, and the same three commands in workflow order without production secrets, Redis, or live providers in `test/ci/quality_baseline_contract_test.exs`

### Implementation for User Story 3

- [X] T016 [US3] Document prerequisites, exact toolchain/service preparation, the three local commands in workflow order, expected diagnostics, and the pre-publication versus post-publication evidence boundary in `README.md`
- [X] T017 [US3] Follow only the new `README.md` section on the conforming revision and compare each local outcome with the parsed workflow command contract; record the revision, exact toolchain, PostgreSQL readiness, three exit statuses, and parity result in `specs/003-continuous-integration-quality-baseline/verification.md`

**Checkpoint**: A clean checkout can reproduce all three CI categories locally and the documentation has executable contract coverage.

---

## Phase 6: Polish & Cross-Cutting Verification

**Purpose**: Complete pre-publication evidence without adding quality categories or product behavior.

- [X] T018 Run `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, and `scripts/ci_unit_tests.sh` in order on the pinned toolchain with PostgreSQL ready; append the revision and category results to `specs/003-continuous-integration-quality-baseline/verification.md`
- [X] T019 Run the YAML parse, focused ExUnit workflow contract, shell runner contract, and full default suite described in `specs/003-continuous-integration-quality-baseline/quickstart.md`; reconcile failures in `.github/workflows/quality-baseline.yml`, `README.md`, `scripts/ci_unit_tests.sh`, `test/ci/quality_baseline_discovery_test.exs`, `test/ci/quality_baseline_contract_test.exs`, and `test/scripts/ci_unit_tests_test.sh`
- [X] T020 Audit the final diff against `specs/003-continuous-integration-quality-baseline/spec.md`, `specs/003-continuous-integration-quality-baseline/plan.md`, `specs/003-continuous-integration-quality-baseline/contracts/quality-baseline.md`, `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, and `docs/CHECKPOINTS.md`; confirm no product data/behavior, secret, live provider, extra quality category, coverage, SonarCloud, deployment, release, E2E, or architecture-check scope was added in `specs/003-continuous-integration-quality-baseline/verification.md`

**Pre-publication gate**: QA and final review may return `Verdict: PASS` only after T001-T020 pass. A missing hosted run for an unpublished workflow is not a blocker.

**Post-publication obligation**: After Agentflow creates the feature commit, pushes it, and opens the PR, verify the hosted run is bound to the PR head SHA. After human merge, verify the separate `main` push run is bound to the integrated SHA. Record both as CP1 evidence, including a cold-cache or equivalent cache-miss proof. These checks are deliberately not pre-publication implementation tasks.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Starts immediately; a prerequisite mismatch stops work for reviewed replanning.
- **Foundational (Phase 2)**: Depends on T001 and must initially fail against absent artifacts.
- **US1 (Phase 3)**: Depends on both foundational harnesses; T004 and T005 precede T006-T008, and T009 validates the completed story.
- **US2 (Phase 4)**: Depends on US1; T010-T011 must fail before T012-T013, then T014 proves controlled failures and restoration.
- **US3 (Phase 5)**: Depends on US1 commands being stable; T015 must fail before T016, then T017 proves parity.
- **Polish (Phase 6)**: Depends on all desired stories and completes the pre-publication gate.
- **Hosted evidence**: Depends on publication and later human merge; it cannot block the pre-publication commit/PR cycle.

### User Story Dependencies

- **US1 (P1)**: The MVP and shared executable baseline; begins after Phase 2.
- **US2 (P2)**: Depends on US1 artifacts so each failure mode can be exercised, but has its own controlled-negative acceptance boundary.
- **US3 (P3)**: Depends on US1 command stability, but is independently accepted through documentation-only execution and parity comparison.

### Parallel Opportunities

- T002 and T003 can run in parallel after T001.
- T006 can run in parallel with the initial T004-T005 red-test work because it changes an independent file, but T007 still depends on T005 and T008 depends on T004.
- Once US1 is stable, US2 test authoring (T010-T011) and US3 documentation-contract authoring (T015) touch shared contract files and should be sequenced, not run concurrently.
- Post-publication evidence collection occurs later and does not delay pre-publication QA/final review.

## Parallel Example: User Story 1

```text
Task T004: Add the parsed positive workflow contract in test/ci/quality_baseline_contract_test.exs
Task T005: Add the positive/fail-propagation runner contract in test/scripts/ci_unit_tests_test.sh

After both tests are red:
Task T006: Add the sentinel in test/ci/quality_baseline_discovery_test.exs
Task T007: Implement scripts/ci_unit_tests.sh after T005
Task T008: Implement .github/workflows/quality-baseline.yml after T004
```

## Implementation Strategy

### MVP First

1. Complete Setup and Foundational phases.
2. Complete US1 test-first through T009.
3. Stop and independently validate the positive parsed workflow contract and conforming local run.

### Incremental Delivery

1. US1 provides the visible three-category gate.
2. US2 proves the gate fails closed for every required defect and leaves no fixture residue.
3. US3 makes the exact behavior reproducible without hosted-only dependencies.
4. Phase 6 supplies the full pre-publication evidence package.
5. Publication and merge unlock the two hosted-evidence checks required for final CP1 records.

## Resolution Notes

- Current `backlog/feedback/TASK-003.md` supersedes the stale statement in `handoffs/product-decision.md` that no human feedback exists.
- Hosted GitHub Actions execution is required post-publication evidence, not a pre-publication QA prerequisite; local pinned-toolchain parity, parsed YAML semantics, and controlled negatives remain mandatory.
- The three-category limit counts enforced quality outcomes, not necessary checkout/toolchain/dependency/PostgreSQL setup steps.
- No domain entity, migration, Redis dependency, provider adapter, product behavior, or architecture boundary is introduced.

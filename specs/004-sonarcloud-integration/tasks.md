---
description: "Executable task list for SonarCloud CI publication and CP1 issue enforcement"
---

# Tasks: SonarCloud Integration

**Input**: Design documents from `/specs/004-sonarcloud-integration/`

**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/sonarcloud-ci.md`, and `quickstart.md`

**Tests**: Required by the specification, constitution, and explicit test-first request. Within each story, create the named failing tests before implementation and retain deterministic fixtures for external behavior.

**Organization**: Tasks are grouped by user story. No task changes application behavior, the domain model, persistence, external football adapters, or `.github/workflows/quality-baseline.yml`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel with adjacent tasks after its declared prerequisites because it targets different files
- **[Story]**: Maps the task to a user story in `spec.md`
- Every task names its exact repository path

## Phase 1: Setup (Shared Test Infrastructure)

**Purpose**: Establish sanitized fixture conventions and a durable oracle for the unchanged TASK-003 workflow.

- [X] T001 Create sanitized SonarCloud fixture conventions, prohibited secret patterns, and fixture provenance guidance in `test/scripts/fixtures/sonarcloud/README.md`
- [X] T002 [P] Capture the pre-feature SHA-256 oracle for the unchanged TASK-003 workflow in `test/ci/fixtures/quality-baseline.sha256`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Fix repository-owned interfaces and non-secret configuration before story implementation.

**Critical**: Complete this phase before any user-story work.

- [X] T003 Define the dependency-free gate CLI, exit-code semantics, diagnostic taxonomy, bounded retry policy, redaction rules, and injectable HTTP boundary as failing interface assertions in `test/scripts/sonar_checkpoint_gate_test.py`
- [X] T004 [P] Add a failing repository contract asserting `.github/workflows/quality-baseline.yml` matches `test/ci/fixtures/quality-baseline.sha256` and remains semantically discoverable in `test/ci/sonarcloud_contract_test.exs`
- [X] T005 Resolve and document the real non-secret SonarCloud organization key and project key placeholders without adding credentials in `sonar-project.properties`

**Checkpoint**: The gate interface, baseline-preservation oracle, and non-secret project identity are fixed; tests are expected to fail until their story implementation lands.

---

## Phase 3: User Story 1 — Review Published Code Analysis (Priority: P1) MVP

**Goal**: Publish a visible SonarCloud result for every supported internal PR head and every push to `main`, with exact revision attribution and no regression to TASK-003.

**Independent Test**: Run the repository contract suite, then open/update an internal PR and verify the completed required check is attached to its latest head SHA; after integration, verify the `main` analysis is attached to the integrated SHA.

### Tests for User Story 1 — write and observe failures first

- [X] T006 [P] [US1] Add failing workflow contract cases for PR event types, draft inclusion, `main` pushes, forbidden `pull_request_target`, least privilege, SHA checkout, full history, immutable action pins, bounded quality-gate wait, and secret indirection in `test/ci/sonarcloud_contract_test.exs`
- [X] T007 [P] [US1] Add failing configuration contract cases for source/test roots, exact exclusions, UTF-8, absent coverage settings, and non-secret identifiers in `test/ci/sonarcloud_contract_test.exs`
- [X] T008 [P] [US1] Add failing contract cases for PR/main concurrency groups, superseded-run cancellation, latest-head governance, and distinct PR-analysis versus primary-count summary labels in `test/ci/sonarcloud_contract_test.exs`

### Implementation for User Story 1

- [X] T009 [P] [US1] Complete CI analysis scope, exact generated/vendor/dependency exclusions, and non-secret organization/project identity in `sonar-project.properties`
- [X] T010 [US1] Implement automatic PR and `main` triggers, least-privilege permissions, SHA checkout with full history, and PR/main-scoped concurrency in `.github/workflows/sonarcloud.yml`
- [X] T011 [US1] Add the immutable-pinned scanner step, protected `SONAR_TOKEN` environment indirection, non-debug operation, 300-second native gate wait, and fail-closed scan/publication behavior in `.github/workflows/sonarcloud.yml`
- [X] T012 [US1] Emit distinct exact-head analysis and current-primary-count headings plus revision-aware findings links in the GitHub step summary from `.github/workflows/sonarcloud.yml`
- [X] T013 [US1] Run the US1 contract suite and baseline oracle, fixing only TASK-004 files until `MIX_ENV=test mix test test/ci/sonarcloud_contract_test.exs` passes with `.github/workflows/quality-baseline.yml` unchanged

**Checkpoint**: Automatic exact-revision analysis is statically verified and ready for hosted publication; the CP1 count remains deliberately non-passing until US2.

---

## Phase 4: User Story 2 — Enforce the Checkpoint Issue Threshold (Priority: P2)

**Goal**: Pass only when a completed published analysis also yields a valid primary-branch `open_issues` count from 0 through 9; fail closed at 10 or on unavailable, malformed, or stale evidence.

**Independent Test**: Run deterministic fixtures proving 9 passes, 10 fails, and all missing/malformed/stale/publication cases fail; for `main`, prove the latest published analysis revision must match the triggering SHA before its measure is accepted.

### Tests for User Story 2 — write and observe failures first

- [X] T014 [P] [US2] Add sanitized measure fixtures for 0, 9, 10, greater-than-10, absent, duplicate, numeric-string, decorated-string, float, negative, and malformed values under `test/scripts/fixtures/sonarcloud/`
- [X] T015 [P] [US2] Add sanitized latest-analysis fixtures for matching, stale, missing, duplicate/ambiguous, and malformed revision evidence under `test/scripts/fixtures/sonarcloud/`
- [X] T016 [US2] Add failing boundary, structural-validation, `main` revision-match, PR current-main-label, and exit-code tests using the fixtures in `test/scripts/sonar_checkpoint_gate_test.py`
- [X] T017 [P] [US2] Add failing workflow contract cases for the exact latest-analysis and `open_issues` API requests, expected-SHA propagation on `main`, PR/main mode separation, and gate failure propagation in `test/ci/sonarcloud_contract_test.exs`

### Implementation for User Story 2

- [X] T018 [US2] Implement strict latest-analysis revision parsing and fail-closed `main` SHA matching with injectable standard-library HTTP transport in `scripts/sonar_checkpoint_gate.py`
- [X] T019 [US2] Implement strict single non-negative integer `open_issues` parsing and the `< 10` decision boundary in `scripts/sonar_checkpoint_gate.py`
- [X] T020 [US2] Wire the post-publication gate, project/branch/expected-revision inputs, protected token header, sanitized summary, and nonzero failure propagation into `.github/workflows/sonarcloud.yml`
- [X] T021 [US2] Run `python3 -m unittest test/scripts/sonar_checkpoint_gate_test.py` and `MIX_ENV=test mix test test/ci/sonarcloud_contract_test.exs`, fixing boundary and revision-freshness defects in `scripts/sonar_checkpoint_gate.py` and `.github/workflows/sonarcloud.yml`

**Checkpoint**: Deterministic tests prove the CP1 boundary and prevent missing, malformed, stale, or unpublished evidence from passing.

---

## Phase 5: User Story 3 — Diagnose Analysis Failures Safely (Priority: P3)

**Goal**: Distinguish issue-threshold, native-gate, authentication, configuration, processing, publication, timeout, API/rate-limit, and malformed-response failures without disclosing credentials.

**Independent Test**: Run controlled fixture failures and verify nonzero conclusions, stable non-sensitive diagnostic classes, bounded retries, and zero fixture-token occurrences in stdout/stderr or tracked content.

### Tests for User Story 3 — write and observe failures first

- [X] T022 [P] [US3] Add sanitized HTTP 401, 403, 404, 429, 5xx, network-error, timeout, and recovery-after-retry fixtures under `test/scripts/fixtures/sonarcloud/`
- [X] T023 [US3] Add failing tests for retry bounds, non-retryable failures, diagnostic classification, stdout/stderr redaction, URL/header redaction, and token-canary absence in `test/scripts/sonar_checkpoint_gate_test.py`
- [X] T024 [P] [US3] Add failing workflow contract assertions that debug logging is disabled and secrets never appear in command arguments, persisted configuration, or summaries in `test/ci/sonarcloud_contract_test.exs`

### Implementation for User Story 3

- [X] T025 [US3] Implement bounded transient retry/backoff, immediate non-retryable auth/configuration failure, stable sanitized diagnostics, and exception redaction in `scripts/sonar_checkpoint_gate.py`
- [X] T026 [US3] Add failure-class-specific non-sensitive annotations and remediation links while preserving nonzero conclusions in `.github/workflows/sonarcloud.yml`
- [X] T027 [US3] Run both SonarCloud test suites and scan tracked TASK-004 files for the token canary, fixing leaks or ambiguous classifications in `scripts/sonar_checkpoint_gate.py` and `.github/workflows/sonarcloud.yml`

**Checkpoint**: Every modeled non-code failure is visibly non-passing, actionable, and free of secret values.

---

## Phase 6: Documentation, Hosted Evidence, and Cross-Cutting Verification

**Purpose**: Document operation, preserve baseline behavior, and collect the external evidence required for CP1 without manufacturing unsafe failures.

- [X] T028 [P] Document reviewer navigation, the two-part PR result, `< 10` interpretation, analyzed scope/exclusions, required repository secret and SonarCloud administration, failure remediation, and rerun behavior in `README.md`
- [X] T029 [P] Reconcile the final workflow/gate design and revision-freshness rule with the durable decision record in `docs/adr/0001-sonarcloud-cp1-whole-project-gate.md`
- [X] T030 Run deterministic SonarCloud verification plus the unchanged TASK-003 parity commands from `specs/004-sonarcloud-integration/quickstart.md`, recording command/result evidence in `specs/004-sonarcloud-integration/verification.md`
- [ ] T031 Publish an internal PR and verify all supported PR lifecycle events, latest-head/concurrency behavior, two-action findings navigation, exact SHA attribution, and visible failure semantics, recording non-secret evidence in `specs/004-sonarcloud-integration/verification.md`
- [ ] T032 After authorized merge, verify the integrated `main` SHA, analysis/compute identity, timestamp, native gate, active profile names/keys, findings URL, and `open_issues` value of 0–9, recording immutable CP1 evidence in `specs/004-sonarcloud-integration/verification.md`
- [X] T033 Perform final scope/security review confirming no product/domain/persistence changes, no coverage gate, no credential material, no action tag pins, and no diff to `.github/workflows/quality-baseline.yml`, documenting the result in `specs/004-sonarcloud-integration/verification.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Starts immediately.
- **Foundational (Phase 2)**: Depends on T001–T002 and blocks all stories.
- **US1 (Phase 3)**: Depends on Foundation; establishes publication workflow and is the MVP.
- **US2 (Phase 4)**: Depends on US1 because it adds the repository-owned threshold gate to the published-analysis workflow.
- **US3 (Phase 5)**: Depends on US2 because it hardens the gate's error and retry paths.
- **Documentation/verification (Phase 6)**: T028–T029 may start after US2 stabilizes; T030 and T033 require US3; T031 requires publication; T032 requires an authorized merge and a completed `main` run.

### User Story Dependency Graph

```text
Setup -> Foundation -> US1 (publication) -> US2 (threshold) -> US3 (safe diagnostics)
                                                        \-> Documentation
US3 -> deterministic verification -> hosted PR evidence -> hosted main CP1 evidence
```

### Within Each User Story

- Add the story's failing tests and fixtures before its implementation tasks.
- Run deterministic tests before hosted validation.
- Never weaken a failing baseline or SonarCloud gate to obtain green evidence.
- A canceled superseded run is obsolete; only the latest SHA's completed run can govern.

## Parallel Opportunities

- T001 and T002 can proceed in parallel.
- T004 and T005 can proceed after T001/T002 while T003 defines the gate interface.
- US1 contract concerns T006–T008 can be authored in parallel, then implementation proceeds T009 → T010 → T011 → T012 → T013.
- US2 fixture sets T014–T015 and workflow contract T017 can proceed in parallel before T016/T018.
- US3 fixtures T022 and workflow security contract T024 can proceed in parallel before T023/T025.
- Documentation T028 and ADR reconciliation T029 can proceed in parallel after behavior stabilizes.

## Parallel Examples

### User Story 1

```text
Task T006: workflow triggers, permissions, checkout, pins, wait, and secret contract
Task T007: scanner source/test scope and exclusions contract
Task T008: concurrency, latest-head, and summary-label contract
```

### User Story 2

```text
Task T014: count-boundary and malformed-measure fixtures
Task T015: latest-analysis revision fixtures
Task T017: API request and workflow propagation contract
```

### User Story 3

```text
Task T022: transport/service failure fixtures
Task T024: workflow secret and debug-output contract
```

## Implementation Strategy

### MVP First

1. Complete Setup and Foundation.
2. Complete US1 and prove exact-revision publication contracts.
3. Stop and validate the hosted PR result before extending the workflow.

US1 is the smallest demonstrable increment, but it does **not** satisfy CP1 until US2, US3, baseline parity, and hosted `main` evidence are complete.

### Incremental Delivery

1. US1 publishes attributable analysis while leaving the checkpoint result non-passing.
2. US2 adds deterministic whole-project threshold enforcement and `main` revision freshness.
3. US3 adds safe, actionable failure handling.
4. Cross-cutting verification preserves TASK-003 and gathers real PR/`main` evidence.

## Completion Criteria

- All 33 tasks retain the exact checklist format and sequential IDs.
- Every story's tests precede implementation and pass before hosted validation.
- The required PR check is attached to the latest SHA and the integrated `main` count is proven fresh.
- Counts 0–9 pass; 10+, missing, malformed, stale, incomplete, or unpublished evidence fail.
- No token value appears in tracked files or output, and `.github/workflows/quality-baseline.yml` is byte-for-byte unchanged.
- Final evidence in `specs/004-sonarcloud-integration/verification.md` covers deterministic tests, TASK-003 parity, hosted PR publication, and hosted `main` CP1 acceptance.

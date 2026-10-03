---

description: "Executable task plan for CP1 acceptance evidence"
---

# Tasks: CP1 Acceptance Evidence

**Input**: Design documents from `/specs/015-cp1-acceptance-evidence/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/cp1-acceptance.md`, `quickstart.md`, approved Sonar decision, and existing TASK-004/TASK-006/TASK-013/TASK-014 behavior

**Tests**: Required. Write each test or contract check first, run it, and record the expected failure before implementing the behavior it specifies.

**Scope boundary**: Verification and documentation only. Do not change authentication policy, catalog contracts, persisted domain rules, quality thresholds, coverage policy, provider behavior, or post-CP1 capabilities.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches different files and has no dependency on an incomplete task
- **[Story]**: Maps a task to its user story
- Every task names its target file or directory

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish safe fixture and staging conventions without changing application behavior.

- [X] T001 Create the acceptance fixture directory and document safe synthetic fixture naming in test/fixtures/cp1_acceptance/README.md
- [X] T002 [P] Add CP1 generated-output, private-receipt, and disposable-demo paths to .gitignore
- [X] T003 [P] Record the exact-revision evidence architecture and post-merge PASS constraint in docs/adr/0010-cp1-exact-revision-acceptance-record.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define the canonical ten-obligation input and shared adversarial fixture vocabulary used by every story.

**Critical rule**: No story implementation starts until the manifest contract and fixture vocabulary are executable.

- [X] T004 Write failing schema and membership tests for exactly ten unique CP1 obligation definitions, allowed evidence classes, required receipt kinds, and durable reference definitions in test/ci/cp1_acceptance_test.py
- [X] T005 [P] Add safe synthetic candidate, receipt, and expected-result fixtures for a complete ten-obligation case in test/fixtures/cp1_acceptance/pass/
- [X] T006 [P] Add synthetic fixtures for missing, duplicate, unknown, malformed, failed, skipped, interrupted, canceled, timed-out, undiscovered, unavailable, inaccessible, stale, unpublished, and mixed-SHA evidence in test/fixtures/cp1_acceptance/non_pass/
- [X] T007 [P] Add synthetic secret sentinels covering passwords, API keys, JWTs, verification values, provider payloads, shell traces, HTTP captures, SQL output, and child failure text in test/fixtures/cp1_acceptance/unsafe/
- [X] T008 Implement the declarative schema-versioned manifest with exactly the ten FR-003 obligations and nested supporting regressions in config/cp1_acceptance.json
- [X] T009 Run the foundational manifest tests and preserve their command and result guidance in test/fixtures/cp1_acceptance/README.md

**Checkpoint**: The manifest is the sole editable definition of CP1 gates; no aggregate verdict or self-referential SHA is stored in it.

---

## Phase 3: User Story 1 - Decide CP1 Acceptance from Complete Evidence (Priority: P1) MVP

**Goal**: Generate one authoritative revision-bound JSON record and deterministic Markdown projection whose overall result is PASS only when all ten obligations pass safely for the same clean committed SHA.

**Independent Test**: Starting only from generated `acceptance.md`, identify all ten criteria, observations, outcomes, evidence classes, provenance values, and usable references; then remove or stale any receipt and verify both outputs become non-passing without leaking raw input.

### Tests for User Story 1

- [X] T010 [P] [US1] Extend failing evaluator tests for full 40-hex SHA correlation, clean-commit versus working-tree snapshot provenance, ten-row conjunction, and every FR-006 non-pass state in test/ci/cp1_acceptance_test.py
- [X] T011 [P] [US1] Add failing deterministic-render tests proving authoritative JSON and Markdown contain matching criteria, observed results, outcomes, evidence classes, provenance, references, collection time, generator version, and manifest hash in test/ci/cp1_acceptance_test.py
- [X] T012 [P] [US1] Add failing safety and reference tests that reject prohibited fields/content, extra receipt fields, unsafe staging, machine-absolute paths, ephemeral URLs, and non-allowlisted enums in test/ci/cp1_acceptance_test.py
- [X] T013 [P] [US1] Add failing Sonar receipt tests for the exact project, `main` branch, completed matching-SHA analysis, active profile identities, `open_issues` integer boundary values 9 and 10, timestamps, and durable link in test/ci/cp1_acceptance_test.py

### Implementation for User Story 1

- [X] T014 [US1] Implement strict manifest and per-receipt schema validation with duplicate, unknown, missing, and extra-field rejection in scripts/cp1_acceptance.py
- [X] T015 [US1] Implement candidate provenance resolution, exact-SHA correlation, working-tree snapshot labeling, and unconditional snapshot `NOT PASSING` behavior in scripts/cp1_acceptance.py
- [X] T016 [US1] Implement all-ten aggregation, nested supporting-regression handling, fail-closed status mapping, and exact Sonar population validation in scripts/cp1_acceptance.py
- [X] T017 [US1] Implement pre-publication secret scanning, fixed-category failure output, unsafe-staging destruction, and nonzero failure exits in scripts/cp1_acceptance.py
- [X] T018 [US1] Implement atomic authoritative JSON acceptance-record generation and deterministic Markdown projection in scripts/cp1_acceptance.py
- [X] T019 [US1] Run all evaluator tests and verify the complete, stale, mixed-SHA, boundary, malformed, and unsafe fixture outcomes in test/ci/cp1_acceptance_test.py

**Checkpoint**: US1 is independently usable for local preflight; only a clean committed exact-SHA hosted run can ever produce final PASS.

---

## Phase 4: User Story 2 - Repeat the CP1 Demonstration (Priority: P2)

**Goal**: Run the complete security, catalog, and OpenAPI demonstration twice from isolated deterministic state while releasing only fixed safe receipts.

**Independent Test**: From the documented prerequisites, run the harness twice with fresh users; verify all behavior IDs pass, both seed assertions remain exactly 5/5/10/4/20 (44 total), no live provider is used, and retained output contains no credential or raw traffic.

### Tests for User Story 2

- [X] T020 [P] [US2] Write failing contract tests for explicit disposable-database guards, `umask 077`, disabled tracing, private child streams, fixed-category failures, and cleanup limited to owned paths in test/ci/cp1_demo_contract_test.exs
- [X] T021 [P] [US2] Write failing contract tests for two seed runs and exact totals/relationships across five leagues, plus fresh-user and duplicate-user behavior IDs in test/ci/cp1_demo_contract_test.exs
- [X] T022 [P] [US2] Write failing contract tests for JWT valid/invalid login, one-time API-key issue/verify/revoke, both protected credential forms, and generic invalid/revoked outcomes in test/ci/cp1_demo_contract_test.exs
- [X] T023 [P] [US2] Write failing contract tests for catalog list/detail/continuation, three filters singly and combined, valid empty and invalid-input outcomes, public OpenAPI JSON/UI, and both protected UI requests in test/ci/cp1_demo_contract_test.exs
- [X] T024 [P] [US2] Write failing tests for receipt schema, fixed behavior IDs, elapsed-time boundaries, provider independence, secret sentinels, and absence of raw HTTP/SQL/browser output in test/ci/cp1_demo_contract_test.exs

### Implementation for User Story 2

- [X] T025 [US2] Implement guarded isolated database preparation, deterministic double seeding, exact relationship assertions, and scoped cleanup in scripts/cp1_demo.sh
- [X] T026 [US2] Implement private transient credential handling and the user, API-key, JWT, invalid-credential, revocation, and dual-auth journeys in scripts/cp1_demo.sh
- [X] T027 [US2] Implement catalog list/detail/continuation/filter/empty/invalid journeys using persisted local data only in scripts/cp1_demo.sh
- [X] T028 [US2] Implement public OpenAPI JSON/UI checks and protected browser requests with both credential forms in scripts/cp1_demo.sh
- [X] T029 [US2] Implement allowlisted demo receipts, precise timing boundaries, safe scanning, atomic receipt release, and unsafe staging destruction in scripts/cp1_demo.sh
- [X] T030 [US2] Run the demo contract tests and two consecutive isolated demonstrations, verifying invariant counts and zero secret-sentinel leakage in test/ci/cp1_demo_contract_test.exs

**Checkpoint**: US2 can be repeated from clean documented state within the 20-minute measured boundary and produces only evaluator-consumable safe receipts.

---

## Phase 5: User Story 3 - Re-run Verification and Preserve Honest Results (Priority: P3)

**Goal**: Orchestrate complete local and hosted verification for an exact candidate SHA, publish safe evidence even on non-pass, and prevent stale or partial results from supporting acceptance.

**Independent Test**: Run the workflow contract fixtures for a passing SHA, a changed SHA, each nonterminal/failure conclusion, and unsafe staging; verify only the integrated `main` run with matching completed GitHub and Sonar evidence can publish PASS.

### Tests for User Story 3

- [X] T031 [P] [US3] Write failing workflow contract tests for exact toolchain setup, formatting, warnings-as-errors compilation, complete unit profile, separate integration profile, coverage, evaluator tests, demo tests, and double demo execution in test/ci/cp1_workflow_contract_test.exs
- [X] T032 [P] [US3] Write failing workflow contract tests for full-SHA GitHub/Sonar correlation, terminal conclusions, PR preflight versus post-merge `main` authority, maximum supported retention, SHA-named artifact, and safe NOT PASSING publication in test/ci/cp1_workflow_contract_test.exs
- [X] T033 [P] [US3] Add synthetic workflow and hosted-receipt fixtures for success, stale SHA, unavailable/inaccessible evidence, canceled/skipped/timed-out checks, Sonar 9/10 boundaries, and unsafe staging in test/fixtures/cp1_acceptance/workflow/

### Implementation for User Story 3

- [X] T034 [US3] Implement exact-SHA PR preflight and integrated-`main` orchestration of all required local checks in .github/workflows/cp1-acceptance.yml
- [X] T035 [US3] Implement same-SHA terminal GitHub and completed Sonar `main` evidence collection without copying earlier PR results in .github/workflows/cp1-acceptance.yml
- [X] T036 [US3] Implement sanitized receipt staging, evaluator invocation, safe failure handling, SHA-named artifact publication, maximum supported retention, and run-summary navigation in .github/workflows/cp1-acceptance.yml
- [X] T037 [US3] Run workflow contract and evaluator fixture suites and verify changed-SHA, unavailable, nonterminal, unsafe, and 9/10 Sonar cases remain non-passing in test/ci/cp1_workflow_contract_test.exs

**Checkpoint**: US3 makes every missing, partial, unsafe, inaccessible, or stale result visible and non-passing; authoritative PASS remains a real post-merge observation, never a local assertion.

---

## Phase 6: Documentation & Cross-Cutting Verification

**Purpose**: Make the evidence discoverable, repeatable, auditable, and ready for independent QA.

- [X] T038 [P] Document prerequisites, clean state, preparation, ordered commands, expected behavior IDs, evidence locations, repeat/reset procedure, timing boundary, and safe troubleshooting in specs/015-cp1-acceptance-evidence/quickstart.md
- [X] T039 [P] Add stable CP1 acceptance, demo, workflow-run, artifact-access, and normal-authorization navigation in README.md
- [X] T040 Reconcile the implemented command and receipt interfaces with the normative contract in specs/015-cp1-acceptance-evidence/contracts/cp1-acceptance.md
- [X] T041 Run `mix format --check-formatted`, warnings-as-errors compilation, locked quality baseline, `mix test.unit`, `mix test.integration`, `mix test.cp1_coverage`, Python evaluator tests, demo contract tests, and workflow contract tests; record only command-level evidence in specs/015-cp1-acceptance-evidence/quickstart.md
- [X] T042 Execute the documented local demonstration twice from isolated state and verify all behavior receipts, the exact seed relationships/counts, the 20-minute boundary, provider independence, and safe retained artifacts in specs/015-cp1-acceptance-evidence/quickstart.md
- [X] T043 Validate manifest-to-spec traceability for FR-001 through FR-021, SC-001 through SC-009, all ten CP1 obligations, and checkpoint invariants in config/cp1_acceptance.json
- [X] T044 Run independent QA against spec.md, plan.md, tasks.md, security/failure fixtures, and local verification evidence, then record `Verdict: PASS` or concrete failures in specs/015-cp1-acceptance-evidence/qa-report.md
- [X] T045 Run independent final review after QA PASS and record `Verdict: PASS` or concrete failures in specs/015-cp1-acceptance-evidence/review-report.md
- [ ] T046 After merge, inspect the integrated `main` workflow and exact-SHA Sonar analysis, verify durable authorized links and safe `cp1-acceptance-<full-sha>` contents, and record the actual CP1 outcome in the hosted artifact generated by .github/workflows/cp1-acceptance.yml

---

## Development reconciliation (2026-10-03)

T001–T043 were reconciled against their named files, required fixtures, B1–B4 regressions, and final command outcomes. Current command evidence is in `quickstart.md`; `handoffs/develop.md` is the sole refreshed development handoff. Final coverage and both demos passed as working-tree evidence. T044/T045 require independent QA/review; T046 requires actual post-merge hosted evidence. Those markers remain unchecked.

## Dependencies & Execution Order

### Required QA corrections Q1–Q2

- [X] T047 Validate complete manifest criteria/traceability and governing receipt/class/regression mappings in scripts/cp1_acceptance.py; add gate-remapping and malformed-manifest regressions in test/ci/cp1_acceptance_test.py.
- [X] T048 Stabilize the existing sanitized database-failure boundary in lib/mix/tasks/catalog.seed.ex; reproduce delayed retry output in test/mix/tasks/catalog.seed_test.exs and rerun the entire locked baseline.

### Phase Dependencies

- **Setup (Phase 1)** starts immediately.
- **Foundational (Phase 2)** depends on Phase 1 and blocks all story implementation.
- **US1 (Phase 3)** depends on the canonical manifest and fixtures from Phase 2.
- **US2 (Phase 4)** depends on the shared fixture vocabulary from Phase 2, but not on US1 implementation; its receipt is integrated by US1 afterward.
- **US3 (Phase 5)** depends on US1's evaluator and US2's demo harness.
- **Documentation and verification (Phase 6)** depends on the selected stories; T044 depends on T041-T043, T045 depends on T044 PASS, and T046 occurs only after merge.

### User Story Completion Order

```text
Setup -> Foundation -> US1 --------> US3 -> Documentation -> QA -> Review -> post-merge evidence
                         \          /
                          -> US2 ---
```

- **MVP**: Setup + Foundation + US1 provides independently testable fail-closed acceptance evaluation.
- **US2** can be built alongside US1 after Foundation, but its receipts cannot contribute to a complete record until integrated with US1.
- **US3** requires both prior stories because it orchestrates and publishes their outputs.

### Within Each Story

- Write and run the listed tests first; confirm their relevant assertions fail before implementation.
- Implement the smallest behavior that satisfies those tests without changing product contracts.
- Run the story's focused suite before its checkpoint.
- Never retain raw child output or credentials as debugging evidence.

## Parallel Execution Examples

### User Story 1

```text
T010 provenance/aggregation tests | T011 rendering tests | T012 safety/reference tests | T013 Sonar tests
```

### User Story 2

```text
T020 harness-safety tests | T021 seed tests | T022 security tests | T023 catalog/OpenAPI tests | T024 receipt tests
```

### User Story 3

```text
T031 local-check workflow tests | T032 hosted/publication tests | T033 workflow fixtures
```

## Implementation Strategy

1. Complete Setup and Foundation, including a failing manifest contract.
2. Deliver US1 as the MVP and validate fail-closed aggregation independently.
3. Deliver US2 and validate two repeatable, isolated, secret-safe demo runs.
4. Deliver US3, first as PR preflight and then as exact-SHA `main` orchestration.
5. Complete documentation, full local verification, independent QA, and independent final review.
6. Treat T046 as post-merge acceptance observation: implementation/PR evidence may be green but cannot itself claim final CP1 PASS.

## Completion Conditions

- All 48 tasks use the required checklist format and name concrete paths.
- All behavioral implementation follows failing tests and focused verification.
- The generated record has exactly ten top-level gates; supporting regressions never become extra checkpoint obligations.
- A missing, stale, unsafe, inaccessible, unpublished, partial, or nonterminal result is always non-passing.
- No raw secret, verification material, provider payload, or private child output is retained or published.
- Independent QA and final review both end exactly with `Verdict: PASS` before the task can enter review.
- Final CP1 PASS, if achieved, is based only on the actual integrated `main` SHA and matching hosted evidence.

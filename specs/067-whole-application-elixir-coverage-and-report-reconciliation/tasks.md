# Tasks: Elixir Coverage Reconciliation

**Input**: `specs/067-whole-application-elixir-coverage-and-report-reconciliation/`
**Prerequisites**: spec.md, plan.md, verification.json, research.md, data-model.md, contracts/coverage-cli.md and quickstart.md. Current feedback is authoritative.
**Tests**: Required by FR-009, repository rules and the requested test-first ordering. Write each story's tests first, observe the intended failure, implement, then confirm the same tests pass. Never use a full profile for a small fixture cycle.
**Format**: `- [ ] Tnnn [P?] [USn?] Description with path`. `[P]` indicates independent files after stated prerequisites. All tasks remain unchecked at architecture; only the last two may remain unchecked when implementation readiness is evaluated.

## Phase 1: Setup

- [X] T001 Confirm pinned toolchain, configured PostgreSQL/Redis test partition, Docker/Compose and installed Chromium using scripts/check_toolchain.sh, docs/TEST_PROFILES.md and existing infrastructure probes; record safe prerequisite outcomes in specs/067-whole-application-elixir-coverage-and-report-reconciliation/handoffs/develop.md without executing full profiles or changing shared data.

## Phase 2: Foundational prerequisites

- [X] T002 Write failing snapshot, deleted/untracked input, output-exclusion, task-checkbox normalization, unsafe-path and lock/status-transition fixtures in test/scripts/application_coverage_test.py; specify fixed snapshot framing vectors and prior-success-followed-by-failure assertions against contracts/coverage-cli.md.
- [X] T003 Implement the tested snapshot/identity, private staging, safe path, invocation lock and atomic current-attempt status primitives in scripts/application_coverage.py; include all execution inputs and preserve immutable historical runs; make T002 pass before story work.

## Phase 3: US1 — Review covered application scope (P1, MVP)

**Goal**: Exact source reconciliation and truthful application-only per-file/aggregate accounting.
**Independent acceptance**: Controlled inventory/native fixtures account for every canonical entry once, exclude all test/support lines, retain zero-executable files explicitly and verify integer totals; no live full-profile run is required for this increment.

- [X] T004 [P] [US1] Add failing scope/accounting tests in test/scripts/application_coverage_test.py for Git versus TASK-065 union, stale/duplicate/unclassified/renamed/reclassified paths, missing exclusion reasons, all non-application roles, attempted test/support inclusion, duplicate/conflicting lines, legitimate shared module source lines and denominator/Boolean-OR arithmetic, including zero-executable files.
- [X] T005 [P] [US1] Add failing real native source-binding fixtures in test/ci/application_coverage_native_test.exs for never-called application functions, nested/generated modules, multiple modules on one source line, non-executable source and excluded test/support modules; compile small temporary sources and independently assert expected executable identities instead of copying implementation totals.
- [X] T006 [US1] Create config/application_coverage_inventory.json with explicit exact path/role/disposition/reason for every config/credo_inventory.json entry; implement Git/canonical/coverage reconciliation in scripts/application_coverage.py with no automatic glob admission or rewriting of TASK-065 classes.
- [X] T007 [US1] Implement compiled-module/source and zero-executable baseline inspection in scripts/application_coverage_native.exs using fresh BEAM metadata and native instrumentation, rejecting stale or ambiguous bindings and failed analysis; make T005 pass without changing lib/ or the CP1 inventory.
- [X] T008 [US1] Implement normalized line-set validation and application-only per-file/aggregate report construction in scripts/application_coverage.py; union by source path/line with covered OR, retain explicit exclusions/N/A and make T004 pass against independent fixture totals.

## Phase 4: US2 — Trust combined profile coverage (P1)

**Goal**: Capture all existing normal unit/integration ExUnit partitions with attributable complete evidence and preserve genuine failures.
**Independent acceptance**: Fake-child orchestration plus real small native exports prove exact partition membership, shared snapshot, failure propagation and union fidelity without extra full-profile executions.

- [X] T009 [P] [US2] Add failing orchestration tests in test/scripts/application_coverage_test.py for exact normal unit/regular/committed-file schedule, empty optional regular group, unique export names, lost/duplicate/foreign/incomplete partitions, snapshot/receipt mismatch, failed/skipped/interrupted profile and cleanup failure, export failure despite exit zero, unchanged default receipts and exactly one profile pair.
- [X] T010 [P] [US2] Add failing native malformed/truncated/duplicate-module-or-line, missing module population, incomplete full counter identities (including multiple clauses on one source line), inconsistent executable sets, wrong-source and fresh-cover-state tests in test/ci/application_coverage_native_test.exs, plus default/opt-in/conflicting-option and unchanged CP1/JS/CI contract regressions in test/ci/application_coverage_contract_test.exs; fixtures must clear inherited coverage options and never recursively run full profiles.
- [X] T011 [US2] Add only the opt-in APPLICATION_COVERAGE_DIR native output override in mix.exs, with mutually exclusive historical CP1 options and unchanged default CP1 allowlist/filter/threshold/output; prove T010 configuration regressions pass.
- [X] T012 [US2] Attach unique native export flags at existing normal ExUnit invocation boundaries in scripts/test_profile_runner.py, predeclare expected logical partitions from existing audit scheduling, preserve selected files/database partitions/events/timeouts/cleanup, isolate recursive child environments and write separate snapshot/export sidecars only after complete owner receipts; do not set CP1_PROFILE_COVERAGE or change receipt schemas.
- [X] T013 [US2] Complete isolated per-partition import/normalization and native population/hash/type checks in scripts/application_coverage_native.exs; compare every exported counter identity against fresh instrumentation, including distinct clauses sharing a source line, and fail without accepted partial output; make native T010 fixtures pass.
- [X] T014 [US2] Implement preflight and exactly-once unit/integration collection in scripts/application_coverage.py, including configured-service/Chromium assertions, assets/build/test.prepare before discovery, expected/observed partition and existing receipt verification, pre/post profile snapshots and atomic publication; make T009 fail-closed/failure-propagation tests pass and preserve existing profile behavior tests.

## Phase 5: US3 — Reproduce and interpret evidence (P2)

**Goal**: Reproducible contributor commands, measured documentation and unmistakable current-run failure status.
**Independent acceptance**: CLI/report fixtures prove documentation matches generated integer totals, no arbitrary threshold, status/report/snapshot agreement and failed-current-attempt rejection after a prior success. Live reproduction is performed once in T020.

- [X] T015 [US3] Add failing CLI/documentation/publication tests in test/scripts/application_coverage_test.py for run/validate exit statuses, status/run/hash mismatch, missing/malformed report (including hash-coherent Boolean/float count tampering in reports, all linked receipt counts including file-oracle audit_count, schema versions, native lines and compiler markers), escaping, report/HTML/measurements agreement, low nonzero and zero coverage without a threshold, genuine prior-success-then-failure/interruption and immutable historical artifacts.
- [X] T016 [P] [US3] Write docs/APPLICATION_COVERAGE.md and update docs/TEST_PROFILES.md with commands, prerequisites, exact application-only scope/exclusion reasons, measured artifact links, one-pair execution, CP1/JS separation, nested-BEAM/E2E limits and no minimum threshold, following quickstart.md and contracts/coverage-cli.md.
- [X] T017 [P] [US3] Complete scripts/application_coverage.py validate and report.json/report.html/measurements.md rendering/publication with reread assertions and safe failure status; make T015 pass, generating actual measured documentation with the immutable report rather than claiming historical metrics.

## Phase 6: Cross-cutting verification and handoff

- [X] T018 Reconcile all new Elixir paths using config/credo_inventory.json and all new case assignments using config/test_profiles.json with scripts/test_inventory.py update --profile unit and --profile integration as applicable; review diffs, keep existing assignments, then check both inventories. Include new inventory config itself and native fixture cases where applicable; do not delete archived evidence.
- [X] T019 Finish source/design/doc edits and verify specs/067-whole-application-elixir-coverage-and-report-reconciliation/spec.md, plan.md, tasks.md and verification.json alignment against authoritative feedback, ADR-0031, every story scenario/edge case and product invariants; resolve findings before final checks without expanding scope or weakening checks.
- [X] T020 Execute every check in specs/067-whole-application-elixir-coverage-and-report-reconciliation/verification.json through scripts/agentflow_check.py in manifest order; application-report owns one unit/integration pair including new focused tests, receipt checks, live service preflight, publication and arithmetic assertions; run E2E once separately. All seven checks must pass before QA. Do not add a full unit/integration rerun or historical CP1 report. Diagnose unchanged-input failures under the documented two-attempt limit.
- [X] T021 Record current run/snapshot, measured report and receipt evidence pointers, exclusions/limitations and any residual risks in specs/067-whole-application-elixir-coverage-and-report-reconciliation/handoffs/develop.md; mark T001–T021 only after their actual checks/work complete and run the normal development readiness gate before independent QA, with no new source/design edits after evidence freeze.
- [X] T022 [gate:qa] Independent QA in specs/067-whole-application-elixir-coverage-and-report-reconciliation/qa-report.md: rerun all manifest checks independently with --stage qa and no reuse, challenge all scenarios/invariants, actual denominator and partition oracles, failure publication and compatibility; end exactly Verdict: PASS only when independently established.
- [X] T023 [gate:review] Final review in specs/067-whole-application-elixir-coverage-and-report-reconciliation/review-report.md: consume fresh QA evidence after T022, independently inspect spec/plan/tasks/feedback alignment, implementation boundary, current measured evidence and targeted uncovered risks; end exactly Verdict: PASS only when established. Human merge remains required.

## Dependencies and execution order

```text
T001 → T002 → T003
                 ├→ T004 ─┐
                 └→ T005 ─┴→ T006 → T007 → T008   (US1)
                 US1 → T009 + T010 → T011 → T012 → T013 → T014   (US2)
                 US2 → T015 → T016 + T017                         (US3)
                 all stories → T018 → T019 → T020 → T021 → T022 → T023
```

US1 is a fixture-verifiable MVP for scope/accounting. US2 integrates the real profile evidence and therefore depends on US1; it does not independently redesign the source oracle. US3 can be fixture-tested independently against its file contract, but live reproduction depends on both prior stories. Within each story, tests must fail meaningfully before implementation and pass before advancing. No implementation/test task has a downstream gate label. `task_stages` maps only T022/T023, and QA cannot start while any T001–T021 work is incomplete.

## Parallel examples

- US1 after T003: T004 Python accounting tests and T005 ExUnit native fidelity fixtures use separate files. T006–T008 remain sequential because they share contracts and consume source bindings.
- US2 after T008: T009 Python orchestration failures and T010 ExUnit native/configuration compatibility tests can be authored concurrently; changes in runner/config/native reader remain dependency-ordered.
- US3 after T015: T016 contributor documentation and T017 Python rendering/validation use different files and consume the same settled contract. T018 must wait for both.

These are file-level opportunities, not instructions to spawn agents. The implementation owner remains singular.

## Implementation strategy

Build the US1 fixture-tested MVP first, then capture complete US2 evidence without changing audited scheduling, then finish US3 contributor interpretation. Use targeted fixtures during development. Register and reconcile new cases, finish edits, and execute the seven final checks once against frozen inputs. The report command performs the only final unit/integration pair; E2E is an existing independent safeguard. Actual measured results are created by implementation, never inferred by architecture. Preserve all existing quality gates and independent QA/review. Do not deploy, publish or merge as part of this task list without the workflow's separate authorization.

## Requirement/check anchors

| Obligations | Primary tasks and executable acceptance |
| --- | --- |
| FR-001–004, SC-001, SC-005; US1 scenarios 1–3 | T004–T008; application-report executes registered source/denominator fixtures and validates live output |
| FR-005–007, SC-002–003; US2 scenarios 1–3 | T009–T014; application-report executes native/partition faults and validates exact live membership and line sets |
| FR-008, SC-004; US3 scenario 3 | T009, T014–T015; application-report executes fake-child genuine failure/interruption tests with no current success |
| FR-009 | T002, T004–T005, T009–T010, T015; registered tests all run inside the application-report audited pair |
| FR-010, SC-006; US3 scenarios 1–2 | T015–T017, T020; application-report validates measured docs and no threshold |
| FR-011–012, SC-007–008 | T010–T012, T018–T020; application-report compatibility fixtures + existing audited regressions, E2E, Credo, OpenAPI and preflight/test-inventory assertions |

No canonical AC IDs exist in spec.md. Every FR/SC maps to real check IDs in verification.json; story acceptance scenarios above supply the finer test oracles. No new endpoint exists, so runtime HTTP declaration checks do not apply; service prerequisites and existing asserted HTTP/browser journeys still execute.

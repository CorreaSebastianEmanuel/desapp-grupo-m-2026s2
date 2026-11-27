# Tasks: Elixir Credo CI Enforcement

**Owner**: TASK-065 | **Feature**: `specs/065-elixir-source-inventory-and-required-credo-ci`
**Inputs**: spec.md, plan.md, verification.json, research.md, data-model.md, contracts/quality-evidence.md, quickstart.md, ADR-0030.

Tests are required by FR-008 and repository rules. Run new assertions red before their implementation and green after it; retain command evidence, never weaken a failing assertion. Every checkbox starts unchecked because this is architecture only. Implementation owner must finish T001–T016 before QA; only T017/T018 may remain deferred at readiness.

## Phase 1: Setup

- [X] T001 Confirm unchanged TASK-066 Credo pin/configuration in mix.exs, mix.lock and .credo.exs; follow specs/065-elixir-source-inventory-and-required-credo-ci/quickstart.md prerequisites and inspect docs/adr/0030-revision-bound-credo-inventory-evidence.md before edits; record only discrepancies in handoffs/develop.md under the feature directory.

## Phase 2: Foundational prerequisites

- [X] T002 Add red assertions in test/ci/workflow_scope_test.exs for the feature's finite tooling/test/workflow allowance and rejection of unknown lib/, migration and workflow paths; preserve all previous negative cases.
- [X] T003 Extend test/support/workflow_scope.ex with exactly the plan.md implementation paths for this feature and rerun T002 green; do not expand other feature allowances or production directories.

**Foundation checkpoint**: scope contracts admit only the planned tooling changes. No new application infrastructure is needed.

## Phase 3: US1 — Review the analyzed source boundary (P1, MVP)

**Goal**: Independently auditable tracked inventory and actual Credo effective source equality.
**Independent test**: temporary Git repositories prove all maintained roots/dotfiles, exact exclusions and missing/stale/mismatched paths; real Credo fixtures prove valid source completion and CLI/API parity. Corresponds to US1 acceptance scenarios 1–3, FR-001–005/008 and SC-001/002.

- [X] T004 [US1] Write and run red :unit tests in test/ci/credo_inventory_test.exs for every matrix case in specs/065-elixir-source-inventory-and-required-credo-ci/contracts/quality-evidence.md, including addition/rename/delete, unsafe/duplicate paths, per-path exclusion reasons and rejection of maintained-root suppression; use isolated temporary Git repositories, not mutations of the working repository.
- [X] T005 [US1] Add config/credo_inventory.json and tracked-path reconciliation/explicit --write-inventory mode in scripts/credo_inventory.exs per data-model.md; classify each existing archived specs probe individually and fail on unknown outside-boundary tracked sources; never regenerate inventory during normal checking.
- [X] T006 [US1] Implement scripts/credo_inventory.exs oracle using Credo.run/1 with exactly --format flycheck, valid filenames/status, completion assignments, halted state and exit status; fail on incomplete analysis, invalid source, findings or any three-set mismatch; retain TASK-066 configuration and rules unchanged.
- [X] T007 [US1] Complete real subprocess parity/invalid-source probes in test/ci/credo_inventory_test.exs and implement oracle JSON output in scripts/credo_inventory.exs with full paths, source/configuration snapshots and safe incomplete/failure semantics; run the focused tests green and inspect a complete standalone reconciliation result before CI integration.

**MVP checkpoint**: US1 works locally without SonarCloud or CI. This is the suggested first demonstrable increment; all stories are still required for final delivery.

## Phase 4: US2 — Require Credo independently in CI (P1)

**Goal**: existing required Quality baseline status fails for either CLI or inventory failure and retains complete evidence.
**Independent test**: executable wrapper fixtures propagate each failure, preserve both statuses, reject source mutation and stale outputs; parsed YAML assertions preserve existing jobs/profiles/Sonar separation and always-upload semantics. Corresponds to US2 scenarios 1–3, FR-006–008/011/012 and SC-003/005.

- [X] T008 [US2] Add and run red :unit tests in test/ci/credo_ci_contract_test.exs for wrapper CLI/inventory/both failures, incomplete oracle, stale report removal, snapshot mutation and complete JSON/log output; extend test/ci/quality_baseline_contract_test.exs and test/ci/test_profiles_quality_contract_test.exs with mandatory-step/upload ordering and unchanged independent Sonar/profile assertions before YAML changes.
- [X] T009 [US2] Implement scripts/credo_ci.sh to clear old tmp/credo-ci/ output only after rejecting traversal and symlink output paths, capture unchanged standard CLI status, run oracle even after CLI failure, compare pre/post snapshots, combine statuses without masks and write complete schema-1 JSON/log evidence atomically per data-model.md; rerun wrapper behavior and output-preservation tests green.
- [X] T010 [US2] Add the nonoptional wrapper step and always-upload revision/run-attempt-specific artifact with 14-day retention and missing-files error to .github/workflows/quality-baseline.yml; retain job IDs, service/test.prepare ordering, unit/integration ownership, E2E, Sonar separation and existing permissions/triggers; update test/ci/fixtures/quality-baseline.sha256 only for this reviewed YAML delta.
- [X] T011 [US2] Run test/ci/credo_ci_contract_test.exs and existing quality/profile contract tests green; use deterministic fixture artifacts to assert full-list retrieval/decoding, trigger SHA versus checked-out HEAD, both exit statuses and independence from all simulated Sonar outcomes; preserve .github/workflows/sonarcloud.yml and all coverage infrastructure unchanged.

**CI checkpoint**: failure propagation is proved by executing child processes, not string inspection alone. Workflow structure and artifact policy are independently asserted. Do not publish or change branch protection during this task's implementation unless separately authorized by the enclosing workflow.

## Phase 5: US3 — Reproduce and interpret locally (P2)

**Goal**: contributors reproduce identical scope/rule level and interpret retained evidence correctly.
**Independent test**: README contract verifies actual command strings, staging/refresh procedure, scope/reasons, revision/dirty labelling, artifact retrieval and both limits; local wrapper produces the documented evidence. Corresponds to US3 scenarios 1–2, FR-009/010 and SC-004.

- [X] T012 [US3] Add and run red documentation assertions in test/ci/credo_ci_contract_test.exs for README.md local commands, tracked/staged inventory refresh, exclusion reference, default-priority rule level, artifact retrieval/retention, revision labelling and explicit bug-absence/native-Java-equivalence limitations in both docs and JSON.
- [X] T013 [US3] Update README.md with the commands and interpretation contract from specs/065-elixir-source-inventory-and-required-credo-ci/quickstart.md, preserving all existing prerequisites/profile/coverage instructions; make T012 green and confirm command examples match scripts/credo_ci.sh and scripts/credo_inventory.exs.

## Phase 6: Polish and owner verification

- [X] T014 Register every new/changed case in config/test_profiles.json using python3 scripts/test_inventory.py update then check, preserving exact :unit tags and existing profile ownership; stage new Elixir sources and refresh/review config/credo_inventory.json only after final source additions, retaining each reviewed exclusion reason.
- [X] T015 Finish source/design edits within plan.md paths, explicitly format scripts/credo_inventory.exs and new tests, remediate only new-file findings, and inspect the final diff for unchanged .credo.exs, mix.lock, application behavior and coverage/Sonar infrastructure; finalize handoffs/develop.md under specs/065-elixir-source-inventory-and-required-credo-ci/ before final checks, without preclaiming success.
- [X] T016 Execute all seven verification.json check IDs via python3 scripts/agentflow_check.py in order (preflight, format, compile, inventory, credo, regression, e2e), retaining actual receipts; follow specs/065-elixir-source-inventory-and-required-credo-ci/quickstart.md and run artifact/manifest validation plus readiness after marking completed owner tasks; each unit/integration/E2E profile runs once for the final source state, with no extra historical CP1 coverage report. On unchanged-input repeated failure follow docs/AGENT_VERIFICATION.md rather than retrying or bypassing.

## Phase 7: Downstream independent gates

- [ ] T017 Independent QA [gate:qa] reruns every verification.json ID using python3 scripts/agentflow_check.py CHECK_ID --stage qa without reuse, challenges all spec acceptance cases/oracle/exclusion/evidence completeness, and writes specs/065-elixir-source-inventory-and-required-credo-ci/qa-report.md ending exactly Verdict: PASS only when independently satisfied.
- [ ] T018 Final review [gate:review] assesses fresh QA evidence, source/plan/spec alignment, preserved invariants/checkpoints and targeted uncovered risks in a separate session; writes specs/065-elixir-source-inventory-and-required-credo-ci/review-report.md ending exactly Verdict: PASS only when satisfied; no merge.

## Dependencies and execution order

`T001 -> T002 -> T003 -> US1(T004–T007) -> US2(T008–T011) -> US3(T012–T013) -> T014 -> T015 -> T016 -> T017 -> T018`.

Within each story, failing tests precede implementation and green checks precede the story checkpoint. T008 YAML tests precede T010; T012 docs tests precede T013. Final receipts follow all source/design changes. A new source change after final checks invalidates receipts as described in docs/AGENT_VERIFICATION.md. Only T017/T018 are mapped in verification.json.task_stages.

## Parallel opportunities and examples

No tasks are marked [P]: shared script, inventory and contract files make task-level parallel execution unnecessary. One implementation owner remains responsible.

- US1: after T004's tests exist, independent temporary-root inclusion/exclusion fixtures may execute concurrently; real Credo VM/process fixtures remain serialized when they share runtime state.
- US2: inside T008, YAML assertion drafting can accompany independent shell-fixture design; both must be red before T009/T010 and consolidated by the owner.
- US3: within T013, documentation prose review can accompany fixture-artifact reading after T012 defines the assertions; edits remain serialized in README.md/test files.

These are bounded opportunities, not instructions to spawn agents or duplicate full profile executions.

## Implementation strategy and completeness

Deliver US1 as the first local MVP, then mandatory CI behavior, then contributor interpretation. Tests use small deterministic fixtures and the existing ExUnit/profile inventory; no new generic framework. All 12 FR and 5 SC IDs map to executable checks in verification.json; story scenarios map to the contract test matrix. No AC IDs are declared in spec.md. No HTTP interface changes, so no new runtime endpoint check is applicable; existing integration and browser E2E assertions remain mandatory. CP2 engineering safeguards are preserved without claiming charts/orders completion or creating an extra CP1 coverage gate.

**Task totals**: 18: setup 1, foundational 2, US1 4, US2 4, US3 2, owner polish/verification 3, independent gates 2. All tasks carry exact paths or explicit feature-relative artifact paths. No implementation task is gate-tagged or deferrable.

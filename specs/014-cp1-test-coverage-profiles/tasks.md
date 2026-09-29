---
description: "Executable task list for CP1 test and coverage profiles"
---

# Tasks: CP1 Test and Coverage Profiles

**Input**: `specs/014-cp1-test-coverage-profiles/{spec.md,plan.md,research.md,data-model.md,quickstart.md,contracts/}`

**Scope resolution**: `config/cp1_coverage_inventory.exs` is the single committed source/module allowlist. It must derive `mix.exs` native coverage exclusions; `test/fixtures/cp1_coverage_source_inventory.json` is test data only and cannot independently define collector scope. Coverage provenance hashes the complete tracked binary diff from `HEAD`; non-generated untracked inputs are rejected. This resolves the former “relevant diff” ambiguity without imposing a clean-tree or pre-QA-commit rule.

**Tests**: Required. Write or extend the listed contract/regression tests first, observe the intended failure, then implement the corresponding tooling. Tests use deterministic local fixtures only.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish documented local prerequisites and generated-artifact boundaries without changing the locked CI baseline.

- [X] T001 [P] Document the pinned BEAM/PostgreSQL, Node.js 24, npm-lock, Chromium-install, focused-profile, and coverage-report prerequisites and commands in README.md
- [X] T002 [P] Ignore only generated CP1 coverage publication paths in .gitignore

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Make the complete default-discovered ExUnit population auditable before a profile may report success.

**⚠️ CRITICAL**: No story may claim a complete profile, regression collection, or coverage result until this phase is complete.

- [X] T003 [P] Extend baseline-parity and default-discovery guard tests without changing the locked three-category workflow in test/ci/quality_baseline_contract_test.exs and test/ci/quality_baseline_discovery_test.exs
- [X] T004 Add exactly one direct `:unit` or `:integration` module tag (with optional direct `:performance`) to every default-discovered ExUnit module under test/football_market/, test/football_market_web/, test/ci/, test/integration/, and test/mix/

**Checkpoint**: The whole discovered ExUnit population has deterministic, exact-one classification and the three-category CI baseline remains byte-for-byte unchanged.

---

## Phase 3: User Story 1 - Run Complete Focused Checks (Priority: P1) 🎯 MVP

**Goal**: Contributors can run complete, mutually exclusive unit or integration profiles with required local prerequisites and fail-closed diagnostics.

**Independent Test**: With deterministic passing tests in both classifications, `mix test.unit` and `mix test.integration` each execute only their own audited population, include selected performance tests, emit a safe receipt, and fail nonzero for every controlled incomplete or prerequisite failure.

### Tests for User Story 1 — write first and observe failure

- [X] T005 [P] [US1] Extend exact-one membership, direct-tag, identity, unreadable-file, empty-scope, and cross-profile-exclusivity contracts in test/ci/test_profile_audit_test.exs
- [X] T006 [P] [US1] Extend controlled assertion, discovery, skip, interruption, malformed-receipt, sentinel, and safe-capture failure contracts in test/ci/test_profile_runner_contract_test.exs
- [X] T007 [P] [US1] Add unit-profile selection, positive-completion, and selected-performance sentinel contracts in test/ci/profile_unit_sentinel_test.exs
- [X] T008 [P] [US1] Add integration Node-24, locked-package, Chromium, browser-regression, and selected-performance sentinel contracts in test/ci/profile_integration_sentinel_test.exs

### Implementation for User Story 1

- [X] T009 [US1] Implement audited default-discovery, direct-tag parsing, deterministic IDs, scope receipts, and profile-only selection in test/support/test_profile_audit.ex
- [X] T010 [US1] Implement private capture-and-release with allowlisted receipts, fixed safe categories, sanitizer failure handling, and no raw child-output retention in scripts/test_profile.sh
- [X] T011 [US1] Configure profile selection only, `mix test.unit`, and `mix test.integration` aliases without changing the baseline aliases in mix.exs and test/test_helper.exs
- [X] T012 [US1] Make the required browser regression use opaque local handoff/status assertions rather than credential-bearing output in test/football_market_web/openapi_browser_test.exs and tools/openapi/browser.mjs

**Checkpoint**: US1 is complete when both focused commands pass their complete classified scope and all controlled profile failures are nonzero, safe, and never represented as success.

---

## Phase 4: User Story 2 - Validate CP1 Behavior and Safe Errors (Priority: P2)

**Goal**: The integration profile demonstrates all existing CP1 success/rejection journeys, with deterministic local data and no credential material released on any path.

**Independent Test**: Run `mix test.integration` against local fixtures and confirm the regression matrix covers every FR-008–FR-013 success and applicable boundary/rejection while scans of released artifacts contain no controlled secret or verification sentinel.

### Tests for User Story 2 — write first and observe failure

- [X] T013 [P] [US2] Add or extend deterministic registration, normalized-email uniqueness, no-partial-state, credential-verification, and projection/non-disclosure regressions in test/football_market/accounts/accounts_test.exs and test/football_market/accounts/persistence_test.exs
- [X] T014 [P] [US2] Add or extend API-key issuance, independent multiple keys, identification, revocation, invalid/revoked rejection, and one-time-secret non-disclosure regressions in test/football_market/accounts/api_key_persistence_test.exs and test/football_market/accounts/api_key_security_test.exs
- [X] T015 [P] [US2] Add or extend login, JWT validity-boundary, invalid-credential, generic unauthenticated, credential-form, precedence, and challenge regressions in test/football_market/accounts/authentication_test.exs and test/football_market_web/controllers/player_catalog_auth_precedence_test.exs
- [X] T016 [P] [US2] Add or extend list/detail/pagination/filter/cursor ordering, malformed/repeated/unknown/conflicting identity, empty-result, and no-provider-read regressions in test/football_market/catalog/player_catalog_index_test.exs, test/football_market/catalog/player_cursor_test.exs, and test/football_market_web/controllers/player_controller_test.exs
- [X] T017 [P] [US2] Add public interactive/OpenAPI availability, protected-operation fidelity, unsupported-capability absence, and browser-contract regressions in test/football_market_web/openapi_contract_test.exs and test/football_market_web/openapi_browser_test.exs

### Implementation and matrix completion for User Story 2

- [X] T018 [US2] Remove raw credentials, JWTs, API keys, tokens, verification material, and browser assertion output from CP1 test helpers and browser harnesses in test/support/authentication_helpers.ex, test/support/openapi_case.ex, and tools/openapi/validate.mjs
- [X] T019 [US2] Map every FR-008 through FR-013 clause to its profile, deterministic success evidence, and applicable rejection/boundary evidence in specs/014-cp1-test-coverage-profiles/contracts/cp1-regression-matrix.md
- [X] T020 [US2] Document the classified CP1 behavioral coverage and safe diagnostic expectations in specs/014-cp1-test-coverage-profiles/quickstart.md

**Checkpoint**: US1 and US2 are complete when integration proves every matrix row locally without provider access, production inputs, or sensitive diagnostic output.

---

## Phase 5: User Story 3 - Review Snapshot-Bound Coverage (Priority: P3)

**Goal**: Maintainers can create an informational native executable-line coverage report truthfully bound to the tested committed revision or working-tree snapshot.

**Independent Test**: With both coverage-mode profile receipts successful, `mix test.cp1_coverage` generates exactly one safe `report.html`/manifest for a stable snapshot, proves inventory-controlled scope and per-source executable-line detail, and publishes nothing for controlled calculation, scope, safety, or snapshot-mutation failures.

### Tests for User Story 3 — write first and observe failure

- [X] T021 [P] [US3] Extend canonical allowlist, native collector inclusion/exclusion, denominator, inventory-hash, and zero-threshold contracts in test/ci/cp1_coverage_inventory_test.exs
- [X] T022 [P] [US3] Extend two-profile export/merge, executable-line aggregate/source detail, receipt correspondence, staging, atomic-publication, and no-publication-on-failure contracts in test/ci/coverage_report_contract_test.exs
- [X] T023 [P] [US3] Add controlled staged/unstaged tracked-diff, untracked-input, ignored-generated-output, changed-HEAD, changed-diff, malformed-export, unsafe-artifact, and source-sentinel fixtures in test/ci/fixtures/cp1_profiles/

### Implementation for User Story 3

- [X] T024 [US3] Create the canonical exact CP1 source-path/module allowlist, exclusion rationale, and inventory hash in config/cp1_coverage_inventory.exs
- [X] T025 [US3] Derive native Mix `:test_coverage` `:ignore_modules` from the canonical inventory and add the informational `mix test.cp1_coverage` alias in mix.exs
- [X] T026 [US3] Implement safe receipt import/merge, native `:cover` executable-line aggregation, per-inventory-source detail, source HTML links, manifest construction, and artifact safety validation in test/support/cp1_coverage_publisher.ex
- [X] T027 [US3] Implement private snapshot capture, complete binary-diff hashing, untracked/ignored input policy, pre-publication revalidation, discarded staging, and atomic ignored publication in scripts/coverage_report.sh
- [X] T028 [US3] Document report location, committed-revision versus working-tree-snapshot labels, provenance fields, source scope, zero threshold, and failure/no-publication semantics in specs/014-cp1-test-coverage-profiles/contracts/coverage-report.md and README.md

**Checkpoint**: All stories are complete when coverage is truthful for a stable uncommitted snapshot and cannot publish a partial, unsafe, stale, or scope-mismatched artifact.

---

## Phase 6: Polish & Cross-Cutting Verification

**Purpose**: Preserve checkpoint obligations, durable decisions, and independently reproducible evidence.

- [X] T029 [P] Reconcile the durable broad-provenance and inventory-scope decision with the final implementation boundary in docs/adr/0009-cp1-coverage-snapshot-provenance-and-scope.md
- [X] T030 [P] Reconcile profile commands, prerequisite failure categories, and coverage verification steps with final behavior in specs/014-cp1-test-coverage-profiles/contracts/test-profiles.md and specs/014-cp1-test-coverage-profiles/quickstart.md
- [X] T031 Run `mix format --check-formatted` and warnings-as-errors compilation without modifying the locked CI baseline in mix.exs and scripts/ci_unit_tests.sh
- [X] T032 Run the focused runner/audit/sentinel, regression-matrix, inventory, and coverage-publication contract suites in test/ci/, test/football_market/, and test/football_market_web/
- [X] T033 Run `mix test.unit`, `mix test.integration`, and `mix test.cp1_coverage`; inspect the safe receipts and one generated report under cover/cp1/

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** has no dependencies.
- **Foundational (Phase 2)** depends on T001–T002 and blocks every profile claim.
- **US1 (Phase 3)** depends on the complete classification baseline in T004.
- **US2 (Phase 4)** depends on US1’s safe runner, because all selected profile output must cross that boundary.
- **US3 (Phase 5)** depends on US1’s coverage-mode profile receipts and runs after the CP1 regression matrix is complete.
- **Polish (Phase 6)** depends on all three stories.

### User Story Dependencies

```text
Setup → Foundational → US1 (MVP) → US2 → US3 → Polish/verification
```

US2’s behavior tests may be authored in parallel with US1’s contracts, but their integrated execution waits for T009–T011. US3’s contract tests may be authored in parallel with US2, but T024–T027 wait for safe profile receipts.

### Parallel Opportunities

- T001/T002 and T003’s two guard files are independent.
- T005–T008 are independent contract files after the foundation.
- T013–T017 cover separate behavioral areas and can proceed concurrently.
- T021–T023 are independent coverage contract/fixture work; T029–T030 can be prepared independently after implementation behavior stabilizes.

## Implementation Strategy

### MVP First

1. Complete T001–T004 to make classification and the locked baseline explicit.
2. Complete US1 through T012 and prove both profile commands independently.
3. Stop and validate focused test completeness and safe diagnostics before expanding the regression collection.

### Incremental Delivery

1. Add US2’s CP1 regression evidence without changing public/product behavior.
2. Add US3’s inventory-controlled, snapshot-bound informational coverage report.
3. Finish the independent verification sequence in T031–T033; record only commands actually run during implementation and leave independent QA/review to fresh sessions.

## Notes

- Every task uses the required checkbox/ID/path format; story tasks carry their required `[US#]` label.
- A task may be marked complete only after its relevant test-first and verification evidence is actually run.
- Do not add a coverage threshold, fourth CI category, Sonar import, provider call, production credential, domain change, or product-data change.

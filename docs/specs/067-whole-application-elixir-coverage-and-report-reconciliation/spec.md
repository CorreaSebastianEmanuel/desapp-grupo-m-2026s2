# Feature Specification: Elixir Coverage Reconciliation

**Feature Branch**: `067-whole-application-elixir-coverage-and-report-reconciliation`

**Created**: 2026-10-20

**Status**: Draft

**Input**: TASK-067 — Generate whole-application coverage for the agreed first-party Elixir scope, reconcile its source inventory and native exports, preserve existing audited test profiles and reports, and document measured coverage without a threshold.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review the covered application scope (Priority: P1)

As a maintainer reviewing quality evidence, I need the percentage to measure only first-party application implementation code while every file in the TASK-065 Elixir inventory is accounted for, so I can tell what the report measures and detect omissions.

**Why this priority**: A whole-application percentage is meaningful only when its source boundary is complete and its exclusions are visible.

**Independent Test**: Compare the report's reconciled source list with TASK-065 source accounting and confirm every application implementation file is included once while every other inventory file is excluded with a reason; verify tests and support contribute neither executable nor covered lines, and verify the aggregate totals.

**Acceptance Scenarios**:

1. **Given** the agreed first-party Elixir source inventory, **When** coverage is generated, **Then** every application implementation file is included once and every other inventory file is excluded with a documented reason.
2. **Given** a maintained application source file is added, removed, renamed, or reclassified, **When** reconciliation runs, **Then** the report reflects the current inventory or the check fails with the discrepancy identified.
3. **Given** all expected source is reconciled, **When** a maintainer reads the report, **Then** it identifies the included and excluded files, exclusion reasons, aggregate measured percentage, and per-file coverage details for application implementation files only.

### User Story 2 - Trust combined profile coverage (Priority: P1)

As a maintainer, I need coverage from the existing audited unit and integration profiles combined without losing profile partitions or counting executable lines twice, so the result represents the agreed application scope accurately.

**Why this priority**: The report must faithfully combine the current evidence sources while leaving the established profiles in control of their runs and results.

**Independent Test**: Generate exports for both completed profiles from the same source snapshot, reconcile their partitions against the inventory, and confirm each executable source line contributes once to the aggregate denominator and at most once to the covered total.

**Acceptance Scenarios**:

1. **Given** complete, valid exports from the audited unit and integration profiles, **When** they are combined, **Then** all expected partitions are represented and shared executable lines are counted once.
2. **Given** an expected export is absent, incomplete, assigned to the wrong profile or snapshot, or has lost a partition, **When** reconciliation runs, **Then** it fails and publishes no complete coverage report.
3. **Given** a native export or report is malformed, **When** it is processed, **Then** the report is rejected with a safe, actionable diagnostic and no partial result is presented as complete.

### User Story 3 - Reproduce and interpret coverage evidence (Priority: P2)

As a contributor or reviewer, I need documented commands, measured results, exclusions, and limitations, so I can reproduce the report and understand what the percentage does and does not establish.

**Why this priority**: Reproducible, bounded evidence helps maintainers assess exercised application code without mistaking coverage for a quality guarantee.

**Independent Test**: Follow the project documentation to run the established audited profiles and coverage report, then compare its documented scope and measured output with the generated report.

**Acceptance Scenarios**:

1. **Given** the documented local environment and successful audited profile runs, **When** a contributor follows the documented procedure, **Then** they can produce the reconciled whole-application report.
2. **Given** the completed report, **When** a reviewer inspects its documentation, **Then** measured coverage and limitations are stated and no minimum percentage is described as a gate.
3. **Given** an audited profile fails, **When** coverage generation is requested, **Then** the genuine failure remains visible and no successful complete report is attributed to that profile.

### Edge Cases

- A newly added, deleted, renamed, or reclassified tracked Elixir source file must not silently disappear from reconciliation.
- Test files and test-support files in the TASK-065 inventory must be explicit exclusions because test cases, fixtures, and harnesses are not application implementation code; none may contribute to the numerator or denominator.
- Every other tracked Elixir file outside the agreed application coverage scope must have a specific, reviewable exclusion reason; an unexplained or stale exclusion fails reconciliation.
- A missing, truncated, duplicate, malformed, or profile-mismatched native export must not produce a complete report.
- A report with missing, duplicated, or conflicting source-line records must fail rather than inflate or reduce the aggregate silently.
- An empty partition or a profile that did not complete must not be interpreted as zero uncovered lines or successful coverage evidence.
- A genuine test/profile failure must retain its failure status through export collection and combination.
- A low measured percentage is reported accurately and does not fail a gate solely for being below an arbitrary threshold.
- Collection and reporting must not overwrite, relabel, or invalidate existing CP1 coverage reports, JavaScript coverage, or established profile receipts.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Coverage MUST measure only maintained first-party Elixir application implementation source rooted under `lib/` and identified by reconciling the current TASK-065 source inventory. Test files and test-support files MUST be excluded from both the covered-line numerator and executable-line denominator, with explicit reasons identifying them as tests, fixtures, or test harness/support rather than application implementation code.
- **FR-002**: Reconciliation MUST account for every tracked Elixir file in the TASK-065 inventory exactly once: each maintained application implementation file rooted under `lib/` is included, and every other inventory entry is excluded with a specific role-based reason. Configuration, migration, script, root-level, test, support, and other non-application inventory entries MUST be excluded; the current inventory identifies the actual paths.
- **FR-003**: Reconciliation MUST fail when an expected application source file is missing, an inventory entry is stale or duplicated, an excluded file lacks a valid reason, a test/support file is included in measurement, or actual included/excluded files differ from the agreed scope.
- **FR-004**: The coverage report MUST identify all included and excluded source files, explain exclusions, and provide per-file and aggregate executable-line coverage for application implementation files only.
- **FR-005**: The aggregate MUST use a unique set of executable source-line identities so a line observed in more than one profile is counted once in the denominator and at most once as covered.
- **FR-006**: Coverage MUST be combined from the existing audited unit and integration profiles using only the native exports needed to represent their evidence. The combined result MUST retain profile identity and all expected partitions.
- **FR-007**: Each accepted export MUST be complete and attributable to its expected profile and the source snapshot represented by the report. Missing, incomplete, mismatched, duplicated, or malformed exports or partitions MUST fail closed without publishing a complete report.
- **FR-008**: Collection or combination MUST preserve genuine test and profile failures. It MUST NOT convert a failed, interrupted, skipped, or incomplete profile into successful coverage evidence.
- **FR-009**: Focused automated tests MUST cover source accounting and exclusions (including explicit test/support exclusion and denominator checks), aggregate/partition accounting without double-counting executable lines, missing and incomplete exports, malformed reports, and genuine failure propagation.
- **FR-010**: Contributor documentation MUST describe the local procedure, measured coverage, application-only source scope, exclusions and reasons, and limitations of the report. It MUST NOT introduce or imply an arbitrary coverage threshold.
- **FR-011**: The change MUST preserve the ownership, behavior, and receipts of existing audited unit and integration profiles, existing CP1 reports, JavaScript coverage, and established quality gates.
- **FR-012**: The feature MUST NOT change application behavior or redesign existing test runners.

### Out of Scope

- Importing coverage into SonarCloud or another external analysis service.
- Dialyzer adoption, dependency work, or PLT generation.
- An arbitrary minimum-coverage threshold or new coverage enforcement gate.
- Changes to application behavior, test-profile ownership, profile execution semantics, or test-runner design.
- Replacing or removing existing CP1 reports, JavaScript coverage, profile receipts, or quality gates.

### Key Entities

- **Coverage source inventory**: The TASK-065-based accounting of first-party Elixir files in the coverage scope and tracked files excluded with reasons.
- **Native profile export**: The necessary coverage data emitted for one completed audited test profile, retaining profile and partition identity.
- **Executable source line**: A unique in-scope source file and executable line identity used once in the aggregate denominator.
- **Reconciled coverage report**: The measured per-file and whole-application coverage result, with complete source accounting, profile/partition evidence, exclusions, and limitations.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of tracked Elixir source files in the TASK-065 inventory are reconciled exactly once; maintained application implementation files rooted under `lib/` are measured and every other file, including all test and test-support files, is excluded with a specific reason.
- **SC-002**: In a valid combined report, 100% of expected profile partitions are retained and each unique executable source line contributes exactly once to the aggregate denominator.
- **SC-003**: Controlled missing, incomplete, malformed, mismatched, duplicated, or partition-losing export cases fail in 100% of attempts and produce no complete report.
- **SC-004**: Controlled genuine unit or integration profile failures remain failures in 100% of coverage collection attempts and are never reported as completed coverage.
- **SC-005**: Every successful report provides a measurable application-only percentage and per-file executable, covered, and uncovered line details for every included application file, alongside all excluded files and reasons; no test or support line affects either total.
- **SC-006**: Documentation states measured coverage and report limitations, with zero arbitrary coverage threshold added to project gates.
- **SC-007**: Existing audited profile ownership and receipts, CP1 reports, JavaScript coverage, and quality gates remain available and unchanged in purpose.
- **SC-008**: Application behavior is unchanged by the coverage feature.

## Assumptions

- TASK-065 source accounting is authoritative for the current tracked first-party Elixir inventory. Its inventory is broader than this coverage denominator: maintained application implementation source rooted under `lib/` is measured, while all test and test-support paths and other non-application paths are explicitly excluded with role-specific reasons. Planning may review the archived broad TASK-065 draft for useful pieces only after this task has its own approved specification and plan; neither that draft nor its historical results are current evidence.
- The existing audited unit and integration profiles are the only coverage partitions required by this task; their accepted execution receipts remain owned by those profiles.
- Profile exports used together represent the same source snapshot, and any required snapshot binding is available from the existing audited evidence or will be specified during planning.
- Existing CP1 and JavaScript reports and all current required quality gates remain the compatibility baseline.
- Coverage is informational evidence about exercised executable lines. It does not prove correctness and has no acceptance minimum.

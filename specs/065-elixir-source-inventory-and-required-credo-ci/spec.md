# Feature Specification: Elixir Credo CI Enforcement

**Feature Branch**: `065-elixir-source-inventory-and-required-credo-ci`

**Created**: 2026-10-20

**Status**: Draft

**Input**: TASK-065 — Make the existing TASK-066 Credo analysis enforceable in CI, with a reviewable and complete inventory of maintained first-party Elixir source.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review the analyzed source boundary (Priority: P1)

As a maintainer reviewing quality evidence, I need to see every maintained first-party Elixir file considered by Credo and understand every excluded tracked Elixir file, so source cannot disappear from review unnoticed.

**Why this priority**: A passing analysis is meaningful only if reviewers can establish which project-owned source was analyzed.

**Independent Test**: Compare the machine-checked inventory with the effective files Credo reports for a repository revision, then inspect the CI evidence for its complete file list and exclusion explanations.

**Acceptance Scenarios**:

1. **Given** a repository revision containing maintained first-party Elixir source, **When** the required quality check runs, **Then** it records the triggering revision and the complete effective Credo file list.
2. **Given** a tracked Elixir file is in the maintained first-party scope, **When** the inventory is reconciled with Credo's effective inputs, **Then** the file is present in both or the check fails.
3. **Given** a tracked Elixir file is excluded from the maintained scope, **When** the inventory is reviewed, **Then** its path and specific exclusion reason are visible and testable.

### User Story 2 - Require Credo independently in CI (Priority: P1)

As a maintainer, I need the existing quality workflow to require the standard Credo analysis independently of SonarCloud, so a Credo or inventory failure cannot be hidden by another service's result.

**Why this priority**: The analysis only protects changes when it is a required, independently failing check.

**Independent Test**: Exercise the required workflow with an intentionally failing Credo invocation and with an invalid inventory; each must fail its own required CI result while the SonarCloud result remains separately reported.

**Acceptance Scenarios**:

1. **Given** a valid source inventory and no default-priority Credo findings, **When** the existing quality workflow runs, **Then** its required Credo result succeeds and reports the analyzed files.
2. **Given** Credo exits unsuccessfully, **When** the quality workflow runs, **Then** the Credo result fails and CI cannot treat SonarCloud success as a substitute.
3. **Given** an inventory entry is missing, stale, or inconsistent with effective Credo inputs, **When** the quality workflow runs, **Then** the inventory/Credo result fails independently of SonarCloud.

### User Story 3 - Reproduce and interpret the check locally (Priority: P2)

As a contributor, I need documented local commands, scope, rule level, exclusions, and limitations so I can reproduce the required analysis and understand what a passing result establishes.

**Why this priority**: Clear evidence makes local diagnosis and review consistent with CI.

**Independent Test**: Follow the project documentation from the repository root and confirm the documented standard invocation and inventory verification produce the same source scope and default-priority result as CI.

**Acceptance Scenarios**:

1. **Given** the project documentation, **When** a contributor follows its commands, **Then** they can run the standard Credo invocation and source inventory verification locally.
2. **Given** CI reports zero Credo findings, **When** a reviewer reads the evidence, **Then** it states that this result does not prove the absence of bugs or equivalence to SonarCloud's native Java analysis.

### Edge Cases

- A newly added maintained `.ex` or `.exs` file must be discovered and included without a manual omission being accepted as a valid inventory.
- A deleted or renamed file must not remain as an unexplained stale inventory entry.
- A file under an excluded generated, vendored, dependency, or build-output area must have a documented category-specific exclusion reason; exclusions cannot be introduced merely to make a check pass.
- Credo may reject or fail before producing a complete effective input list; the required result must fail closed and must not publish an incomplete list as valid evidence.
- SonarCloud may pass, fail, or be unavailable; none of those states changes the independently evaluated Credo/inventory result.
- Existing CI profiles may run independently or in parallel; adding this gate must not change their ownership or result requirements.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST use the Credo dependency, standard default-priority invocation, rules, and reviewed source scope established by completed TASK-066; this feature MUST NOT repeat TASK-066 remediation or change its findings policy.
- **FR-002**: The project MUST define an auditable inventory boundary for maintained, tracked, first-party `.ex` and `.exs` files, including application source, configuration, migrations, scripts, root-level Elixir source, and maintained test/support source.
- **FR-003**: The project MUST expose a machine-checkable inventory and compare it with both the maintained tracked source set and Credo's effective analyzed file list.
- **FR-004**: Every maintained first-party file in the boundary MUST be analyzed. A maintained file missing from the inventory or effective Credo inputs, an inventory entry no longer in scope, or any other mismatch MUST fail the inventory check.
- **FR-005**: Every excluded tracked Elixir source file MUST be identifiable with a specific, reviewable reason. An unexplained or unrecognized exclusion MUST fail the inventory check; the exclusion mechanism MUST NOT silently narrow the reviewed TASK-066 source scope.
- **FR-006**: The existing quality workflow MUST run the inventory reconciliation and standard Credo invocation as a mandatory required CI result. Credo failure, an invalid or incomplete inventory, or failure to produce a complete effective analyzed file list MUST fail that result.
- **FR-007**: The Credo/inventory required result MUST be independently evaluated and reported; success or failure of SonarCloud MUST NOT mask, replace, or satisfy it.
- **FR-008**: The change MUST add focused automated tests for maintained-source inclusion, justified exclusion behavior, missing inventory entries, stale inventory entries, effective-input mismatches, and propagation of Credo and inventory failures into the required result.
- **FR-009**: Contributor documentation and CI evidence MUST identify the local commands, analyzed source scope, exclusions and their reasons, default-priority rule level, limitations, and the revision that triggered the evidence.
- **FR-010**: Documentation and CI evidence MUST state that zero Credo findings do not establish absence of bugs and do not establish equivalence to SonarCloud native Java analysis.
- **FR-011**: The implementation MUST preserve application behavior, existing JavaScript and Elixir coverage reports, SonarCloud checks, CP1 gates, and existing unit, integration, and browser E2E profiles. Existing regression gates remain required.
- **FR-012**: The implementation MUST use the smallest changes supported by the existing toolchain and quality workflow, without creating another coverage execution pipeline or redesigning existing test runners.

### Out of Scope

- Whole-application coverage collection, export merging, coverage inventory, new coverage threshold, or coverage-report adapter.
- Dialyzer dependency, compatibility assessment, PLT work, or adoption decision.
- SonarCloud compatibility probes, external Elixir finding or coverage imports, credentials, or account-permission changes.
- Domain/application refactors, another language analyzer, suppression baseline, disabled standard Credo rules, or a general-purpose verification/report framework.
- Changes owned by TASK-067, TASK-068, or TASK-069.

### Key Entities

- **Maintained source inventory**: The revision-specific set of tracked, first-party Elixir source files in the reviewed scope, plus any explicit and justified exclusions.
- **Effective analyzed file list**: The set of source paths Credo actually accepts and analyzes for a given CI revision.
- **CI quality evidence**: The revision-associated result showing inventory reconciliation, effective file list, Credo outcome, and documented interpretation limits.
- **Required Credo result**: The independently evaluated CI result for source reconciliation and standard Credo analysis.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every maintained tracked first-party `.ex` and `.exs` file in the declared boundary appears in both the verified inventory and Credo's effective analyzed file list for the triggering revision; every excluded tracked Elixir file has a specific reason.
- **SC-002**: All focused automated cases pass for inclusion, exclusion, missing and stale entries, effective-input mismatch, and failure propagation.
- **SC-003**: An invalid or incomplete inventory and a failing standard Credo invocation each cause the required Credo CI result to fail without relying on SonarCloud's status.
- **SC-004**: Reviewers can identify the triggering revision, commands, complete analyzed file list, rule level, exclusions, and limitations from the CI evidence and project documentation.
- **SC-005**: Existing coverage reports, SonarCloud checks, CP1 gates, and unit, integration, and browser E2E regression profiles remain present and required after the change.

## Assumptions

- TASK-066 has been merged and remains the authoritative source for Credo version, standard invocation, default-priority rules, and reviewed maintained-source scope.
- “Tracked” means source present in the repository revision being checked; generated outputs and third-party/dependency content are not maintained first-party source, but any tracked Elixir file outside the maintained boundary still needs an explicit exclusion reason.
- CI evidence is revision-specific and its complete analyzed path list is reviewable as an artifact or equivalent output retained by the existing workflow.
- The existing required quality workflow can host this check without changing the established ownership of test profiles or SonarCloud checks.

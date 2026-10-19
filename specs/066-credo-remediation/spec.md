# Feature Specification: Existing Credo Findings Remediation

**Feature Branch**: `066-remediate-existing-elixir-credo-findings-without-behavior-changes`

**Created**: 2026-10-18

**Status**: Draft

**Input**: TASK-066 — Remediate all existing first-party Elixir Credo findings without behavior changes.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Establish a repeatable Credo standard (Priority: P1)

As a maintainer, I need a pinned, documented Credo invocation so the team can reproduce the same default-priority findings while maintaining the application.

**Why this priority**: A stable measurement is necessary to establish and verify the cleanup prerequisite for TASK-065.

**Independent Test**: Inspect dependency configuration and project documentation, then run the documented command and confirm that it uses the pinned analyzer version and its standard default-priority rules.

**Acceptance Scenarios**:

1. **Given** the development/test dependency configuration, **When** Credo is resolved, **Then** it is pinned to version 1.7.19 and is not part of the runtime dependency set.
2. **Given** the documented standard command, **When** a maintainer runs it, **Then** it measures default-priority findings without disabling rules, suppressing findings, applying a baseline, or raising thresholds.

### User Story 2 - Remove existing first-party findings safely (Priority: P1)

As a maintainer, I need all existing first-party findings assessed and remediated so the repository meets the agreed lint standard without changing application behavior.

**Why this priority**: TASK-065 depends on a complete and trustworthy cleanup, and partial refactoring would leave existing findings unaccounted for.

**Independent Test**: Run the standard Credo measurement against the completed change and review the source changes and regression evidence against the pre-change behavior and all stated preservation constraints.

**Acceptance Scenarios**:

1. **Given** the first-party Elixir source, **When** the full default-priority measurement is reviewed, **Then** every existing finding across application code, configuration, migrations, and maintained test/support code has been assessed and remediated.
2. **Given** a behavior-preserving cleanup, **When** relevant unit, integration, and actual browser end-to-end regressions are run, **Then** existing assertions and user-visible outputs remain unchanged and the affected regressions pass.
3. **Given** preserved cleanup changes originating in TASK-065, **When** they are considered for this task, **Then** they are independently reviewed against this specification before reuse, and the combined cleanup is verified as a whole rather than accepted from partial historical evidence.

### User Story 3 - Preserve critical test and domain safeguards (Priority: P1)

As a product and engineering reviewer, I need cleanup to preserve the assertions and safeguards protecting financial and native-profile behavior.

**Why this priority**: Style remediation must not weaken the tests or domain protections that guard market integrity and profile ownership.

**Independent Test**: Inspect relevant E2E assertions and ownership/receipt paths, then run their affected regressions and compare assertions and safeguards before and after cleanup.

**Acceptance Scenarios**:

1. **Given** E2E fixtures that assert subset patterns, **When** those tests are maintained during cleanup, **Then** meaningful subset-pattern assertions remain intact and are not replaced with weaker checks.
2. **Given** native profile handling, **When** findings in those paths are remediated, **Then** all existing ownership and receipt safeguards remain intact.
3. **Given** financial or authentication code in the finding set, **When** it is refactored, **Then** business behavior, public outputs, error ordering, transaction boundaries, locking, idempotency, and financial invariants remain unchanged.

### Edge Cases

- A source change can remove a lint finding while subtly altering evaluation order, error ordering, or output shape; relevant existing regressions must detect and reject such changes.
- A finding in test/support code can tempt an assertion rewrite; assertion meaning and strength must be preserved, especially for E2E subset patterns.
- A previously prepared cleanup patch can be incomplete or based on a stale source snapshot; it is evidence to review, not proof that the current full finding set is clean.
- A tooling dependency accidentally included at runtime violates the requested scope even if the lint command succeeds.
- Shared Credo prerequisites already present in TASK-065 must not be delivered a second time in this task.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST declare Credo version 1.7.19 as a development/test dependency that is excluded from runtime dependency loading.
- **FR-002**: The project MUST document one standard invocation that runs Credo with its default-priority rule set.
- **FR-003**: The standard measurement MUST NOT disable standard rules, suppress findings, add a baseline, increase accepted finding thresholds, or remove tests to obtain a passing result.
- **FR-004**: The cleanup MUST assess and remediate every existing first-party Credo finding in application code, configuration, migrations, and maintained test/support code.
- **FR-005**: Cleanup MUST preserve observable business behavior, public outputs, error ordering, transaction boundaries, locking, idempotency, and all financial invariants defined by the product documentation.
- **FR-006**: Cleanup MUST preserve meaningful E2E subset-pattern assertions and all native-profile ownership and receipt safeguards.
- **FR-007**: The preserved TASK-065 draft cleanup MAY be reused only after independent review against this specification; the complete resulting cleanup MUST be measured and assessed as a whole.
- **FR-008**: Any behavior correction discovered during remediation MUST have tests, and no cleanup may remove or weaken existing test assertions.
- **FR-009**: Relevant existing unit, integration, and actual browser end-to-end regressions MUST be run after causal fixes; historical pre-split checks MUST NOT be represented as evidence for the completed task.
- **FR-010**: SonarCloud probes, whole-application coverage collectors, report adapters, credentials, and new mandatory CI integration MUST remain outside this task and within TASK-065.
- **FR-011**: Completion MUST include fresh independent QA and final review, each with an exact `Verdict: PASS`, before human merge.
- **FR-012**: TASK-065 MUST remain blocked until this cleanup is completed.

### Key Entities *(include if data involved)*

- **Credo finding**: A default-priority static-analysis observation associated with existing first-party Elixir source and requiring assessment and remediation.
- **Cleanup change**: A source or configuration adjustment reviewed for finding removal and preservation of existing behavior, outputs, and safeguards.
- **Regression evidence**: Results from relevant unit, integration, and browser end-to-end checks used to establish that cleanup preserved behavior.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The standard measurement reports zero first-party default-priority findings across the specified source categories after cleanup, with no suppressed or baselined findings.
- **SC-002**: The documented invocation consistently identifies the pinned analyzer version and default-priority rule set.
- **SC-003**: All relevant unit, integration, and actual browser end-to-end regression checks run after causal fixes pass, with existing test assertions retained.
- **SC-004**: Review confirms zero changes to the specified business behavior, output, ordering, transaction, locking, idempotency, and financial invariants.
- **SC-005**: Fresh independent QA and final review both conclude with the exact verdict `PASS`, and TASK-065 remains blocked until this task is complete.

## Assumptions

- The task’s product scope is limited to existing first-party lint remediation and the minimal Credo prerequisite; TASK-065 owns its quality-integration instrumentation and CI changes.
- Existing behavior and test assertions are the compatibility baseline; the cleanup does not authorize product or business-rule changes.
- The preserved draft patch and its manifest are local review inputs, not canonical specifications or proof of completion.
- Product and architecture invariants in `docs/PRODUCT.md` and `docs/ARCHITECTURE.md`, and delivery governance in `docs/CHECKPOINTS.md` and the constitution, continue to apply.

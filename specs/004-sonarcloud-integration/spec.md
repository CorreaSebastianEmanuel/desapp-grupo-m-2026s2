# Feature Specification: SonarCloud Integration

**Feature Branch**: `004-sonarcloud-integration`

**Created**: 2026-09-16

**Status**: Draft

**Input**: User description: "TASK-004 SonarCloud integration — Publish analysis from CI and keep the project below the CP1 issue threshold."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Review Published Code Analysis (Priority: P1)

As a reviewer, I can see a current SonarCloud analysis for every proposed change so that I can assess code-quality findings for the exact revision under review.

**Why this priority**: Publishing trustworthy analysis from continuous integration is the core task outcome and provides the evidence needed for the CP1 quality decision.

**Independent Test**: Open or update a proposed change and verify that automated analysis starts, examines the submitted revision, and publishes a visible result linked to that revision.

**Acceptance Scenarios**:

1. **Given** any pull request in the repository, **When** continuous integration runs for its current revision, **Then** SonarCloud analysis runs and displays a completed result for that exact revision.
2. **Given** a published analysis, **When** a reviewer opens its result from the proposed change, **Then** the reviewer can see the issue count and whether the checkpoint threshold is satisfied.
3. **Given** an update to an existing proposed change, **When** continuous integration analyzes the update, **Then** the visible result corresponds to the latest submitted revision rather than an earlier one.
4. **Given** a revision is integrated into `main`, **When** continuous integration runs for that revision, **Then** SonarCloud analysis runs and publishes the current project result for `main`.

---

### User Story 2 - Enforce the Checkpoint Issue Threshold (Priority: P2)

As a maintainer, I receive a passing quality result only while the analyzed project has fewer than 10 unresolved SonarCloud issues, so that CP1 compliance cannot be claimed when the threshold is exceeded.

**Why this priority**: CP1 explicitly requires fewer than 10 issues; a published report without an enforceable, unambiguous threshold would not protect that outcome.

**Independent Test**: Evaluate controlled analyses on both sides of the boundary and verify that 9 unresolved issues pass while 10 unresolved issues fail.

**Acceptance Scenarios**:

1. **Given** a completed analysis with 0 through 9 unresolved issues, **When** the checkpoint quality result is evaluated, **Then** the issue-threshold condition passes.
2. **Given** a completed analysis with 10 or more unresolved issues, **When** the checkpoint quality result is evaluated, **Then** the issue-threshold condition fails and the proposed change cannot present a successful SonarCloud quality result.
3. **Given** analysis cannot complete or its result cannot be published, **When** continuous integration finishes, **Then** the SonarCloud quality result does not pass and provides a visible failure reason.

---

### User Story 3 - Diagnose Analysis Failures Safely (Priority: P3)

As a contributor, I can distinguish code findings from configuration, authorization, or service failures without exposing credentials, so that I can take the correct corrective action.

**Why this priority**: Actionable and safe diagnostics reduce recovery time while ensuring that integration failures are not mistaken for compliant analysis.

**Independent Test**: Exercise a code-threshold failure and a non-code analysis failure, then verify that each is visibly classified and that no secret value appears in output or repository content.

**Acceptance Scenarios**:

1. **Given** analysis completes but violates the issue threshold, **When** a contributor inspects the result, **Then** the result identifies the issue-count violation and links to the published findings.
2. **Given** analysis cannot authenticate, publish, or reach the analysis service, **When** a contributor inspects the result, **Then** the integration reports a failed analysis with enough non-sensitive context to distinguish it from a code-threshold failure.
3. **Given** the integration uses a credential, **When** repository content and automated output are inspected, **Then** the credential value is absent from version-controlled files and logs.

### Edge Cases

- Exactly 9 unresolved issues satisfies the checkpoint threshold; exactly 10 does not.
- A superseded or concurrent run must not replace the status of the latest proposed-change revision with an older result.
- A skipped, timed-out, canceled, incomplete, or unpublished analysis must not be represented as a successful quality result.
- Temporary unavailability, authorization failure, or invalid project configuration must fail visibly without being counted as zero issues.
- Analysis of generated, vendored, dependency, or other non-project code must not distort the issue count; the analyzed scope must match the repository-owned application and test source defined by project conventions.
- A pull request analysis that cannot access required configuration or credentials must fail visibly; it must not be skipped or reported as successful.
- Re-running analysis for the same revision must not create ambiguity about which result governs that revision.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST automatically run SonarCloud analysis for every pull request, without exceptions based on contribution origin or trust context.
- **FR-002**: The analysis MUST evaluate the exact revision associated with the continuous-integration run and MUST publish a result attributable to that revision and proposed change.
- **FR-003**: The published result MUST expose the unresolved issue count and an unambiguous pass or fail status for the checkpoint threshold.
- **FR-004**: The checkpoint issue-threshold condition MUST pass only when the completed analysis reports fewer than 10 unresolved issues; 10 or more MUST fail.
- **FR-005**: A successful SonarCloud quality result MUST require both a completed, published analysis and satisfaction of the checkpoint issue threshold.
- **FR-006**: An analysis error, timeout, cancellation, authorization failure, configuration failure, or publication failure MUST NOT produce a successful SonarCloud quality result.
- **FR-007**: The integration MUST provide contributors with sufficient non-sensitive diagnostics to distinguish an issue-threshold violation from an analysis or publication failure.
- **FR-008**: Any credential used to publish analysis MUST be supplied through protected repository configuration and MUST NOT be stored in version-controlled content or exposed in automated output.
- **FR-009**: The analyzed scope MUST include repository-owned application and test source relevant to checkpoint quality and MUST exclude generated, vendored, dependency, build-output, and secret-bearing files according to repository conventions.
- **FR-010**: A result for an older or different revision MUST NOT be presented as the governing result for the latest revision under review.
- **FR-011**: Every continuous-integration run on `main` MUST run and publish SonarCloud analysis so that the project's current checkpoint issue count remains visible outside an individual pull request.
- **FR-012**: The repository MUST document where reviewers find the published analysis, how the fewer-than-10 threshold is interpreted, which source scope is analyzed, and how contributors distinguish and address code findings versus integration failures.
- **FR-013**: This task MUST be limited to SonarCloud analysis publication, checkpoint issue-threshold enforcement, safe configuration, and supporting documentation; changing product behavior, adding coverage thresholds, resolving unrelated findings, or changing the TASK-003 baseline checks is outside scope.
- **FR-014**: The integration MUST preserve the existing continuous-integration quality baseline and MUST NOT allow SonarCloud execution to bypass or convert a failure in formatting, warnings-as-errors compilation, or unit tests into a successful overall quality result.

### Key Entities

- **Analysis Run**: Evaluation of one repository revision, identified by revision and change context, with completion and publication states.
- **Published Analysis**: The reviewer-visible SonarCloud result for an analysis run, including its unresolved issue count, threshold status, and findings location.
- **Checkpoint Quality Result**: The pass or fail decision derived from whether a valid published analysis contains 0–9 unresolved issues.
- **Analysis Credential**: Protected authorization material used only to publish analysis; its value is never repository content or diagnostic output.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of pull-request revisions automatically run SonarCloud analysis and receive a visible result attributable to the exact revision.
- **SC-002**: In boundary verification, analyses with 9 unresolved issues pass and analyses with 10 unresolved issues fail in 100% of attempts.
- **SC-003**: 100% of successful SonarCloud quality results have both a completed published analysis and an unresolved issue count between 0 and 9 inclusive.
- **SC-004**: For the primary integration branch, the latest accepted revision has a published analysis showing fewer than 10 unresolved issues at CP1 acceptance.
- **SC-005**: In controlled analysis, publication, authorization, timeout, and configuration failure cases, 100% produce a visible non-passing result rather than a false success.
- **SC-006**: Reviewers can reach the published findings and determine the analyzed revision, unresolved issue count, and threshold outcome from the proposed change in no more than two navigation actions.
- **SC-007**: Repository and automated-output inspection finds zero analysis credential values in version-controlled content and logs.
- **SC-008**: Existing formatting, warnings-as-errors compilation, and unit-test checks retain their pass/fail behavior in 100% of regression comparisons after this feature is introduced.
- **SC-009**: 100% of continuous-integration runs on `main` run SonarCloud analysis and publish a result attributable to the analyzed revision.

## Assumptions

- TASK-003 supplies the working continuous-integration quality baseline on which this dependent task builds.
- "Issue" means an unresolved issue included in the governing SonarCloud project analysis; resolved or accepted findings are not counted as unresolved issues.
- "Fewer than 10" means 0–9 inclusive, and the threshold applies to the project analysis rather than only issues introduced by the proposed change.
- The repository does not accept contributions from forks; all pull requests originate from trusted internal branches where the required protected analysis configuration is expected to be available.
- The repository's primary integration branch is the authoritative source for the current project-level issue count.
- SonarCloud project and organization administration are available to an authorized maintainer; account procurement and organization-wide policy changes are outside this task.
- The task reports and enforces findings but does not expand into remediation of pre-existing unrelated issues beyond what is necessary to meet the stated fewer-than-10 acceptance threshold.
- No product-domain entity, persistent business data, external football-provider behavior, or application-facing functionality changes as part of this feature.

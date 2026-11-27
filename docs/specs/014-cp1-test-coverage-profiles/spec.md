# Feature Specification: CP1 Test and Coverage Profiles

**Feature Branch**: `014-cp1-automated-test-and-coverage-profiles`

**Created**: 2026-09-29

**Status**: Draft

**Input**: TASK-014: "Separate unit and integration execution, report coverage, and test CP1 behavior and errors." Remediation approved 2026-09-29.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run Complete Focused Checks (Priority: P1)

As a contributor, I can run the CP1 unit or integration profile independently in the documented supported local environment, so that I receive complete, focused feedback before sharing a change.

**Why this priority**: Reliable profile execution is the foundation for all CP1 regression and coverage evidence.

**Independent Test**: In a supported local checkout containing passing unit and integration tests, run each documented profile and verify that it completes only its own classified scope, reports its own result, and does not require live provider data or production credentials.

**Acceptance Scenarios**:

1. **Given** passing tests in both classifications, **When** a contributor runs either profile, **Then** every test in its classification runs and is reported, no test in the other classification runs, and the selected profile succeeds.
2. **Given** the documented local environment, **When** the integration profile includes the published-contract browser regression, **Then** the required Node.js 24 runtime, package toolchain, and browser runtime are available as documented prerequisites and the regression can run locally.
3. **Given** a failing, skipped, undiscovered, or interrupted selected test, or a missing profile prerequisite, **When** the selected profile runs, **Then** it fails without claiming complete success and gives only safe, actionable diagnostic categories.

---

### User Story 2 - Validate CP1 Behavior and Safe Errors (Priority: P2)

As a release reviewer, I can run the integration profile separately to verify CP1 user, credential, authentication, catalog, and published-contract behavior, including rejection behavior, without exposing credential material if a check fails.

**Why this priority**: CP1 users depend on these public and persistence-boundary interactions working together, and an unsafe failure report is itself a security defect.

**Independent Test**: Run the documented integration profile with deterministic local data and controlled failure fixtures; verify CP1 success and error journeys, fail-closed diagnostics, and the absence of raw sensitive values in every retained or emitted output.

**Acceptance Scenarios**:

1. **Given** deterministic local data, **When** a contributor runs the integration profile, **Then** it executes and reports the full integration classification separately from the unit result, without live provider data or production credentials.
2. **Given** a regression in a CP1 successful journey or specified rejection, **When** the integration profile runs, **Then** the relevant regression fails and identifies the affected behavior without changing or concealing the failure.
3. **Given** any profile failure path, including a missing Node.js runtime or browser prerequisite, **When** diagnostics are emitted, retained, or published, **Then** raw passwords, JWTs, API keys, tokens, credential-verification material, and test verification material are absent.

---

### User Story 3 - Review Snapshot-Bound Coverage (Priority: P3)

As a maintainer, I can generate an informational coverage report for the exact CP1 source and working-tree snapshot I tested, so that I can assess exercised behavior before creating a QA commit.

**Why this priority**: Coverage is useful only when its source scope and provenance are truthful; a clean-HEAD-only rule blocks ordinary pre-QA work without improving that truthfulness.

**Independent Test**: From a checkout with relevant uncommitted changes, run the documented coverage command after both profiles succeed and inspect one report labelled as a working-tree snapshot. Verify its base revision, deterministic snapshot hash, source inventory, overall percentage, and source-level executed/unexecuted detail.

**Acceptance Scenarios**:

1. **Given** both profiles succeed for a tracked working-tree snapshot, **When** coverage reporting is requested, **Then** it produces one readable report labelled as a working-tree snapshot with an overall percentage and source-level executed and unexecuted coverage for application-owned CP1 behavior.
2. **Given** relevant uncommitted changes, **When** coverage reporting succeeds, **Then** its provenance binds the base HEAD revision and a deterministic hash of the relevant working-tree diff; a pre-QA commit or clean worktree is not required.
3. **Given** coverage calculation, scope validation, snapshot capture, or publication fails, or the relevant snapshot changes before publication, **When** coverage reporting completes, **Then** it fails visibly and publishes no report falsely attributed to the tested snapshot.

### Edge Cases

- Every automated CP1 test belongs to exactly one profile; no test is silently omitted from both or counted in both.
- An empty, skipped, undiscovered, or interrupted profile cannot be reported as complete success.
- Diagnostics must fail closed: if output cannot be safely sanitized and checked before emission, the command fails using a generic safe diagnostic rather than forwarding child output.
- The browser/public-contract regression cannot be treated as passing, skipped, or optional merely because its Node.js 24 or browser prerequisite is absent.
- Tests use deterministic local fixtures; no live football-provider call, production credential, or production data is required.
- Existing CP1 error contracts remain observable: authentication precedes protected-request validation and catalog access; malformed, unknown, repeated, and conflicting valid catalog inputs retain their established outcomes.
- The committed CP1 source inventory controls actual coverage inclusion and exclusion. A source outside it cannot affect the aggregate percentage, and an included inventory source cannot be silently omitted.
- Coverage is informational: a low percentage is reported accurately and never becomes a pass/fail threshold or a fourth CI baseline category.
- A report for an unchanged committed revision is labelled with that revision; a report with relevant local changes is labelled as a working-tree snapshot and is never presented as clean-HEAD evidence.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST provide documented, independently runnable unit and integration profiles, each with a clear success or failure result and safe failure diagnostics.
- **FR-002**: The documented supported local test environment MUST specify and provide Node.js 24, its required package toolchain, and a supported browser runtime for the CP1 published-contract browser regression, alongside the existing CP1 test prerequisites.
- **FR-003**: Every automated CP1 test MUST be classified into exactly one profile. The unit profile MUST execute all and only unit-classified tests; the integration profile MUST execute all and only integration-classified tests.
- **FR-004**: A profile MUST fail when a test in its defined scope fails, cannot be discovered, is skipped in place of execution, terminates before the complete scope finishes, or a required local prerequisite is absent. It MUST NOT represent a partial execution as complete success.
- **FR-005**: The unit profile MUST exercise isolated CP1 application behavior, and the integration profile MUST exercise public-interface and persistence-boundary CP1 behavior, using deterministic local data and without live football-provider access, production credentials, or production data.
- **FR-006**: Before any profile or coverage child output, exception detail, report content, or retained diagnostic is emitted or published, it MUST be safely sanitized and checked. If that cannot complete, the command MUST fail closed with a generic safe diagnostic.
- **FR-007**: Test and coverage outputs in every success and failure path, including missing-prerequisite paths, MUST NOT disclose raw passwords, API-key secrets, JWTs, tokens, credential-verification material, or test verification material.
- **FR-008**: The CP1 regression collection MUST cover successful and rejected user registration, including validation, normalized-email uniqueness, no partial account state, credential verification, and credential non-disclosure.
- **FR-009**: The CP1 regression collection MUST cover API-key issuance, multiple-key independence, identification, revocation, invalid or revoked-key rejection, and the rule that raw secrets and stored verification material do not appear outside the one-time successful issuance result.
- **FR-010**: The CP1 regression collection MUST cover successful credential login and validation, invalid credential rejection, token validity boundaries, and the generic non-disclosing unauthenticated outcome.
- **FR-011**: The CP1 regression collection MUST cover protected catalog access with each supported credential form, authentication precedence over request validation and catalog reads, and the documented generic unauthenticated response including its challenge.
- **FR-012**: The CP1 regression collection MUST cover catalog list, detail, pagination, and league, team, and position filtering behavior, including malformed or repeated inputs, unknown or conflicting valid identities, cursor misuse, ordering, empty results, and no provider interaction during local reads.
- **FR-013**: The CP1 regression collection MUST cover that published interactive and machine-readable documentation remains available without a credential, accurately represents supported protected catalog operations and their success and error contracts, and does not claim unsupported CP1 capabilities.
- **FR-014**: The repository MUST provide a documented coverage execution that reports the current tested CP1 snapshot. It MUST state an overall percentage and source-level executed and unexecuted coverage information for application-owned CP1 behavior.
- **FR-015**: The committed CP1 source inventory MUST demonstrably control the coverage collector's actual source scope. Each included source MUST be eligible for the aggregate denominator, and test-only, generated, third-party, and every inventory-excluded source MUST contribute 0% to that total.
- **FR-016**: Each published coverage result MUST include traceable provenance: base HEAD revision, deterministic hash of the relevant working-tree diff, source-inventory identity and hash, and the two successful profile results. A result with relevant local changes MUST be explicitly labelled a working-tree snapshot.
- **FR-017**: Coverage publication MUST accept a valid working-tree snapshot before commit; it MUST NOT require a clean worktree or pre-QA commit. It MUST fail visibly and publish nothing if its calculation, scope validation, provenance validation, or safe-output validation fails, or if the relevant snapshot changes before publication.
- **FR-018**: The existing continuous-integration quality baseline MUST retain its three required categories—formatting, warnings-as-errors compilation, and unit tests. This feature MUST NOT add coverage enforcement, a coverage threshold, SonarCloud changes, deployment, release automation, end-to-end tests, or architecture checks to that baseline.
- **FR-019**: This feature MUST add confidence in existing CP1 behavior without changing user registration, API-key, authentication, catalog, filtering, documentation, domain rules, persisted product data, or external-provider behavior.

### Key Entities

- **Test Profile**: One named, independently executable classification of automated CP1 tests: unit or integration. Each test belongs to exactly one profile.
- **Supported Local Test Environment**: The documented set of local tools and services required to execute the complete CP1 test profiles, including the Node.js 24 browser-regression prerequisite.
- **CP1 Regression Collection**: The automated tests demonstrating the successful and error behavior already specified for CP1 accounts, credentials, authentication, catalog, filters, and published contracts.
- **Coverage Source Inventory**: The committed, rationalized list of application-owned CP1 sources included in coverage and excluded material that cannot affect the total.
- **Working-Tree Snapshot**: The tested state identified by its base HEAD revision and deterministic hash of relevant local execution-input changes; it may exist before commit. Generated QA/review artifacts written after execution are excluded.
- **Coverage Report**: A snapshot-bound record of exercised and unexercised inventory-owned CP1 behavior, including aggregate and source-level coverage information.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In a controlled suite containing passing tests in both classifications, 100% of unit-classified tests run only in the unit profile and 100% of integration-classified tests run only in the integration profile.
- **SC-002**: In the documented supported local environment, 100% of profile runs, including the published-contract browser regression, can start with their declared prerequisites available; an absent prerequisite produces a nonzero, safe diagnostic in 100% of controlled attempts.
- **SC-003**: In controlled negative verification, a failing, skipped, undiscovered, prematurely terminated, or missing-prerequisite test causes its selected profile to fail in 100% of attempts, with no false complete-success result.
- **SC-004**: In automated regression verification, 100% of the CP1 success and failure behavior listed in FR-008 through FR-013 has at least one deterministic passing test and at least one applicable specified-error or boundary test.
- **SC-005**: In controlled profile and coverage success/failure output, 0 raw passwords, JWTs, API keys, tokens, credential-verification values, or test verification values appear in any emitted or retained output, including missing-runtime failures.
- **SC-006**: For 100% of successful coverage executions, maintainers can find an overall percentage and source-level executed and unexecuted coverage for every inventory-included source; generated, third-party, test-only, and inventory-excluded material contributes 0% to that total.
- **SC-007**: In 100% of successful coverage reports, the report identifies the base HEAD revision, relevant working-tree-diff hash, inventory hash, and both complete profile results; reports with relevant local changes visibly state that they are working-tree snapshots.
- **SC-008**: In controlled coverage calculation, scope, snapshot, stale-publication, and changed-snapshot failures, 100% produce a visible safe failure and no falsely attributed report.
- **SC-009**: Review of the quality baseline confirms it continues to expose exactly its original three required categories, with 0 coverage threshold or enforcement obligation.

## Assumptions

- TASK-003 supplies the existing three-category quality baseline and its local-equivalent commands; TASK-014 preserves that baseline while adding separately selectable profiles and coverage reporting.
- TASK-013 and the preceding completed CP1 tasks define the behavior and error contracts that this task verifies rather than redefines.
- The supported local environment continues to use the project-pinned Elixir, Erlang/OTP, locked dependencies, and local PostgreSQL test service; Node.js 24, its package toolchain, and Chromium are additional documented prerequisites for the browser regression.
- A test's profile classification is based on whether it verifies isolated behavior or a public/persistence-boundary interaction; the implementation plan records the repository's concrete classification convention.
- A relevant working-tree diff contains the tracked local changes that can affect profile execution, coverage scope, source inventory, or report provenance. The implementation plan will enumerate the exact deterministic input set and change-detection rule.
- Coverage is a transparency report in CP1, not a release or merge threshold. A future checkpoint may define a policy threshold without changing this report's truthfulness.
- Normal package dependency retrieval is permitted. Deterministic fixtures replace live football-provider calls and production data in every automated test.

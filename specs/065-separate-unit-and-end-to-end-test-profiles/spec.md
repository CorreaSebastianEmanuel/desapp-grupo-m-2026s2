# Feature Specification: Separate Unit and End-to-End Test Profiles

**Feature Branch**: `063-separate-unit-and-end-to-end-test-profiles`

**Created**: 2026-10-16

**Status**: Draft

**Input**: TASK-063 — Verify existing unit/integration profiles and add a distinct actual end-to-end profile for authenticated CP2 browser journeys and API/background-work scenarios, preserving coverage and CI quality checks.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run isolated test profiles (Priority: P1)

As a contributor, I can run the existing unit and integration checks independently and run a separate end-to-end profile, so each result describes the scope that actually ran.

**Why this priority**: CP2 requires evidence of real end-to-end behavior while retaining the established unit, integration, coverage, and CI contracts.

**Independent Test**: Run each named profile against a controlled inventory and verify the profile discovers and executes its assigned tests only, reports its own result, and fails when an assigned test is omitted or fails.

**Acceptance Scenarios**:

1. **Given** the declared test inventory, **When** a contributor runs the unit, integration, or end-to-end profile, **Then** only the selected profile's assigned tests execute and its discovered and expected test counts are reported.
2. **Given** a test is unclassified, undiscovered, skipped instead of executed, or assigned to multiple profiles, **When** profile completeness is checked, **Then** the check fails and identifies the discrepancy.
3. **Given** a selected profile fails, is interrupted, or lacks a required local prerequisite, **When** its run ends, **Then** it reports failure with a safe actionable diagnostic and never reports complete success.

### User Story 2 - Complete an authenticated browser shell journey (Priority: P1)

As a release reviewer, I can use a real browser to sign in, reach the authenticated portfolio workspace, and sign out, so the end-to-end profile verifies the delivered browser authentication boundary.

**Why this priority**: TASK-046 delivers the authenticated LiveView shell that CP2 browser features build on. This task must verify that implemented shell and session behavior without claiming later feature behavior.

**Independent Test**: With a deterministic local account and running application, use browser navigation and form submission at `/sign-in`, `/portfolio`, and `/sign-out`; verify the protected workspace is unavailable before authentication and available only during the authenticated session.

**Acceptance Scenarios**:

1. **Given** an unauthenticated browser, **When** it requests `/portfolio`, **Then** it is redirected to sign in and no protected workspace is rendered.
2. **Given** a valid deterministic account, **When** the browser signs in through `/sign-in`, **Then** it reaches `/portfolio` and sees the authenticated portfolio workspace shell.
3. **Given** an authenticated browser, **When** it signs out, **Then** the session is revoked and a later request to `/portfolio` again requires authentication.
4. **Given** invalid credentials or an expired session, **When** the browser attempts sign-in or accesses the protected workspace, **Then** it receives the existing safe failure or sign-in recovery behavior and no authenticated workspace is exposed.

### User Story 3 - Observe catalog synchronization through API and background work (Priority: P1)

As a maintainer, I can request a catalog synchronization through the supported trusted local interface, let the durable worker process it, and inspect its result through the supported API, so end-to-end evidence covers accepted work and its final catalog effect.

**Why this priority**: TASK-019 is already implemented and supplies a concrete durable background workflow. It provides an end-to-end scenario independent of unfinished charts and conditional orders.

**Independent Test**: Start the application with isolated local persistence and a deterministic fixture source. Request synchronization for one supported league-season scope using the trusted local synchronization interface; wait for the durable run to finish; inspect the run through its local inspection interface and retrieve the resulting catalog through authenticated `GET /api/players`.

**Acceptance Scenarios**:

1. **Given** a valid supported scope and deterministic fixture source, **When** a trusted local operator requests synchronization, **Then** the request returns an accepted run identifier before retrieval finishes, and the background worker eventually records the terminal result.
2. **Given** the synchronization has succeeded, **When** an authorized API client calls `GET /api/players`, **Then** the response contains the fixture's expected catalog records and no duplicate identities.
3. **Given** the same fixture publication or accepted work is replayed, **When** processing completes, **Then** catalog state remains idempotent and the API still exposes each expected identity once.
4. **Given** an unsupported or malformed synchronization scope, **When** a trusted local operator requests it, **Then** the request is rejected before executable work is admitted and the existing catalog remains unchanged.
5. **Given** an API request to `GET /api/players` without valid API authentication or with an invalid `page_size`, **When** the request is made, **Then** the API returns its documented unauthorized or `invalid_page_size` response without changing catalog or synchronization state.

### User Story 4 - Preserve regression and CI quality evidence (Priority: P2)

As a maintainer, I can rely on the existing unit and integration behavior, coverage reporting, and required continuous-integration checks after end-to-end coverage is added.

**Why this priority**: A new end-to-end profile adds confidence only if it preserves existing regression and quality safeguards.

**Independent Test**: Compare current TASK-014 and CI behavior with the resulting profile contract, then run the affected profiles and required quality checks to confirm existing tests, reports, and required check categories remain intact.

**Acceptance Scenarios**:

1. **Given** the existing unit and integration suites, **When** profiles are run and reviewed, **Then** their tests remain discoverable and runnable in their existing scopes; crossing an application boundary alone does not reclassify an integration test as end-to-end.
2. **Given** the established coverage report, **When** profiles are run, **Then** coverage remains available with its existing scope and no new threshold is implied.
3. **Given** the existing required CI quality checks, **When** the changed CI configuration is reviewed and executed, **Then** each required category remains required with its existing contract and the end-to-end profile does not replace or weaken it.

### Edge Cases

- A test that calls a public endpoint or persistence boundary in isolation is not end-to-end unless it starts at a supported browser/API boundary and verifies the complete observable outcome across the relevant application journey.
- Browser scenarios must use real navigation and supported authentication; bypassing sign-in or replacing application behavior with mocked responses does not qualify.
- The catalog synchronization journey must verify the completed persisted run and API-visible catalog result, not only work admission or job completion.
- Duplicate fixture publication or work delivery must not create duplicate catalog identities.
- Missing browser, application, database, or worker prerequisites must fail the selected profile visibly rather than skip its scenarios.
- Test output and retained artifacts must not expose passwords, session tokens, API keys, or provider credentials.
- End-to-end scenarios use deterministic local fixtures and do not call live football providers or use production data or credentials.
- Unfinished portfolio charts and conditional-order behavior are not prerequisites or claimed coverage for this task; their owning tasks and TASK-034 remain responsible for their own scenarios.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST provide independently runnable unit, integration, and end-to-end test profiles with declared scopes and separate success or failure outcomes.
- **FR-002**: The existing unit and integration profiles MUST be reviewed against actual discovery, execution, coverage, and CI behavior. Any gap or overlap MUST be documented while preserving their required behavioral coverage.
- **FR-003**: Every automated test MUST be assigned to exactly one declared profile. A completeness check MUST compare expected and discovered tests and fail on unclassified, duplicated, omitted, or skipped-in-place-of-run tests.
- **FR-004**: End-to-end scenarios MUST begin at a supported browser or API boundary and verify externally observable outcomes across all relevant application boundaries. Isolated internal calls or boundary tests alone MUST NOT qualify.
- **FR-005**: The end-to-end profile MUST include a browser journey through the implemented TASK-046 authentication shell: unauthenticated protection of `/portfolio`, sign-in via `/sign-in`, authenticated workspace access, and sign-out/session revocation.
- **FR-006**: The end-to-end profile MUST include a TASK-019 catalog synchronization journey using the trusted local request and inspection interfaces, durable background processing, and authenticated `GET /api/players` to verify the final catalog result.
- **FR-007**: The synchronization journey MUST cover one accepted deterministic fixture synchronization, one invalid-scope rejection before work admission, and replay/idempotency protection against duplicate catalog identities.
- **FR-008**: The API portion MUST verify the documented authentication failure for unauthenticated catalog access and the documented `invalid_page_size` response for invalid input, with no catalog mutation.
- **FR-009**: Authentication and synchronization scenarios MUST use deterministic isolated local accounts and catalog fixtures, and MUST NOT require live external providers, production data, or production credentials.
- **FR-010**: A profile MUST fail when any in-scope scenario fails, is skipped instead of executed, is undiscovered, is interrupted, or cannot start because a required prerequisite is absent. It MUST NOT report partial execution as complete success.
- **FR-011**: End-to-end diagnostics and retained artifacts MUST not expose raw passwords, session tokens, API keys, provider credentials, or other secret material.
- **FR-012**: Adding the end-to-end profile MUST preserve existing unit and integration behavioral coverage and the coverage-reporting contract; it MUST NOT introduce an unstated coverage threshold.
- **FR-013**: The existing required CI quality categories MUST remain required with their current behavior and scope. End-to-end execution MUST NOT substitute for or weaken them.
- **FR-014**: This task MUST add test-profile and test-evidence capabilities only. It MUST NOT implement or alter authentication, portfolio visualization, trading, valuation, catalog synchronization, conditional orders, or background-processing product behavior.
- **FR-015**: The end-to-end scenarios MUST verify results against the implemented TASK-046, TASK-019, and player catalog API contracts; they MUST NOT assert that unfinished chart or conditional-order features exist.

### Key Entities *(include if data involved)*

- **Test Profile**: An independently runnable, explicitly scoped group of automated tests with an isolated result.
- **Test Inventory**: The expected set of automated tests and their unique profile assignments, compared with tests discovered during a run.
- **End-to-End Scenario**: A deterministic journey beginning at a supported browser or API boundary and checking its externally observable final result.
- **Fixture State**: Local account, catalog, synchronization source, and persisted run state prepared for a reproducible scenario.
- **Profile Result**: Evidence of expected and discovered scope, execution outcome, and any failure, omission, skip, interruption, or missing prerequisite.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Contributors can independently run all three profiles, and 100% of the controlled expected test inventory is discovered and executed only by its assigned profile.
- **SC-002**: The end-to-end profile completes the authenticated browser journey and verifies protected access before sign-in and after sign-out.
- **SC-003**: The end-to-end profile verifies an accepted fixture catalog synchronization from trusted request through durable worker completion to API-visible catalog records, plus invalid-scope rejection and duplicate-free replay.
- **SC-004**: In controlled negative runs, every in-scope failure, omission, duplicate assignment, skipped or undiscovered scenario, interruption, and missing-prerequisite case causes a failed profile with no complete-success report.
- **SC-005**: Review and execution confirm that all existing unit and integration coverage remains runnable and the established coverage report remains available without an added enforcement threshold.
- **SC-006**: Review confirms that 100% of existing required CI quality categories remain required and are not replaced or weakened.
- **SC-007**: Review of controlled output and retained artifacts finds zero passwords, session tokens, API keys, provider credentials, or other secret material.

## Assumptions

- TASK-014 defines the existing unit/integration and coverage contract to preserve; actual discovery and CI configuration will be inventoried during planning before proposing changes.
- TASK-046's implemented `/sign-in`, `/portfolio`, and `/sign-out` browser authentication shell is the browser scope for this task. Its current workspace is an unavailable-content shell; portfolio charts are not implemented here.
- TASK-019's trusted local synchronization request and inspection interfaces, durable worker, and PostgreSQL-backed history are used for the catalog journey; TASK-019 does not define a public synchronization HTTP endpoint.
- The supported catalog API read boundary is authenticated `GET /api/players`; it exposes locally persisted catalog records.
- TASK-034 owns broader CP2 regression and demo coverage. TASK-057/TASK-058 own analytics and charts, and TASK-059/TASK-060/TASK-061 own conditional-order behavior. TASK-063 does not claim or test those unfinished product journeys.
- The smallest maintainable profile setup, local prerequisites, and location of the end-to-end CI gate will be determined in planning while retaining the existing required CI baseline.

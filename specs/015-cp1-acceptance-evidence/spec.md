# Feature Specification: CP1 Acceptance Evidence

**Feature Branch**: `015-cp1-acceptance-evidence`

**Created**: 2026-09-29

**Status**: Draft

**Input**: User description: "TASK-015 CP1 acceptance evidence — Verify every CP1 item and produce a repeatable demo with links to evidence."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Decide CP1 Acceptance from Complete Evidence (Priority: P1)

As a checkpoint reviewer, I can inspect one revision-bound acceptance record that covers every CP1 obligation so that I can reach a defensible pass or fail decision without reconstructing evidence from team knowledge.

**Why this priority**: The task succeeds only if every checkpoint obligation is explicitly verified and traceable to trustworthy evidence for the reviewed revision.

**Independent Test**: Starting only from the acceptance record, verify that each CP1 obligation has an outcome, acceptance criterion, evidence link, and revision identity, and that the overall result is passing only when all obligations pass.

**Acceptance Scenarios**:

1. **Given** a candidate revision for CP1 acceptance, **When** its acceptance record is reviewed, **Then** it separately covers repository accessibility, the automated quality build, SonarCloud issue count, JWT authentication, OpenAPI 3 publication, the minimum catalog model, unit tests, user creation, API-key creation, and the protected player catalog.
2. **Given** every CP1 obligation passes for the same candidate revision, **When** the overall result is calculated, **Then** the acceptance record identifies that revision and reports CP1 as passing.
3. **Given** any obligation is failed, unverified, stale, inaccessible, or attributable to another revision, **When** the overall result is calculated, **Then** CP1 is reported as not passing and the affected obligation is identified.
4. **Given** an obligation relies on hosted evidence, **When** a reviewer follows its link, **Then** the destination identifies the relevant project or revision and exposes the claimed result to an authorized reviewer.

---

### User Story 2 - Repeat the CP1 Demonstration (Priority: P2)

As a demonstrator, I can follow one ordered guide from a documented clean starting state to reproduce the CP1 journeys and their expected outcomes without undocumented setup or production secrets.

**Why this priority**: Repeatability turns a one-time evidence collection into a usable checkpoint demonstration and exposes missing prerequisites or hidden state.

**Independent Test**: Give the guide to a contributor familiar with the repository but not its CP1 implementation; verify that they can prepare the environment, execute every step in order, observe the stated results, and cleanly repeat the demo.

**Acceptance Scenarios**:

1. **Given** a clean checkout of the recorded revision and the documented prerequisites, **When** a demonstrator follows the guide, **Then** they can prepare local services and deterministic demonstration data without manual source edits or live football-provider access.
2. **Given** the prepared demonstration environment, **When** the demonstrator follows the security journey, **Then** they create a user, obtain an API key, obtain a JWT through valid credentials, and observe rejection of an invalid credential without exposing stored credential material.
3. **Given** either issued credential form, **When** the demonstrator follows the catalog journey, **Then** they can list players, retrieve a player, apply league, team, and position filters, and observe the documented unauthenticated and invalid-input outcomes.
4. **Given** the published documentation, **When** the demonstrator follows the contract journey, **Then** they can find the OpenAPI 3 description, open the interactive documentation without a credential, and execute a protected catalog request with each supported credential form.
5. **Given** the demo has completed once, **When** its documented reset or repeat procedure is followed, **Then** it can run again with the same expected outcomes and without duplicate seed-owned catalog data.

---

### User Story 3 - Re-run Verification and Preserve Honest Results (Priority: P3)

As a contributor, I can execute the documented local verification sequence and refresh the acceptance record so that evidence remains current, safe, and attributable when the candidate revision changes.

**Why this priority**: Acceptance evidence becomes misleading if it cannot be regenerated or if results from different source states are combined.

**Independent Test**: Run the documented checks for a candidate revision, change the candidate revision or force one controlled check to fail, and verify that stale or failing evidence cannot yield a passing record.

**Acceptance Scenarios**:

1. **Given** the supported local environment, **When** the verification sequence runs, **Then** formatting, warnings-as-errors compilation, unit tests, integration tests, coverage reporting, and the CP1 demonstration each expose an unambiguous result.
2. **Given** a failed, skipped, interrupted, undiscovered, or unavailable required check, **When** evidence is recorded, **Then** it is shown as non-passing rather than omitted or inferred successful.
3. **Given** the candidate revision changes after evidence was collected, **When** the acceptance record is evaluated, **Then** revision-bound evidence from the prior candidate is marked stale and cannot support a passing result.
4. **Given** verification or demonstration output is retained or linked, **When** it is inspected, **Then** it contains no raw password, API-key secret, JWT, credential-verification material, or other production secret.

### Edge Cases

- Exactly 9 unresolved SonarCloud issues satisfies CP1; 10 does not.
- A green automated run for an older commit, another branch, or only a subset of required checks cannot establish acceptance for the candidate revision.
- A canceled, skipped, timed-out, inaccessible, unpublished, or manually asserted check is unverified and therefore non-passing.
- Hosted evidence may require normal repository authorization, but links must not depend on one person's local filesystem or private browser session.
- Evidence generated from a working-tree snapshot must be labelled as such and cannot be represented as evidence for a committed revision unless their identities match by the established provenance rules.
- Existing local data must not make the demo appear successful when preparation, user creation, key issuance, or seed idempotency is broken.
- Repeating user creation with the same identity may exercise the documented duplicate-user rejection; repeatability may use a fresh documented identity while catalog seeding remains idempotent.
- Expected authentication and validation failures are successful demo observations only when their exact public outcomes match the governing CP1 contracts.
- If a credential or secret appears in retained evidence, that evidence is unsafe, must not be linked as acceptance proof, and the affected verification is non-passing.
- Provider or network unavailability must not prevent locally persisted catalog reads; hosted quality evidence that genuinely requires its service must fail visibly when unavailable.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST provide one discoverable CP1 acceptance record and one ordered repeatable demonstration guide for the candidate revision.
- **FR-002**: The acceptance record MUST identify the candidate revision, evidence collection date, overall result, and the reviewer-visible status of every individual CP1 obligation.
- **FR-003**: The acceptance record MUST include a traceability entry for each of these CP1 obligations: accessible GitHub repository; green automated quality build; fewer than 10 unresolved SonarCloud issues; JWT issuance and validation; valid OpenAPI 3 documentation; minimum persisted catalog model; unit-test execution; user creation; API-key creation and lifecycle; and authenticated player catalog list, detail, and filtering.
- **FR-004**: Each traceability entry MUST state an unambiguous acceptance criterion, observed result, pass or non-pass outcome, applicable candidate revision or snapshot identity, and a direct link or repository-relative reference to reproducible evidence.
- **FR-005**: The overall CP1 result MUST pass only when every traceability entry passes for the same candidate revision and all required evidence is current, accessible to the intended reviewer, and safe to retain.
- **FR-006**: Failed, skipped, interrupted, canceled, timed-out, undiscovered, unavailable, inaccessible, stale, or unpublished verification MUST be recorded as non-passing; absence of evidence MUST NOT be treated as success.
- **FR-007**: The automated quality-build evidence MUST show that formatting, warnings-as-errors compilation, and the complete unit profile passed for the candidate revision.
- **FR-008**: The SonarCloud evidence MUST identify the candidate revision, show a completed published analysis, and report between 0 and 9 unresolved issues inclusive. Ten or more issues, an incomplete analysis, or an unpublished result MUST be non-passing.
- **FR-009**: The automated test evidence MUST separately report the complete unit and integration profiles and MUST link the current coverage report with its declared revision or working-tree snapshot provenance and source scope.
- **FR-010**: The minimum-model evidence MUST demonstrate the persisted league, season, team, position, and player relationships and constraints required by TASK-005, using representative deterministic data across all five supported leagues.
- **FR-011**: The security demonstration MUST show successful validated user creation, one-time API-key issuance and subsequent verification, JWT issuance from valid credentials, protected access with each credential form, revocation behavior, and generic rejection of invalid or revoked credentials, without disclosing stored verification material.
- **FR-012**: The catalog demonstration MUST show authenticated list and detail reads, bounded continuation, and league, team, and position filters individually and in combination, including at least one empty valid result and one documented invalid-input result.
- **FR-013**: The contract demonstration MUST show that unauthenticated readers can access a valid OpenAPI 3 machine-readable description and interactive documentation, find the supported protected catalog operations and both alternative credential forms, and execute a protected catalog request with each credential form.
- **FR-014**: The demonstration guide MUST state prerequisites, clean starting conditions, preparation and deterministic seed steps, ordered commands or actions, expected observable outcomes, evidence capture locations, reset or repeat steps, and safe troubleshooting guidance.
- **FR-015**: A contributor using only repository documentation and the declared prerequisites MUST be able to run the local verification and demonstration without production credentials, production data, live football-provider access, manual source edits, or undocumented machine state.
- **FR-016**: Demonstration preparation MUST be repeatable. Re-running seed preparation MUST preserve the seed-owned dataset without duplicates, and the guide MUST explain how repeat executions use or create suitable demonstration users and credentials.
- **FR-017**: Every retained or linked local artifact MUST be attributable to the tested revision or explicitly identified working-tree snapshot. Evidence from another source state MUST be marked stale and MUST NOT support the current overall result.
- **FR-018**: Acceptance artifacts and retained outputs MUST NOT contain raw passwords, API-key secrets, JWTs, credential-verification material, test verification material, production secrets, or private provider payloads. A failed safety check MUST invalidate the affected evidence.
- **FR-019**: Links MUST target durable hosted results or version-controlled repository-relative artifacts and MUST describe any normal authorization needed to open them. Machine-specific absolute paths and ephemeral private-session links MUST NOT be the only evidence for an obligation.
- **FR-020**: The acceptance record MUST distinguish automated proof, demonstrated observation, and external hosted evidence so reviewers can judge the strength and reproducibility of each claim.
- **FR-021**: This feature MUST verify and document existing CP1 behavior without changing authentication policy, catalog contracts, persistent domain rules, quality thresholds, coverage policy, provider behavior, or any post-CP1 product capability.

### Key Entities

- **Candidate Revision**: The committed source state proposed for CP1 acceptance and used to correlate hosted and local evidence.
- **Acceptance Record**: The single revision-bound checkpoint decision document containing all CP1 traceability entries and the overall result.
- **Traceability Entry**: One CP1 obligation mapped to its acceptance criterion, observed result, evidence references, provenance, and outcome.
- **Evidence Reference**: A durable hosted link or repository-relative artifact that supports a traceability entry without containing secret material.
- **Demonstration Guide**: The ordered, repeatable procedure for preparing, exercising, observing, and resetting the CP1 journeys.
- **Verification Snapshot**: A committed revision or explicitly labelled working-tree state to which local results and coverage evidence are bound.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The acceptance record maps 100% of the ten CP1 obligations enumerated in FR-003 to an explicit criterion, observed result, outcome, provenance, and at least one usable evidence reference.
- **SC-002**: For the accepted candidate revision, 100% of required automated quality categories, unit and integration profiles, and documented CP1 demonstration steps complete successfully with no skipped or undiscovered required check.
- **SC-003**: The governing SonarCloud result for the candidate revision reports 0–9 unresolved issues, and reviewers can reach both it and the green automated quality run from the acceptance record in no more than two navigation actions per result.
- **SC-004**: A contributor familiar with the repository can complete the full local CP1 demonstration from its documented clean starting state within 20 minutes after declared prerequisites are available, using only the guide.
- **SC-005**: In two consecutive demonstration runs, all required journeys produce their documented outcomes, seed-owned catalog counts and relationships remain unchanged after the first preparation, and no manual source edit is required.
- **SC-006**: The demonstration exercises both supported credential forms, all five supported leagues, all three catalog filters singly and in combination, list and detail access, and at least one specified authentication and catalog-input rejection.
- **SC-007**: Changing the candidate revision or forcing any one required check to fail causes the overall result to become non-passing in 100% of controlled acceptance evaluations until current passing evidence replaces it.
- **SC-008**: Inspection of version-controlled acceptance artifacts and retained verification output finds zero raw passwords, API-key secrets, JWTs, credential-verification values, test verification values, production secrets, or private provider payloads.
- **SC-009**: A checkpoint reviewer can determine the overall CP1 result, identify any non-passing obligation, and locate its supporting evidence from the acceptance record within five minutes without undocumented assistance.

## Assumptions

- TASK-001 through TASK-014 define and implement the CP1 capabilities and their detailed behavioral contracts; this task aggregates verification and does not supersede those specifications.
- The ten traceability obligations in FR-003 are the complete CP1 acceptance scope derived from `docs/CHECKPOINTS.md`; coverage reporting and separate integration execution support confidence but remain informational rather than new checkpoint thresholds.
- The candidate revision is a commit reachable in the shared GitHub repository. Local pre-commit coverage may be useful supporting evidence only when its working-tree provenance is explicit.
- Authorized checkpoint reviewers have ordinary access to the repository, automated build results, and SonarCloud project; acceptance artifacts do not grant or broaden permissions.
- Deterministic development seed data from TASK-006 is the default catalog dataset for the repeatable demonstration.
- Expected public behavior, response shapes, error precedence, credential handling, and performance boundaries remain governed by the prerequisite task specifications.
- The acceptance record may reference evidence generated by several checks, but all revision-bound evidence must resolve to the same candidate revision before the overall result can pass.

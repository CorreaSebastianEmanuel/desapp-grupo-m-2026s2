# Feature Specification: Phoenix Project Foundation

**Feature Branch**: `main`

**Created**: 2026-09-08

**Status**: Review Ready

**Input**: User description: "TASK-001 Phoenix project foundation — Create a compiling Phoenix application with a minimal test baseline and documented local startup."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Verify a Buildable Foundation (Priority: P1)

As a contributor, I can obtain the project and run its standard compilation check so that I know the shared application foundation is valid before adding product features.

**Why this priority**: Every later checkpoint capability depends on contributors having a valid application foundation.

**Independent Test**: From a clean project checkout with the documented prerequisites available, run the documented preparation and compilation commands and confirm that they complete successfully without manual source changes.

**Acceptance Scenarios**:

1. **Given** a clean checkout and the documented prerequisite software, **When** a contributor follows the documented preparation steps and invokes the standard compilation check, **Then** the application compiles successfully without source changes.
2. **Given** the prepared project, **When** compilation is repeated without source changes, **Then** it remains successful and requires no undocumented setup.

---

### User Story 2 - Run the Minimal Test Baseline (Priority: P2)

As a contributor, I can run one documented automated test command and receive an unambiguous successful result so that future behavior can be developed against a trusted baseline.

**Why this priority**: A passing baseline distinguishes foundation defects from regressions introduced by later tasks.

**Independent Test**: Execute the documented test command in a prepared clean checkout and verify that at least one meaningful application test is discovered, executed, and passes.

**Acceptance Scenarios**:

1. **Given** a prepared clean checkout, **When** a contributor runs the documented test command, **Then** at least one meaningful test executes and the command exits successfully with zero failures.
2. **Given** an intentionally failing assertion in a temporary local test change, **When** the same test command runs, **Then** it reports the failure and exits unsuccessfully, demonstrating that the baseline can detect regressions.

---

### User Story 3 - Start the Application Locally (Priority: P3)

As a new contributor, I can follow the repository documentation to start the application locally and confirm that it is reachable, so that I can begin development without relying on undocumented team knowledge.

**Why this priority**: Local startup is necessary for productive development, but it depends on the buildable and testable foundation.

**Independent Test**: A contributor unfamiliar with the repository follows only the startup documentation, starts the application, and reaches the documented local address.

**Acceptance Scenarios**:

1. **Given** a clean checkout and documented prerequisites, **When** a contributor follows the local startup instructions exactly, **Then** the application starts without source changes and exposes a reachable default page at the documented address.
2. **Given** the application is running, **When** the contributor stops it using the documented method, **Then** it terminates cleanly and can be started again by repeating the same instructions.

### Edge Cases

- If a prerequisite is absent or unsupported, the startup documentation identifies it before the contributor attempts to compile or run the application.
- If preparation, compilation, testing, or startup fails, the command returns a non-success result or a visible diagnostic rather than appearing successful.
- The documented workflow must work from a clean checkout and must not depend on untracked files, machine-specific absolute paths, credentials, or prior application state.
- If no external data services are available, the documented foundation workflow remains bounded to this task; provisioning PostgreSQL and Redis belongs to TASK-002.
- Generated artifacts and downloaded dependencies must not be required in version control for another contributor to reproduce the workflow.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The repository MUST contain one coherent application foundation that can be prepared and compiled from a clean checkout using documented commands.
- **FR-002**: The standard compilation command MUST complete successfully with no compilation errors on the documented supported local environment.
- **FR-003**: The repository MUST provide one standard automated test command that discovers and executes at least one meaningful application test.
- **FR-004**: The initial automated test baseline MUST complete with zero failures and MUST return an unsuccessful result when a test assertion fails.
- **FR-005**: The repository MUST document all prerequisite software needed for preparation, compilation, testing, and local startup, including supported versions or version ranges where compatibility matters.
- **FR-006**: The repository MUST document, in execution order, the commands needed to prepare, compile, test, start, verify, and stop the application locally.
- **FR-007**: Following only the documented instructions from a clean checkout MUST result in a running application reachable at a documented local address.
- **FR-008**: The foundation MUST not implement player catalog, authentication, API keys, trading, valuation, background processing, caching, external-provider integration, or other later-backlog behavior.
- **FR-009**: The foundation MUST preserve the project-wide separation expected among presentation, domain, persistence, background-work, cache, and external-adapter responsibilities, without prematurely adding behavior to those areas.
- **FR-010**: The foundation workflow MUST not require credentials, committed generated artifacts, or machine-specific absolute paths.
- **FR-011**: Failures during preparation, compilation, testing, or startup MUST be observable through a non-success command result or a clear diagnostic message.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 100% of clean-checkout verification attempts on the documented supported environment, contributors can complete preparation and compilation without modifying source files.
- **SC-002**: The complete baseline automated test suite executes at least one meaningful test and finishes with zero failures.
- **SC-003**: A new contributor can start the application and reach the documented local address within 10 minutes after prerequisites are installed, using only repository documentation.
- **SC-004**: A deliberately failing test is detected in 100% of verification attempts and causes the standard test command to report failure.
- **SC-005**: A reviewer can locate documented commands for all six lifecycle actions—prepare, compile, test, start, verify reachability, and stop—with no undocumented step required.
- **SC-006**: Review finds zero implemented business capabilities from later backlog tasks in the foundation scope.

## Assumptions

- The intended application platform is the single modular Elixir/Phoenix application mandated by `docs/ARCHITECTURE.md`; this is a project constraint, not a new behavioral choice introduced by this specification.
- Contributors run the documented workflow on a development machine capable of installing the declared prerequisite software and binding a local network port.
- This task establishes only the application, compilation, test, and startup baseline. PostgreSQL and Redis provisioning is deferred to TASK-002; continuous integration is deferred to TASK-003.
- The default generated page is sufficient evidence of reachability for this foundation task; product-specific screens and endpoints are outside scope.
- No domain entities or persistent business data are introduced by this feature.

# Tasks: Phoenix Project Foundation

**Input**: Design artifacts in `specs/001-phoenix-project-foundation/`

**Scope**: TASK-001 only. PostgreSQL/Redis activation belongs to TASK-002, CI to TASK-003, and product capabilities to later backlog tasks.

**Test policy**: Automated tests and executed lifecycle evidence are mandatory under the specification and constitution. Story-specific tests are ordered before the behavior they prove where practical.

## Pre-Generation Checks Performed

The task design was checked against `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, `docs/CHECKPOINTS.md`, `.specify/memory/constitution.md`, `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/foundation-http.md`, `quickstart.md`, ADR-001, the TASK-001 backlog record, all three handoffs, and the existing requirements checklist. The active run records no human feedback, so no human override had to be incorporated.

### Requirements and consistency analysis

| Concern | Result | Task consequence |
|---|---|---|
| Product invariants | Preserved: this feature creates no domain data, money, quotes, tokens, trades, or audit records. | T005 and T019 explicitly reject later-backlog behavior and persistence activation. |
| Architecture | Aligned with one root Phoenix modular monolith and web/domain/persistence separation. ADR-001 makes deferred Repo supervision durable. | T003–T005 retain Ecto-ready plumbing without database contact or speculative layers. |
| CP1 coverage | TASK-001 supplies only the compiling/testable repository foundation. CI, SonarCloud, JWT, OpenAPI, models, users/API keys, and catalog remain assigned to TASK-003–TASK-015. | T019 records checkpoint evidence without claiming full CP1 completion. |
| Testability | Each story has an executable independent oracle. The meaningful test crosses the Phoenix endpoint and asserts status plus owned marker. | T009 is written and observed failing before T010; T011 proves the runner detects a disposable failure. |
| Security | No credentials, `.env`, externally bound development server, dashboard, mailer, or unnecessary operational surface is permitted. Dependencies are locked. | T004, T005, and T018 enforce safe defaults and review them. |
| Failure behavior | Finite preparation, compilation, tests, and probes must fail nonzero; readiness and shutdown are bounded. | T006, T013–T017 exercise unsupported tools, missing dependencies, occupied port, unhealthy HTTP, shutdown, and restart behavior. |
| Artifact alignment | Spec, plan, contract, quickstart, ADR, and handoffs agree on database-independent startup and the `Football Player Market` oracle. | No behavioral planning edit was required before task generation. |

### Resolutions and remaining risks

- **Resolved in existing planning artifacts**: ADR-001 resolves the architecture baseline versus TASK-002 ownership by retaining `FootballMarket.Repo` but excluding it from supervision in TASK-001.
- **Resolved in existing planning artifacts**: “clean checkout,” supported versions, meaningful testing, HTTP readiness, shutdown, restart, generated component limits, and allowed network/cache state all have objective oracles.
- **Remaining low risk — workflow metadata**: `spec.md` names `main`, while `plan.md` names `001-phoenix-project-foundation` and the working branch may be created later by Agentflow. Implementation must use the run-selected feature branch and must not interpret the spec header as permission to implement directly on `main`.
- **Remaining medium risk — exact toolchain availability**: Elixir 1.20.3/OTP 29.0.3/Phoenix 1.8.13 may not be installed on every contributor machine. T001 must fail clearly rather than silently broaden the claimed matrix.
- **Remaining medium risk — generator drift**: generated Phoenix output can change. T002 and T005 require explicit review against the allowed component list instead of accepting generator defaults wholesale.
- **Remaining low risk — platform breadth**: local validation covers the documented macOS/Linux baseline; a wider OS/version matrix remains TASK-003 work.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish reproducible tooling and the minimal root application skeleton without implementing a user-story outcome.

- [ ] T001 Validate and document the exact Erlang/OTP 29.0.3, Elixir 1.20.3, Mix/Hex/Rebar, and Phoenix phx_new 1.8.13 prerequisites with nonzero mismatch behavior in README.md
- [ ] T002 Generate and integrate the root `football_market` / `FootballMarket` Phoenix application while preserving repository governance files, excluding mailer and LiveDashboard, and creating mix.exs, mix.lock, config/, lib/, assets/, priv/static/, and test/
- [ ] T003 Configure the standard formatter and compiler paths for the root application in .formatter.exs and mix.exs

**Checkpoint**: The repository contains one coherent Phoenix project with pinned dependencies and no product behavior.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Apply the architectural, service-independence, and security boundaries required by every story.

**Critical**: Complete this phase before story work.

- [ ] T004 Configure the development endpoint to bind only to 127.0.0.1:4000 and keep secrets development-scoped with no credential requirement in config/dev.exs and config/runtime.exs
- [ ] T005 Retain the inert FootballMarket.Repo contract but remove Repo supervision and all startup database contact, while excluding Oban, Redis, OpenAPI, JWT/authentication, provider, catalog, valuation, trading, audit, mailer, and dashboard behavior in lib/football_market/repo.ex, lib/football_market/application.ex, and mix.exs
- [ ] T006 Add a reusable bounded HTTP oracle that retries for at most 30 seconds, requires status 200 plus `Football Player Market`, and exits nonzero for timeout, bad status, missing marker, or connection failure in scripts/verify_foundation.sh
- [ ] T007 [P] Configure generated and downloaded build outputs, dependencies, local environment files, and credentials to remain untracked in .gitignore
- [ ] T008 [P] Preserve presentation-only routing and document future domain-context placement without creating empty domain, worker, cache, or adapter modules in lib/football_market_web/router.ex and specs/001-phoenix-project-foundation/adrs/001-defer-repository-activation.md

**Checkpoint**: The app can implement all three stories without PostgreSQL, Redis, credentials, or architectural leakage.

---

## Phase 3: User Story 1 — Verify a Buildable Foundation (Priority: P1) MVP

**Goal**: A contributor can prepare and compile a clean checkout through documented, repeatable commands.

**Independent Test**: In a fresh checkout without `_build/`, `deps/`, or generated asset output, follow README preparation and run `mix compile --warnings-as-errors` twice; both compilation runs exit zero without source changes or implicit dependency fetching.

- [ ] T009 [US1] Document the ordered prepare and warnings-as-errors compile commands, including network boundaries and clear missing-tool/dependency failure expectations, in README.md
- [ ] T010 [US1] Execute preparation followed by two successful `mix compile --warnings-as-errors` runs from the clean-checkout fixture and record commands, versions, exit statuses, and absence of source changes in specs/001-phoenix-project-foundation/handoffs/implementation-evidence.md

**Checkpoint**: User Story 1 is independently demonstrable and is the smallest deliverable MVP.

---

## Phase 4: User Story 2 — Run the Minimal Test Baseline (Priority: P2)

**Goal**: The standard test command runs a meaningful application-boundary test and visibly detects regressions.

**Independent Test**: `mix test` discovers an endpoint test that requires HTTP 200 and `Football Player Market`; it passes in the implementation checkout, while a disposable assertion mutation makes the same command exit nonzero.

### Tests first

- [ ] T011 [US2] Write the initially failing endpoint contract test for status 200 and the `Football Player Market` marker in test/football_market_web/controllers/page_controller_test.exs

### Implementation

- [ ] T012 [US2] Implement the public GET / route and application-owned default page marker without persistence access in lib/football_market_web/router.ex, lib/football_market_web/controllers/page_controller.ex, and lib/football_market_web/controllers/page_html/home.html.heex
- [ ] T013 [US2] Configure database-free ConnCase support and the standard ExUnit entry point in test/support/conn_case.ex and test/test_helper.exs
- [ ] T014 [US2] Run `mix test`, then prove a disposable wrong-marker assertion exits nonzero without modifying the implementation worktree, and record both results in specs/001-phoenix-project-foundation/handoffs/implementation-evidence.md

**Checkpoint**: User Story 2 passes independently and demonstrates that its baseline catches an application regression.

---

## Phase 5: User Story 3 — Start the Application Locally (Priority: P3)

**Goal**: A new contributor can start, verify, stop, and restart the application from repository documentation with no external services.

**Independent Test**: With PostgreSQL and Redis unavailable, follow only README instructions to start the app, satisfy the bounded real-HTTP contract, interrupt it, observe exit and released port within 10 seconds, restart successfully, and stop again.

### Verification first

- [ ] T015 [US3] Add shell-level verification coverage for successful readiness, 30-second timeout, bad status or missing marker, occupied port, and post-stop connection failure in test/scripts/verify_foundation_test.sh

### Documentation and runtime integration

- [ ] T016 [US3] Document exact start, bounded reachability, foreground stop, 10-second shutdown, released-port confirmation, restart, and common failure commands in README.md
- [ ] T017 [US3] Execute the documented start-probe-stop-restart-stop lifecycle with PostgreSQL and Redis unavailable and record HTTP status, marker, readiness time, shutdown time, released-port result, restart result, and exit statuses in specs/001-phoenix-project-foundation/handoffs/implementation-evidence.md

**Checkpoint**: User Story 3 is independently usable and all three contributor journeys are complete.

---

## Phase 6: Polish, Documentation, and Verification

**Purpose**: Close cross-cutting quality, scope, and review obligations without expanding TASK-001.

- [ ] T018 [P] Review tracked files for credentials, machine-specific absolute paths, non-loopback binding, accidental dashboards, and unlocked dependencies, and record findings in specs/001-phoenix-project-foundation/handoffs/implementation-evidence.md
- [ ] T019 [P] Review the implementation for zero domain entities, migrations, Repo supervision, external services, and later-backlog capabilities, and map delivered evidence to TASK-001 plus its limited CP1 contribution in specs/001-phoenix-project-foundation/handoffs/implementation-evidence.md
- [ ] T020 Run mix format --check-formatted, mix compile --warnings-as-errors, mix test, test/scripts/verify_foundation_test.sh, and the full quickstart.md isolated-checkout lifecycle, recording exact outputs and failures in specs/001-phoenix-project-foundation/handoffs/implementation-evidence.md
- [ ] T021 Obtain independent QA and final review reports that each end exactly with `Verdict: PASS`, linking their evidence and any remaining risks in specs/001-phoenix-project-foundation/handoffs/verification.md and specs/001-phoenix-project-foundation/handoffs/review.md

---

## Dependencies and Execution Order

### Phase dependencies

- Phase 1 has no implementation dependency.
- Phase 2 depends on the generated root project from Phase 1 and blocks every user story.
- US1, US2, and US3 all depend on Phase 2. Execute them in priority order for incremental delivery; US1 and the initial US2 test may proceed in parallel only after the foundational file ownership is settled.
- US3 depends on US2's stable page contract because its real-HTTP probe uses the same marker.
- Phase 6 depends on all selected stories. T018 and T019 may run in parallel; T020 follows all implementation and documentation tasks; T021 follows successful T020 evidence.

### Story dependency graph

```text
Setup -> Foundation -> US1
                    -> US2 -> US3
US1 + US2 + US3 -> Cross-cutting verification -> Independent QA -> Final review
```

### Sequencing decisions

- Generator integration precedes tests because no executable Phoenix test harness exists before the project skeleton.
- Within US2, the endpoint contract test is created and observed failing before the owned page marker is implemented.
- The real-runtime shell checks are created before README lifecycle acceptance is claimed.
- Evidence tasks run commands; documentation or source inspection alone never establishes a pass.
- QA and final review remain independent and do not modify implementation, per the constitution.

## Parallel Opportunities

- T007 and T008 can run concurrently after T002 because they affect separate files and enforce independent concerns.
- After Phase 2, T009 can proceed independently of T011 because README compilation guidance and the endpoint test touch different files.
- T018 and T019 can run concurrently after implementation because they inspect security/supply-chain concerns and domain/scope boundaries separately.
- Independent reviewers may prepare their environments early, but final QA must consume T020 evidence and final review must follow QA.

## Parallel Examples

### User Story 1 and User Story 2 start

```text
Task T009: document clean preparation and compilation in README.md
Task T011: write the failing endpoint contract in test/football_market_web/controllers/page_controller_test.exs
```

### Cross-cutting review

```text
Task T018: inspect security and reproducibility constraints
Task T019: inspect architecture, product-invariant, checkpoint, and scope constraints
```

## Implementation Strategy

### MVP first

1. Complete Setup and Foundational phases.
2. Complete US1 and reproduce compilation from the defined clean fixture.
3. Stop and independently validate the buildable foundation before adding runtime behavior.

### Incremental delivery

1. Add US2 as the regression-detecting web-boundary baseline.
2. Add US3 as the documented real-runtime lifecycle using the same contract oracle.
3. Complete security/scope reviews and the full command suite.
4. Hand the unchanged implementation to independent QA and final review; completion requires both exact PASS verdicts.

## Implementation Guidance

- Preserve existing human changes and repository governance files when integrating generated output.
- Keep `FootballMarket.Repo` inert but coherent for TASK-002; do not validate database connectivity in TASK-001.
- Use integer/status/time comparisons only here; do not introduce domain money or quote representations.
- The readiness script must use bounded retries and reliable nonzero exits. It must not start services or accept a generic Phoenix error page.
- Disposable regression proof must occur outside the implementation worktree or restore only its own temporary copy; do not use destructive Git cleanup.
- If the pinned toolchain or package network is unavailable, record a visible blocked result instead of weakening versions or claiming verification.
- Every completed task should leave its named file(s) sufficient for the next task without relying on untracked local state.

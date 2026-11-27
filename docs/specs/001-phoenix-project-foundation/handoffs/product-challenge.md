# Product Challenge: Phoenix Project Foundation

## Dissenting assessment

The foundation outcome is reasonable, but the current specification is not yet fully testable. Its most important promise—startup from a clean checkout—depends on an unresolved database choice that the product handoff explicitly delegates to architecture. Several success criteria also use undefined populations or subjective terms, so a passing implementation could be either genuinely useful or nearly vacuous. These are planning risks, not reasons to add later product capabilities.

No human feedback has been recorded for the active run. This review therefore cannot treat any disputed interpretation as human-approved.

## Findings and recommendations

### 1. Clean startup and the TASK-002 boundary are in direct tension

**Evidence:** US3, FR-007, and SC-003 require a running, reachable application from a clean checkout. The edge cases and assumptions defer PostgreSQL and Redis provisioning to TASK-002. The product handoff leaves repository-backed startup unresolved. A normal Phoenix/Ecto endpoint may boot without a live repository until a request touches it, or it may fail during startup or on the default route depending on supervision and generated code. Consequently, “reachable” does not establish that the application is healthy, and the same spec permits materially different foundations.

**Recommendation to the architect:** Make one explicit, testable choice in the plan:

- Prefer a foundation whose default route and startup do not require PostgreSQL, while retaining Ecto dependencies/configuration for TASK-002; or
- Declare PostgreSQL a startup prerequisite and move/provide the minimum environment under TASK-001, with an explicit dependency/boundary adjustment approved by the human.

Do not adopt the ambiguous middle ground where the endpoint boots but requests fail because the repository is unavailable. Redis should remain absent from the runtime path for this task.

### 2. “Clean checkout” and “prepared clean checkout” are not operationally defined

**Evidence:** US1 alternates between a clean checkout and a “prepared project”; US2 assumes a “prepared clean checkout.” FR-001, FR-007, SC-001, and SC-003 do not define whether package caches, downloaded Hex/Rebar tooling, compiled dependencies, environment variables, or an existing database are allowed. The edge cases prohibit prior application state but not prior tool or dependency state.

**Recommendation to the architect:** Define the verification fixture in the plan: fresh repository clone, empty project build/dependency directories, permitted global tools, required network access, allowed caches, environment variables, and service state. Use a temporary clone or equivalent ignored-artifact cleanup for evidence. Keep dependency downloading in “prepare,” not compilation or startup, so phase failures are attributable.

### 3. The supported environment is deferred too late and can make every percentage claim meaningless

**Evidence:** FR-005 requires supported versions or ranges, but the specification does not name an OS, OTP, Elixir, Phoenix, or package-manager baseline. SC-001 and SC-004 claim success in 100% of attempts without defining the attempt population or minimum repetitions. SC-003’s ten-minute limit starts only after prerequisites are installed and therefore excludes the largest onboarding cost.

**Recommendation to the architect:** Select a narrow compatibility matrix before implementation (at minimum OS scope plus exact or bounded OTP, Elixir, and Phoenix versions). Translate “100%” into deterministic checks over that matrix and state how many clean runs constitute evidence. Treat the ten-minute measure as a timed documentation smoke test, not a broad reliability statistic. If only one local platform is supported in TASK-001, say so and leave broader support to a later task rather than implying portability.

### 4. “Meaningful application test” is subjective and permits a vacuous baseline

**Evidence:** US2, FR-003, SC-002, and the product handoff require at least one meaningful test but give no observable minimum. A test of `1 + 1`, a generated placeholder, or merely asserting HTTP 200 could all be defended. The deliberate-failure scenario proves the runner exits nonzero, not that the baseline detects application regressions.

**Recommendation to the architect:** Define “meaningful” in the plan as exercising the shipped application surface through its public web boundary and asserting both status and a stable, application-owned response marker. The regression demonstration should mutate a copy or temporary assertion and must leave the worktree unchanged afterward. Avoid adding domain logic merely to create something to test.

### 5. Reachability and clean shutdown lack observable criteria

**Evidence:** “Reachable default page,” “starts,” and “terminates cleanly” in US3 have no protocol, status, response expectation, readiness timeout, shutdown timeout, signal, or post-stop check. A Phoenix error page can be reachable; a process can print shutdown noise while leaving its port occupied.

**Recommendation to the architect:** Map startup verification to a bounded HTTP probe of the documented loopback URL that asserts an expected success status and stable response marker. Define readiness timeout. Define stop as the documented foreground interrupt or explicit process signal, followed by bounded process exit and confirmation that the listening port is released; verify a subsequent restart.

### 6. Failure visibility is too weak to be useful

**Evidence:** FR-011 permits either a non-success result *or* a “clear diagnostic.” A command could exit successfully after a serious failure if it emits a message, contradicting the edge-case expectation that failures not appear successful. Startup is long-running, so its success/failure semantics also differ from prepare, compile, and test.

**Recommendation to the architect:** Require finite prepare, compile, test, and reachability commands to return nonzero on failure. For the long-running server, require startup failure to terminate nonzero or remain observably unhealthy so the bounded probe fails. Diagnostics should supplement exit status, not substitute for it.

### 7. FR-009 is untestable and risks speculative scaffolding

**Evidence:** FR-009 says the foundation must “preserve” separation among six responsibility areas while FR-008 forbids implementing their behavior. There may be nothing in most of those areas to inspect. The architecture and constitution demand boundaries when responsibilities exist; they do not require empty modules or directories.

**Recommendation to the architect:** Interpret FR-009 as a negative review constraint: generated web concerns must not contain business, persistence, worker, cache, or adapter behavior. Do not scaffold empty contexts, adapters, workers, cache abstractions, or domain layers to manufacture evidence. Record future module placement in the plan only where it constrains today’s project/module naming.

### 8. Scope exclusions need a sharper generated-code rule

**Evidence:** FR-008 excludes authentication, background processing, caching, and other later behavior, while the architecture baseline names Ecto, Oban, Redis, Telemetry/Prometheus, REST/OpenAPI, and LiveView. A generated Phoenix project can legitimately include Ecto, LiveView, telemetry, mailer, asset, or dashboard plumbing even when the feature does not expose business capabilities. SC-006’s phrase “zero implemented business capabilities” does not distinguish inert framework plumbing from prematurely operational infrastructure.

**Recommendation to the architect:** Allow only framework plumbing necessary for compilation and the chosen default page; justify any retained generated component by current use or near-term CP1 compatibility. Exclude Oban, Redis clients, provider adapters, JWT/OpenAPI features, catalog concepts, and product entities. Credible alternatives are (a) a minimal generator profile with later additions, lowering current complexity, or (b) selected standard Phoenix components retained to reduce churn; if choosing (b), enumerate them and confirm they do not create runtime service dependencies.

### 9. Security expectations for a development server are implicit

**Evidence:** FR-010 prohibits credentials and machine-specific paths, but nothing constrains network binding, committed secrets, development-only dashboards, debug information, host/origin settings, dependency integrity, or generated secret handling. “Documented local address” could be loopback or all interfaces. The constitution prohibits exposing secrets, and CP3 later requires security hardening, but unsafe defaults should not be normalized in the foundation.

**Recommendation to the architect:** Bind the documented development endpoint to loopback by default; keep generated secrets demonstrably non-production and environment-scoped; commit no credentials; do not expose dashboards or debug endpoints beyond development; and pin dependencies through the ecosystem lockfile. Document any dependency download/network requirement. Do not pull TASK-050 hardening into scope, but establish defaults that do not knowingly expose the developer machine.

### 10. CP1 compatibility is asserted but not evidenced

**Evidence:** CHECKPOINTS requires a GitHub repository, green Actions build, SonarCloud, JWT, OpenAPI 3, a minimum model, tests, user/API-key creation, and catalog by 2026-09-29. TASK-001 properly defers most of these, but neither the spec nor handoff identifies which foundation decisions later CP1 tasks rely on. The specification header also says `Feature Branch: main`, while the Agentflow governance describes generated feature branches; this is misleading provenance even if it has no runtime effect.

**Recommendation to the architect:** Add a short dependency-compatibility section to the plan mapping project/module naming, test command, formatting/config conventions, and directory boundaries to TASK-002 and TASK-003–015 without implementing them. Treat the branch label as workflow metadata to verify, not a product requirement. Flag conflicts early rather than expanding TASK-001 to satisfy all of CP1.

### 11. Documentation-only acceptance is vulnerable to self-confirmation

**Evidence:** SC-005 asks only whether commands can be located; US3 claims that a contributor unfamiliar with the repository can follow them. The constitution requires executed evidence. A maintainer executing instructions on the machine used to author them does not test missing assumptions.

**Recommendation to the architect:** Require a reviewer-executable lifecycle script or exact command sequence and capture results from an isolated checkout. Preserve manual documentation readability, but use commands as the source of reproducible evidence. A second-person usability study is unnecessary for this small task; an independent reviewer following only the README is the proportionate alternative.

## Boundary cases the plan must cover

- The documented port is already occupied.
- Dependency download is unavailable or a package cannot be resolved.
- A required tool exists but is outside the supported version range.
- Build artifacts or dependencies from a prior run are absent.
- PostgreSQL and Redis are both unavailable.
- The server process starts, but the default request returns an error response.
- The server becomes ready slowly and the probe times out.
- Shutdown occurs during a request, or the process exits while a child process retains the port.
- The lifecycle is repeated without source changes and without relying on a previously running process.

The documentation need not solve every environmental failure, but it must expose each relevant failure unambiguously and avoid claiming successful startup when the application is unhealthy.

## Architect decision gate

Architecture should not proceed on an implicit database assumption. Before implementation, the plan should explicitly record: (1) whether TASK-001 startup is database-independent, (2) the supported environment and clean-checkout fixture, (3) the concrete meaningful-test oracle, (4) HTTP readiness and shutdown oracles, and (5) the allowed generated Phoenix components. These decisions resolve the current ambiguities without enlarging the product scope or creating a second specification.

# Feature Specification: Agentflow Preflight and Failure Recovery

**Feature Branch**: `070-agentflow-preflight-and-efficient-failure-recovery`

**Created**: 2026-10-24

**Status**: Draft

**Input**: TASK-070 — Run a deterministic, non-destructive preflight for the effective child environment before start or resume; emit actionable safe failure diagnostics and partial QA reports; continue independent checks after isolated failures while enforcing the same-input retry limit; align feedback-cycle governance; audit and remove avoidable duplicate local full-profile executions without weakening CI, independent QA, or real HTTP acceptance.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Check the child environment before launch (Priority: P1)

As a task owner, I need Agentflow to verify the environment that a child stage will actually receive before starting or resuming it, so an environment mismatch is caught before it wastes a stage attempt or produces misleading evidence.

**Why this priority**: Environment differences between the parent shell and launched child can cause avoidable failures and retries.

**Independent Test**: Use controlled launch environments with matching and mismatching required prerequisites, then verify preflight results and whether a child stage is launched.

**Acceptance Scenarios**:

1. **Given** a start or resume request and a valid effective child environment, **When** preflight runs, **Then** it evaluates the same effective environment intended for that child and allows launch only after all applicable prerequisites pass.
2. **Given** a required executable, setting, service or other declared prerequisite is absent or incompatible, **When** preflight runs, **Then** it fails before launching the child and names the failed prerequisite, expected condition, observed safe detail and recovery action.
3. **Given** preflight runs, **When** it inspects prerequisites, **Then** it is deterministic for unchanged inputs and does not alter source files, task artifacts, services, databases or saved workflow state.
4. **Given** prerequisite values may contain credentials or other sensitive data, **When** a diagnostic is emitted, **Then** it reports the field and failure without exposing the value.

### User Story 2 - Recover from failures with useful evidence (Priority: P1)

As a task owner, I need each failure to leave a safe, specific diagnostic and QA to retain a partial report when some checks fail, so I can repair the cause without rerunning completed independent work or mistaking incomplete evidence for success.

**Why this priority**: Failure reports should guide repair and preserve trustworthy results even when a complete gate cannot finish.

**Independent Test**: Inject isolated and blocking check failures into a multi-check QA run and inspect execution order, continued checks, partial report contents, redaction and terminal verdict.

**Acceptance Scenarios**:

1. **Given** a check fails, **When** its result is recorded, **Then** the diagnostic identifies the check and stage, failure class, safe cause, elapsed time, evidence reference and actionable next step without copying secrets or requiring a full transcript.
2. **Given** one check fails and another check has no dependency on it or on state it may have corrupted, **When** a stage executes its check set, **Then** the independent check still runs and both outcomes appear in the partial report.
3. **Given** a failed prerequisite is required by a later check, **When** the check set proceeds, **Then** the dependent check is explicitly marked blocked or not run with its dependency stated, while other independent checks continue.
4. **Given** QA ends with any failed, blocked or unexecuted required check, **When** its report is written, **Then** completed evidence and unresolved outcomes are retained and the report cannot end in `Verdict: PASS`.
5. **Given** all required QA checks complete successfully, **When** the final QA report is written, **Then** its verdict reflects only that complete fresh QA run.

### User Story 3 - Respect retry and feedback governance (Priority: P1)

As a task owner, I need retries and feedback repairs to follow consistent rules, so repeated failures stop at the agreed limit and feedback reopens only the earliest stage that owns the affected decision or artifact.

**Why this priority**: Retry limits conserve effort, while correct feedback routing prevents stale upstream decisions and unnecessary rework.

**Independent Test**: Exercise repeated failures under unchanged and changed relevant inputs, plus feedback cases affecting product, architecture, verification and implementation; inspect attempt eligibility, stage selection and preserved artifacts.

**Acceptance Scenarios**:

1. **Given** a stage has failed twice with unchanged relevant inputs, **When** another full attempt is requested, **Then** Agentflow stops the attempt and reports the cause, elapsed check time and evidence references from the failures.
2. **Given** a relevant input has been corrected after a failure, **When** the next attempt is requested, **Then** the retry policy evaluates the changed input and does not treat unrelated edits as a valid reset.
3. **Given** two failed attempts have the same failed check and dependency closure, **When** only an independent check's input changes, **Then** the third attempt remains refused; a change to a failed check or dependency input makes recovery eligible.
4. **Given** a stage launcher is already active, **When** another process requests the same stage, **Then** it receives a safe running-stage refusal and cannot alter or append to the active attempt journal.
5. **Given** feedback changes a product requirement, architecture decision, verification obligation or implementation detail, **When** repair is routed, **Then** work returns to the earliest stage that owns the affected artifact and all dependent stages remain gated until it is repaired.
6. **Given** feedback affects implementation only, **When** repair starts, **Then** settled product and architecture artifacts remain intact and only cited regressions and affected required checks are invalidated or rerun.
7. **Given** feedback impact is materially ambiguous, **When** the owning stage cannot be determined from canonical artifacts, **Then** the workflow identifies the unresolved impact and requests a human decision before dependent work proceeds.

### User Story 4 - Remove avoidable duplicate local full-profile runs (Priority: P1)

As a maintainer, I need local verification to avoid repeating the same full test profile without a new reason, so delivery spends less time on duplicate execution while CI, independent QA and real HTTP acceptance remain intact.

**Why this priority**: Duplicate full-profile runs consume time without adding independent evidence, but optimization must preserve all quality gates.

**Independent Test**: Trace each local full-profile invocation across development and QA, compare it with CI and HTTP acceptance obligations, and verify that each required independent gate still executes.

**Acceptance Scenarios**:

1. **Given** a required local full profile has already run successfully for the current development inputs and covers the applicable checks, **When** the remaining local verification plan is formed, **Then** no avoidable duplicate development full-profile execution is added.
2. **Given** a full profile failed, was interrupted, is stale, or does not cover a required check, **When** readiness is evaluated, **Then** it cannot be counted as successful evidence and required repair or execution remains visible.
3. **Given** independent QA begins, **When** required full-profile checks apply, **Then** QA executes its own fresh checks and does not reuse development receipts.
4. **Given** CI or real HTTP acceptance is required, **When** local duplicate executions are removed, **Then** those obligations remain unchanged and are still fulfilled by their respective gates.

### Edge Cases

- The parent shell and child differ in executable search path, environment settings or service visibility; preflight must use the effective child view.
- Preflight itself cannot determine a prerequisite safely or a prerequisite is unavailable; it must fail closed with the exact unknown or unavailable condition, without exposing sensitive configuration.
- A failed check may leave shared state unsafe for another check; only checks independent of that state may continue.
- A QA process is interrupted after some checks; completed outcomes remain distinguishable from failed, blocked and unexecuted outcomes.
- An unchanged failure is retried in a resumed run; prior attempts count toward the same stage's retry limit.
- Irrelevant documentation or formatting changes occur between attempts; they do not reset the retry limit for an unchanged failing input.
- A required real HTTP check is not covered by a local full profile; its distinct acceptance obligation remains in force.
- A previous successful profile belongs to a different source state or execution stage; it cannot satisfy current development or independent QA evidence.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Before every new child-stage launch on start or resume, Agentflow MUST run preflight against the effective child environment and applicable prerequisites. A failed preflight MUST prevent that child from launching.
- **FR-002**: Preflight MUST be deterministic for unchanged relevant inputs and non-destructive: it MUST NOT change application or workflow source, task artifacts, external services, databases or saved run state.
- **FR-003**: Preflight MUST distinguish passed, failed and unknown/unavailable prerequisites. It MUST identify the exact prerequisite and expected condition, report only safe observed details, and provide an actionable recovery step. Sensitive values MUST be redacted.
- **FR-004**: Failure diagnostics MUST include task/stage/check identity where available, failure category, concise cause, elapsed check time, evidence reference and actionable next step. A combined CI profile failure MUST identify the failing registered profile and safe execution step/partition when known. Diagnostics MUST avoid secrets and unnecessary transcript output.
- **FR-005**: QA MUST write a partial report when interrupted or when any required check fails, is blocked or remains unexecuted. The report MUST preserve completed outcomes and explicitly account for every remaining required check; an incomplete or failed report MUST NOT claim `Verdict: PASS`.
- **FR-006**: Within a stage, a failure in one check MUST NOT prevent checks that are independent of the failed check and its possible side effects from running. Dependent checks MUST be recorded as blocked/not run with the dependency and reason. The workflow MUST preserve required execution order and fail closed when independence is unknown.
- **FR-007**: The same-input retry limit MUST stop a stage after two failed full attempts with unchanged relevant inputs. Retry scope MUST contain the failed checks and their transitive dependency closure; changes limited to independent checks MUST NOT reset that scope. A material input or dependency change within that scope MAY make another attempt eligible. Running/interrupted or legacy attempts without a trustworthy scope MUST conservatively use the complete stage snapshot. A further unchanged attempt MUST be refused with safe cause, elapsed time and evidence references. Prior failures MUST remain available across resume. Concurrent launchers for one workspace/feature/stage MUST NOT read, append or replace the attempt journal simultaneously; an active stage lock MUST refuse the second launcher without modifying the active attempt.
- **FR-008**: Feedback MUST be classified by affected canonical artifact and routed to its earliest owning stage. Product-impacting feedback MUST repair the spec and receive independent product challenge; architecture and verification changes MUST repair their owning artifacts before dependent work; implementation-only feedback MUST preserve settled upstream artifacts and rerun cited regressions and affected checks. Ambiguous material impact MUST pause dependent work for a human decision.
- **FR-009**: Local verification planning MUST identify avoidable duplicate executions of the same applicable full profile for the same development inputs and remove them when an existing successful run fully covers the obligation. A failed, interrupted, stale or incomplete run MUST NOT satisfy the obligation.
- **FR-010**: Development evidence reuse MUST NOT substitute for independent QA. QA MUST execute fresh applicable checks in its independent session and produce its own partial or complete report.
- **FR-011**: The optimization MUST preserve all existing CI obligations, independent QA, final review, terminal PASS gates and real HTTP acceptance obligations. Local execution deduplication MUST NOT remove, weaken or replace these gates.
- **FR-012**: Behavioral changes to preflight, diagnostics, check continuation, partial reporting, retry accounting, feedback routing or execution deduplication MUST have automated behavioral coverage, including failure and compatibility cases.
- **FR-013**: This feature MUST remain limited to Agentflow workflow behavior and its tests/documentation. It MUST NOT change football-market application behavior, domain invariants or checkpoint product scope.

### Key Entities

- **Preflight result**: The applicable prerequisite, effective child context, expected condition, safe observed outcome and readiness decision.
- **Check outcome**: A required check's identity, dependencies, execution status, result, elapsed time and evidence reference.
- **Partial QA report**: A truthful report of completed, failed, blocked and unexecuted QA checks with the resulting gate verdict.
- **Retry record**: A stage attempt, relevant input identity, failure cause, elapsed time and evidence reference used to enforce the same-input limit.
- **Feedback impact**: The affected canonical artifact, earliest owning stage, preserved artifacts and dependent work that must be repaired or rerun.
- **Verification obligation**: A local profile, CI check, independent QA check or HTTP acceptance check that remains required for delivery.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In all representative start and resume fixtures, effective-child environment mismatches are detected before child launch; valid fixtures pass with no writes to protected inputs or state.
- **SC-002**: Every injected preflight or check failure report identifies the stage/check, cause, elapsed time, evidence reference and recovery action, while redaction tests find zero secret values.
- **SC-003**: Across all representative mixed-result QA cases, every independent check runs, every blocked dependency is identified, every required check has an outcome, and no incomplete case ends in `Verdict: PASS`.
- **SC-004**: A third full attempt with unchanged relevant inputs is refused after two failures, including across resume; unrelated edits do not reset the limit, and a material correction is handled according to the documented retry policy.
- **SC-005**: Each tested feedback category routes to the earliest owning stage, preserves unaffected settled artifacts and blocks dependent work until required upstream repairs are complete.
- **SC-006**: The local verification plan contains no avoidable duplicate full-profile run for unchanged development inputs, while all applicable CI runs, one fresh independent QA execution and real HTTP acceptance remain accounted for.
- **SC-007**: Every new workflow behavior has automated acceptance coverage for successful and negative cases, and no application-level behavior or product invariant changes as part of this task.

## Assumptions

- The existing two-failure rule in `docs/AGENT_CONTEXT_POLICY.md` is the intended same-input retry limit for each stage; full attempts, not individual commands within one attempt, consume that limit.
- “Effective child environment” means the executable lookup, environment settings, working context and prerequisite visibility the child process actually receives after launch configuration is applied.
- Prerequisite checks may perform read-only availability probes where needed, but must not mutate service state or run full test profiles as a side effect of preflight.
- A completed check may be continued past only when its dependencies and possible side effects establish independence; uncertain dependence blocks continuation.
- A successful local full profile can cover development obligations only while its relevant inputs and evidence remain current and intact. Independent QA and CI are separate obligations.
- No application behavior, market rule, external service, credential, publication or merge authority is introduced or changed by this workflow task.

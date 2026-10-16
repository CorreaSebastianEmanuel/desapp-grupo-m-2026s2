# Feature Specification: Proportional Agentflow Delivery and Measurable Efficiency

**Feature Branch**: `064-proportional-agentflow-delivery-and-measurable-efficiency`

**Created**: 2026-10-15

**Status**: Draft — revised for human Feedback 1 (2026-10-16)

**Input**: TASK-064 — optimize workflow delivery, artifact volume, feedback repair and efficiency measurement and implement repository-scoped stage model assignment per human Feedback 1, while preserving application behavior and independent verification. Feedback 1 supersedes the original Sol-everywhere baseline restriction; the requirements below incorporate both authorized outcomes.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Discover delivery failures before independent QA (Priority: P1)

As the implementation owner, I need the actual applicable delivery checks and their environment requirements identified during planning and executed before QA, so a locally green feature does not fail because CI uses different commands, missing local metadata or undiscovered tests.

**Why this priority**: Avoidable QA retries consume time and resources and undermine confidence in delivery evidence.

**Independent Test**: Exercise a representative workflow change from a clean checkout without local feature metadata, compare selected checks with current CI obligations, and verify the development gate refuses incomplete or failed preparation.

**Acceptance Scenarios**:

1. **Given** a task and current CI definitions, **When** architecture prepares verification, **Then** it identifies applicable commands, service/toolchain requirements and applicability reasons, and explicitly accounts for CI obligations excluded from local execution.
2. **Given** local feature metadata is absent in a clean checkout, **When** applicable CI commands discover and execute tests, **Then** required tests execute without depending on private metadata; checks that genuinely require an active feature resolve it through the existing ownership mechanism or fail with an actionable explanation.
3. **Given** a required test collection is empty, a required service is unavailable, or the toolchain differs from the required one, **When** development verification runs, **Then** the discrepancy is detected before QA and cannot be reported as a passing preparation.
4. **Given** overlapping checks and intact current development evidence, **When** required coverage can be satisfied by an existing profile, **Then** preparation does not add a duplicate full-profile execution; independent QA still executes its own checks.

### User Story 2 - Produce only necessary supporting documents (Priority: P1)

As a maintainer, I need complete canonical delivery artifacts with proportionate supporting documentation, so agents retain all acceptance and design obligations without repeatedly generating settled information.

**Why this priority**: Smaller context and artifact volume must not hide requirements or weaken readiness gates.

**Independent Test**: Compare planning for a workflow-only change with planning for a change requiring new data or an interface; verify optional documents follow the concrete need and all entry points agree.

**Acceptance Scenarios**:

1. **Given** any feature, **When** delivery reaches its applicable stage, **Then** complete `spec.md`, `plan.md`, `tasks.md`, `verification.json`, `qa-report.md` and `review-report.md` are required regardless of feature size.
2. **Given** no unresolved research, changed data model, new or changed interface, or feature-specific startup/demo procedure, **When** planning runs, **Then** research, data-model, contracts and quickstart artifacts may respectively be omitted with a concise applicability rationale in the plan, and gates accept justified omissions.
3. **Given** one of those concrete needs exists, **When** planning completes, **Then** the corresponding supporting artifact contains the necessary feature-specific decision or interface, references settled canonical material and is required by readiness checks.
4. **Given** a feature is planned or resumed through skills or workflow hooks, **When** artifact readiness is evaluated, **Then** the same applicability rules apply, and handoffs supply only decisions, risks and guidance absent from canonical artifacts.

### User Story 3 - Review compact, trustworthy evidence and resume safely (Priority: P1)

As a reviewer, I need a compact versioned final evidence summary and reliable local verification, so I can assess delivery without committing voluminous per-attempt evidence or mistaking stale receipts for current proof.

**Why this priority**: Evidence reduction is acceptable only when integrity, freshness and resumability remain meaningful.

**Independent Test**: Generate evidence, resume a run and inject missing, stale, altered and interrupted check results; distinguish portable final summaries from reusable workspace evidence.

**Acceptance Scenarios**:

1. **Given** checks run repeatedly, **When** evidence is recorded, **Then** full logs, per-file hash inventories, receipts and intermediate QA evidence remain in ignored local paths or CI artifacts, while a compact final summary is versioned with the feature.
2. **Given** an unchanged successful development check, **When** reuse is explicitly requested, **Then** reuse requires matching command, relevant inputs, source state, successful completion and intact output; changing any bound input or evidence prevents reuse.
3. **Given** failure or interruption follows an earlier pass, **When** readiness or reuse is requested, **Then** the earlier pass cannot authorize progression. After two failures for unchanged inputs in a stage, further full retries stop with cause, elapsed time and evidence references.
4. **Given** only the feature's versioned files are available in another checkout, **When** evidence is reviewed, **Then** the final summary remains understandable, absent local output is disclosed, and local checks must execute before workspace readiness can pass.
5. **Given** historical tracked artifacts or an existing interrupted run, **When** the new policy is adopted, **Then** neither historical artifacts nor run state are deleted or bulk rewritten, and supported resume paths remain usable without weakening current verification.

### User Story 4 - Repair feedback at the earliest affected stage (Priority: P1)

As a task owner, I need feedback to reopen exactly the work it invalidates, so a code or test correction does not restart settled product decisions and a real scope change cannot bypass specification repair.

**Why this priority**: Repair must save repeated effort while preserving authoritative human feedback and valid evidence.

**Independent Test**: Apply implementation, verification, architecture and product feedback to representative task states, check stage selection and preserved artifacts, and follow repair through independent gates.

**Acceptance Scenarios**:

1. **Given** feedback cites an implementation discrepancy without changing behavior or design, **When** repair starts, **Then** development resumes with settled product and architecture artifacts preserved and cited regressions plus required checks scheduled.
2. **Given** feedback changes a verification obligation, architecture decision or product requirement, **When** repair starts, **Then** it returns respectively to the stage owning that obligation or decision; a product change receives independent challenge again.
3. **Given** an explicit requested stage conflicts with the actual impact, **When** feedback is accepted, **Then** the conflict is explained and no later stage proceeds with invalid upstream artifacts; material unresolved choices follow the existing human product-check rule.
4. **Given** repaired work, **When** it is proposed for completion, **Then** affected evidence is regenerated, unaffected evidence is preserved subject to freshness rules, and fresh independent QA and final review both end exactly in `Verdict: PASS`.

### User Story 5 - Measure efficiency without speculative savings (Priority: P2)

As a workflow maintainer, I need honest consumption and retry measurements and a reproducible comparison protocol, so future optimization decisions use observed evidence rather than model guesses.

**Why this priority**: Measurement makes the optimization assessable without adding experimental spending to this task.

**Independent Test**: Feed existing telemetry processing deterministic complete, partial, repeated and resumed attempt records; verify stage summaries and a pilot protocol another maintainer can follow without executing a new task now.

**Acceptance Scenarios**:

1. **Given** observable model, reasoning effort and reported token dimensions, **When** an attempt is summarized, **Then** model and effort provenance, input, cached input, output and reasoning token counts, attempt identity and stage attribution are retained; unavailable fields are explicitly unknown.
2. **Given** cumulative, repeated, interrupted or ambiguous usage reports, **When** totals are calculated, **Then** usage is not counted twice, partial coverage is disclosed and unknown usage is never presented as zero or inferred from runtime.
3. **Given** this feature is delivered, **When** a maintainer reads the pilot protocol, **Then** it defines baseline and comparison observations for the next normally authorized real task, including consumption, generated file counts and volume, retries, quality outcomes and comparability limitations, without starting that task or claiming savings.
4. **Given** the historical Sol Medium configuration and the new stage assignment, **When** the comparison protocol is described, **Then** it names both configurations, separates workflow changes from model changes, documents unavailable baseline measurements and makes no percentage quality or token savings claims before a real measured task supports them.

### User Story 6 - Select stage models explicitly and resume honestly (Priority: P1)

As a repository maintainer, I need configurable stage defaults and a deliberate development override, so model assignment is predictable, independent verification remains intact and saved runs are not silently reconfigured.

**Why this priority**: Human Feedback 1 requires model assignment in this delivery alongside efficiency improvements.

**Independent Test**: Use deterministic launcher fixtures to capture model/effort arguments for each stage, conflicting configuration sources, failures and saved resumes; no live model calls are required to prove selection.

**Acceptance Scenarios**:

1. **Given** a future start without overrides, **When** each agent stage launches, **Then** product, product_challenge and develop select `gpt-6-luna` / `high`, architecture and final review select `gpt-6.1-sol` / `medium`, and independent QA selects `gpt-6.1-sol` / `low`; each independent stage retains its own session.
2. **Given** repository defaults and a task development override to Sol for concurrency, transactions, idempotency or security, **When** development launches, **Then** the explicit override is applied and its source is visible without changing unrelated stages or classifying the task automatically.
3. **Given** conflicting explicit command-line, task and repository settings, **When** a new run resolves each model/effort field, **Then** explicit stage/run command-line values win over explicit run-wide command-line values, then task development values, then repository stage defaults; the resolved pair and winning sources are inspectable before launch.
4. **Given** malformed configuration, an unknown stage, unsupported model/effort or an unavailable selected model, **When** resolution or launch fails, **Then** the error names the stage and selected settings, no silent fallback or automatic escalation occurs and the stage cannot be marked successful.
5. **Given** a saved run, including a legacy run with missing provenance, **When** it resumes normally, **Then** known saved launch settings remain authoritative, absent values stay explicitly unknown and repository edits do not silently change its assignment. A documented explicit adoption path may apply new resolved settings only to future attempts, preserving prior attempts and completed evidence.
6. **Given** frozen active run `72789de8`, **When** it continues with original launch settings, **Then** reports distinguish those settings and any observed identity from the new defaults; they do not claim this run exercised the new assignment.
7. **Given** any assignment or override, **When** launch telemetry and delivery gates are evaluated, **Then** configured, resolved and observed identities remain distinguishable, missing observations are unknown, and product challenge, required checks, independent QA/review and human merge authority remain mandatory.

### Edge Cases

- CI changes after planning: verification applicability must be re-evaluated; an old manifest cannot silently stand for the new obligations.
- A required environment cannot be reproduced locally: report the exact limitation and required CI evidence; absence of evidence cannot satisfy the development gate.
- A supported optional artifact becomes necessary after feedback: require it at its owning stage without regenerating unrelated documents.
- A receipt, output, final summary or bound source is altered, missing or from another checkout: reject it as current workspace proof, with a diagnostic explaining the mismatch.
- A checkout has old tracked receipts or an old manifest: preserve historical files and apply an explicit compatibility policy; do not manufacture new passes or silently waive requirements.
- Feedback wording is ambiguous about affected behavior: use canonical artifacts to resolve it; escalate only remaining material decisions, preserving settled content meanwhile.
- Model configuration is known but actual execution identity is unavailable: distinguish configured values from observed values rather than claiming execution provenance.
- A repository configuration changes during an active run: saved assignment remains stable unless an explicit documented adoption is requested; completed attempts are never relabeled.
- A launch option is accepted locally but rejected by the provider: record a visible failed attempt without trying a different model or effort.
- A legacy run lacks recoverable launch settings: disclose unknown provenance and require an explicit selection if needed to continue; never invent prior settings.
- All token dimensions are unknown, or only some attempts report them: expose coverage and unknowns; a measured subtotal must not be labeled a complete total.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Scope MUST remain workflow tooling, skills, templates, hooks, policy, behavioral tests and this feature's required artifacts. Application behavior, financial invariants, checkpoint obligations, unrelated backlog tasks and historical specifications MUST remain unchanged.
- **FR-002**: Planning MUST discover actual applicable CI commands and service/toolchain requirements from current project mechanisms, record applicability and exclusions, and map every FR/AC/SC identifier to executable checks in `verification.json`. Existing scripts and profiles MUST be reused instead of creating duplicate full profiles.
- **FR-003**: Development MUST execute applicable checks before independent QA, including clean-checkout operation, missing private feature metadata and required test discovery. Required collections with zero discovered tests, failed environment parity and unavailable required services MUST fail visibly. Execution evidence MUST identify the commands and parity assessed.
- **FR-004**: Required formatting, compilation, behavioral, static, architecture and checkpoint checks MUST remain enforced where applicable. Historical CP1 coverage MUST NOT become an extra default CP2 gate. Unavailable required evidence MUST block readiness rather than silently reduce the checks.
- **FR-005**: Complete canonical `spec.md`, `plan.md`, `tasks.md`, `verification.json`, QA and review reports MUST remain required. Supporting research, data-model, contracts and quickstart MUST be conditional respectively on an unresolved decision, changed data structure, changed interface or feature-specific setup/demo need; the plan MUST record each applicability decision and missing applicable artifacts MUST block readiness.
- **FR-006**: Skills, templates, workflow prompts, hooks and readiness validation MUST apply the same artifact policy, including resume paths. Handoffs MUST reference canonical facts and contain only additional decisions, unresolved assumptions, risks or next-stage guidance within existing word limits.
- **FR-007**: Newly generated voluminous per-attempt evidence, receipts, per-file hash inventories and intermediate QA outputs MUST remain ignored locally or in CI artifacts. Each completed delivery MUST retain a compact, schema-versioned final evidence summary identifying the task/revision, check identities and outcomes, execution stage, environment, coverage, evidence availability, integrity/freshness binding and independent verdicts; it MUST omit raw output and per-file inventories and MUST NOT grow with the number of attempts.
- **FR-008**: Workspace verification MUST validate command identity, bound source and canonical inputs, output integrity, successful exit and freshness before accepting evidence. Failure, interruption, missing output, stale inputs or tampering MUST invalidate acceptance. A final summary alone MUST NOT authorize local receipt reuse or replace independent checks.
- **FR-009**: Existing tracked historical evidence and resumable run state MUST be preserved without destructive cleanup or bulk historical rewrites. Compatibility handling MUST distinguish legacy records from current valid evidence and allow safe continuation with reruns when proof is unavailable. No remote storage service or credential disclosure may be introduced.
- **FR-010**: Explicit development reuse MUST require current intact development evidence. QA MUST independently rerun applicable checks without developer receipt reuse; final review MUST use fresh QA evidence and run targeted checks for uncovered risks. Two unchanged-input failures per stage MUST stop further repeated execution with cause, elapsed check time and evidence references; irrelevant changes MUST NOT reset the limit.
- **FR-011**: Feedback repair MUST identify the earliest actually affected owning stage, preserve settled artifacts, and invalidate only evidence no longer valid under the freshness rules. Implementation-only repair MUST NOT reopen product or architecture. Verification-plan, architecture or behavioral changes MUST repair their owning artifacts before dependent work proceeds; ambiguous material impact requires a precise human decision.
- **FR-012**: Repair MUST add or execute regressions for the cited discrepancy, rerun required affected checks and obtain fresh independent QA and final review. Every workflow behavioral change in this task MUST have automated behavioral tests, including negative gate cases, compatibility and resume behavior.
- **FR-013**: Independent product challenge, conditional human product checks, separate implementation/QA/review sessions and both terminal `Verdict: PASS` gates MUST remain mandatory. Publication authority MUST remain unchanged and humans alone may merge. TASK-064 completion MUST include independent QA and final review PASS evidence.
- **FR-014**: Measurement MUST extend existing structured telemetry and summaries, without broad run-log exploration. Per-attempt records and stage summaries MUST include observed model, reasoning effort where observable, reported input/cached-input/output/reasoning tokens, attempts and stage attribution, with unknown fields explicit and configured values distinguished from observed execution.
- **FR-015**: Summaries MUST disclose measurement completeness and provenance, prevent duplicate accounting across repeated/resumed/cumulative records and distinguish observed subtotals from complete totals. Missing dimensions MUST NOT be inferred from another token dimension, elapsed time or model defaults; cached and reasoning subsets MUST NOT be added again to their parent totals.
- **FR-016**: Documentation MUST provide a reproducible pilot comparison protocol for the next normally authorized real task: identify baseline source and workflow/model configuration, comparison boundaries, collection commands, consumption coverage, generated file counts and volume, stage retries and causes, required-check and verdict outcomes, and scope/measurement limitations. Unavailable baseline measures MUST be marked unknown; savings claims require comparable observed evidence. This task MUST NOT start a second backlog task or execute a paid experiment.
- **FR-017**: Repository-scoped configurable defaults MUST select the following model/effort pairs for future starts. These are delivery behavior requirements, not claims of model availability or quality:

  | Agent stage | Model | Reasoning effort |
  | --- | --- | --- |
  | product | gpt-6-luna | high |
  | product_challenge | gpt-6-luna | high |
  | develop | gpt-6-luna | high |
  | architecture | gpt-6.1-sol | medium |
  | review (final review) | gpt-6.1-sol | medium |
  | qa (independent QA) | gpt-6.1-sol | low |

- **FR-018**: Maintainers MUST be able to explicitly override development model/effort per task or run, including selecting Sol for concurrency, transactions, idempotency or security work. Selection MUST NOT use speculative autonomous task classification. For each supplied field, precedence MUST be explicit stage/run command-line override, explicit run-wide command-line override, task development override, repository stage default. Effective pairs and source provenance MUST be inspectable before launch; development-only overrides MUST NOT alter other stages. No new global user settings may be written.
- **FR-019**: Malformed configuration, unknown stages and unsupported model/effort combinations MUST fail visibly before an affected stage can succeed. Availability failures detected on launch MUST remain visible failed attempts identifying stage, selection and actionable cause. The system MUST NOT silently fall back, automatically escalate retries to another model/effort or execute paid capability probes/benchmarks.
- **FR-020**: Assignment MUST be stable for a saved run: normal resume preserves known saved launch settings, and legacy missing provenance remains explicitly unknown. Documentation MUST describe normal resume and an explicit adoption path for new defaults/overrides on future attempts only, preserving completed attempts, independent sessions, valid artifacts and verification obligations. Missing settings that prevent launch MUST require explicit configuration rather than silently inventing a selection. Frozen active run `72789de8` MAY retain original launch settings and MUST report that exception honestly without claiming the new defaults were exercised.
- **FR-021**: Existing telemetry MUST expose the configured selection, resolved launch model/effort and their source where known, separately from observed execution identity. Summaries MUST retain attempt/stage attribution across changed settings and resumes without relabeling prior attempts. Unknown observed values MUST NOT be filled from defaults. Deterministic behavioral tests MUST prove all stage pairs, development overrides, CLI/config precedence, unsupported selection and availability failures, telemetry provenance, legacy/resume compatibility and unchanged independent gates.
- **FR-022**: Model assignment MUST preserve independent product challenge and separate implementation, QA and final-review sessions. TASK-064 MUST NOT introduce recursive agents, hidden retry escalation, autonomous spending experiments or extra application behavior. The historical Sol Medium configuration MAY be named as a measurement baseline; it MUST NOT override FR-017. No optional-future-Luna restriction remains: the approved stage assignment is implemented now, without launching an additional task or benchmark.

### Key Entities

- **Verification obligation**: Required command, applicability, environment, requirement coverage and execution stage.
- **Artifact applicability decision**: Supporting document, concrete need or omission rationale, and owning canonical plan.
- **Attempt evidence**: Stage, attempt, command identity, bound inputs, completion result, integrity/freshness data and local or CI evidence reference.
- **Final evidence summary**: Compact portable account of the final verified revision, coverage, results, evidence availability and independent verdicts; distinct from reusable local receipts.
- **Feedback impact**: Cited discrepancy, earliest affected stage, preserved artifacts, invalidated evidence and required regressions.
- **Usage observation**: Attempt/stage identity, observed or configured model/effort provenance, reported token dimensions and completeness.
- **Stage assignment**: Repository defaults, explicit task/run overrides, effective model/effort, winning configuration sources and saved-run adoption boundary.
- **Pilot protocol**: Baseline/comparison boundaries, reproducible observations, quality constraints and limitations for the next real task.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All required delivery checks are accounted for before QA; representative missing-metadata, empty-test, environment-mismatch and unavailable-service failures are detected in development rather than first appearing in independent QA.
- **SC-002**: Both a minimal change and a change needing supporting documents retain 100% of mandatory canonical artifacts; every omitted supporting document has a reviewed applicability rationale and every necessary supporting document is enforced.
- **SC-003**: Repeated attempts add zero new versioned raw logs, per-file hash inventories or individual receipts. The final evidence summary remains bounded by final checks and requirements rather than attempt count; historical tracked artifacts remain intact.
- **SC-004**: All representative missing, stale, tampered, interrupted and cross-checkout evidence cases reject invalid reuse; an unchanged valid development case permits explicit reuse and independent QA still runs afresh.
- **SC-005**: Each tested feedback category returns to its earliest affected stage, preserves unaffected canonical content and evidence where still fresh, and cannot complete without appropriate regressions and both independent PASS verdicts.
- **SC-006**: Every measured attempt exposes stage, model/effort provenance and all requested token dimensions or explicit unknowns; repeated/resumed records produce no duplicate totals and partial measurements remain identifiable.
- **SC-007**: A maintainer can reproduce the documented next-task comparison using the named observations for consumption, generated files, retries and quality, with no invented baseline or savings and no second task or spending experiment executed by TASK-064; routine authorized delivery may use its resolved model assignment.
- **SC-008**: All new workflow behaviors have automated acceptance coverage, and TASK-064 obtains independent QA and final review reports ending exactly in `Verdict: PASS`, with human merge authority preserved.

- **SC-009**: All six stage selections and every precedence/override case in Story 6 match the declared policy; invalid or unavailable selections yield zero silent fallbacks and zero false successful stages.
- **SC-010**: Legacy, normal, explicitly adopted and frozen-run resume cases preserve completed history and independent gates; every attempt exposes known assignment provenance or explicit unknowns.

## Assumptions

- Target users are task owners, implementation agents, independent product critics, QA agents and reviewers; no new application end-user behavior is intended.
- `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, `docs/CHECKPOINTS.md`, the constitution and `docs/AGENT_CONTEXT_POLICY.md` remain authoritative. Existing verification and telemetry mechanisms are the starting point, not a reason to add infrastructure.
- Applicability is based on affected obligations and current CI definitions, not on feature size alone. Full independent QA remains required even when development reuses evidence.
- Final summaries are portable review records; execution reuse remains workspace-specific. Evidence retention follows existing local/CI facilities without a new storage service or destructive migration.
- Preserving unaffected evidence means keeping it available, not declaring it fresh when bound inputs changed; conservative current freshness checks take precedence over reuse savings.
- Pilot delivery means a complete protocol, not measured savings. The next real task is undertaken only under its own normal authorization. Baseline gaps are reported explicitly rather than repaired by exploratory historical log scans.
- Human Feedback 1 authorizes repository stage assignment now. The original optional Luna trial and Sol-everywhere restrictions are superseded; no model availability, pricing, observed execution identity or percentage savings is asserted.
- Precedence and resume adoption above are conservative defaults for otherwise unspecified configuration details. Syntax and persistence design belong to architecture; they must preserve these observable rules.
- This product-stage revision does not certify implementation, independent challenge, QA or review. Existing downstream artifacts remain useful inputs but must be reconciled with this revised behavioral source before implementation.

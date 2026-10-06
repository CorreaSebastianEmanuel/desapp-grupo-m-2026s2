# Feature Specification: Agentflow Task Feature Directory Binding

**Feature Branch**: `054-agentflow-task-feature-directory-binding`

**Created**: 2026-10-06

**Status**: Draft

**Input**: TASK-054 — Correct task-to-feature association across local Agentflow discovery, verified publication, explicit completion, and post-merge reconciliation while retaining delivery safeguards and isolating the fix from the provider work in PR #28.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find and publish the feature belonging to a task (Priority: P1)

As a maintainer running Agentflow for one backlog task, I want it to locate that task's canonical feature artifacts even when the feature directory has a different number, so verification and publication use the work actually produced for my task.

**Why this priority**: Selecting the wrong feature prevents legitimate delivery or attaches another task's evidence to a publication.

**Independent Test**: In isolated repositories, exercise local discovery and publication with unequal task and feature numbers, distracting directories, and absent or misleading local session pointers. Capture publication actions rather than sending a real push or PR.

**Acceptance Scenarios**:

1. **Given** TASK-017 on `017-football-data-api-adapter` and `specs/055-football-data-api-adapter/spec.md` declaring that exact Feature Branch, **When** local Agentflow discovers its feature and prepares verified publication, **Then** it selects that directory and references its specification, plan, tasks, QA, and review reports, retaining TASK-017 and its existing branch identity.
2. **Given** TASK-020 and `specs/054-player-match-statistics/spec.md` declaring `020-player-match-statistics-model`, **When** Agentflow resolves TASK-020, **Then** it selects that feature rather than a task-number match or another task's more recently modified artifacts.
3. **Given** an otherwise valid association and both independent verification reports ending in `Verdict: PASS`, **When** authorized publication runs, **Then** existing branch, artifact, workflow-result, and verification requirements still apply; the published task enters `review` and awaits human merge.
4. **Given** a legacy task with exactly one matching equal-number feature and no contradictory association, **When** it is discovered, **Then** existing local delivery remains supported under the compatibility rules in FR-004.
5. **Given** a valid new task for which no feature has yet been created, **When** its product stage begins, **Then** feature creation remains possible; absence is never treated as permission to select another task's feature or to publish or complete the task.

---

### User Story 2 - Reconcile a human-merged task using its own evidence (Priority: P1)

As a maintainer merging a reviewed delivery PR, I want post-merge reconciliation to use the merged branch's feature association so that only the corresponding backlog task is completed.

**Why this priority**: Incorrect reconciliation either leaves completed work unavailable to dependents or completes a task using unrelated reports.

**Independent Test**: Invoke the post-merge command against an isolated copy of the actual TASK-017 backlog and feature artifacts, then compare every input and backlog file before and after. Exercise rejected cases separately.

**Acceptance Scenarios**:

1. **Given** the copied TASK-017 is in `review`, its feature is `specs/055-football-data-api-adapter`, and both copied independent reports have terminal `Verdict: PASS`, **When** the post-merge command receives `017-football-data-api-adapter`, **Then** it changes only the copied TASK-017's `status` to `done` and `active_run` to `none`.
2. **Given** TASK-020 in `review` with passing reports in `specs/054-player-match-statistics`, **When** reconciliation receives `020-player-match-statistics-model`, **Then** it completes TASK-020 using that directory and preserves unrelated backlog files.
3. **Given** successful reconciliation has already completed the task, **When** the same merged branch is reconciled again, **Then** it succeeds as a no-op with no file changes.
4. **Given** a task outside `review` or an invalid delivery branch, **When** completion is attempted, **Then** no backlog task is changed to `done`. The existing workflow skips non-delivery branches without changing backlog state.

---

### User Story 3 - Refuse uncertain associations and invalid verification (Priority: P1)

As a maintainer, I want an explicit failure when feature ownership or verification is uncertain, so automation cannot silently publish or complete the wrong task.

**Why this priority**: Ownership and independent verification are prerequisites for trustworthy delivery.

**Independent Test**: Exercise the same association and report rejection matrix through local resolution, publication, explicit completion, and post-merge reconciliation. Assert failures and unchanged unrelated files, with no publication side effects.

**Acceptance Scenarios**:

1. **Given** required feature ownership is missing, multiple specifications declare the same branch, or durable association sources disagree, **When** Agentflow needs a feature for verification, publication, or completion, **Then** it reports the missing, ambiguous, or conflicting association with the task, branch, and relevant candidates, and refuses the operation.
2. **Given** a valid task association but a missing, unreadable, empty, failed, malformed, or nonterminal passing QA or review report, **When** publication, explicit completion, or post-merge completion is attempted, **Then** the task cannot enter `review` through publication or become `done`, and no push or PR is created.
3. **Given** unrelated features have passing reports, **When** the selected task's reports fail validation, **Then** unrelated evidence cannot satisfy either verification gate.
4. **Given** `.specify/feature.json` is absent, stale, or points to another task and unrelated directories are newer, **When** durable ownership is resolved, **Then** the result and safety decisions are unchanged.
5. **Given** optional durable task metadata names an invalid path or disagrees with the specification's declared branch, **When** the task is resolved, **Then** it fails explicitly without falling back to directory-number or modification-time guesses.

### Edge Cases

- An unrelated equal-number directory exists alongside a correct unequal-number Feature Branch match: the explicit association wins; the unrelated directory's reports are never used.
- Two directories declare the same expected Feature Branch, including when task metadata points to one: ambiguity is refused rather than hidden by precedence.
- Task metadata points to one feature but a different feature declares the expected branch: the disagreement is refused.
- A declared Feature Branch is malformed, duplicated, or belongs to another task: it cannot be ignored to enable a legacy fallback.
- A metadata path is empty, missing, outside the repository's immediate `specs/` children, or escapes that boundary through a symbolic link: it is invalid.
- Multiple equal-number directories or an equal-number directory without a usable `spec.md` do not establish a legacy association.
- Backlog task identity is missing, duplicated, or disagrees with the requested task or merged branch: completion is refused.
- A report contains `Verdict: PASS` earlier but ends in failure, commentary, or a different verdict spelling: it does not pass. Trailing blank lines and surrounding whitespace on the final nonempty line retain existing handling.
- Missing `status` or `active_run` metadata prevents reconciliation without a partial task update.
- Reconciliation runs on the merged base checkout rather than the original feature branch and without ignored local state: versioned artifacts remain sufficient.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Agentflow MUST resolve a backlog task to its own canonical feature independently of the feature directory's numeric prefix. TASK-017 with `specs/055-football-data-api-adapter` and TASK-020 with `specs/054-player-match-statistics` MUST be supported without renaming tasks, branches, or existing feature directories.
- **FR-002**: The authoritative association MUST be durable repository-versioned information: an exact canonical `spec.md` Feature Branch declaration and/or validated task metadata naming the feature directory. Existing canonical branch declarations MUST suffice without adding metadata to TASK-017 or TASK-020. If both sources exist, they MUST agree; metadata MUST NOT conceal duplicate branch associations or override a contradictory declaration.
- **FR-003**: Local task feature discovery, verification, verified publication, explicit task completion, and post-merge reconciliation MUST share one unambiguous association contract. Consumers MUST NOT independently infer ownership from task-number equality, ignored `.specify/feature.json`, newest-directory order, or modification time. A session pointer MAY be populated for downstream stage tools after authoritative resolution, but MUST NOT establish task ownership.
- **FR-004**: Legacy equal-number layouts MUST remain supported. Compatibility resolution is allowed only when no durable association identifies the task's feature, exactly one equal-number directory exists with a usable `spec.md`, and that candidate has no contradictory Feature Branch declaration or task metadata. Explicit branch matches take precedence over incidental equal-number directories. Invalid explicit information and multiple candidates MUST cause refusal rather than fallback.
- **FR-005**: Resolution MUST validate task and branch identity, specification ownership, and any metadata path. A selected feature MUST exist within an immediate child of the repository's `specs/` directory, remain within that boundary after path resolution, and contain readable canonical `spec.md`. Missing, malformed, ambiguous, and conflicting associations MUST produce actionable errors and MUST NOT enable verification, publication, or completion using another feature.
- **FR-006**: Publication and all transitions to `done` MUST require both independent QA and final review reports from the resolved feature. Each report's final nonempty line, after surrounding whitespace is removed, MUST equal `Verdict: PASS` exactly. Missing, unreadable, empty, failed, malformed, or nonterminal passing reports MUST fail closed. Existing publication requirements for successful workflow execution, required artifacts, branch matching, and verification evidence MUST remain in force.
- **FR-007**: Post-merge reconciliation MUST derive the task identity from the supplied valid merged delivery branch, resolve its versioned feature association from the merged checkout, and require the target task to be in `review` before completing it. On success it MUST update only that backlog file's `status` to `done` and `active_run` to `none`; all other content and all unrelated files MUST be preserved. Validation failures MUST leave backlog files unchanged. An already `done` task MUST remain an unchanged successful no-op.
- **FR-008**: Explicit local completion MUST retain its human review or merge authorization prerequisite and its `review` status prerequisite, and MUST additionally enforce the resolved feature's two terminal passing verdicts before changing `status` or `active_run`. This correction MUST NOT grant agents merge authority or introduce automatic completion before the existing authorized completion boundary.
- **FR-009**: The post-merge workflow MUST preserve its merged-PR-to-`main` trigger, non-delivery-branch skip, existing permissions, serialized reconciliation, and human control over implementation PR merges. The fix MUST NOT broaden workflow privileges, weaken report validation, or change unrelated Actions behavior.
- **FR-010**: Every changed behavior MUST have meaningful automated regressions. Coverage MUST include unequal-number TASK-017 and TASK-020 associations; legacy equality; explicit matches with distracting equal-number directories; absent/stale session pointers; differing directory modification times; missing, duplicate, malformed, ambiguous, conflicting, and unsafe associations; invalid task states; both terminal verdict gates; publication side effects; and reconciliation idempotence and file preservation.
- **FR-011**: Validation MUST include executing the actual post-merge command against an isolated copy of the actual TASK-017 backlog, canonical specification, QA report, and review report from the provider delivery branch associated with PR #28. The successful fixture MUST retain the actual unequal-number layout and report contents. Validation MUST demonstrate the expected copied backlog delta and MUST leave the real TASK-017 backlog, feature artifacts, branch, and PR unchanged.
- **FR-012**: Delivery MUST be a separate TASK-054 PR intended to merge before PR #28, with that sequencing made explicit for human reviewers. This task MUST NOT modify Elixir application behavior, provider implementation, TASK-017 feature artifacts, unrelated backlog files, or broader Actions optimizations. Required checks MUST be scoped to this Python/workflow correction; unrelated Elixir suites MUST NOT be rerun unless concrete evidence identifies an affected application behavior.

### Key Entities *(include if feature involves data)*

- **Backlog task**: Stable TASK identifier, title, status, active run, and optional durable feature association. Directory numbering does not redefine its identity.
- **Delivery branch**: Existing task-specific branch identity used for publication and post-merge task identification.
- **Canonical feature**: Versioned directory containing the task's specification and delivery artifacts; its number is independent of the task number.
- **Feature association**: Validated ownership relationship established by the canonical Feature Branch declaration and/or versioned task metadata, with narrowly bounded legacy compatibility.
- **Independent verification reports**: Separate QA and final review evidence belonging to the resolved feature; both terminal verdicts govern publication and completion.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Both named unequal-number examples and the legacy equal-number example select the correct feature in 100% of the prescribed local and post-merge regression cases, without identity changes.
- **SC-002**: Every prescribed invalid association and invalid verification case is refused, with zero unauthorized publications or task completions and zero changes to unrelated backlog files.
- **SC-003**: One execution of the post-merge command against the actual isolated TASK-017 artifacts changes exactly the two intended metadata values in the copied task; a second execution changes no files. The real task and feature artifacts remain unchanged.
- **SC-004**: The complete relevant regression set passes, and independent QA and final review each produce terminal `Verdict: PASS` before TASK-054 is offered for human merge.
- **SC-005**: Reviewers receive one separate correction PR with its required merge order explicit, and its changes remain entirely within the stated tooling and workflow scope.

## Assumptions

- Existing task identifiers and task-specific branch naming remain authoritative. Feature directory numbers are independently allocated; existing artifact sets do not need migration or renumbering.
- Durable metadata is optional. Its representation, shared resolver placement, and error presentation are routine architectural choices provided the behavior above is preserved.
- Missing feature artifacts are expected before a new task's product stage creates its specification. Absence is a blocker whenever an existing feature is required for later verification, publication, or completion.
- PR #28's TASK-017 artifacts are available from its existing provider delivery branch for read-only copying into isolated verification fixtures. Their prior verdicts are fixture inputs for this tooling test, not fresh acceptance of provider behavior.
- `docs/PRODUCT.md` domain invariants and `docs/ARCHITECTURE.md` application boundaries remain unchanged. This CP1 tooling correction supports trustworthy delivery without adding football-market behavior or reopening the provider's CP2 requirements.
- The existing Agentflow workflow supplies subsequent independent product challenge, architecture, implementation, QA, and final review stages. This product stage defines their behavioral contract; it does not claim implementation or task completion.

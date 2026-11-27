# Implementation Plan: Agentflow Task Feature Directory Binding

**Branch**: `054-agentflow-task-feature-directory-binding` | **Date**: 2026-10-06 | **Spec**: [spec.md](spec.md)

**Input**: `specs/055-task-feature-binding/spec.md`; TASK-054 (CP1). The Spec Kit setup returns `055-task-feature-binding` as its session label; that is not the delivery branch.

## Summary

Replace numeric-prefix/mtime selection with one standard-library Python association and evidence boundary, shared by local Agentflow, stage verification, explicit completion, dependency reconciliation, and the post-merge command. Exact specification branch ownership wins over legacy equality; optional versioned `feature_directory` task metadata must agree. All completion transitions validate two contained terminal PASS reports before one narrowly scoped backlog write. Existing delivery authorization, workflow result, artifact, receipt and human merge gates remain intact.

## Technical Context

**Language/Version**: Python 3, existing tooling syntax requires 3.10+; local inspection used 3.14.4. Retain the runner's supported version, without raising it.
**Primary Dependencies**: Python standard library (`pathlib`, `re`, `json`, `subprocess`, `unittest`, `tempfile`, `hashlib`); existing Git/GitHub CLI/Spec Kit adapters. No new dependency.
**Storage**: Versioned Markdown/frontmatter and canonical feature files; ignored session pointers are downstream conveniences only. No database migration.
**Testing**: `unittest`, isolated temporary repositories, captured Git/gh publication adapters, real reconciler subprocesses, immutable provider artifact snapshots with SHA-256 provenance.
**Target Platform**: Existing local Python CLI and Ubuntu Actions; preserve POSIX and Windows launchers and direct-script import compatibility.
**Project Type**: Delivery tooling correction inside the modular monolith repository.
**Performance Goals**: One deterministic immediate-child `specs/` scan per resolution; no network lookup or mtime sorting. No new throughput SLA.
**Constraints**: One task; no application/provider changes, no TASK-017 artifact edits, no unrelated backlog edits, no real publication during tests; preserve workflow privileges and human merge authority.
**Scale/Scope**: One shared module, affected orchestration/probe/reconciler consumers, focused Python tests and fixture snapshots, tooling documentation. No settled-stack research.
**Unknowns**: None outstanding. Feedback 1 resolves the new-task boundary; strict scalar frontmatter is the conservative parser choice. Feature-specific inspection and unchanged fixture provenance are recorded in research.md.

## Constitution Check

| Principle / gate | Before research | After design |
|---|---|---|
| I: spec before code | PASS: canonical spec and product decision loaded; authoritative Feedback 1 (architecture rewind) and QA B1 loaded | PASS: contracts, requirement map and task ordering trace to spec |
| II: domain integrity | PASS: no market behavior in scope | PASS: all seven PRODUCT invariants unaffected; no Elixir/data changes |
| III: modular simplicity | PASS: tooling boundary only | PASS: standard-library helper, no services; ADR-0014 records durable tooling choices |
| IV: evidence-based quality | PASS: behavioral regressions required | PASS: test-first tasks, executable manifest, real isolated CLI, scoped syntax/whitespace/workflow checks |
| V: independent verification | PASS: critic and product decision read; no human decision pending | PASS: implementation precedes separate QA/review; terminal PASS and human merge preserved |
| Safety and CP1 delivery | PASS: architecture-only session | PASS: separate TASK-054 delivery before PR #28; no permission expansion or application suites |

These are design assessments, not claims that future implementation checks have passed. No constitutional exception is requested.

## Project Structure

### Documentation (this feature)

```text
specs/055-task-feature-binding/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  verification.json
  contracts/task-feature-binding.md
  tasks.md
  checklists/architecture.md
  handoffs/architecture.md
  handoffs/tasks.md
docs/adr/0014-durable-agentflow-feature-ownership.md
```

### Source Code (implementation boundary)

```text
agentflow                                  # orchestration and adapters
scripts/agentflow_feature.py                # new shared identity/resolution/evidence/completion policy
scripts/reconcile_merged_task.py            # thin merged-branch CLI adapter
scripts/workflow_artifact_probe.py          # authoritative active feature for checks/stage gates
scripts/agentflow_check.py                  # inherited active_feature; no unrelated receipt redesign
.github/workflows/agentflow-finalize.yml     # retain unchanged unless import execution needs a minimal fix
README.md                                  # existing Agentflow section only
test/scripts/agentflow_feature_test.py     # new resolver contract tests
test/scripts/agentflow_branch_test.py      # existing local delivery tests, expanded
test/scripts/agentflow_completion_test.py  # new explicit/dependency completion tests
test/scripts/reconcile_merged_task_test.py # expanded post-merge tests
test/scripts/workflow_artifact_probe_test.py # adapt fixtures; preserve probe regressions
test/scripts/task_feature_binding_acceptance_test.py # preflight, actual fixture, workflow/scope
tests/test_agentflow.py                   # existing lifecycle/probe regression fixtures
tests/test_agentflow_delivery.py          # existing history/delivery regression fixtures
test/scripts/fixtures/task_feature_binding/provider/ # exact four source snapshots + provenance.json
```

**Structure Decision**: Keep policy separate from Git/gh, workflow launching and CLI adapters. The helper accepts a repository root and explicit task/head identity, reads canonical files, and returns a resolved association or actionable error. It never launches agents, pushes, creates PRs or reads runner logs. File mutations are limited to a shared guarded task completion operation; publication retains its current adapter.

## Phase 0: Focused research

Use existing application decisions in `docs/ARCHITECTURE.md` and the constitution without a dependency survey. Resolve only the observed completion bypass, exact-title branch derivation, containment, candidate scope, retry boundary and source-fixture availability. See research.md and ADR-0014. No external documentation is necessary for these repository-specific unknowns.

## Phase 1: Shared design

### Identity and association

Implement the algorithm and diagnostics in contracts/task-feature-binding.md. Validate unique filename/frontmatter task identity and deterministic branch (`NNN` plus existing title slug). Branch-based consumers must match the complete expected branch, including legacy and metadata-only cases. Keep declaration parsing strict and candidate-scoped; reject every duplicate expected declaration even if metadata selects one. Do not require unrelated historical specifications to be repaired.

Use one strict scalar-frontmatter parser before any ownership, state, dependency, publication or completion decision. Reject unsupported lines and duplicate keys rather than silently discarding them. In particular, `feature_directory :`, `status :`, indented/quoted/case-variant keys and structured YAML cannot conceal conflicting metadata. Agentflow adapters must consume the same validated fields; the existing permissive `meta()` must not make critical decisions independently. Unknown fields in canonical scalar form and task body bytes remain preserved. See the contract for grammar and mutation rules.

Optional `feature_directory: specs/<immediate-child>` is a root-relative versioned frontmatter scalar. Empty, absolute, traversal, missing, duplicate, nested or escaping values fail. Both lexical and resolved containment matter. Exact canonical branch declarations alone support TASK-017 and TASK-020; no metadata migration.

Validate spec and reports resolve inside the selected feature. Contained symlinks are permitted; foreign-feature/outside escapes fail. A symlinked immediate child may resolve only to a directory still immediately under the real repository specs root; canonical aliases to the same target do not create two distinct features, but two distinct matching targets do.

Classify equal-number directories by validated ownership before counting legacy candidates. One or more safe specs with a single canonical declaration for a different TASK ID are foreign, excluded from legacy cardinality, and cannot block a new task with no own feature. This exception never applies to an explicit metadata target, a same-task wrong branch, duplicate/malformed declarations, unsafe/unreadable numbered candidates, or headerless legacy candidates. A unique readable headerless candidate retains legacy resolution; multiple eligible legacy candidates fail.

Absence is a typed non-error result only for an explicitly allowed pre-product lookup after that classification leaves no own/eligible legacy candidate and no invalid relevant information. Discovery for later stages, verification, publication and completion requires a resolved feature. Remove unused newest-feature selection. At start/resume/verify, set the downstream session pointer only after successful resolution; for pre-product absence clear a stale pointer before feature creation. Do not change Spec Kit numbering or allocation.

The Python stage/check `active_feature()` obtains the current delivery branch from Git, locates its task and uses the shared resolver, ignoring a missing/stale pointer for ownership. It rejects base/detached/wrong branches before accepting evidence. Spec Kit shell tools may still use the populated pointer as session context; they do not authorize delivery. Adapt existing probe fixtures with a deterministic local delivery branch/task/spec rather than weakening production validation.

### Consumers and transitions

- `feature_for_task()` wraps the shared resolver; history may allow true pre-product absence, but errors are never replaced with a newest-feature fallback.
- `finalize()` requires successful workflow execution, resolved spec/plan/tasks and both reports before review/no-pr/publication. Preserve existing blocked diagnostics for validly parsed tasks failing later workflow/report checks. Direct `publish()` rechecks branch, selected feature and report/artifact guards before status, commit, push or gh side effects; never accept a caller's foreign feature path. Stage manifest/receipt validation remains in the existing workflow readiness boundary, now resolved authoritatively.
- `verify()` resolves before launching its existing independent verifier; absent/unsafe associations cannot launch a verification against all specs. Preserve delegation permissions and recursion prevention.
- Explicit `complete()` keeps the existing user-invoked acceptance boundary (see complete skill) and review-only prerequisite. It delegates to the common guarded transition; no new automatic authorization flag or merge capability.
- `reconcile_merged_dependencies()` retains `review_pr_merged()` and dependency-only iteration. After confirmed human merge, use the same guard and reports; refuse missing/failed/foreign evidence and leave that dependency untouched. Do not infer new dependencies or auto-complete unmerged ones.
- Post-merge CLI validates supplied full branch and unique task identity first. A `done` task is then an unchanged successful no-op without feature/report reads. Otherwise require review, association and both reports. Validate both unique `status`/`active_run` fields and build the entire replacement in memory before one file replacement; preserve every other byte and unrelated files. Never perform two separate metadata writes that can partially complete a task.

Do not introduce new completion states or weaken prior publication checks. For unsupported or duplicate critical metadata, all consumers must refuse before writing any backlog file, including a blocked-state update: interpreting ambiguous status and then overwriting it is unsafe. Preserve the existing blocked-on-failure behavior only for validly parsed tasks failing later workflow/report checks. No push/PR/review promotion occurs for rejected evidence. Completion rejection performs no backlog write. Malformed UTF-8 and unreadable canonical files fail with task, expected branch and candidate context rather than a traceback-dependent fallback.

### Workflow, checkpoint and delivery scope

Keep `.github/workflows/agentflow-finalize.yml` merged-closed PR/main predicate, branch skip, pinned checkout, `contents: write`, serialized group, cancellation policy and human implementation-merge boundary. Test these exact safeguards. A Python import adjustment is permitted only if the real command demonstrates need; no broader Actions changes.

Retain separate TASK-054 publication. Include the existing task Outcome in the generated PR body so its explicit merge-before-PR-#28 instruction reaches reviewers; test captured PR text and artifact links. Do not publish during implementation tests. This is CP1 tooling reliability evidence, not CP1/CP2 application acceptance. Product invariants, provider adapter work and CP2 behavior remain outside the patch.

## Verification design and acceptance trace

`verification.json` maps all 12 FR and 5 SC identifiers (spec has no AC identifiers). Numbered scenarios are traced individually in checklists/architecture.md. Feedback regressions extend the same executable module checks: hidden-key refusal across every consumer and real start-path foreign-directory cases. Preserve the original adversarial diagnostic (it asserts the old bypass, so its eventual failure is not acceptance); tracked tests must assert the inverse refusal. Run the preserved root probe unchanged after the fix. All required receipts from the previous implementation are stale after this rewind and must be regenerated by the owner, followed by fresh independent QA/review. It requires tooling preflight, resolver matrix, local publication/verification, explicit/dependency completion, post-merge matrix, actual provider CLI fixture, workflow/scope assertions, probe regression, syntax compilation and whitespace checks.

There are no affected HTTP interfaces; runtime_required is false. Tooling preflight asserts Python compatibility, Git availability and immutable fixture hashes; actual-provider executes the actual post-merge CLI rather than mocking it. No Phoenix/PostgreSQL/Redis service is applicable. If an HTTP interface is later added, amend spec/plan/manifest to add service readiness and status/header/body runtime assertions before implementation continues.

The actual fixture is copied byte-for-byte from provider commit `1aa2731f048efcb1056a589b3b2ea938b843edd4` on `017-football-data-api-adapter`, associated with PR #28. Store only the task, spec and two reports under the test fixture root, preserving their paths. Record source commit, branch, PR and the hashes from research.md; no provider implementation is copied. Subprocess tests compare every fixture/backlog file before and after, assert exactly the two permitted values change, then assert a second run changes nothing. Confirm source snapshots and available source refs/real task files remain unchanged. Vendoring makes tests reproducible when the provider ref is not fetched; do not substitute synthetic successful reports.

Implementation writes tests before each changed policy and observes their relevant failure before implementation, then runs every manifest check through `python3 scripts/agentflow_check.py CHECK_ID` after final source edits. All implementation/developer tasks must complete before QA; only the two independent downstream tasks are stage-mapped. QA reruns checks independently and challenges assertions, then final review uses fresh QA and targeted checks. See quickstart.md for commands and tasks.md for ordering.

The independent verifier identified two directly affected existing tooling suites outside the original manifest. Adapt only their dependency, probe and history fixture preconditions to supply canonical task/spec/branch ownership and reviewed reports, retaining every original assertion and production guard. Include both suites as `legacy-tooling` and `legacy-delivery` checks (12 manifest checks total), and restrict the scope allowlist to these two additional test files. This completes SC-004's relevant regression coverage without adding application behavior or changing the association design.

## Complexity Tracking

No constitution violations. ADR-0014 records durable workflow ownership and containment decisions as a tooling deviation from historical numeric equality; it does not alter the application architecture baseline.

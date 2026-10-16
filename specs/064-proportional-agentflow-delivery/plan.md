# Implementation Plan: Proportional Agentflow Delivery and Measurable Efficiency

**Branch**: `064-proportional-agentflow-delivery` (spec declaration: `064-proportional-agentflow-delivery-and-measurable-efficiency`) | **Date**: 2026-10-16 | **Spec**: [spec.md](spec.md)

## Summary

Extend the existing Python/shell delivery tooling with executable CI applicability, conditional supporting-artifact validation, local integrity-bound evidence, bounded portable summaries, explicit feedback impact and honest telemetry. Reuse existing ownership, profiles and independent gates. No application implementation, database, API, publication permission or other backlog change is included. Human Feedback 1 and the refreshed independent challenge are incorporated, including repository-scoped stage assignment (FR-017–022). No further product decision is outstanding.

## Technical Context

**Language/Version**: Existing Python 3 standard library and POSIX shell/Bash; application checks use exact Elixir 1.20.3 and OTP 29.0.6/ERTS 17.0.6 from scripts/check_toolchain.sh. Node 24 and Ruby YAML are existing CI prerequisites.

**Primary Dependencies**: Existing Git, Spec Kit scripts, Agentflow Python helpers, Mix/ExUnit, npm/OpenAPI/Playwright; no new runtime library or service.

**Storage**: Existing ignored local filesystem and CI artifacts; bounded versioned final JSON summary. No application persistence change.

**Testing**: Python unittest behavior/subprocess fixtures; existing shell runner tests; existing ExUnit CI collection once per implementation/QA execution; OpenAPI Node tests and contract validator. Negative cases must fail meaningfully rather than merely match source strings.

**Target Platform**: Local POSIX development and Ubuntu 24.04 CI; retain existing Windows wrappers and backward-compatible CLI behavior with additive selection flags. OS differences are disclosed, not asserted identical.

**Project Type**: Repository workflow tooling within the existing modular monolith.

**Performance Goals**: No duplicate full profile in a stage; zero new versioned per-attempt receipts; final summary growth bounded by checks/requirements. No token savings target or claim without a comparable observed pilot.

**Constraints**: One implementation owner; independent product challenge, conditional human check and fresh separate QA/review remain. No broad live-log exploration, paid experiment, historical rewrite, credential output, push or merge from this stage.

**Scale/Scope**: One backlog task, six stories, existing supported workflow snapshots and legacy receipt shapes. No generic workflow engine replacement.

## Constitution Check

Pre-design: PASS. I: spec and challenge loaded; no unresolved product choice. II: application code, token supply, precision, trading atomicity, audit and immutable quotes remain unchanged and are protected by existing regression tests. III: extend current helpers, no infrastructure. IV: test-first behavior tasks and explicit manifest checks precede QA. V: independent sessions and both terminal PASS gates remain mandatory; humans merge.

Post-design: PASS. ADR-0027 resolves saved model assignments and attempt boundaries; ADR-0026 records durable changes to evidence placement, report bindings and conditional artifact policy; ADR-0014 remains ownership truth. Required checks are neither waived nor fabricated. QA/review reports are downstream deliverables, not planning claims.

## Supporting-artifact applicability

All four supporting artifacts are needed for this particular feature even though implementation will permit justified omissions on future minimal changes. This does not override the current skills' required outputs.

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve concrete CI discovery, evidence-binding and feedback/telemetry gaps in current tooling."},
  "data_model": {"required": true, "reason": "Local receipts, retry journals, final summary and usage records change shape and state semantics."},
  "contracts": {"required": true, "reason": "Feedback impact, shared artifact policy and evidence CLI/JSON interfaces change."},
  "quickstart": {"required": true, "reason": "Candidate checkout isolation, CI parity and post-review evidence finalization need a feature-specific validation sequence."}
}
```

Canonical artifacts remain required at their owning stages regardless of size. Exact schemas/state transitions live in data-model.md and contracts/workflow-delivery.md. Research cites existing decisions instead of surveying settled technology.

## Project Structure and boundary

- `scripts/agentflow_artifacts.py` (new shared applicability parser/CLI), `scripts/workflow_artifact_probe.py`, `.specify/scripts/bash/{setup-plan,setup-tasks,check-prerequisites}.sh`: consistent stage policy.
- `scripts/agentflow_ci_check.py` (new bounded adapter), existing `scripts/ci_unit_tests.sh`, `scripts/check_toolchain.sh`, `scripts/local_services.sh`: CI inventory, readiness and isolated candidate execution. Reuse existing command semantics; do not create another test profile.
- `scripts/agentflow_verification.py`, `scripts/agentflow_check.py`, `scripts/agentflow_evidence.py` (new finalizer): manifest, freshness, local evidence and portable finalization.
- `.agentflow/models.json` (new repository defaults), `scripts/agentflow_models.py` (new shared resolver/launch adapter); model contract in contracts/workflow-delivery.md.
- `agentflow`, `scripts/agentflow_feature.py` only if a shared guard integration is necessary, `scripts/agentflow_runtime.py`, `scripts/agentflow_codex.py`: feedback, resume, publication guard and allowlisted measurement. Preserve resolver semantics from ADR-0014.
- `.agents/skills/{speckit-plan,speckit-tasks,speckit-implement,speckit-analyze,speckit-converge,feedback,resume,verify,start}/SKILL.md`, `.specify/templates/{plan,tasks}-template.md`, `.agentflow/workflow.yml`, `.specify/workflows/desapp-delivery/workflow.yml`: same rules across entry points; hook dispatch logic remains intact. Generic `.specify/workflows/speckit/workflow.yml` uses the shared prerequisite policy rather than requiring a new engine.
- `docs/AGENT_CONTEXT_POLICY.md`, `docs/AGENT_VERIFICATION.md`, new `docs/AGENTFLOW_PILOT.md` and `docs/AGENTFLOW_MODELS.md`, `.gitignore`: aligned guidance/retention. Existing ignore roots already contain new local evidence; no deletion or untracking of historical evidence.
- `test/scripts/*_test.py`, shell discovery tests, new `test/support/workflow_scope.ex`, affected historical scope tests and `test/ci/quality_baseline_contract_test.exs`: behavioral coverage and pointer-independent CI; no relaxation of product assertions.
- Feature outputs: this plan, tasks.md, verification.json, research.md, data-model.md, contracts/workflow-delivery.md, quickstart.md, concise handoffs; downstream QA/review reports and evidence-summary.json.

Production `lib/`, migrations, product docs, checkpoint docs, global user model settings and unrelated backlog/specs are outside implementation scope. Changes to legacy tests are limited to eliminating private-pointer coupling and preserving accurate candidate-scope checks. Inspect other scope tests only if the actual clean CI execution exposes the same concrete failure.

## Design and critic resolution

1. **Executable parity, not inventory alone**: bind current CI workflow content, classify each obligation below, assert tool/service parity and required collection counts, run real commands. Changes to CI require applicability re-evaluation. A ci-required obligation without revision-bound evidence blocks before QA; this feature selects local equivalents for all affected executable obligations, avoiding a pre-QA publication dependency.
2. **Noncircular report finalization**: follow ADR-0026 exact output exclusions and freeze/finalize sequence. All canonical plans, contracts, policies, feedback and source remain bound. Record base revision plus source digest for an uncommitted candidate. Final report hashes are separate provenance; final summary is not execution proof.
3. **Bounded compatibility**: current schema-1 manifests remain; schema-2 local evidence is mandatory for this feature. Existing receipt and workflow formats are read/preserved, not trusted as current schema-2 proof. Resume current guards even for old saved snapshots. Missing proof reruns, malformed unsupported state refuses without rewrite. Pass -> fail/interruption invalidates pass first; persistent relevant-input failure scope survives sessions/irrelevant edits. See data-model.md.
4. **Honest efficiency**: deterministic fixtures compare minimal and necessary-artifact plans and repeated attempts' versioned file counts/bytes. The pilot is a protocol for the next normally authorized task; absent baseline remains unknown. No numerical savings, additional task launch or spending experiment is part of delivery. Historical Sol Medium is a comparison baseline; repository stage assignment is now authorized.

Feedback category is explicit structured input, not a semantic classifier. A mismatched requested stage fails before mutation; absent/ambiguous impact stays pending and blocks dependent work until classified. Existing feedback text is preserved. Implementation/test fixes return to develop; verification/design to architecture; behavior to product including a new independent challenge. QA/report-only repair still requires independent gates appropriate to its impact.

## Current CI obligation inventory

| Current workflow obligation | Local evidence / disposition |
|---|---|
| quality-baseline: checkout candidate, cache | Isolated clean candidate checkout with source digest and original base semantics, no private pointer; cache is optimization, not a passing check. |
| Install exact BEAM; verify toolchain | `preflight` invokes scripts/check_toolchain.sh; observed required versions recorded. |
| PostgreSQL 17.6 and Redis 8.2.1 health | `preflight` asserts pinned local service versions/readiness; unavailable services fail. No silent substitute. |
| Hex/Rebar, locked deps get/compile | quickstart setup with exact existing CI commands; preflight asserts availability/lock consistency; subsequent compile/tests fail missing deps. |
| Formatting | `mix format --check-formatted` once. |
| Warnings-as-errors | `MIX_ENV=test mix compile --warnings-as-errors` once. |
| Node 24, npm ci, Chromium install | Existing setup commands; preflight validates version, lock and browser launch. |
| OpenAPI test and JSON validation | `npm test --prefix tools/openapi`; `node tools/openapi/validate.mjs priv/static/openapi.json`. |
| Unit tests (default collection) | `clean-tests` runs scripts/ci_unit_tests.sh once with sentinel/nonzero collection assertions; includes existing default integration-tagged tests, excludes only existing performance behavior. No additional full unit/integration profile or historical CP1 coverage report. |
| Sonar native analysis + CP1 threshold | CI automation preserved. No changed lib/assets production analysis scope/configuration: remote scan is not a local TASK-064 prerequisite. Both live analysis and live project count remain remote CI obligations outside this unchanged local scope; local Sonar adapter negative fixtures (Python) and existing Sonar contract tests (CI collection) cover tooling regression only and do not certify the live count. No local claim of a remote PASS; if implementation changes analysis scope/config, return to architecture and require proper evidence. |
| agentflow-finalize post-merge reconciliation/push | Post-merge side effect is inapplicable before QA and is never simulated as publication. Local reconciliation and completion behavior tests verify preserved guard semantics. Remote post-merge CI remains unchanged. |

Additional affected workflow obligations: Python unittest discovery with explicit `*_test.py` pattern and nonzero suite; shell ci_unit_tests discovery fixtures; script syntax/byte-compilation; scope/policy/invariant checks and delivery regressions. The Workflow behavior tests step is wired into quality-baseline before its single full CI test command so future clean CI cannot omit Python or shell suites. Update bounded CI contract assertions to account for this without weakening formatting/compile/service checks. Refresh the CI inventory once those intended steps are added; unrecognized additions fail closed. No CP2 charts/orders/browser-product feature is claimed; no CP3 obligations are added.

## Test-first validation and acceptance coverage

Each story starts with failing behavior fixtures, then implementation, then focused green checks. Fixtures use disposable repositories/workflow states and deterministic model events, never current run logs or live model calls.

| Story / numbered scenarios | Automated acceptance evidence |
|---|---|
| US1.1–4 | CI command inventory/changes; missing pointer clean candidate; required counts and empty suites; wrong toolchain/missing services; one invocation per full collection; unavailable required evidence refused. `agentflow_ci_check_test.py` plus actual preflight/clean-tests and shell discovery fixtures. |
| US2.1–4 | Minimal vs necessary documents, every missing/empty/malformed applicability record, canonical/report stage enforcement, skill/hook/resume consistency and handoff bounds. `agentflow_artifacts_test.py` plus workflow probe regressions. |
| US3.1–5 | Bounded summary over repeated attempts, ignored output/no new tracked receipts, command/source/feedback/output tampering, cross-checkout/workspace/stage refusal, interruption recovery, two-failure stop, irrelevant edit/resume vs relevant repair, legacy formats and finalization order. `agentflow_evidence_test.py` plus existing probe/completion tests. |
| US4.1–4 | All six impact categories, combinations, explicit-stage conflict/no mutation, pending ambiguity, artifact preservation, saved snapshots, current guards on legacy resume and both fresh verdict gates. `agentflow_feedback_test.py`. |
| US6.1–7 | Per-field precedence and all six defaults; malformed/unknown/unsupported pairs; start/resume subprocess launch rejection with exactly one invocation, nonzero stage outcome and no fallback; immutable saved assignments, partial legacy/frozen cases, explicit adoption new attempt/session, changed repository between resolution and launch; observed identity unknown and gates intact. `agentflow_models_test.py` plus metrics/completion regressions. |
| US5.1–4 | Complete/partial/absent dimensions, observed/configured provenance, duplicate/conflicting/reordered/cumulative/reset/interrupted/resumed events; no subset double count; protocol fields, historical/new assignment boundaries and no experiment launches. `agentflow_metrics_test.py`. |

`agentflow_policy_test.py` enforces immutable product/checkpoint/publication boundary and explicit model policy and consistency with skill/template/workflow consumers, and validates manifest coverage plus all story scenario cases above. Behavioral tests, not only text assertions, establish guards. FR/SC -> concrete checks live only in verification.json; there are 32 FR/SC identifiers and no explicit AC identifiers in the current spec.

## Implementation and verification sequence

Setup fixtures and shared policy; deliver US1 parity; US2 conditional artifacts; US3 local evidence; US4 feedback; US6 stage assignment (P1); US5 metrics/protocol (P2); reconcile consumers and inventory. Finish all source/design edits before final manifest checks. Run final checks through agentflow_check.py, explicitly requesting development reuse only when valid. QA independently executes the same obligations without reuse; review uses fresh QA plus targeted risk checks. Only downstream Independent QA and Final review tasks are deferrable. Finalizer runs after both PASS reports and before existing publication. Never create dummy reports or receipts to satisfy planning.

## Complexity Tracking

No constitution violation. New small helpers separate policy parsing, CI execution, model selection and final summary assembly from the existing runner; they add no service/dependency. ADR-0026 justifies durable workflow deviations. No unresolved clarification remains.

## Stage assignment and critic dispositions

Repository defaults and exact CLI/persistence semantics are specified in contracts/workflow-delivery.md and ADR-0027. The resolver is pure and shared by pre-launch inspection, start and resume; the existing Codex wrapper applies one resolved pair before spawning. No global user configuration, live capability probe, classifier or recursive agent is introduced. Explicit launcher arguments win over ambient integration defaults; conflicting unmanaged model/effort flags fail rather than silently winning. Stage shell gates do not get model assignments. Tasks synthesis stays in the architecture session.

Critic 1: retry identity is stage + check + command + relevant obligation inputs, not aggregate stage failures. Interrupted running attempts recover as one failure; unrelated checks/edits and resume cannot clear the budget (ADR-0026).

Critic 2: normal resume uses saved settings. Adoption freezes a new assignment generation and starts a future attempt in a new child session, preserving interrupted/completed attempts. Missing legacy fields require explicit values; repository edits cannot fill them implicitly (ADR-0027).

Critic 3: full-source reuse remains conservative. Exact generated report paths are excluded from source binding; canonical design, CI, policy, current feedback and repository model configuration remain included. Summary binds final report hashes separately. Report-only changes leave execution bindings intact; source/config changes invalidate receipts (ADR-0026).

Critic 4: tests substitute the actual child executable, record invocation arrays, reject selected settings and assert start/resume propagate nonzero outcome, one invocation, failed provenance and unchanged gates. Resolver-only string tests are insufficient. Test spawn errors and provider error events even with exit zero; neither may produce success or fallback (ADR-0027).

Frozen run 72789de8 is permitted to retain its original launch configuration. This architecture session does not inspect that run or certify observed identity or execution of the new assignments. The new defaults are delivery requirements proven first through deterministic fixtures.

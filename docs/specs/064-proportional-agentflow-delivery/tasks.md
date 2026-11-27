# Tasks: Proportional Agentflow Delivery and Measurable Efficiency

**Input**: spec.md, plan.md, research.md, data-model.md, contracts/workflow-delivery.md, quickstart.md and ADR-0026.

**Tests**: Required by spec FR-012 and repository policy. Write behavior tests and observe their intended failure before implementation; import errors alone are not sufficient red evidence. All tasks begin unchecked. Prospective files named below must be created before completion. One implementation owner; [P] indicates optional concurrent work on independent files, not authorization to launch agents.

## Phase 1: Setup

- [X] T001 Reconfirm current TASK-064 feedback and source boundary; reconcile concrete CI inventory against `.github/workflows/quality-baseline.yml`, `.github/workflows/sonarcloud.yml` and `.github/workflows/agentflow-finalize.yml` in `specs/064-proportional-agentflow-delivery/plan.md` without adding a coverage-profile gate.
- [X] T002 Create reusable disposable Git/workflow/evidence/model-event fixtures in `test/scripts/support/agentflow_delivery_fixtures.py`; preserve tracked/untracked/deletion and saved-snapshot cases without inspecting live run logs or invoking models.

## Phase 2: Foundational prerequisites

- [X] T003 Add and run failing boundary/gate behavior tests in `test/scripts/agentflow_policy_test.py` for immutable product/checkpoint/model/publication rules, canonical-stage requirements, no implementation task deferral and two independent terminal PASS guards; preserve existing completion fixtures in `test/scripts/agentflow_completion_test.py`.
- [X] T004 Define shared fixture schema builders and baseline snapshots in `test/scripts/support/agentflow_delivery_fixtures.py` for applicability, CI inventory, local receipts, final summary, assignment generations and feedback/usage records per `specs/064-proportional-agentflow-delivery/data-model.md`; no production behavior changes yet.

Foundation checkpoint: deterministic isolation and explicit failure assertions exist. Production guards are implemented within their owning story below.

## Phase 3: US1 — Delivery failures before QA (P1, MVP)

**Independent test**: Changed CI, no pointer, empty suites, wrong versions and absent services fail before QA; the real default CI collection runs once on the candidate.

- [X] T005 [US1] Write and run failing subprocess tests in `test/scripts/agentflow_ci_check_test.py` for inventory drift, local-equivalent vs unavailable required CI evidence, exact environment mismatch, service absence, zero discovery and one full-suite invocation; extend `test/scripts/ci_unit_tests_test.sh` for failure propagation and missing sentinel/count.
- [X] T006 [P] [US1] Write failing pointer-absence/candidate-isolation and retained-scope cases in `test/scripts/agentflow_clean_checkout_test.py` and `test/ci/workflow_scope_test.exs`, covering base branch, exact durable feature ownership and a current candidate with tracked deletions/untracked tests.
- [X] T007 [US1] Implement inventory/preflight/isolated clean-tests commands in `scripts/agentflow_ci_check.py`, reusing `scripts/check_toolchain.sh`, `scripts/local_services.sh` and `scripts/ci_unit_tests.sh`; validate collection counts, versions, required evidence and candidate identity with bounded output and no credential capture.
- [X] T008 [US1] Implement pointer-independent test-scope resolution in `test/support/workflow_scope.ex`; update `test/football_market/market/scope_test.exs`, `test/football_market/statistics/scope_test.exs` and `test/football_market/providers/scope_test.exs` to retain historical product assertions and exact current allowlists without private metadata. Extend only other scope tests demonstrated to have this same failure, with regression evidence.
- [X] T009 [US1] Wire nonzero Python `*_test.py` discovery and shell runner fixtures into `.github/workflows/quality-baseline.yml`; update its bounded assertions in `test/ci/quality_baseline_contract_test.exs` and `test/ci/fixtures/quality-baseline.sha256` if its existing fixture changes. Preserve all existing CI commands/services and run focused US1 tests; reconcile new inventory in `specs/064-proportional-agentflow-delivery/verification.json` and `specs/064-proportional-agentflow-delivery/plan.md`.

## Phase 4: US2 — Necessary supporting documents (P1)

**Independent test**: Minimal and necessary-document fixture features retain all canonical artifacts; justified omissions pass, missing applicable artifacts fail through direct skills, hooks and resume.

- [X] T010 [US2] Write and run failing behavioral applicability tests in `test/scripts/agentflow_artifacts_test.py`, extending `test/scripts/workflow_artifact_probe_test.py` for malformed/missing decisions, canonical stage ownership, missing/empty applicable files, minimal vs necessary file counts and legacy plans.
- [X] T011 [US2] Implement the shared applicability parser/JSON CLI in `scripts/agentflow_artifacts.py` and use it in `scripts/workflow_artifact_probe.py`; reject missing applicable documents and unsafe paths while preserving stage-appropriate canonical requirements and legacy handling.
- [X] T012 [US2] Integrate shared applicability validation into `.specify/scripts/bash/setup-plan.sh`, `.specify/scripts/bash/setup-tasks.sh` and `.specify/scripts/bash/check-prerequisites.sh`; cover direct and resume consumers with fixture subprocess tests in `test/scripts/agentflow_artifacts_test.py`. Do not require a completed plan before setup can create it.
- [X] T013 [US2] Align `.agents/skills/speckit-plan/SKILL.md`, `.agents/skills/speckit-tasks/SKILL.md`, `.agents/skills/speckit-implement/SKILL.md`, `.agents/skills/speckit-analyze/SKILL.md`, `.agents/skills/speckit-converge/SKILL.md` and `.specify/templates/plan-template.md` plus `.specify/templates/tasks-template.md` with shared applicability, canonical completeness and delta handoffs; preserve required hook dispatch and validate through `test/scripts/agentflow_artifacts_test.py`.

## Phase 5: US3 — Compact trustworthy evidence and safe resume (P1)

**Independent test**: Current unchanged development evidence permits explicit reuse; every altered/missing/interrupted/cross-checkout case fails. Repeated attempts add no versioned receipts and do not grow the final summary.

- [X] T014 [US3] Write and run failing behavior tests in `test/scripts/agentflow_evidence_test.py` for schema-2 receipt integrity, command/source/canonical/feedback changes, exact report exclusions, stage/workspace mismatch, path escapes, legacy receipts and bounded summary growth across attempts.
- [X] T015 [US3] Add failure/interruption/retry tests in `test/scripts/agentflow_evidence_test.py`: pass followed by failure, termination while running, two failures per stage/check/command/relevant inputs across resume/irrelevant edits, independent check budgets, relevant repair, altered output, missing inventory and unavailable proof; assert legacy files and saved states remain byte-identical.
- [X] T016 [US3] Move new receipts, hashes and retry journals to ignored schema-2 workspace/stage namespaces in `scripts/agentflow_check.py` and `scripts/agentflow_verification.py`; share readiness/reuse validation, preserve historical tracked receipts and make missing legacy proof rerun instead of pass.
- [X] T017 [US3] Implement persistent relevant-obligation retry scopes and interruption recovery in `scripts/agentflow_check.py`; bind all canonical inputs/current feedback, retain conservative full-source reuse checks and exclude only exact generated output paths in `scripts/agentflow_verification.py`. Do not reset retry limits for session/report/unrelated edits.
- [X] T018 [US3] Implement schema-1 bounded final-summary assembly and validation in `scripts/agentflow_evidence.py`; record base revision/source/manifest and final report bindings, per-check environment/coverage/availability and both independent verdicts; reject summary-only workspace readiness and make same-input finalization idempotent.
- [X] T019 [US3] Integrate current readiness guards into legacy/current resume and summary finalization after independent review but before publication in `agentflow`, `.agentflow/workflow.yml` and `.specify/workflows/desapp-delivery/workflow.yml`; test saved snapshots without the new steps in `test/scripts/agentflow_evidence_test.py` and preserve human-only merge.
- [X] T020 [US3] Align evidence guidance in `docs/AGENT_VERIFICATION.md`, `docs/AGENT_CONTEXT_POLICY.md`, `.agents/skills/resume/SKILL.md` and `.agents/skills/verify/SKILL.md`; verify existing `.gitignore` contains every new local output and run focused US3 plus probe/completion regressions in `test/scripts/agentflow_evidence_test.py` and `test/scripts/agentflow_completion_test.py`. Do not delete or untrack historical evidence.

## Phase 6: US4 — Earliest-stage feedback repair (P1)

**Independent test**: Implementation correction preserves product/design; verification/design and product changes reopen their owners; conflicts/pending ambiguity block, and repair requires fresh independent gates.

- [X] T021 [US4] Write and run failing feedback/rewind behavior tests in `test/scripts/agentflow_feedback_test.py` for all impact categories/combinations, requested-stage mismatch/no mutation, absent impact/pending feedback, existing unclassified text, active process protection and old saved step orders.
- [X] T022 [US4] Implement structured impact classification and earliest-owner stage validation in `agentflow` using `specs/064-proportional-agentflow-delivery/contracts/workflow-delivery.md`; preserve feedback text, upstream artifacts, saved-state backups and unaffected evidence subject to current freshness. No keyword-based semantic inference.
- [X] T023 [US4] Enforce pending-impact/current-feedback guards and required cited regressions through resume/readiness in `agentflow` and `scripts/workflow_artifact_probe.py`; integrate fresh QA/review after repair without changing ownership semantics in `scripts/agentflow_feature.py` unless strictly necessary.
- [X] T024 [US4] Align `.agents/skills/feedback/SKILL.md`, `.agents/skills/start/SKILL.md`, `.agents/skills/resume/SKILL.md`, `.agentflow/workflow.yml` and `.specify/workflows/desapp-delivery/workflow.yml` with impact routing and artifact preservation; run `test/scripts/agentflow_feedback_test.py` plus existing branch/feature/completion regressions.

## Phase 7: US6 — Explicit stage selection and stable resumes (P1)

**Goal**: Implement Feedback 1 now without changing independent sessions or gates.

**Independent test**: All six defaults, per-field precedence, development overrides and saved/adopted/partial legacy/frozen cases work; rejected selections fail visibly with exactly one child invocation, no fallback and no false success.

- [X] T025 [US6] Write and run failing resolution/config tests in `test/scripts/agentflow_models_test.py` for every stage default, per-field precedence including partial overrides, duplicate/unknown flags, unsupported pairs, strict task scalar parsing, dry-run no mutation and development-only isolation; use `test/scripts/support/agentflow_delivery_fixtures.py`.
- [X] T026 [US6] Write and run failing executable-child start/resume tests in `test/scripts/agentflow_models_test.py`: capture actual argv, provider rejection including error events with exit zero, spawn failure, one invocation/no fallback, separate stage sessions, unchanged PASS/publication gates, saved/partial legacy/frozen runs, adoption new attempt/session and repository edits between resolution and launch. Assert structured failed-attempt provenance and nonzero workflow outcome; do not launch live models.
- [X] T027 [US6] Add strict schema-1 repository defaults in `.agentflow/models.json` and pure shared resolver in `scripts/agentflow_models.py`; implement the six pairs, per-field sources, pair validation and strict task `develop_model`/`develop_effort` parsing through the existing ADR-0014 parser, with no global setting or automatic classifier.
- [X] T028 [US6] Integrate start/resume flags, no-write dry-run and immutable local assignment generations into `agentflow`; preserve known saved settings, require explicit legacy missing values, reject resume selection flags without adoption, protect active processes and make adoption create only future attempts/sessions per `specs/064-proportional-agentflow-delivery/contracts/workflow-delivery.md`. Bind pending generations safely to runner IDs and preserve existing saved workflow bytes.
- [X] T029 [US6] Apply the frozen selected pair at the child launch boundary in `scripts/agentflow_codex.py` using `scripts/agentflow_models.py`; reject unknown/ambiguous stages and conflicting unmanaged launch settings, preserve error-event failure even on zero child exit, propagate availability/spawn failures once, and emit configured/resolved/observed provenance with null unknowns. Keep tasks in architecture and separate product challenge/develop/QA/review sessions.
- [X] T030 [US6] Document repository defaults, dry-run inspection, explicit development Sol override, stable normal resume, `--adopt-models` future-attempt behavior, legacy missing-field recovery and frozen run exception in `docs/AGENTFLOW_MODELS.md`; align `.agents/skills/start/SKILL.md`, `.agents/skills/resume/SKILL.md`, `.agentflow/workflow.yml` and `.specify/workflows/desapp-delivery/workflow.yml` without a new session for tasks or live capability probes.
- [X] T031 [US6] Run focused `test/scripts/agentflow_models_test.py` and `test/scripts/agentflow_completion_test.py` green; assert all Story 6 scenarios and critic 2/4 cases are covered, source binding includes `.agentflow/models.json` and task overrides, and schema generations remain ignored. Reconcile `specs/064-proportional-agentflow-delivery/verification.json` before final developer checks.

## Phase 8: US5 — Honest efficiency measurement (P2)

**Independent test**: Deterministic telemetry preserves provenance/unknowns, never double counts replay or token subsets, and a complete next-task protocol exists without a task/model launch.

- [X] T032 [US5] Write and run failing event/aggregation tests in `test/scripts/agentflow_metrics_test.py` for complete/partial/absent dimensions, configured vs observed identity, duplicate/conflicting/reordered/cumulative/reset/resumed/interrupted records and legacy identity-less events.
- [X] T033 [US5] Extend allowlisted structured events in `scripts/agentflow_codex.py` with schema/attempt/event identity, configured and observed model/effort provenance and explicit unknowns; preserve conservative ambiguous-counter handling and never scan unrelated historical logs or expose private session identifiers.
- [X] T034 [US5] Extend `scripts/agentflow_runtime.py` metrics aggregation and `agentflow` metrics output with idempotent attempt/event accounting, measured subtotals and per-dimension coverage/unknowns; preserve legacy readers in `scripts/workflow_token_audit.py` and add compatibility tests there only if affected by the new event format.
- [X] T035 [US5] Write `docs/AGENTFLOW_PILOT.md` with named baseline/configuration, next-authorized-task boundary, reproducible metrics and generated-file count/byte commands, retry causes, quality/verdict observations and comparability limits; mark missing baseline unknown and name the approved stage defaults and explicit development overrides, separate workflow from model changes, and prohibit fabricated savings or an additional task/benchmark launch.
- [X] T036 [US5] Validate protocol completeness, correct staged defaults, explicit override provenance and no hidden switching or extra task invocation using `test/scripts/agentflow_metrics_test.py` and `test/scripts/agentflow_policy_test.py`; run focused metrics tests and retain explicit unknown execution identity where unavailable.

## Phase 9: Cross-cutting integration and developer verification

All implementation and applicable developer checks below must complete before independent QA. Focused red/green story tests are distinct from the final once-per-stage full checks.

- [X] T037 Complete cross-consumer/legacy-resume/report-finalization behavior cases in `test/scripts/agentflow_policy_test.py`; reconcile all six stories' numbered scenarios and all four refreshed critic findings against `specs/064-proportional-agentflow-delivery/verification.json` and preserve ADR-0026/ADR-0027/source boundaries. Finish every source/design edit before final manifest execution.
- [X] T038 Execute manifest `preflight` through `scripts/agentflow_check.py` and record exact tool/service/CI parity in local evidence; failures block rather than skip obligations in `specs/064-proportional-agentflow-delivery/verification.json`.
- [X] T039 Execute manifest `script-syntax`, `workflow-tests` and `shell-discovery` through `scripts/agentflow_check.py`; verify nonzero collections, negative guards, compatibility, preservation, all scenario/FR/SC coverage and no raw versioned attempt output per `specs/064-proportional-agentflow-delivery/verification.json`.
- [X] T040 Execute manifest `format`, `compile`, `openapi-tests` and `openapi-contract` through `scripts/agentflow_check.py` using the exact existing CI commands in `specs/064-proportional-agentflow-delivery/verification.json`.
- [X] T041 Execute manifest `clean-ci-tests` through `scripts/agentflow_check.py`, proving the current candidate's complete default ExUnit collection without private feature metadata and without a duplicate full-profile or CP1 coverage run; reference ignored command output in `specs/064-proportional-agentflow-delivery/handoffs/develop.md`.
- [X] T042 Reconcile completed artifacts/check evidence and write concise changes, risks, elapsed check time and independent QA guidance in `specs/064-proportional-agentflow-delivery/handoffs/develop.md`; confirm `scripts/workflow_artifact_probe.py` plan/tasks/develop readiness passes with only T043/T044 deferred and no fabricated independent reports or summary. Summary finalization is the implemented post-review runner obligation tested by T018/T019, not an unchecked developer task.
- [ ] T043 [gate:qa] Independent QA rerun every applicable manifest check without developer reuse, challenge every scenario and FR/SC mapping, verify current source/environment/local evidence and write `specs/064-proportional-agentflow-delivery/qa-report.md` plus `specs/064-proportional-agentflow-delivery/handoffs/qa.md`, ending report exactly `Verdict: PASS` only on success.
- [ ] T044 [gate:review] Final review inspect fresh independent QA evidence, architecture/security/checkpoint preservation and targeted uncovered risks; write `specs/064-proportional-agentflow-delivery/review-report.md` plus `specs/064-proportional-agentflow-delivery/handoffs/review.md` with required backlog-impact entry and exact terminal verdict; verify the implemented `scripts/agentflow_evidence.py` post-review finalizer is required before publication of `specs/064-proportional-agentflow-delivery/evidence-summary.json`.

## Dependencies and execution order

`T001 -> T002 -> T003 -> T004 -> US1 -> US2 -> US3 -> US4 -> US6 -> US5 -> T037..T042 -> T043 -> T044 -> runner summary finalization -> existing publication`.

The first green increment/MVP is US1 after foundations, validated independently. It is not sufficient to declare TASK-064 complete: all six stories are required. No deployment/demo/publication is authorized by this tasks file. Existing Agentflow publication permission is unchanged.

US2 can be fixture-tested without US1; integrated readiness uses US1's inventory. US3 uses the US2 policy and US1 obligations; US4 uses US3 evidence semantics; US6 uses the receipt/resume guard interfaces and emits provenance consumed by US5; US5's event processing is independently fixture-testable but final integration uses all earlier guards. Tasks touching agentflow/shared workflow files are sequential. Within each story, test tasks precede the corresponding code changes; run the intended failing assertions before implementation, then focused green tests.

## Parallel examples and strategy

- US1: T006 independent checkout/scope fixture work may run alongside T005 preflight fixtures after T004; implementation T007/T008 waits for those tests, and T009 waits for both implementations.
- US2: after T010, policy parsing and template drafting can be prepared separately, but T012/T013 integration follows T011; do not concurrently edit the same skill/script.
- US3: after T014/T015, final-summary schema fixtures can be prepared alongside local receipt work; T018 final integration waits for T016/T017 and T019 waits for both.
- US4: saved-snapshot and impact-category cases can be exercised independently inside T021; changes T022–T024 remain sequential because they share runner/readiness consumers.
- US6: resolution and launcher fixture matrices can be prepared independently inside T025/T026; T027–T031 implementation/integration waits for both red suites, with shared runner and wrapper edits sequential.
- US5: protocol drafting T035 can be prepared alongside event fixtures T032; T036 waits for event capture/aggregation T033/T034 and completed protocol.

Use incremental red/green story delivery, then one frozen final check pass. Never run a second full profile to compensate for unclear applicability; resolve the obligation and manifest instead. Stop after two failures for unchanged relevant inputs, report cause/time/evidence and repair. Independent QA reruns; review targets uncovered risk. Humans retain merge authority.

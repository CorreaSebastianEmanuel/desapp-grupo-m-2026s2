# Tasks: Agentflow Preflight and Failure Recovery

**Input**: `specs/068-agentflow-preflight-recovery/` — spec.md, plan.md, verification.json and all four applicable supporting artifacts. TASK-070 / branch `070-agentflow-preflight-and-efficient-failure-recovery`.

**Policy**: Current `backlog/feedback/TASK-070.md` Feedback 1 overrides prior planning. One implementation owner; full workflow because this changes workflow behavior. All checkboxes remain open until executed. Tests are mandatory under FR-012 and repository rules. Write each behavioral test first, observe the intended failure, implement, then pass focused regressions. Do not run full profiles during routine iteration. No implementation publication or merge is authorized by this checklist.

## Phase 1: Setup

- [X] T001 Audit actual launch, receipt, feedback and profile consumers in agentflow, scripts/ci_unit_tests.sh, .agentflow/workflow.yml and .specify/workflows/desapp-delivery/workflow.yml; create specs/068-agentflow-preflight-recovery/verification-audit.md with command/profile/env identities, source/stage consumers, CI/E2E/HTTP obligations and planned invocation counts, without executing full profiles.

## Phase 2: Foundational prerequisites

- [X] T002 Write failing contract tests in test/scripts/agentflow_stage_checks_test.py for safe diagnostics, manifest dependency/state/static metadata rejection, cycles/unknown IDs and conservative legacy defaults; assert no execution/state mutation on invalid configuration and no secret canaries in output.
- [X] T003 Implement shared allowlisted diagnostic records in scripts/agentflow_runtime.py and optional manifest metadata validation in scripts/agentflow_verification.py per data-model.md and contracts/workflow-recovery.md; pass T002 without weakening existing receipt, HTTP or task-stage validation.

Foundation checkpoint: typed safe outcomes and fail-closed metadata work before any story executor consumes them.

## Phase 3: US1 — Effective child preflight (P1; MVP)

Goal: prove launch uses the exact context checked and never launches on failed/unknown readiness. Independent acceptance: controlled start/resume/provider fixtures pass or refuse correctly, protected bytes and fake-service mutation counters unchanged (US1 scenarios 1–4; FR-001–003; SC-001/002).

- [X] T004 [US1] Write failing test/scripts/agentflow_preflight_test.py fixtures for child-only PATH/cwd/defaults, configuration changes, override and executable/version/setting/service failures, timeout/unknown, deterministic safe results, redaction and byte-for-byte preflight purity.
- [X] T005 [P] [US1] Add failing launch-order and exact env/cwd/argv equivalence regressions in test/scripts/agentflow_providers_test.py for start/resume, outer and each provider-stage spawn, both supported shims and mocked Windows behavior; no live provider calls.
- [X] T006 [US1] Create scripts/agentflow_preflight.py final-context builder, typed stage/check inventory, bounded read-only evaluator and CLI; use existing toolchain/provider rules and return diagnostics without saved-state or service writes.
- [X] T007 [US1] Integrate the checked context into agentflow, scripts/agentflow_codex.py and scripts/agentflow_opencode.py; move model/state writes after outer preflight, recheck changed inputs and before each provider spawn, and do not create a stage attempt on preflight refusal.
- [X] T008 [US1] Run focused test/scripts/agentflow_preflight_test.py and test/scripts/agentflow_providers_test.py plus affected tests/test_agentflow.py cases; verify T004/T005 oracles and record concise outcomes for specs/068-agentflow-preflight-recovery/handoffs/develop.md.

## Phase 4: US2 — Useful failure evidence and continuation (P1)

Goal: account for every required check and continue only proven-independent work. Independent acceptance: mixed failures, dependency/state blocks and interruption preserve all outcomes with no incomplete PASS (US2 scenarios 1–5; FR-004–006/010/012; SC-002/003).

- [X] T009 [US2] Extend failing test/scripts/agentflow_stage_checks_test.py for mixed outcomes, unknown effects, transitive dependencies/contaminated state, declaration-order reports, fresh QA enforcement, fake-clock duration and two-worker static scheduling; reject forged static argv and prove no Mix/E2E overlap.
- [X] T010 [P] [US2] Add failing signal/early-exit/abrupt-termination fixtures to test/scripts/agentflow_evidence_test.py for incremental non-PASS reports, every required inventory row, single recovery, secret redaction and provider exit before the batch starts.
- [X] T011 [US2] Create scripts/agentflow_stage_checks.py ordered runner and atomic inventory/outcome journal using scripts/agentflow_check.py compatibility helpers; permit only registered disjoint static groups (max two), drain before serial work, block unsafe dependents and collect durations/counts/peak workers.
- [X] T012 [US2] Add incremental QA report projection and handled-signal finalization in scripts/agentflow_runtime.py, scripts/agentflow_codex.py and scripts/agentflow_opencode.py; recover abrupt death truthfully, preserve provenance gates and require independent semantic assessment before PASS.
- [X] T013 [US2] Run focused test/scripts/agentflow_stage_checks_test.py and test/scripts/agentflow_evidence_test.py with real short-lived fixture subprocesses; confirm serial/two-worker results agree, handled SIGINT/SIGTERM are nonzero and SIGKILL recovery cannot promote historical evidence.

## Phase 5: US3 — Retry and feedback governance (P1)

Goal: enforce two unchanged failures at both full-stage and per-check scope, and three durable feedback repair cycles. Independent acceptance: third unchanged attempt and fourth feedback repair refuse across resume, relevant correction is auditable, upstream bytes survive implementation-only feedback (US3 scenarios 1–5; FR-007/008; SC-004/005).

- [X] T014 [US3] Write failing test/scripts/agentflow_recovery_test.py for full-attempt boundaries, nested/idempotent finalization, two failures/third refusal across resume, per-check stop, interruption accounting, corrupt journal refusal and material-versus-unrelated input changes including scoped feedback.
- [X] T015 [P] [US3] Extend failing test/scripts/agentflow_feedback_test.py for earliest mixed-impact owner, product challenge ordering, ambiguous/pending refusal, preserved upstream bytes and durable three-cycle cap; cover pre-existing counts >=3, third repair completion, fourth refusal, absent-key default and explicit configuration without silent resets.
- [X] T016 [US3] Implement persistent full-stage attempt identities and component-scoped retry guards in scripts/agentflow_stage_checks.py, scripts/agentflow_verification.py and agentflow; carry one token through provider/check children, retain per-check safeguards, and keep full-source receipt freshness distinct from retry relevance.
- [X] T017 [US3] Align feedback rewind/pending governance in agentflow and .agentflow/config.toml with three cycles and retained history; preserve incoming feedback/evidence on exhaustion, refuse dependent launch and recommend a human-approved split without creating tasks or resetting budgets automatically.
- [X] T018 [US3] Run focused test/scripts/agentflow_recovery_test.py, test/scripts/agentflow_feedback_test.py and affected tests/test_agentflow_delivery.py cases; prove count/fingerprint persistence and artifact-preservation assertions before proceeding.

## Phase 6: US4 — Remove duplicate local full profiles (P1)

Goal: baseline validates parity without executing profiles; stabilize once, then execute one complete development manifest and fresh independent QA. Independent acceptance: instrumented native invocation counts, stale receipt rejection, unchanged CI/HTTP obligations and measured static concurrency (US4 scenarios 1–4; FR-009–013; SC-006/007).

- [X] T019 [US4] Write failing test/scripts/agentflow_dedup_test.py for zero native profile calls from parity in all receipt states, exact wrapper/profile/env contract, missing/mismatched obligation refusal, unchanged CI/application paths/product invariants (assert no edits to lib/, priv/, assets or existing application behavior), fresh QA, receipt freshness and legacy baseline compatibility: new runs use parity while a resumed legacy run continues its saved baseline exactly once without changing snapshot bytes; include HTTP detector/runtime assertions with unavailable service and bare-request negative fixtures.
- [X] T020 [P] [US4] Extend failing test/scripts/agentflow_policy_test.py with Vibecode procedure examples/exclusions: small clear reversible low-risk work requires brief spec/preflight/focused tests/CI/independent PASS gates/human merge; financial/security/data-integrity/external-contract/migration/workflow or uncertain work stays full-flow; no executable shortcut selector is introduced.
- [X] T021 [US4] Implement scripts/agentflow_stage_checks.py --ci-parity using read-only command/profile/env comparisons and isolated test/scripts/ci_unit_tests_test.sh stub assertions; never fall back to native suites and never let parity substitute for current development receipts.
- [X] T022 [US4] Replace local baseline with parity in .agentflow/workflow.yml and .specify/workflows/desapp-delivery/workflow.yml for new runs. Preserve saved legacy workflow snapshots byte-for-byte; resume the saved baseline command exactly once for those runs because Spec Kit resume reloads its saved workflow and exposes no workflow override. Retain QA/report/CI gates and keep .github/ unchanged.
- [X] T023 [US4] Document the Vibecode procedure in docs/WORKFLOW_SPEED.md with risk/rollback/acceptance fields, required independent gates and explicit exclusions; preserve separate docs-only guard and shared-cache warnings, and state TASK-070 is excluded.
- [X] T024 [US4] Run focused test/scripts/agentflow_dedup_test.py, test/scripts/agentflow_policy_test.py and test/scripts/ci_unit_tests_test.sh; compare worker=1/2 with controlled static fixtures from test/scripts/agentflow_stage_checks_test.py and record actual times/counts in specs/068-agentflow-preflight-recovery/verification-audit.md without repeating full profiles.

## Phase 7: Cross-cutting verification and handoff

- [X] T025 Register every new workflow test identity in config/test_profiles.json without changing profile membership; isolate the diagnosed fresh-process quotes outcome test in its own existing integration partition, extend the profile audit contract, and run focused inventory/ownership/HTTP/readiness regressions.
- [X] T026 Align docs/AGENT_CONTEXT_POLICY.md, docs/AGENT_VERIFICATION.md, README.md and .agents/skills/start/SKILL.md, .agents/skills/resume/SKILL.md, .agents/skills/feedback/SKILL.md, .agents/skills/verify/SKILL.md, .agents/skills/speckit-implement/SKILL.md with focused iteration, frozen final manifest, independent continuation, parity, static-only concurrency and three feedback cycles; finalize specs/068-agentflow-preflight-recovery/verification-audit.md and verification.json coverage before input freeze.
- [X] T027 Freeze source/design/feedback and execute every check in specs/068-agentflow-preflight-recovery/verification.json via scripts/agentflow_stage_checks.py --stage develop --reuse or scripts/agentflow_check.py CHECK_ID --reuse; complete services/preflight, formatting/compile/Credo, assets/database/inventory, behavioral regressions and exactly one applicable ci_profiles pair, with safe continuation, two-failure stops and closed browser prerequisite causes. Relevant repairs invalidate evidence; no CP1 coverage, clean-tests or baseline suite duplication.
- [X] T028 Complete the applicable scenarios in specs/068-agentflow-preflight-recovery/quickstart.md and write specs/068-agentflow-preflight-recovery/handoffs/develop.md under 400 words with changes, command/evidence references, measured counts and QA guidance; reuse already-current development checks rather than repeating profiles and leave all unsatisfied tasks open.
- [X] T029 Reconcile all T001–T028 artifacts/check outcomes in specs/068-agentflow-preflight-recovery/tasks.md, then execute python3 scripts/workflow_artifact_probe.py develop --readiness and the fast parity step; require all implementation/check tasks complete and all current receipts before QA.
- [X] T030 Independent QA [gate:qa] rerun specs/068-agentflow-preflight-recovery/verification.json freshly with --stage qa and no reuse; challenge every acceptance scenario, failure/compatibility oracle and invariant, continue independent checks after isolated failure, and write specs/068-agentflow-preflight-recovery/qa-report.md plus handoffs/qa.md with terminal PASS only for complete fresh acceptance.
- [X] T031 Final review [gate:review] inspect implementation and fresh specs/068-agentflow-preflight-recovery/qa-report.md evidence, run targeted checks only for uncovered risks, verify checkpoint/domain/scope and authoritative feedback alignment, and write specs/068-agentflow-preflight-recovery/review-report.md plus handoffs/review.md ending Verdict: PASS only if independently justified.

## Dependencies and implementation strategy

`T001 → T002 → T003 → US1(T004–T008) → US2(T009–T013) → US3(T014–T018) → US4(T019–T024) → T025 → T026 → T027 → T028 → T029 → T030 → T031`.

All stories are P1. Foundation blocks all stories. US2 uses US1 launch context; US3 uses US2 journals; US4 uses the validated runner and recovery seams. Tests remain independently runnable with temporary repositories/fake processes, without running a live Agentflow task. Start with US1 as the demonstrable MVP; it is not sufficient to close TASK-070. Complete all stories before independent QA. No application behavior, financial rule, provider boundary or checkpoint scope changes.

Parallel opportunities concern disjoint test drafting after prerequisites: US1 T004/T005, US2 T009/T010, US3 T014/T015 and US4 T019/T020. These are per-story examples, not permission to spawn agents or execute test suites concurrently. Production edits share modules and remain ordered under one owner. Runtime concurrency is separately limited to the two registered static commands; no concurrent Mix/E2E or separate QA/review overlap.

Only T030/T031 are deferred downstream gates, mapped in verification.json. T001–T029 including all applicable test and developer-check tasks must finish before QA. Independent QA reruns the complete manifest for this high-risk workflow task; review uses fresh QA evidence and targeted discrepancies. Neither local parity nor documentation can replace CI or human merge.

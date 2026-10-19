---
id: TASK-066
title: Remediate existing Elixir Credo findings without behavior changes
type: task
checkpoint: CP2
priority: high
status: review
depends_on: none
active_run: 15435314
---

## Outcome

Prerequisite for TASK-065, explicitly approved by the user after the quality integration expanded into refactors across 40 application files. Introduce or reuse pinned Credo 1.7.19 as a dev/test runtime-false dependency and a documented standard default-priority invocation. Assess and remediate all existing first-party Elixir findings, including application code, configuration, migrations and maintained test/support code, without changing business behavior, public outputs, error ordering, transaction boundaries, locking, idempotency, financial invariants, or test assertions. Reuse the preserved draft cleanup patch from TASK-065 only after independent review; partial refactors are not accepted evidence. Preserve meaningful subset-pattern assertions in E2E fixtures and all native profile ownership/receipt safeguards. Add tests for any behavioral correction and run existing affected unit, integration and actual browser E2E regressions. Do not disable standard rules, suppress findings, add a baseline, increase thresholds, remove tests, reset databases or weaken checks. Keep SonarCloud probes, whole-application coverage collectors, report adapters and new mandatory CI integration in TASK-065. Completion requires fresh independent QA and final review with Verdict: PASS and human merge. TASK-065 remains blocked until this cleanup is completed.

## Preserved draft

Local ignored `tmp/task066-split/TASK-066-draft.patch` preserves 71 existing-source refactors, including 40 application files, plus the minimal Credo dependency/configuration needed to evaluate them. `tmp/task066-split/manifest.json` records the base revision, paths and SHA256 digests. The application/test refactors were removed from TASK-065's diff after verifying a lossless reverse application of the archived patch. Shared Credo prerequisites remain in its integration draft until this prerequisite lands; they must not be delivered twice.

The patch is incomplete and unverified as a whole. The last complete Credo measurement before subsequent corrections reported 71 findings. A corrected E2E subset assertion and 42 passing targeted regressions describe the pre-split snapshot only. Reassess the full remaining findings and run all required checks independently; never treat this draft or historical test result as task completion. The task is captured, not started; use the normal start workflow from a clean checkout.

## Execution guidance

Use the normal specify hook and persist the resolved `.specify/feature.json`; later product-decision checks require that pointer. Do not apply the preserved draft until this task has its own approved specification and implementation plan. Review the entire draft against those artifacts, especially financial/authentication paths and the E2E subset-pattern assertion.

The draft was based on commit 57b26cc. The local services were last verified at PostgreSQL 55432 and Redis 6379; inspect actual service mappings again before choosing a fresh task-owned partition. Inherited sandbox socket errors are permission failures, not evidence of missing services. Ask for approved execution access when necessary; do not disable checks or infer passes. Run targeted regressions after causal fixes, and do not substitute repeated unchanged full-suite runs for diagnostics. Keep all TASK-065 instrumentation, Sonar probes and credentials outside this task.

---
id: TASK-075
title: Required Dialyzer analysis with trustworthy PLT caching
type: task
checkpoint: CP2
priority: high
workflow: thinflow-v1
status: todo
depends_on: TASK-074, TASK-068
active_run: none
---

## Outcome

Build on TASK-068 to integrate compatible pinned Dialyxir and Dialyzer into existing CI, resolve dependency type-model limitations, define production and test-support scope, cache PLTs with correct invalidation, and progress to a trustworthy mandatory check with isolated detection and recovery evidence.

## Acceptance

- Reuse `specs/068-assess-dialyzer-compatibility-and-operational-cost/assessment.md`. It measured a carefully constructed local PLT, not clean hosted CI or turnkey Dialyxir adoption. Verify current compatibility and pin Dialyxir and the OTP/Elixir-provided Dialyzer toolchain; record actual versions and locked dependencies.
- Resolve or individually explain unresolved dependency functions/types and type-model problems before calling the analysis reliable. Address the recorded optional/native dependency types, Ecto.Multi opaque-type signals, test-only compile-time hooks and intentional invalid callback fixtures. A produced PLT or zero first-party findings with an invalid dependency model is not a clean result.
- Define and document application versus test-support scope, build profile and included dependencies. Keep deliberate fixtures and production findings distinguishable. Any exception must identify its exact finding, reason and scope; no broad warning suppression or hidden baseline.
- Cache PLTs in the existing workflow with explicit invalidation for runner/platform compatibility, exact OTP and Elixir, dependency/lock changes and relevant Dialyzer configuration/scope. Verify cache-key changes with focused checks; do not rebuild cold PLTs for every key test.
- Classify current findings and implement a documented gradual rollout ending in a trustworthy mandatory check through the existing required gate. Any interim informative mode must be visibly labelled non-blocking, with unresolved work explicit. Informative execution alone does not complete mandatory protection or this task's final acceptance.
- Run the real analyzer on an isolated sample with a demonstrable type/contract error; preserve file/line/rule or warning-kind evidence and a failing check, then show the corrected sample passes. Keep the sample out of application behavior and preserve analyzer errors separately from findings.
- Record one useful cold and warm/cache-hit timing with environment and cache identity; reuse TASK-068's historical observations as context. Do not repeat benchmarks without a changed relevant input or a concrete diagnostic need.
- Reuse existing CI/test/report mechanisms and preserve Sobelow, Credo, tests, TASK-067 accounting and SonarCloud checks. Larger application/type remediation outside this scope must be reported and preserved as a concrete blocker.

## Execution gate

TASK-074 is a sequencing dependency so its quality-workflow integration lands before another analyzer changes the same dependencies/workflow. Start in a separate branch/PR from clean main only after human merge and done-state reconciliation of TASK-074 and TASK-068. A dependency merely in review is insufficient, even if the harness offers it as ready. Do not mark unresolved mandatory adoption complete; no automatic merge. After human merge, continue with TASK-076.

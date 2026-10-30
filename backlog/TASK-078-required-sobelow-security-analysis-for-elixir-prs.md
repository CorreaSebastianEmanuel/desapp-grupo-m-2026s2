---
id: TASK-078
title: Required Sobelow security analysis for Elixir PRs
type: task
checkpoint: CP2
priority: high
workflow: thinflow-v1
status: todo
depends_on: TASK-069, TASK-065
active_run: none
---

## Outcome

Add compatible pinned Sobelow analysis to the existing quality workflow, triage current findings, enforce a documented blocking policy, and prove detection and recovery with isolated unsafe and corrected fixtures. Reuse the current CI and preserve application behavior.

## Acceptance

- Select and lock an exact Sobelow version compatible with the repository's pinned Elixir/OTP and Phoenix dependencies. Verify the actual version, supported checks, finding metadata and exit behavior rather than assuming Java/Sonar severity semantics.
- Analyze the current application, classify the existing findings and document the analyzed scope, limitations and blocking policy using the tool's real capabilities. Resolve findings within the security-analysis scope; explain any necessary larger product correction as a blocker rather than silently refactoring application behavior.
- Justify each accepted exception individually with its rule, location and rationale. No blanket exclusions, broad suppressions, finding-count threshold chosen to hide existing results, or disabled security checks to obtain green CI.
- Integrate into the existing quality workflow and required aggregate path. Findings covered by the blocking policy and analyzer execution/configuration errors must fail the control. Keep finding details with file, line and rule where the analyzer supplies them.
- Exercise the real analyzer and the same CI control on an isolated, intentionally unsafe sample: record the detected finding and failing outcome, then the corrected sample and passing outcome. Do not rely only on mocked exit codes or put a vulnerability in application code.
- Preserve tests, Credo, TASK-067 coverage, existing SonarCloud checks, permissions and secret protection. Retain bounded, non-sensitive evidence for detection, failure propagation and recovery.

## Boundaries and reuse

This task adds security analysis, not another framework, dashboard or test pipeline. TASK-050 remains responsible for broader functional API/UI hardening; do not duplicate its validation, authorization, rate-limiting or feature work. Use focused development checks and the required stabilized-candidate controls; do not repeat full suites without changed inputs or a concrete failure.

## Execution gate

Start from clean main only after TASK-069 / PR #67 and TASK-065 are human-merged and their backlog states reconciled to done. Agentflow's willingness to start against a dependency in review does not waive this user-required merge gate. Use this task's own branch and PR, never implement it in TASK-069 and never merge automatically. After human merge, continue with TASK-079.

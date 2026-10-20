---
id: TASK-065
title: Elixir source inventory and required Credo CI
type: task
checkpoint: CP2
priority: high
status: todo
depends_on: TASK-066
active_run: none
---

## Outcome

Make the existing TASK-066 Credo analysis an enforceable, reviewable CI check. Identify the first-party tracked Elixir files considered by the current Credo configuration, show the effective analyzed file list, and justify any exclusions so that files cannot be silently omitted. Reuse the pinned Credo dependency, standard default-priority invocation, rules, and reviewed source scope already delivered by TASK-066, including maintained tests and support code. Do not repeat its remediation or silently narrow its scope.

Run Credo as a mandatory step in the existing quality workflow: a failing invocation or invalid/incomplete source inventory must fail its required CI result independently of the SonarCloud result. Use the smallest implementation supported by the existing toolchain and workflow. Add focused automated tests for source inclusion/exclusion, missing or stale inventory entries, and failure propagation. Document the local commands, analyzed scope, exclusion reasons, rule level, limitations, and the triggering revision in CI evidence. Explain that zero Credo findings does not establish the absence of bugs or equivalence to SonarCloud native Java analysis.

Preserve application behavior, TASK-066 rules and findings policy, existing JavaScript and Elixir coverage reports, SonarCloud checks, CP1 gates, and current unit/integration/browser E2E profiles. Existing regression gates remain required; this task does not redesign their runners or add another coverage execution pipeline.

## Boundaries

- No whole-application coverage collector, export merger, coverage inventory, new coverage threshold, or coverage report adapter.
- No Dialyzer dependency, compatibility assessment, PLT work, or adoption decision.
- No SonarCloud compatibility probe, external Elixir finding/coverage import, credentials, or account-permission changes.
- No domain/application refactors, new language analyzer, suppression baseline, disabled standard Credo rules, or new general-purpose verification/report framework.
- Reuse existing profiles and CI infrastructure. Make only the minimal changes needed to register and verify the new quality checks.

## Deferred work

- TASK-067 owns whole-application Elixir coverage and its report reconciliation.
- TASK-068 owns the Dialyzer compatibility and cost assessment.
- TASK-069 owns the minimal SonarCloud external-report compatibility probe and any supported imports.

## Fresh execution

The user approved this narrower outcome on 2026-10-20. Start a new SDD run from main containing merged TASK-066. Generate a new specification and plan from this outcome; do not resume the earlier broad run or automatically apply its specification, implementation, reports, receipts, or task-specific feedback. The old draft is preserved separately for reference and is not acceptance evidence. This scope change does not mark any implementation or verification gate complete.

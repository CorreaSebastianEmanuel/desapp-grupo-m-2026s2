---
id: TASK-065
title: Whole-application Elixir quality analysis and coverage
type: task
checkpoint: CP2
priority: high
status: todo
depends_on: none
active_run: none
---

## Outcome

Establish verifiable quality checks for all first-party Elixir application code, independently of SonarCloud native language support. Inventory analyzed files and reconcile omissions explicitly. Add mandatory Credo analysis in CI and evaluate Dialyzer compatibility and cost before deciding its adoption. Generate whole-application Elixir coverage with documented justified exclusions, preserving existing CP1 inventory reports and gates. Verify SonarCloud support for external Elixir findings and coverage using a minimal reproducible probe; import only supported reports and document unsupported metrics without claiming full native analysis. Ensure failures in required Elixir checks fail CI even when the SonarCloud gate passes. Add automated tests for report adapters, source inventory completeness, malformed or missing reports and gate failure cases. Preserve existing JavaScript coverage, SonarCloud checks and application behavior. Document local commands, report scope, limitations and exact-revision CI evidence. No self-hosted SonarQube deployment, custom language analyzer, automatic issue suppression, arbitrary coverage threshold or changes to SonarCloud account permissions are included.

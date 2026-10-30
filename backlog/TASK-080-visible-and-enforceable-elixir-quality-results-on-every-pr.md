---
id: TASK-080
title: Visible and enforceable Elixir quality results on every PR
type: task
checkpoint: CP2
priority: high
workflow: thinflow-v1
status: todo
depends_on: TASK-065, TASK-067, TASK-071, TASK-078, TASK-079
active_run: none
---

## Outcome

Reuse Credo, Sobelow, Dialyzer, existing tests and TASK-067 coverage to show useful per-PR Actions summaries and linked file-line-rule findings, distinguish analyzer outcomes, and prove integration with the existing required merge gate and actual repository protection without claiming Java-equivalent analysis.

## Acceptance

- Reuse existing Credo, Sobelow and Dialyzer outputs, audited tests and TASK-067 collectors/reconciliation. Do not reconstruct collectors, add a framework/dashboard or introduce another test pipeline. Reuse the existing audited execution for tests and coverage with only necessary workflow integration; do not rerun complete profiles merely to format or publish results.
- For every in-scope PR revision, publish a readable GitHub Actions summary and links to retained reports. Findings include file, line and rule/warning kind where supplied; absent tool metadata remains explicit. Show native tool versions, revision, analyzed scope and measured coverage provenance. Keep evidence non-sensitive.
- Distinguish approved, failed due to findings, not executed/skipped, and analyzer execution/configuration error. Missing, stale, malformed or incomplete reports and an informative analyzer mode cannot be presented as a passing required analysis. Preserve useful diagnostics and failure artifacts.
- Integrate analyzer outcomes with the existing `ThinFlow required` mechanism and preserve its current safeguards. Inspect the actual main-branch protection/rulesets and required status contexts, including enforcement limitations/bypass, and correlate exact-head checks. A failing subprocess or a check displayed in Actions alone is not proof that GitHub prevents merge.
- Verify the effective required-check configuration read-only. If external configuration or access is missing, document the exact pending setting, required context and evidence/access gap. Do not silently change repository security settings or claim merge blocking without proof; unresolved effective protection remains pending, not completed work.
- Demonstrate an isolated controlled problem producing a visible native finding with file/line/rule, the CI control's failed outcome, then correction and an approved outcome. Use the real analyzer/control and current workflow, with revision/run/report evidence. Keep unsafe fixtures outside application behavior and distinguish this control evidence from separately verified GitHub merge enforcement.
- Retain SonarCloud for its supported languages and document TASK-069's observed Elixir import limits: ignored coverage and unproven issue visibility. No normal Elixir import is enabled based solely on scanner acceptance or a green gate.
- Document a capability/gap matrix for maintainability, types/contracts, security and coverage. Coverage is a test-execution measurement, not bug absence; tool-specific rules are not total detection or equivalence with native Java analysis in SonarCloud. Any remaining informative modes, unexecuted tools or external settings stay explicit.

## Boundaries and reuse

TASK-052 remains the final release/quality closure; this task delivers per-PR visibility and enforceability and does not replace release acceptance. Preserve profile ownership, receipt integrity, existing quality gates, secret protection and application behavior. Use focused development proofs, then the repository-selected candidate checks once inputs stabilize.

## Execution gate

Start from clean main in this task's own branch/PR after all listed prerequisites are human-merged and reconciled to done. A review-state dependency is not authorization to start, even if Agentflow lists it as ready. Keep pending protection or required-analyzer work visible and do not mark it done. Human merge remains mandatory.

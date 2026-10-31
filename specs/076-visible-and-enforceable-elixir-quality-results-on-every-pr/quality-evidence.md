# Per-PR Elixir quality evidence

## Controls and limits

| Area | Required evidence | What it establishes | What it does not establish |
| --- | --- | --- | --- |
| Maintainability | Credo default-priority invocation and effective-input inventory | Findings for the maintained Elixir scope at the reported revision | Bug absence, complete issue discovery, or equivalence to SonarCloud's native Java analysis |
| Types and contracts | Dialyzer model and application reports for dev and test | Reported type and contract warnings for analyzed files | A proof of all runtime behavior or contracts |
| Security | Sobelow strict JSON result and complete scan accounting | Reported security rules and exact reviewed exceptions | Exhaustive security coverage or absence of vulnerabilities |
| Coverage | TASK-067 validated native executable-line report, its profile receipts and source snapshot | Which application lines were executed by the audited unit/integration profiles | Correctness, bug absence, E2E/nested-BEAM coverage, or a minimum quality threshold |
| SonarCloud | Existing project analysis and supported-language checks | Existing JavaScript LCOV and configured supported-language results | Elixir report compatibility. TASK-069 observed that generic coverage imported zero of 217 files and external issue visibility was not demonstrated; ordinary Elixir imports remain disabled. |

The PR Actions summary links retained artifacts and source findings to the exact checked-out revision. Analyzer findings retain file, line, and the native rule/warning kind when available. A report with missing metadata says so explicitly. Approved, findings-blocked, skipped, and execution/configuration-error states are separate; a missing, stale, malformed, or incomplete required report fails closed.

The authorized B1/B2 repair handles the pinned Credo formatter's optional line/column positions without inventing rule identifiers. Evidence validation errors are contained within their analyzer or Dialyzer phase: the summary retains revision, unaffected outcomes, coverage provenance and available artifact links, and its final result remains nonpassing. Regression controls use native Credo output and the producers' timeout/incomplete/missing-report shapes, including an explicit failed workflow step with otherwise successful phase reports.

## Required-check integration

The workflow's `ThinFlow required` job aggregates the exact workflow-run results of `Quality baseline`, `End-to-end profile`, and `SonarCloud`. Its summary prints the tested revision and all three outcomes. This proves CI aggregation, not branch protection by itself.

Read-only GitHub API inspection on 2026-10-31 used the authenticated repository read context:

- `GET /repos/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/branches/main/protection` returned HTTP 404, `Branch not protected`.
- `GET /repos/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/rulesets?includes_parents=true` returned an empty list.
- The required status context to configure is exactly `ThinFlow required`.
- No repository security setting was changed. Effective merge enforcement, bypass restrictions, and exact-head protection are **unverified** because `main` currently has no visible protection or ruleset.

Pending external setting: configure branch protection or an applicable ruleset for `main` that requires the exact status context `ThinFlow required`. Evidence still needed after that setting is made: read-only effective configuration showing the context and enforcement/bypass policy, plus a PR exact-head check showing `ThinFlow required` completed on the head eligible for merge. Until then, this task makes no claim that GitHub blocks merge.

## Controlled finding and recovery

The focused `SobelowCiTest.test_real_finding_and_recovery_reach_the_pr_summary` uses the pinned native Sobelow control on an isolated temporary source tree. It records the unsafe SQL finding with source file, line, and native rule; verifies the summary labels it `Failed due to findings` and links to that exact line; then corrects the query and verifies the summary labels the same control approved. The source is outside application paths and is not included in project behavior.

The current workflow runs this test inside its required Sobelow analysis step and uploads `tmp/sobelow-ci/` even after failure. `summary-controls.json` records the revision, workflow run/attempt when present, analyzer version, unsafe/corrected native reports, and both rendered summaries. This controlled CI result is separate from repository merge enforcement.

This develop workspace has focused local test results but no published task PR or exact-head Actions run. Therefore it does not yet contain a hosted revision/run/artifact URL for the controlled fixture or the aggregate. Those hosted receipts remain pending publication and must be checked on the final PR head; local test output is not represented as hosted enforcement evidence.

## Evidence lifecycle

TASK-067 coverage is produced by the existing audited unit/integration profile executions and validated from their receipts; it is not regenerated for formatting or publication. Credo, Sobelow, Dialyzer, coverage reports, and controlled Sobelow evidence are uploaded as attempt-specific artifacts with 14-day retention. The feature summary reports the exact PR revision. An eventual exact-head hosted `ThinFlow required` result and configured branch protection remain downstream evidence, not inferred from local implementation checks.

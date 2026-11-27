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

Published [PR #82](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/pull/82) initially tested revision `ce8ae2823c640693aa3cac79f6c5a1db408acd92` in [run 41228774520](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/41228774520). Credo, Sobelow (including the native controlled fixture), Dialyzer, E2E and SonarCloud passed. The [retained Sobelow artifact](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/41228774520/artifacts/13054076209) contains the finding/correction evidence. The aggregate failed because coverage validation did not finish before the job timeout; this run is not approval for merge.

## Hosted timeout and processing repair

The initial hosted job reached its 35-minute limit during final coverage validation. Both audited profiles had completed at 18:48:13 UTC: 686 unit and 708 integration cases. The [retained coverage artifact](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/41228774520/artifacts/13053758185) contains the 15 exports, 15 normalized outputs and assembled report, while status correctly remains `running`, never `complete`.

Native normalization previously reconstructed the same full expected counter set in a separate Mix invocation for every partition, then repeated that work during independent report validation. The repair uses one native batch per pass, reconstructs that set once from validated source/BEAM hashes, rechecks bindings for each job, and starts fresh `:cover` state for every import. Final validation independently reconstructs the baseline in its own batch and still compares every normalized output, module/line population and artifact hash. No profile is rerun or removed, and the 35-minute job limit remains unchanged.

Local measured control on the pinned toolchain with `ERL_FLAGS='+S 4:4'` and 337 compiled modules: three full exports took 53.69 seconds through the previous single-export invocations and 17.65 seconds through one batch, with identical JSON results (67% less processing time). A batch of 15 full exports took 28.58 seconds and matched the previous reader's result for each export. These are processor measurements with deterministic native exports, not a claim about total hosted suite time. Actions now prints bounded phase start/completion/duration records for preflight, audited profiles, native normalization, native verification and report validation. The repaired PR head still requires its own hosted `ThinFlow required` result.

## Evidence lifecycle

TASK-067 coverage is produced by the existing audited unit/integration profile executions and validated from their receipts; it is not regenerated for formatting or publication. Credo, Sobelow, Dialyzer, coverage reports, and controlled Sobelow evidence are uploaded as attempt-specific artifacts with 14-day retention. The feature summary reports the exact PR revision. An eventual exact-head hosted `ThinFlow required` result and configured branch protection remain downstream evidence, not inferred from local implementation checks.

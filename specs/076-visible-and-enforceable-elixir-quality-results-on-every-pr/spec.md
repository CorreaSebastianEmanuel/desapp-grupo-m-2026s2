# Outcome specification: Visible and enforceable Elixir quality results on every PR

**Feature Branch**: `076-visible-and-enforceable-elixir-quality-results-on-every-pr`  
**Task**: `TASK-076`

## Outcome

Every pull request revision receives a readable GitHub Actions quality summary backed by the existing Credo, Sobelow, Dialyzer, audited test, and TASK-067 coverage evidence. Findings link to their source line and retain the analyzer's rule or warning kind when available. The current `ThinFlow required` aggregate remains authoritative for CI outcome, while actual GitHub merge enforcement is reported only when confirmed from repository protection settings.

## Acceptance

- [ ] Existing analyzer and audited test/coverage outputs are reused; tests and coverage are not rerun to render or publish reports.
- [ ] Each in-scope PR revision publishes an Actions summary with revision, native tool versions, analyzed scope, analyzer outcomes, coverage provenance, and links to retained reports.
- [ ] Findings expose file, line, and analyzer rule/warning kind where supplied; absent metadata is labeled unavailable. Findings link to the exact checked-out revision.
- [ ] Approved, findings-blocked, skipped/not-executed, and execution/configuration-error outcomes remain distinct. Missing, stale, malformed, incomplete, or informative-only evidence cannot be represented as an approved required analysis.
- [ ] The aggregate `ThinFlow required` fails when any constituent required analysis fails or its evidence cannot be validated. Existing profile ownership, receipts, protections, and SonarCloud checks remain intact.
- [ ] A controlled unsafe fixture produces a native file/line/rule finding, a failed CI-control outcome, then an approved outcome after correction. Evidence is isolated from application behavior and tied to the current report/control logic.
- [ ] Main-branch protection and repository rulesets are inspected read-only. If `ThinFlow required` is not effectively required, the exact pending setting/context and evidence gap are documented; no security setting is changed and no merge-blocking claim is made.
- [ ] SonarCloud continues to analyze supported languages. TASK-069's ignored Elixir coverage and unproven external-issue visibility remain explicit; ordinary Elixir report imports stay disabled.
- [ ] A capability/gap matrix covers maintainability, types/contracts, security, and coverage. It states that coverage measures executed code, analyzer rules are bounded, and these controls do not establish bug absence or equivalence with native SonarCloud Java analysis.

## Scope

- Extend the existing quality workflow to render validated analyzer and coverage evidence into a PR summary and source links, and retain report artifacts on success or failure.
- Add focused tests for report validation, status distinctions, finding links/metadata, summary publication, aggregate failure propagation, and controlled analyzer detection/recovery.
- Record analyzer capability limits, TASK-069 observations, exact-head CI integration, and the read-only repository-protection result in this feature's evidence document.
- Reuse the current test profile receipts and TASK-067 collector outputs without rerunning profiles for publication.

## Non-goals

- New analyzer, report framework, dashboard, test pipeline, coverage collector, or SonarCloud Elixir import.
- Application behavior, existing analyzer policies/exceptions, profile scheduling, receipt schemas, secret permissions, or branch/repository security-setting changes.
- Claims of native Java-equivalent analysis, universal issue detection, bug absence, or merge enforcement without effective protection evidence.

## Risk

- Declared: high; CI workflow and required status behavior. Existing path-to-risk classification is authoritative.
- Any missing or invalid evidence must fail closed. Repository protection is external state and remains pending unless verified; the builder will not alter it.

## Decisions

- Reuse the current `Quality baseline` job and its evidence artifacts; publish a single summary after all current analyses and coverage evidence are available, without rerunning audited test profiles.
- Preserve `ThinFlow required` and existing SonarCloud behavior. TASK-069 evidence keeps generic Elixir issue and coverage imports disabled.
- Read-only GitHub API inspection on 2026-10-31 returned `Branch not protected` for `main`; no repository rulesets were returned. The precise required context is `ThinFlow required`. Effective merge enforcement therefore remains pending external repository configuration and exact-head protection evidence.
- On 2026-10-31, the user explicitly authorized one additional grouped repair of independent evaluator findings B1/B2: native Credo positions are optional, and invalid analyzer evidence must retain a full nonpassing summary. The repair uses current ThinFlow checks and a fresh independent evaluation before resuming the existing verdict gate; global harness limits and saved workflow state stay intact.

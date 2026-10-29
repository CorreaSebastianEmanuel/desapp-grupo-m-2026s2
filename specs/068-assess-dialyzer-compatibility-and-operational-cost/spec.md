# Assess Dialyzer compatibility and operational cost

**Feature Branch**: `068-assess-dialyzer-compatibility-and-operational-cost`

**Task**: `TASK-068`

## Outcome

Produce a reviewable assessment of running Dialyzer against the project on its pinned Elixir 1.20.3 / OTP 29.0.6 toolchain. Record reproducible PLT construction and application analysis commands, actual elapsed time and peak memory when measurable, compatibility with compiled project/dependency BEAM files, warning categories and whether findings identify actionable defects. Compare the proposed local workflow with the existing CI job. End with an evidence-based recommendation to adopt or defer; distinguish measured facts from estimates and unavailable hosted-CI observations.

## Acceptance

- [ ] A concise assessment artifact records the revision, toolchain, exact commands, scope, environment, raw warning output or a stable summary, elapsed time and peak memory for each completed measurement.
- [ ] PLT generation and analysis are attempted using the existing lockfile and compiled first-party application/dependency BEAM files, without adding a dependency or changing CI.
- [ ] Findings are reviewed against source and classified as actionable, false positive/limitation, or unreviewed; no finding is claimed useful without a source-level explanation. Warning output from OTP and dependencies is summarized separately from first-party findings.
- [ ] The recommendation addresses compatibility, repeat-run cost, PLT invalidation/maintenance, CI fit, and the evidence limits. Failed or unavailable measurements remain explicit.
- [ ] This compact specification contains only the sections Outcome, Acceptance, Scope, Non-goals, Risk, and Decisions.
- [ ] The fast-lane guard accepts `specs/**` and `REVIEW.md` as already permitted by ThinFlow's documentation policy, while still rejecting application changes.

## Scope

- Inspect the pinned toolchain, locked dependencies, existing compile/quality commands, and CI quality workflow.
- Run a bounded local compatibility and cost probe with a temporary PLT outside the repository; document exact reproduction steps and results.
- Document the recommendation in `assessment.md` beside this specification.
- Apply the authorized minimal guard compatibility repair and regress the real selector/guard mismatch.

## Non-goals

- Add Dialyzer or Dialyxir dependencies, CI jobs, mandatory gates, persistent PLT artifacts, or workflow policy changes.
- Remediate application-wide findings, change application behavior or permissions, or add SonarCloud imports or coverage collectors.
- Reuse archived TASK-065 assessment results as current evidence.

## Risk

- High for the guard repair under the existing harness rule; the Dialyzer assessment remains read-only. No application behavior, permissions, CI jobs, or path-risk policy changes.

## Decisions

- Use the pinned local Elixir/OTP toolchain and current locked dependencies. Keep generated PLT files under the operating system temporary directory and remove them after measurement.
- A local result can establish compatibility and local cost only. Hosted CI performance or credentials are reported as unmeasured unless directly observed.
- The minimal guard repair aligns the executable check with the existing reviewed policy; it does not broaden that policy.

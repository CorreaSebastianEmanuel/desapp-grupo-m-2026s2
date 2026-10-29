# Outcome specification: Verify SonarCloud external Elixir report compatibility

**Feature Branch**: `069-verify-sonarcloud-external-elixir-report-compatibility`

**Task**: `TASK-069`

## Outcome

Provide a bounded, opt-in experiment in the existing SonarCloud workflow to determine whether the project's PR analysis imports a generic Elixir issue and TASK-067 application coverage, and which project measures change. Bind every run to the open internal TASK-069 PR and exact checked-out head. Preserve the normal JavaScript LCOV import, SonarCloud quality gate, and independent Credo gate. Enable no normal import until project evidence demonstrates it.

## Acceptance

- [ ] A deterministic synthetic issue on a TASK-065-maintained source path and a generic report generated from fresh TASK-067 coverage are bound to the checked-out revision and hashed.
- [ ] An explicit manual dispatch accepts the TASK-069 PR number only on its open internal PR branch, base `main`, and exact current head. It runs three ordered analyses on that same revision: control, issue-only, and coverage-only.
- [ ] Each completed analysis has a machine-readable result binding its Sonar CE task/analysis to the requested PR and revision. Record issue presence and each of `open_issues`, `bugs`, `vulnerabilities`, `code_smells`, `coverage`, and control measure `ncloc` separately against the control result. Missing or stale evidence is `unverified`, never evidence of unsupported behavior.
- [ ] Probe results are uploaded even when a scanner or quality gate fails; the job still fails for any failed analysis or gate. Credentials remain protected runner environment values and are absent from command arguments, logs, summaries, and artifacts.
- [ ] Focused automated tests cover report generation, observation classification and revision safeguards, exact PR/ref safeguards, and preservation of the normal JavaScript, SonarCloud, and Credo gates. Tests do not assert project compatibility.
- [ ] Probe documentation gives the bounded dispatch command, exact inputs, output artifact contract, current observation status, and limits. External generic imports remain distinct from native Elixir analysis.

## Scope

- Update the existing `.github/workflows/sonarcloud.yml` manual-dispatch interface and add a probe-only job; retain its normal `workflow_call` and non-probe dispatch behavior.
- Reuse `scripts/application_coverage.py run` and validation; generate isolated generic reports from its fresh output, with no stale coverage fallback.
- Run the three analyses serially on the same TASK-069 PR head, recording scan outcome, issue visibility, each requested measure, and exact analysis identity independently.
- Keep generic issue and coverage properties out of normal SonarCloud analysis until project-specific support is demonstrated.
- Keep the change within the task's probe, evidence, documentation, and focused tests.
- Register only the exact probe workflow and test paths in the legacy workflow-scope guard; retain rejection of application and unplanned workflow edits.

## Non-goals

- Deploying SonarQube or implementing native Elixir analysis.
- Changing project/account permissions, weakening gates, suppressing findings, or publishing credentials.
- Claiming generic import support, native Elixir metrics, or Java-equivalent analysis without observed project evidence.
- Changing application behavior, Credo policy, TASK-067 coverage accounting, ordinary SonarCloud analysis, or unrelated workflow policy.

## Risk

- A probe can change the TASK-069 PR's SonarCloud PR analysis while it runs. The probe is explicit, serialized, reviewable, restricted to its open internal PR and exact head, and uses only one clearly synthetic issue; quality-gate failures remain failures.
- If required access, a fresh coverage report, the exact analysis identity, or a measure response is unavailable, record the affected result as unverified and leave imports disabled.

## Decisions

- Use the existing workflow's manual dispatch with an explicit probe flag and PR number; reject main, forks, closed PRs, wrong base/branch, or mismatched head.
- Compare one control with issue-only and coverage-only analyses, in that order, on the same full revision. Do not combine report types in one analysis.
- Treat absence of an issue or measure change as inconclusive if the report, source indexing, PR analysis, or corresponding API evidence cannot be verified.
- Keep all normal imports disabled until demonstrated project results identify supported report types and measures.

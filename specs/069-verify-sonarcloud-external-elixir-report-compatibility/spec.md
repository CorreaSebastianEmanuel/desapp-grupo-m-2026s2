# Outcome specification: Verify SonarCloud external Elixir report compatibility

**Feature Branch**: `069-verify-sonarcloud-external-elixir-report-compatibility`

**Task**: `TASK-069`

## Outcome

Determine, for the existing SonarCloud project, whether a minimal external Elixir finding and the TASK-067 application coverage report can be imported, and which project measures each changes. Record reproducible probe inputs, project and revision, observed results, and limits. Missing authorized project access is an explicit unverified result. Enable an adapter only for report types and measures whose import is demonstrated. Keep Credo as the mandatory independent Elixir gate and preserve the existing JavaScript LCOV import and SonarCloud quality gate.

## Acceptance

- [ ] A checked-in probe defines one deterministic synthetic external issue on a TASK-065-maintained source path and one generic coverage report from TASK-067 data, with a documented command/configuration and pinned input revision.
- [ ] When authorized project access is available, a SonarCloud analysis records whether the external issue appears and separately records changes, no change, or unavailable evidence for `open_issues`, `bugs`, `vulnerabilities`, `code_smells`, and `coverage`; it records `ncloc` as a control for Elixir source indexing. Without authorized access, document each project-specific result as unverified and leave all imports disabled.
- [ ] External finding import and coverage import are evaluated independently. Only report types and individual metrics shown to import in the project are enabled in the scanner workflow; unsupported or unverified imports are omitted.
- [ ] Automated focused tests validate report generation, required fields, source paths/line locations, and that existing JavaScript coverage, SonarCloud checks, and the independent Credo gate remain configured. These tests do not claim project compatibility.
- [ ] Documentation identifies the exact report inputs, observed status of each report/metric, revision, access limits, and the distinction between generic external findings and native Elixir analysis.

## Scope

- Inspect the current SonarCloud scanner config, TASK-065 Credo source accounting, and TASK-067 application coverage report contract.
- Add only the smallest report adapter(s), probe input(s), focused tests, and evidence documentation required to test the criteria above.
- Use the existing SonarCloud CI analysis path and limited read access, if authorized, to test the existing project without changing account permissions or exposing credentials.
- Preserve the JavaScript LCOV report, current SonarCloud checks and thresholds, and independent Elixir quality gate.

## Non-goals

- Deploying SonarQube or implementing an Elixir language analyzer.
- Changing SonarCloud account/project permissions, weakening or suppressing findings, or publishing credentials.
- Claiming native Java-equivalent analysis or treating generic imports as native Elixir metrics.
- Changing application behavior, the TASK-065 Credo policy, TASK-067 coverage accounting, or unrelated workflow policy.

## Risk

- Declared: low. External imports can affect project analysis results, so probes must use a reviewable revision and deterministic, clearly identified findings. The existing gate and Elixir quality gate remain authoritative.
- An inaccessible project or unavailable authorized token limits the result to unverified; it does not justify enabling an unproven import.

## Decisions

- Probe one controlled external finding on a TASK-065-maintained source path and the TASK-067 application-only coverage report separately.
- Report the candidate measures individually: `open_issues`, `bugs`, `vulnerabilities`, `code_smells`, `coverage`, and the `ncloc` source-indexing control. A measure is supported only when the project analysis shows the corresponding controlled input changed it.
- Do not enable a project import when its behavior cannot be observed with authorized access.

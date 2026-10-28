# TASK-069 SonarCloud compatibility probe

## Result

Project `CorreaSebastianEmanuel_desapp-grupo-m-2026s2` import compatibility is **unverified**. The workspace had no `SONAR_TOKEN`, so no authenticated scanner run or project measures were available. The available TASK-067 coverage report is also stale for this checkout: it records source revision `394cf7c6a37b941c9b0804025ee1f49af09a37a3`, while the current base revision is `776c00c27d6d0644074dfa1ada1c18bea31ddc05`; `python3 scripts/application_coverage.py validate` refuses it with `category=snapshot`. I did not rerun the full unit/integration coverage profiles. No report imports were added to `sonar-project.properties` or `.github/workflows/sonarcloud.yml`. Existing JavaScript LCOV import and SonarCloud checks remain configured; Credo remains a separate required Elixir gate.

SonarQube Cloud documentation describes generic external issue imports through `sonar.externalIssuesReportPaths` and generic coverage imports through `sonar.coverageReportPaths` ([external issue format](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/importing-external-issues/generic-issue-data), [generic coverage format](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/test-coverage/generic-test-data)). This establishes documented report formats, not compatibility with this project's scanner analysis, indexing of Elixir files, or its metrics.

## Reproducible local inputs

On a checkout with a fresh, valid TASK-067 application report:

```sh
python3 scripts/application_coverage.py validate
python3 scripts/sonar_elixir_probe.py
```

The generator validates the current application report, then writes three files under `tmp/sonar-elixir-probe/`:

- `external-issues.json`: one synthetic generic external issue, explicitly labelled as a probe and not as a Credo finding. It uses a maintained Elixir path and executable line from the application coverage report.
- `coverage.xml`: the measured application-only executable lines in Sonar's generic coverage format. Covered and uncovered line identities come directly from the TASK-067 report.
- `probe.json`: base Git revision, TASK-067 source revision, coverage run and source snapshot identities, selected source location, and SHA-256 hashes of both reports.

The probe files are isolated under ignored temporary output. They are not added to normal SonarCloud analysis. For an authorized project probe, run a control analysis and then an analysis of the same PR revision with:

```sh
sonar-scanner \
  -Dsonar.pullrequest.key="$PR_NUMBER" \
  -Dsonar.pullrequest.branch="$FEATURE_BRANCH" \
  -Dsonar.pullrequest.base=main \
  -Dsonar.externalIssuesReportPaths=tmp/sonar-elixir-probe/external-issues.json \
  -Dsonar.coverageReportPaths=tmp/sonar-elixir-probe/coverage.xml \
  -Dsonar.qualitygate.wait=true \
  -Dsonar.qualitygate.timeout=300
```

Record the analysis revision and inspect the measures independently. Compare `open_issues`, `bugs`, `vulnerabilities`, and `code_smells` for the external issue; compare `coverage` for the coverage report; inspect `ncloc` as the Elixir indexing control. Keep the existing quality gate result visible. The scanner must run with its normal protected `SONAR_TOKEN` environment; do not put the token in command arguments or logs. The controlled finding may affect the branch's analysis and gate, so use a reviewable task PR and report the result without suppressing or weakening the gate.

## Project result matrix

No project analysis ran at revision `776c00c27d6d0644074dfa1ada1c18bea31ddc05` because authorized project credentials were unavailable. The local tests establish only that deterministic report files are generated from validated TASK-067 evidence.

| Probe | Project observation | Status |
| --- | --- | --- |
| Controlled generic external Elixir finding appears | No authenticated project analysis | Unverified |
| `open_issues` | No authenticated project analysis | Unverified |
| `bugs` | No authenticated project analysis | Unverified |
| `vulnerabilities` | No authenticated project analysis | Unverified |
| `code_smells` | No authenticated project analysis | Unverified |
| Generic Elixir coverage import / `coverage` | No authenticated project analysis | Unverified |
| `ncloc` control for Elixir file indexing | No authenticated project analysis | Unverified |

No external issue or coverage metric is claimed as supported for this project. Generic report format availability must not be described as native Elixir analysis, and Credo does not establish equivalence to SonarCloud's native Java analysis.

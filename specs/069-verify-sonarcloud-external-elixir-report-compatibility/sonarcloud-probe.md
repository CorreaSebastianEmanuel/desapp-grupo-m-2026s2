# TASK-069 SonarCloud compatibility probe

## Purpose and current evidence

This probe tests generic external issue and generic coverage imports independently in the existing public SonarCloud project `CorreaSebastianEmanuel_desapp-grupo-m-2026s2`. SonarQube Cloud documents these report formats and scanner properties ([generic external issues](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/importing-external-issues/generic-issue-data), [generic coverage](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/test-coverage/generic-test-data)); that does not establish project import support or native Elixir analysis.

An anonymous read on 2026-10-28 returned HTTP 200 for the project and measures at the primary branch: `ncloc=70`, `coverage=71.8`, `bugs=0`, `vulnerabilities=0`, `code_smells=0`, and `violations=0`. These are baseline project observations only. They do not demonstrate that an Elixir report is imported. The issue and coverage import results, including their individual measures, remain **unverified** until the manual experiment below produces revision-bound authenticated evidence.

No generic report properties are enabled in normal analysis. Existing JavaScript LCOV import, SonarCloud quality checks, and independent Credo enforcement remain in place.

## Bounded dispatch

After the TASK-069 PR head is ready, dispatch the existing workflow on that exact feature ref and pass its open PR number (currently PR `#67`):

```sh
gh workflow run sonarcloud.yml \
  --ref 069-verify-sonarcloud-external-elixir-report-compatibility \
  -f task069_probe=true \
  -f task069_pull_request=67
```

The runner rejects any ref other than the TASK-069 branch, a fork, a closed or non-`main` PR, or a PR whose head SHA differs from the dispatched revision. It obtains the existing protected `SONAR_TOKEN` only inside scanner and observation steps. The credential is not passed in command arguments or written to logs, summaries, or artifacts. No project/account permission changes are made.

The probe job first prepares the fresh test database with `MIX_ENV=test mix test.prepare`, then uses the existing TASK-067 `scripts/application_coverage.py run` collector and validates and converts its fresh output. It runs three serial analyses on the exact same PR revision: control (no generic report), issue-only (`sonar.externalIssuesReportPaths`), then coverage-only (`sonar.coverageReportPaths`). Each scanner still waits for the ordinary SonarCloud quality gate. Scanner and gate failures remain job failures; the result artifact is uploaded even after a failed analysis.

## Inputs and artifact

The generator writes ignored files under `tmp/sonar-elixir-probe/`:

- `external-issues.json`: one deterministic synthetic external issue, explicitly marked as not a Credo finding, at an executable line in a TASK-065-maintained source path.
- `coverage.xml`: generic coverage derived from TASK-067's current application-only line sets.
- `application-coverage.json`: the exact validated TASK-067 input report.
- `probe.json`: checked-out Git revision, TASK-067 source revision/run/snapshot, selected source path and line, and SHA-256 hashes for the input and both generated reports.
- `results/control.json`, `results/issue.json`, `results/coverage.json`: scan outcome, verified Sonar CE task and analysis identity, revision, issue-search result, and separate values/comparisons for `open_issues`, `bugs`, `vulnerabilities`, `code_smells`, `coverage`, and the `ncloc` indexing control.

The artifact is named `task-069-sonarcloud-probe-<run id>` and retained for 14 days. A measure comparison is `changed` or `no_change` only when both exact-revision results are verified and the measure is returned. Otherwise it is `unverified`. A missing issue is recorded as `not_observed`, with the result explicitly inconclusive if indexing or PR filtering is not verified. A failed scanner does not become a successful compatibility result.

Analysis identity uses the CE task from the scanner report, the current PR task from `api/ce/component`, and the commit SHA returned by `api/project_pull_requests/list`. Current analysis and revision are checked again after all measure and issue reads; if replaced or unavailable, all collected values and comparisons are marked unverified. The public API contract does not define a PR selector for `api/project_analyses/search`, so that branch-history endpoint is not used for PR revision verification. Each metric is requested separately; one unavailable metric does not erase other observations. Comparisons require a verified control from the same PR and revision.

## Project result matrix

| Probe | Current result | Evidence required to change status |
| --- | --- | --- |
| Generic external issue appears | Unverified | Issue-only PR analysis and matching controlled issue observation on exact revision |
| `open_issues` | Unverified | Separate control and issue-only measure values |
| `bugs` | Unverified | Separate control and issue-only measure values |
| `vulnerabilities` | Unverified | Separate control and issue-only measure values |
| `code_smells` | Unverified | Separate control and issue-only measure values |
| Generic coverage import / `coverage` | Unverified | Separate control and coverage-only measure values |
| `ncloc` indexing control | Unverified | Exact-revision measure in all three analyses; this does not prove native Elixir analysis |

Only demonstrated report types and measures may later be considered for normal scanner configuration. Generic imports do not establish a SonarCloud Elixir analyzer or equivalence with native Java analysis. Credo remains the mandatory independent Elixir quality gate.

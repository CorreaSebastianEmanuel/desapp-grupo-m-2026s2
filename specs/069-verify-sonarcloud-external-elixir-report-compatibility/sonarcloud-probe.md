# TASK-069 SonarCloud compatibility probe

## Purpose and current evidence

This probe tests generic external issue and generic coverage imports independently in the existing public SonarCloud project `CorreaSebastianEmanuel_desapp-grupo-m-2026s2`. SonarQube Cloud documents these report formats and scanner properties ([generic external issues](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/importing-external-issues/generic-issue-data), [generic coverage](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/test-coverage/generic-test-data)); that does not establish project import support or native Elixir analysis.

The authenticated three-analysis experiment completed on 2026-10-29. **The scanner accepted the synthetic issue report, but issue visibility was not demonstrated. Elixir coverage was ignored: zero files imported and 217 unknown files.** All three scanner quality gates passed; this is execution success, not proof of report compatibility. Exact revision, observations, input fingerprints and bounded log evidence are retained below in this versioned document.

An anonymous read on 2026-10-28 returned HTTP 200 for primary-branch measures: `ncloc=70`, `coverage=71.8`, and `bugs=vulnerabilities=code_smells=violations=0`. These historical whole-project values are baseline observations, not Elixir coverage or findings.

No generic report properties are enabled in normal analysis. Existing JavaScript LCOV import, SonarCloud quality checks, and independent Credo enforcement remain in place.

The [first attempt](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/40793559253), at `a4f780a008f4344b5c96cd74a33bb7b412f684c6`, completed control and issue-only scans but failed in the observation CLI's baseline-path conversion; coverage-only analysis was skipped. The boundary was corrected and a subprocess regression covers both affected commands. This partial attempt is superseded by the complete run below. PR #67 remains subject to independent evaluation, exact-head hosted CI and human merge.

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

## Completed experiment and durable evidence

These are historical observations of the exact tested revision, not measurements of later documentation commits or subsequent application changes. The compact evidence here remains usable after Actions artifacts expire; the artifact contains the full input/report bytes and machine-readable responses. No credentials, authorization headers or signed download URLs are retained.

| Identity | Recorded value |
| --- | --- |
| Observed date | 2026-10-29 UTC |
| PR / exact tested revision | #67 / `e8553a338b8c423b068e819c6bb5dbff6a6b93a0` |
| Workflow / job | [40801239426](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/40801239426) / [123209589288](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/40801239426/job/123209589288) |
| Input/result artifact | [12867312976](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/40801239426/artifacts/12867312976), `task-069-sonarcloud-probe-40801239426`; expires 2026-11-12 |
| Workflow result | Success; control, issue-only and coverage-only scanner/native gates all passed |
| Hosted delivery check at tested revision | [40801078919](https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/40801078919), `ThinFlow required` success; not a receipt for later heads |
| TASK-067 input run / snapshot | `262ad69b-d99c-431c-8973-d0cc994221b3` / `8d5b596e075af2278d407d549e0f9a52df16fca9c655b38c5fe2b6381080e757` |
| Native input measurement | Complete; 217 sources, 5,544 covered / 6,233 executable lines, 689 uncovered, 88.95%. This is TASK-067 coverage, not a SonarCloud measure. |
| Synthetic issue descriptor | Engine `credo-task-069-probe`, rule `TASK-069-PROBE`, maintainability impact `INFO`, `CONVENTIONAL`; `lib/football_market/accounts.ex:13`; message explicitly labels the issue as a controlled probe, not a Credo finding |

Downloaded inputs were checked against `probe.json`; its coverage source revision equals the tested checkout. All 217 report paths also existed and were tracked in that source tree. Recorded SHA-256 values identify the original bytes; they do not replace the retained scanner/observation evidence or guarantee artifact availability after expiry.

| Input | SHA-256 |
| --- | --- |
| `application-coverage.json` | `7277f8fa2aa03475f7bc7e52fbfcad51ffbcebc948697b986143535036000baf` |
| `coverage.xml` | `e2594f772dc27f1b7cb6615e6282144ed8362cd412cd05a60181559592a25dda` |
| `external-issues.json` | `1a59134c48ee98b5c0dd9c75e0ad50bd5e4c335f246c4b1fff1db228f28e7e1b` |
| Uploaded artifact ZIP | `ffa4c064319608dfece1e55a330947be9a3946bdfd69d17d0a936cfa9e377289` |

### Analysis identity and observations

| Stage | Scanner-reported CE task | API observation |
| --- | --- | --- |
| Control | `AaGFaROlJ7RPXL2DXBDs` | Verified PR #67 and tested revision; analysis `d522b7e5-30ca-48a0-be91-ddf1e72f3702`; analysis date `2026-10-29T02:06:37+0000` |
| Issue-only | `AaGFaZnL_8FN_pN6WMCf` | Verified same PR/revision; analysis `4e567aee-644c-4be5-b736-88d97f5b7293`; analysis date `2026-10-29T02:07:17+0000` |
| Coverage-only | `AaGFagkI_8FN_pN6WMDx` | **Unverified**, reason `analysis-task-not-current-for-pr`; no verified API analysis ID, values or comparisons retained |

Both verified issue searches returned zero matching synthetic issues: control and issue-only. The scanner accepted one issue, but this did not demonstrate its visibility in the PR. The target line is unchanged application code; [PR analysis can omit newly found issues on old code](https://docs.sonarsource.com/sonarqube-cloud/analyzing-source-code/pull-request-analysis). Filtering and source indexing remain limits, not established proof that external issues can never work.

| Metric | Control API | Issue-only API / comparison | Coverage-only API |
| --- | --- | --- | --- |
| `open_issues` | 0 | 0 / no change | Unverified |
| `bugs` | 0 | 0 / no change | Unverified |
| `vulnerabilities` | 0 | 0 / no change | Unverified |
| `code_smells` | 0 | 0 / no change | Unverified |
| `coverage` | Missing / unverified | Missing / unverified | Unverified |
| `ncloc` | Missing / unverified | Missing / unverified | Unverified |

The coverage phase's identity guard refused attribution. Its values are not reconstructed from a later API read or substituted from another analysis. Separately, the exact-revision scanner log directly establishes that the submitted XML's coverage was ignored.

### Retained scanner excerpts

These bounded excerpts come from job `123209589288`; times are UTC on 2026-10-29. Each phase logs the same full SCM revision shown above. No secret-bearing environment sections are copied.

```text
02:02:54 APPLICATION_COVERAGE status=complete run=262ad69b-d99c-431c-8973-d0cc994221b3
02:06:55 [control] SCM revision ID 'e8553a338b8c423b068e819c6bb5dbff6a6b93a0'
02:07:05 [control] QUALITY GATE STATUS: PASSED
02:07:12 TASK-069 control observation: verified
02:07:31 [issue-only] Imported 1 issue in 1 file
02:07:31 [issue-only] SCM revision ID 'e8553a338b8c423b068e819c6bb5dbff6a6b93a0'
02:07:34 [issue-only] QUALITY GATE STATUS: PASSED
02:07:41 TASK-069 issue observation: verified
02:07:56 [coverage-only] Parsing .../tmp/sonar-elixir-probe/coverage.xml
02:07:56 [coverage-only] Imported coverage data for 0 files
02:07:56 [coverage-only] Coverage data ignored for 217 unknown files, including:
  lib/football_market.ex
  lib/football_market/accounts.ex
  lib/football_market/accounts/api_key.ex
  lib/football_market/accounts/authenticated_actor.ex
  lib/football_market/accounts/authentication.ex
02:08:00 [coverage-only] SCM revision ID 'e8553a338b8c423b068e819c6bb5dbff6a6b93a0'
02:08:08 [coverage-only] QUALITY GATE STATUS: PASSED
02:08:10 TASK-069 coverage observation: unverified
```

Bracketed stage labels and the abbreviated workspace prefix were added for readability; timestamps, messages, paths and revisions retain the relevant reported values. In the [generic coverage importer](https://github.com/SonarSource/sonarqube/blob/master/sonar-scanner-engine/src/main/java/org/sonar/scanner/genericcoverage/GenericCoverageReportParser.java), unknown includes absent indexed inputs or inputs without a recognized language. The observed result is rejection of these 217 source paths under this project's configuration, not proof of a particular internal cause for every file or a guarantee about future support.

## Acceptance conclusion

Preparation was independently approved before execution. The complete run now demonstrates the guarded execution route, scanner acceptance of the synthetic issue format, preserved input provenance and conservative refusal of an unverifiable observation. It **does not demonstrate issue visibility, an effect on the four issue metrics, imported Elixir coverage, or Elixir `ncloc`**. Coverage import is observed not to work with the tested source indexing; API coverage comparisons remain unverified.

Normal generic imports stay disabled. Credo remains the independent required Elixir quality check and TASK-067 remains the source of measured Elixir coverage. This experiment adds neither a native Elixir analyzer nor equivalence with Java's native SonarCloud rules, type analysis or security capabilities. TASK-069 is ready for human review only after fresh evaluation of this documented conclusion and exact published-head hosted CI; it remains `review` until human merge.

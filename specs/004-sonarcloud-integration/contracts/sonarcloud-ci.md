# Contract: SonarCloud CI and CP1 Gate

## Trigger and identity contract

The required workflow runs for internal pull requests targeting `main` on `opened`, `synchronize`, `reopened`, and `ready_for_review`, including drafts, and for every push to `main`. It checks out the triggering revision with full Git history. Concurrency may cancel an older run, but only a completed result attached to the latest head SHA can satisfy the PR.

## Published-analysis contract

The workflow performs CI-based SonarCloud analysis with automatic analysis disabled. Upload is not completion: server-side processing must finish, publish the matching analysis, and return a passing native quality gate within 300 seconds. Any scan, authentication, configuration, compute, publication, cancellation, or timeout condition is non-passing.

## Checkpoint-count contract

After publication, a `main` run first requests the latest published analysis:

```text
GET https://sonarcloud.io/api/project_analyses/search
  ?project=<configured-project-key>
  &branch=main
  &ps=1
```

The latest analysis revision must equal the triggering Git SHA before its count can pass. The checkpoint gate then requests exactly:

```text
GET https://sonarcloud.io/api/measures/component
  ?component=<configured-project-key>
  &branch=main
  &metricKeys=open_issues
```

It accepts exactly one non-negative integer `open_issues` measure. Values 0–9 pass; 10+ fail. Missing/stale revision evidence on `main`, missing/duplicate/non-integer/negative measures, invalid JSON, HTTP failures, or exhausted bounded retries fail closed. Output identifies the metric, branch, revision context, count, boundary, result, and findings location without printing credentials.

For PRs, the exact-head PR analysis and current primary-branch count are separately labelled. For a `main` push, the processed analysis revision and primary-branch measure must represent that integrated run before success is reported.

## Scope and profile contract

- Sources: `lib`, `assets/js`
- Tests: `test`
- Exclusions: `_build/**`, `deps/**`, `assets/vendor/**`, compiled `priv/static/assets/**`, generated digests, and source maps
- No path is excluded merely because it might contain a secret.
- All Sonar issue types produced by the active per-language profiles contribute when their status is Open.
- Live checkpoint evidence records profile name/key per detected language; this task does not create or mutate profiles.

## Security and permissions contract

The workflow uses `contents: read`, protected `SONAR_TOKEN` secret indirection, pinned third-party action commits, and non-debug logging. Token values are absent from repository content, fixtures, command arguments rendered in summaries, and diagnostics. `pull_request_target` is forbidden.

## Regression and evidence contract

`.github/workflows/quality-baseline.yml` remains unchanged. Formatting, warning-fatal compilation, and unit tests retain their existing commands and conclusions. Deterministic fixtures establish boundary/error behavior; one hosted current-head PR run and one integrated `main` run establish publication evidence. Navigation is measured from the PR Checks view to the required check and then its SonarCloud findings link (at most two actions).

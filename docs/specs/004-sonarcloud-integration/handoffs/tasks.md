# Tasks Handoff

## Resolutions

- Closed the plan's revision-evidence gap: `/api/measures/component` does not identify the analyzed SHA, so a `main` success now requires the latest published analysis revision from `/api/project_analyses/search` to match the triggering SHA before `open_issues` is accepted. PRs continue to show the current `main` count separately from the exact-head PR analysis.
- Made immutable pinning apply to both the scanner and checkout actions; mutable major-version tags cannot satisfy the security contract.
- Kept US1 demonstrable but explicitly non-CP1-complete until threshold enforcement, safe diagnostics, baseline parity, and hosted `main` evidence finish.
- Converted TASK-003 preservation into a byte-level oracle plus semantic regression checks. The existing workflow must never be edited or wrapped.

## Remaining risks

- Real organization/project keys, protected `SONAR_TOKEN`, `main` primary-branch selection, disabled automatic analysis, required-check configuration, and active profile identities need maintainer-controlled SonarCloud/GitHub setup.
- SonarCloud API v1/profile drift may change live behavior. Parsing is isolated and fails closed; evidence must capture profiles and time.
- A PR's current-primary count is not a prediction of its post-merge total. Only the post-merge `main` run supplies final CP1 evidence.

## Sequencing guidance

Author fixtures/contracts before each implementation slice. Publish US1 only after local contracts pass; add US2 and US3 without weakening native gates. Run deterministic and TASK-003 parity checks before hosted validation. Do not manufacture live auth/timeout failures. T032 is intentionally last because it requires authorized merge and a fresh `main` analysis showing 0–9 issues.

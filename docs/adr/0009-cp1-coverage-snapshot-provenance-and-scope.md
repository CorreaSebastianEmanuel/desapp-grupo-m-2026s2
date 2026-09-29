# ADR 0009: CP1 Coverage Snapshot Provenance and Scope

- **Status**: Accepted
- **Date**: 2026-09-29
- **Feature**: TASK-014 CP1 automated test and coverage profiles

## Context

CP1 coverage must truthfully describe the state tested before a QA commit. A clean-HEAD rule blocks that workflow, while an informal subset of “relevant” files can omit a test, configuration, lock, or browser change. Native Mix also sees more compiled modules than CP1 should count, so an inventory not consumed by the collector cannot define a truthful denominator.

## Decision

Bind a report to base HEAD and SHA-256 of complete binary `git diff HEAD`, including staged and unstaged tracked changes. Exclude only the active feature's generated post-execution QA/review artifacts (`qa-report.md`, `review-report.md`, and `handoffs/`): they neither affect test execution nor can be written until after the tested snapshot exists. Reject nonignored untracked inputs except those same generated artifacts and stated tool outputs; stage reports outside the repository and revalidate fingerprint immediately before atomic publication. Empty diffs are committed-revision reports; nonempty diffs are working-tree snapshots.

Maintain one committed exact source-path/Elixir-module CP1 allowlist. `mix.exs` derives native Mix coverage exclusion from it using a deny-all-except policy. Publish executable-line numerator/denominator only for that inventory, with native module source HTML and an aggregate report.

## Consequences

- Pre-commit evidence is valid and traceable; unrelated tracked execution-input edits intentionally change its identity, while generated QA/review documentation cannot invalidate an already tested snapshot.
- Untracked non-generated input must be resolved before publication.
- Inventory changes require rationale and actual-scope tests.
- Coverage remains threshold-zero informational evidence; CI, SonarCloud, product behavior, and production architecture do not change.

## Rejected alternatives

- Clean worktree/pre-QA commit conflicts with approved remediation and FR-017.
- Enumerated relevant-diff subset can omit an execution-affecting file.
- Native default scope includes non-CP1 compiled modules.
- A new coverage dependency or threshold expands scope without a CP1 need.

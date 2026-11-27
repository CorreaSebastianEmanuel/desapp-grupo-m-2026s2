# Outcome specification: Elixir CI harness regression stability

**Feature Branch**: `081-elixir-ci-harness-regression-stability`

**Task**: `TASK-081`

## Outcome

Make the existing quality-harness regression suite deterministic and passing by correcting the observed coverage path-normalization, Dialyzer preparation, and Sobelow finding-link failures without weakening quality gates or changing product behavior.

## Acceptance

- [x] Coverage batch manifests use canonical absolute paths, and their regression test compares against the same canonical form on macOS and Linux.
- [x] Dialyzer preparation creates and validates the native `prepared` receipt for both `dev` and `test`; a missing, malformed, or failed preparation remains a failed required gate.
- [x] A Sobelow finding with a normalized repository-relative file and positive line number appears in the PR summary with a link to that exact file and line; unsafe or unnormalized paths still fail closed.
- [x] Regression tests cover these behaviors without changing analyzer thresholds, exception rules, CI required status, or product behavior.

## Scope

- Coverage export path normalization and its platform-independent regression oracle.
- Dialyzer preparation and receipt validation.
- Sobelow finding path normalization and PR-summary links.
- Focused regression tests for the above.
- Do not change product behavior or weaken a required quality gate.

## Non-goals

- Product features, broad harness refactors, full regression-suite execution, workflow-policy changes, and changing analyzer thresholds or reviewed exceptions.

## Risk

- Declared: low; changes are limited to quality-harness determinism and evidence reporting. Existing required gates and fail-closed behavior remain authoritative.

## Decisions

- No unresolved material choices. Keep coverage paths canonical at the manifest boundary, require a successful native Dialyzer receipt before analysis, and construct Sobelow links only from validated repository-relative paths.

# ADR-0001: Combine SonarCloud PR Analysis with a Whole-Project CP1 Gate

**Status**: Accepted  
**Date**: 2026-09-16  
**Scope**: TASK-004 SonarCloud integration

## Context

CP1 requires fewer than 10 unresolved SonarCloud issues for the project. The feature also requires analysis for every pull-request revision. SonarCloud pull-request analysis intentionally reports issues introduced by the PR and evaluates only new-code quality-gate conditions; it is therefore not an authoritative whole-project issue count.

## Decision

Every supported PR receives normal exact-head SonarCloud PR analysis and must pass its native gate. The repository-owned checkpoint gate separately queries `open_issues` for the SonarCloud project's primary `main` branch and applies the strict 0–9 pass / 10+ fail rule. The check presentation labels these as two distinct facts. Every push to `main` performs and publishes main analysis before evaluating the same measure.

Because the measures endpoint does not identify the analyzed commit, a `main` run first requests exactly the latest published analysis from `/api/project_analyses/search` and requires its full revision to match the triggering Git SHA. Only then does it accept `/api/measures/component` for `open_issues`. Missing, ambiguous, malformed, or stale revision evidence fails closed. PR runs do not compare their head SHA to `main`; their summary explicitly labels the separate primary-branch count as current context.

`open_issues` includes all issue types in Open status produced by the active language quality profiles. Accepted, Fixed, and False Positive issues do not count. Live CP1 evidence records revision, analysis identity, timestamp, count, and profile identities.

## Consequences

- PR findings remain attributable to the exact reviewed revision.
- CP1 retains its whole-project meaning instead of silently becoming a new-code rule.
- A PR can be non-passing because its native new-code gate fails, because the existing primary project has 10+ open issues, or because either result is unavailable.
- The current primary count does not claim to predict the post-merge whole-project total; the mandatory `main` run supplies the authoritative integrated result.
- Profile changes can change future counts, so profile identity is part of acceptance evidence.
- Bounded retries apply only to transient rate-limit, server, and network failures; authentication, authorization, configuration, and malformed successful responses fail immediately.

## Rejected alternatives

- Use PR `new_violations`: changes the checkpoint from whole project to new code.
- Use `violations`: includes issues in all states rather than unresolved/Open issues.
- Analyze each PR as a synthetic long-lived branch: adds lifecycle/licensing assumptions and undermines native PR analysis/decorations.
- Create an exact-count live fixture project: adds administration and produces weaker, mutable test evidence than sanitized deterministic fixtures.

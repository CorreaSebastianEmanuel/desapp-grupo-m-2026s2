# Research: SonarCloud Integration

## Authoritative CP1 count

**Decision**: Query the primary branch's `open_issues` metric and apply `count < 10` in a repository-owned fail-closed gate. The metric includes all Sonar issue types produced by active language profiles in Open status and excludes Accepted, Fixed, and False Positive issues.

**Rationale**: The specification says unresolved whole-project issues, not all historical issue records and not only new code. Sonar documents `open_issues` as the Open-status count, while `violations` includes all states. Project key, `branch=main`, and the metric key make the evidence reproducible.

**Alternatives considered**: `violations` overcounts non-open states. Type-specific sums couple CP1 to taxonomy changes. `new_violations` contradicts the whole-project requirement.

## PR analysis versus whole-project policy

**Decision**: Require both SonarCloud's exact-head PR analysis/native gate and the primary-branch CP1 count. Label them separately in the check summary.

**Rationale**: SonarCloud documents that PR analysis reports issues introduced by the PR and applies only new-code gate conditions. It cannot truthfully supply a whole-project count for that PR context. The dual result preserves exact-revision review and the checkpoint's current project-level invariant.

**Alternatives considered**: Calling the PR count “project issues” is misleading. Creating per-PR long-lived branches adds plan/licensing dependence and loses normal PR semantics. Replacing CP1 with a new-code gate changes observable policy.

## CI analysis mode and completion

**Decision**: Use CI-based analysis, disable automatic analysis, and set `sonar.qualitygate.wait=true` with a 300-second timeout before querying the checkpoint measure.

**Rationale**: Duplicate automatic and CI analyses conflict. Scanner upload success alone is insufficient because SonarCloud processes reports asynchronously; waiting establishes a published server-side result.

**Alternatives considered**: Automatic analysis cannot host the repository-owned threshold evaluator. Fire-and-forget scanning can falsely pass before publication fails.

## Event and concurrency model

**Decision**: Analyze internal PR events `opened`, `synchronize`, `reopened`, and `ready_for_review` plus pushes to `main`; include drafts. Cancel superseded runs in a PR/main-specific group and govern by the check on the latest SHA.

**Rationale**: This is the testable denominator for “every PR.” Human feedback explicitly removes forks and untrusted contexts, so a privileged target workflow is unnecessary.

**Alternatives considered**: Default event types omit an explicit ready transition. `pull_request_target` increases privilege and analyzes the wrong revision unless handled dangerously. Treating an old cancellation as a latest-head failure conflates obsolete work with governing evidence.

## Analysis scope

**Decision**: Analyze application source in `lib` and repository-owned browser source in `assets/js`; classify `test` separately. Exclude only dependency/build/generated/vendor paths: `_build/**`, `deps/**`, `assets/vendor/**`, compiled `priv/static/assets/**`, generated digests, and source maps.

**Rationale**: Sonar requires disjoint source/test sets and supports path exclusions. Enumerated exclusions keep project code visible, including configuration that may contain security defects.

**Alternatives considered**: Scanning the repository root introduces workflow/docs noise. Excluding “secret-bearing” filenames may hide findings and does not protect actual secrets.

## Verification strategy

**Decision**: Use sanitized Web API fixtures for 9/10 and error behavior, plus one real PR publication and one real `main` result recording count, revision, timestamp, native gate, and active profiles.

**Rationale**: Fixture tests are deterministic and safe. Live evidence confirms integration without deliberately polluting the CP1 project or damaging credentials.

**Alternatives considered**: Manufacturing exact live counts is unstable. Live auth/timeout tests are disproportionate. Static-only tests cannot prove publication.

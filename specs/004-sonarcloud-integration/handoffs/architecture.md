# Architecture Handoff

## Decisions not repeated in the plan

- Treat SonarCloud administration as a deployment prerequisite: `main` must be primary, automatic analysis disabled, the repository bound to the correct organization/project, and `SONAR_TOKEN` protected. Implementation must not automate account/project/profile mutation.
- Prefer a dependency-free Python gate so parsing, retries, and redaction are testable without changing the Phoenix dependency graph. Keep HTTP transport injectable for fixtures.
- Preserve a captured hash/content oracle for `.github/workflows/quality-baseline.yml` in contract tests; TASK-004 adds a sibling required check and never edits or wraps TASK-003.

## Risks

- SonarCloud API v1 is progressively being replaced. Isolate endpoint/JSON parsing in the gate and fail closed; an API migration is a later reviewed change, not an automatic fallback.
- `assets/js` may contain little analyzable code initially. The explicit path is still repository-owned scope; contract tests should reject silently broadening to generated CSS/static output.
- Profile/rule updates can move the live count without a code change. Evidence must include active profile identities and timestamp; do not freeze or clone profiles within TASK-004.
- A current PR analysis plus primary count is deliberately not a prediction of the merged total. The post-merge `main` run is mandatory CP1 evidence.

## Implementation guidance

- Keep secrets in environment variables and send API authentication as a header; never interpolate tokens into URLs, exceptions, fixtures, or summaries.
- Make retry policy explicit and bounded for transient 429/5xx/network failures; never retry 401/403 or malformed successful responses into a pass.
- Validate the response structurally before comparison. Reject floats, numeric strings with decoration, multiple `open_issues` entries, negatives, and absent branch/project identity where available.
- Fixture tests should assert exit code, diagnostic class, and redaction rather than exact third-party prose.

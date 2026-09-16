# Architecture Handoff

## Decisions

- Current TASK-003 feedback supersedes the earlier no-feedback observation. Hosted Actions execution is post-publication evidence; the plan's parsed contract, exact local parity, and controlled negatives are the complete pre-publication gate.
- YAML must actually be parsed before semantic assertions run. Account for YAML tooling that interprets the plain `on` key under YAML 1.1 semantics.

## Risks

- Exact Elixir/OTP pins may be unavailable on the hosted runner. If setup fails after publication, report the blocker; do not widen versions or introduce a container without review.
- A dependency cache can conceal setup defects. Obtain a cold-cache run or equivalent cache-miss proof when collecting post-publication evidence.
- Branch protection is repository governance outside TASK-003. The workflow supplies a stable job but must not mutate repository settings.

## Implementation guidance

- Controlled defects must be temporary and isolated. Restore each one and verify the working tree before proceeding.
- Once the PR exists, bind hosted evidence to its head SHA; after merge, bind the push run to the integrated `main` SHA.
- If the exact hosted toolchain forces a container, version widening, new service, or other architecture deviation, stop for review and record it in an ADR. No current design choice requires an ADR.

# Tasks Handoff

## Resolutions

- Current `backlog/feedback/TASK-003.md` supersedes the product-decision handoff's stale claim that no feedback exists. Parsed workflow checks, exact pinned-toolchain local parity with PostgreSQL, and isolated negative fixtures form the pre-publication gate. Hosted PR-head and merged-`main` runs are post-publication evidence and cannot block creation of the commit/PR.
- “Exactly three” means enforced quality categories. Checkout, toolchain verification, locked dependency setup, and ephemeral PostgreSQL readiness remain visible setup steps in the same required job.
- The complete-suite oracle is the unfiltered default ExUnit alias plus a committed discovery sentinel; intentional ExUnit skips alone are not failures.

## Remaining risks

- Hosted availability of Elixir 1.20.3 / OTP 29.0.6 is proven by setup; the PR run must still prove the complete gate. Do not widen versions or introduce a container without reviewed replanning/ADR.
- Workflow tests must parse YAML and account for YAML 1.1 treating plain `on` as a boolean-like key.
- Controlled defects can contaminate later evidence unless each is restored and the worktree is checked before continuing.
- CP1 remains incomplete until hosted PR-head and post-merge `main` evidence is captured, including a cold-cache or equivalent cache-miss proof.

## Sequencing guidance

Keep the red-test boundary explicit: harnesses, then positive contracts, then artifacts; negative contracts, then hardening; documentation contract, then README. QA/final review may pass on complete pre-publication evidence. Collect hosted evidence only after Agentflow publishes, and bind every result to the exact SHA.

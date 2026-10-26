# ADR-0035: Effective sandbox policy is part of check identity

- **Status:** Accepted
- **Date:** 2026-10-26
- **Decision owners:** TASK-029 architecture and workflow feedback

## Context

Agentflow launches Codex for development and verification checks. Codex command
presets and configuration can select a sandbox policy that differs from an
inherited environment label. In particular, `--approve-for-me` selects
`workspace-write`; passing it with an explicit sandbox is invalid or changes the
effective policy. Database-backed local checks also need loopback access, so a
launcher that silently narrows or widens the configured mode can change test
results and invalidate retry evidence.

## Decision

Resolve the effective sandbox from explicit CLI selection, invocation-level
configuration, the user's root Codex configuration, or `workspace-write` when
none is configured. Accept only `read-only`, `workspace-write`, and
`danger-full-access`. Refuse ambiguous, malformed, project-scoped, and
profile-based sandbox declarations before spawning the provider.

Remove existing sandbox declarations from the child arguments and forward one
normalized `--sandbox MODE`. Set
`AGENTFLOW_CODEX_SANDBOX_MODE` from that resolved value, replacing any inherited
value. Remove `--approve-for-me` only when the resolved mode is
`danger-full-access` and the configured approval policy is `never`; preserve it
for other policies and modes. Keep workspace-write loopback access as a
separate invocation setting rather than changing the selected sandbox.

Checks that depend on this launcher identity declare the resolved mode in
`retry_env`, which binds the mode into check identity without storing its value
in evidence. Verification reports only the closed sandbox enum.

## Consequences

- Missing or invalid policy fails before a check starts; the launcher never
  escalates a user's selection automatically.
- A mode change starts a distinct retry identity, while unrelated environment
  changes do not reset retry limits.
- Fake-child launcher tests verify normalized arguments, environment agreement,
  approval-policy handling, and safe metadata.

## References

- [ADR-0034: Check environment and retry identity](0034-check-environment-retry-identity.md)
- `specs/068-atomic-idempotent-token-purchase/contracts/profile-diagnostics.md`
- `test/scripts/agentflow_models_test.py`
- `test/scripts/agentflow_evidence_test.py`

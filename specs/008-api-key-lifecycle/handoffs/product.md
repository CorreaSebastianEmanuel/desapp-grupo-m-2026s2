# Product Handoff: API Key Lifecycle

## Decisions

- No additional product decision is needed before planning.

## Unresolved Assumptions

- No material product assumption remains unresolved at this stage.

## Guidance

- Design the verification path for a high-entropy generated credential. Select a hash and lookup strategy that preserves one-way storage, predictable lookup behavior, and the one-second outcome target; document the choice in planning.
- Enforce secret uniqueness across active and revoked records at the authoritative persistence boundary. Make collision behavior testable with controlled generation, without weakening production randomness.
- Keep the lifecycle behind the Accounts/domain boundary. Any future controller should derive the acting account from authenticated context rather than accept an untrusted owner identifier.
- Return only safe projections from ordinary reads. Review inspect output, changesets, exception paths, and telemetry metadata for accidental credential exposure.
- Preserve a clear seam for TASK-010 to consume identification outcomes. It should receive actor and key identity, never the stored hash.

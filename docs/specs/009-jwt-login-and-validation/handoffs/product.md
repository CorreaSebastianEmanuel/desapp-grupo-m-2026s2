# Product Handoff: JWT Login and Validation

## Decisions

- No additional product decision is needed before planning.

## Unresolved Assumptions

- No material product assumption remains unresolved at this stage.

## Guidance

- Select the signing method and key strategy during planning. Prefer the smallest trustworthy CP1 choice, document runtime configuration and rotation implications, and keep caller-controlled token metadata from choosing weaker verification behavior.
- Preserve a narrow Accounts/authentication boundary: consume TASK-007 email lookup and password verification without exposing credential material, and return a safe verified identity for TASK-010 rather than leaking token claims into domain code.
- Use controlled time in tests for issuance, expiration, future-issued and not-before cases. Apply any configured clock-skew allowance consistently, never to extend expiration.
- Make generic failures genuinely non-enumerating across unknown-account, wrong-password, and malformed-input paths, including logs and telemetry metadata.
- Keep complete tokens visible only in successful login output and transient validation input. Redact them from inspection, errors, logs, telemetry, and test failure output.

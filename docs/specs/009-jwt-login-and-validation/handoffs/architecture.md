# Architecture Handoff: JWT Login and Validation

## Decisions not obvious from the plan

- Treat configuration load and cryptographic failure as fail-closed, safe domain errors at callable boundaries even though production startup should already reject invalid configuration. This prevents tests or alternate boot paths from turning misconfiguration into an exception leak.
- Keep decoded claims in the authentication module until verification completes. Do not let logging/debug helpers inspect intermediate token structures containing the compact token or raw unverified claims.
- TASK-010 may translate the two stable error atoms, but must not widen them or bypass Accounts to call Joken directly.

## Risks

- HS256 makes every holder of the signing key capable of minting tokens. Restrict the key to this application and rotate to a key ring or asymmetric signing only when a real multi-service verification requirement appears.
- Login remains exposed to online guessing until later throttling/lockout work. Do not describe CP1 as production-hardened authentication.
- `Argon2.no_user_verify/0` removes the obvious hash-work gap but cannot make database/scheduler timing constant. Preserve public response equivalence and avoid adding cause-specific telemetry.
- Zero skew assumes issuer and validator use the same application clock. A later distributed verifier must revisit skew deliberately without extending `exp`.

## Implementation guidance

- Validate token header algorithm before trusting claims and configure JOSE/Joken with an HS256-only signer; mutation tests should prove algorithm confusion is rejected.
- Use integer seconds from the injected clock once per operation. Derive `exp` from the captured `iat`, not a second clock read.
- Suppress or sanitize any database/query logging on credential lookup and ensure authentication telemetry contains operation/outcome/duration only—never email, password, token, claims, key, account ID, or JTI.
- Keep performance benchmarking tagged/manual and keep all security boundary assertions in the default test suite.

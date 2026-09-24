# ADR-0005: Use a Fixed HS256 JWT Boundary with Standalone Validation

**Status**: Accepted

**Date**: 2026-09-23

**Scope**: TASK-009 JWT login and validation

## Context

The architecture baseline defines a modular Accounts context but no JWT library, signing policy, claim precision, or validation relationship to persisted accounts. TASK-009 requires signed 15-minute JWTs and standalone validation while explicitly excluding transport, revocation, and authorization. These choices are durable because later route authentication will depend on the contract.

## Decision

Accounts delegates token mechanics to a focused authentication component using Joken/JOSE and one HS256 signer. A Base64-encoded key of at least 32 decoded bytes, issuer, and audience come only from trusted runtime configuration; production has no defaults. Tokens use integer Unix seconds, `exp = iat + 900`, zero skew, UUID `sub` and `jti`, and strict required-claim validation. Expiration is invalid at `exp <= now`; future `iat` and optional future `nbf` are invalid.

Validation verifies the method, signature, configured values, required claims, formats, and time rules before returning only account ID and JTI. It does not query PostgreSQL, so account changes do not revoke a token before expiry. Login uses the TASK-007 verifier and dummy Argon2 work for unknown accounts, exposing one generic authentication failure.

## Consequences

- The feature adds one JWT dependency but no service, route, cache, migration, or stored token.
- Key holders can mint tokens; the key must remain limited to this application.
- Claim boundaries are deterministic and testable to the second, with no expiration leeway.
- Later route adapters consume stable domain results and cannot select signing policy.
- Revocation, account-state revalidation, rotation/key IDs, distributed clock tolerance, throttling, and asymmetric verification require later explicit decisions.

## Rejected alternatives

- Phoenix.Token or custom JOSE orchestration: does not provide the same focused JWT claim-policy boundary or duplicates it.
- RS256 and a key-distribution/rotation system now: adds operational machinery without a current external verifier.
- Reusing Phoenix `SECRET_KEY_BASE`: couples independent cryptographic purposes and rotations.
- Positive skew: unnecessary in the current single application and complicates exact boundaries.
- Database lookup on validation: silently introduces account-state revocation and persistence coupling outside the specification.

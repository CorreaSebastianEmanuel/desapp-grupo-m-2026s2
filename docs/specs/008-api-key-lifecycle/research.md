# Research: API Key Lifecycle

No material question remains unresolved. The current spec and product decision authorize the internal lifecycle; no TASK-008 human-feedback file exists.

## Secret generation and storage

**Decision**: Generate 32 random bytes with OTP `:crypto`, encode as canonical unpadded Base64URL, and store a SHA-256 digest in a separate `api_keys` row. Index the digest uniquely across active and revoked keys.

**Rationale**: The secret has 256 bits of unpredictable entropy, exceeding FR-003's 128-bit minimum. A fast one-way digest does not make a random secret practically guessable, and a unique database index is authoritative under concurrency. A UUID identifies a row for management but has no identification power.

**Alternatives considered**: Argon2id would add cost appropriate to human passwords but unnecessary for high-entropy keys and counterproductive to the local timing target. Reversible encryption or plaintext storage violates FR-005. A pepper/HMAC adds key-management infrastructure without a requirement. A digest scoped only to active keys could allow reuse after revocation, so it is rejected.

## Collision and failed issuance

**Decision**: Treat a digest uniqueness conflict as failed issuance, returning a safe error and no raw secret. Let the foreign key reject an account deleted during issuance. Never expose an Ecto changeset containing the digest.

**Rationale**: A single insert either commits one row or none; a bounded retry loop and injectable production entropy source are unnecessary to meet FR-010. Test the unique constraint with a deliberate duplicate digest and the context's safe error mapping without adding a public secret override.

**Alternatives considered**: Application-only duplicate checks race. Retrying after collisions would add branching for an event already made negligible by the secret space. Returning database errors/changesets risks exposing verification material.

## Revocation ordering and trust

**Decision**: Use an owner-scoped conditional update and an authoritative PostgreSQL read for identification. A lookup whose database read begins after revocation commits must reject; one that reads before commit may identify successfully. Keep issuance/revocation internal until authenticated adapters exist.

**Rationale**: This gives a testable post-commit boundary without locks or caching and honors the product challenge. The future web adapter must obtain owner identity from authenticated context, not request input.

**Alternatives considered**: Redis/process caches can serve stale active status. Row locks on every lookup add contention without improving the required post-commit case. Public management routes or caller authentication belong to later tasks.

## Safe failures and measurements

**Decision**: Malformed, unknown, and revoked identification share one safe result shape; unknown and other-owner revocation share another. Do not promise timing parity. Measure 40 completed local calls per operation after warmup, including database work; require 38 within one second for each operation.

**Rationale**: The spec asks for nondisclosing outcomes and a 95% local target. The fixed sample makes the target reproducible without inventing a CP1 continuous performance gate.

**Alternatives considered**: Timing equalization could add artificial delay and still fail to guarantee parity under system load. A benchmark of pure hashing would omit persistence and could not validate SC-005.

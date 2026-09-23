# ADR-0004: Store High-Entropy API Key Digests and Read Authoritative Revocation State

**Status**: Accepted

**Date**: 2026-09-23

**Scope**: TASK-008 API key lifecycle

## Context

The architecture baseline provides Accounts, Ecto, and PostgreSQL but no API key storage policy. TASK-008 requires one-time secret disclosure, durable multiple-key ownership, collision safety, and immediate rejection after committed revocation. A later task will add the public authentication boundary.

## Decision

Accounts generates each key from 32 CSPRNG bytes, encodes the secret as unpadded Base64URL, and stores only a SHA-256 digest with a separately generated UUID ID. PostgreSQL enforces a unique digest across active and revoked rows and a foreign key to the owner. An insert conflict fails closed without returning a secret. Revocation is an owner-scoped conditional update of `revoked_at`; identification queries PostgreSQL for an active matching digest on every call. The API key lifecycle is internal only, and any future web adapter must derive the owner from authenticated context.

## Consequences

- The table cannot store two keys with the same usable secret, even if one is revoked. Raw secrets exist only in the issuance result and transient presentation.
- Lookups begun after revocation commit reject the key. An in-flight lookup may observe active state if its database read preceded that commit.
- Key verification performs one digest and an indexed database read; no password-hash cost, cache invalidation, pepper rotation, or new service is introduced.
- Application output must use safe projections and errors. Credential query logging must be suppressed, and existing query telemetry handlers reviewed for parameter export; custom telemetry and audit output must not carry credential material.
- The implementation uses `log: false` on credential insert, lookup, and revoke queries; the existing telemetry metrics record database durations without credential parameter tags.

## Rejected alternatives

- Argon2id for random keys: useful for human passwords but adds cost without meaningful protection for 256-bit random values.
- Plaintext or reversible encryption: violates the non-recoverable storage requirement.
- Application-only duplicate checks or an active-only unique index: cannot reliably prevent duplicate or previously revoked secrets.
- Redis or process caching of active state: can identify a revoked key after commit.
- Public key-management routes or accepting an owner ID from request input: crosses the current trust boundary before TASK-010 authentication.

# ADR-0003: Protect User Credentials with Argon2id and Database-Enforced Email Identity

**Status**: Accepted  
**Date**: 2026-09-22  
**Scope**: TASK-007 user registration and credential storage

## Context

User registration needs a durable, case-insensitive email identity and password verification without storing or exposing a password. Concurrent requests must not create duplicate accounts, and a failed write must not leave a user or credential behind.

## Decision

The Accounts context will normalize email by trimming surrounding whitespace and lowercasing it before validation and persistence. PostgreSQL will enforce the same identity with a unique functional index on `lower(btrim(email))`; application validation is feedback, while the index is the race-safe authority.

Password material will be held in a one-to-one credential record and stored only as an Argon2id encoded hash generated with a random salt. Production settings are `t_cost: 2`, `m_cost: 65536`, `parallelism: 1`, a 16-byte salt, and a 32-byte hash; test-only settings reduce cost without changing the algorithm or stored format. User-facing account values exclude the hash. Creating the user and credential occurs in one `Ecto.Multi` transaction.

## Consequences

- The database prevents duplicate normalized identities even when requests race.
- A credential verifier can compare a submitted password without exposing its stored representation.
- Argon2's native dependency and configured cost become part of build/runtime validation; registration remains subject to the specification's 30-second local outcome.
- Direct persistence access is internal-only; public Accounts results expose only user identity fields.

## Rejected alternatives

- Application-only duplicate checks: vulnerable to concurrent inserts.
- Plaintext, encrypted, or fast-digest passwords: retain recoverable/reusable material or provide inadequate password hashing resistance.
- A login endpoint, token, or registration UI: explicitly outside TASK-007.
- Storing the hash directly in ordinary user retrieval data: makes accidental disclosure easier and weakens the separate credential boundary.

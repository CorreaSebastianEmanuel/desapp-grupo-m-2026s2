# ADR-0024: Atomic Initial Player Issuance and Shared Financial Coordination

**Status**: Accepted for TASK-028 architecture within approved specification and AGENTS rule 9
**Date**: 2026-10-14

## Context

Initial allocation is fixed at 100 tokens and one credit, independent of statistics/active performance strategy. Existing users have no roles/balances; no durable quote or holding table exists. The product critic identifies post-commit acknowledgement loss, contradictory linked facts, adjacent financial-write races and CP2 initialization ordering. ADR-0010/0023 establish DB immutability/serialized financial evidence; ADR-0020 defers performance quote retention to TASK-026.

## Decision

Use a trusted internal Market context and singleton-list configuration of one existing account. A protected initialization-lock row serializes issuance before player row locks. First committed issuance inserts an immutable market recipient singleton; every later player must use that original account. Compare all retained issuance recipients too. Configuration cannot reassign issued tokens or choose a new initial owner for a different player. No role system/account creation/public invocation is added.

READ COMMITTED post-lock validation sees coherent holdings/quote facts. Quote/holding DB guards acquire the existing player lock; future financial writers share this contract. Deferred conserved-supply/linkage checks and restrictive FKs permit atomic redistributions while retaining exactly 100; a first-commit issuance guard also verifies all tokens initially belong to its recipient. Initialization rejects nesting in caller transactions so success follows its own durable commit. Pure validation rejects legacy contradictions, negative offsets, wrong quote linkage or invalid designation before returning a retry success. No repair. Initialization takes global-before-player; future multi-player writers sort player locks and never request the global issuance lock afterward.

Create one shared market_quotes store, not a parallel initialization history. Its initial_issuance/1 rule supplies exact NUMERIC 1 and sampled DB UTC effective time; immutable issuance references that quote. This deliberate fixed rule lies outside performance strategy selection. TASK-026 extends the same store with required performance evidence; no such calculation/retention is implemented here. Quotes, issuance and recipient are protected from ordinary UPDATE/DELETE/TRUNCATE. Trusted DB-owner destructive DDL is outside the threat model.

Pre-commit failure rolls back every new effect including recipient fixation. Commit followed by lost acknowledgement retains evidence; valid retry returns it. SC-003 applies to incomplete attempts, consistent with US2 scenario 3/FR-006; committed retries follow FR-008/009. No deletion or financial compensation.

## Consequences and alternatives

Explicit CP2 setup must initialize a fresh eligible player before performance quoting. Prior unissued quote history remains an error; no backfill/automation. Future trading/quote code must coordinate through these locks and preserve original evidence. Initialization is serialized globally, acceptable for explicit setup without an invented throughput requirement.

Application-only locking misses multiple processes/direct DML. Player-only locking permits conflicting first recipients across players. Serializable retry infrastructure is unnecessary here. A separate initial quote store fragments history; active-strategy valuation changes the required fixed price. A new balance/role model exceeds scope. Corruption tests use pure snapshots/test-owned legacy schemas, committed races use isolated namespaces, and fresh runtimes prove durability without deleting protected records.

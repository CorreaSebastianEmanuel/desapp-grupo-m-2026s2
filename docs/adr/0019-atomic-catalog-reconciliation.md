# ADR-0019: Atomic catalog reconciliation and observation identity

**Status**: Accepted for TASK-018 design
**Date**: 2026-10-08

## Context

The merged provider contract uses result-local references; ingestion needs persistent identity without names or source IDs becoming market identities. Critic findings require exact delivery equivalence, absent-scope/shared-league coordination and valid final-state team key swaps. Current normalized expression indexes reject swaps during intermediate updates.

## Decision

Use the existing PostgreSQL transaction as the publication boundary. Capture accepted revision before retrieval, representing absence as 0; fetch outside the transaction. Acquire a deterministic per-scope transaction advisory lock, then replay exact accepted delivery before revision and timestamp rejection. Scope collision in the lock hash can only add serialization. Concurrent different-season creation of a shared canonical league uses existing nondeferrable business uniqueness and conflict-safe insert/re-read.

Persist provider/kind/scope-qualified typed source bindings and append-only observations/membership. Compare a versioned canonical delivery including resolved facts/bindings, retrieval time and fixture attribution; verify full equality after digest lookup. Later identical football facts receive separate observation evidence; only exact deliveries converge/replay. Keep provider-neutral UUID catalog identities and current-affiliation semantics from ADR-0002.

Replace only the two team normalized expression indexes with same-named UNIQUE constraints on generated stored normalized columns, DEFERRABLE INITIALLY IMMEDIATE. Explicitly defer these inside publication, validate the whole retained final candidate, and force constraints immediate before acceptance. Keep all other uniqueness and restrictive/composite FKs. Do not use deferred uniqueness as ON CONFLICT arbiters. This database extension preserves business uniqueness and valid swaps; it adds no infrastructure.

Trusted retrieval instants remain the ordering key. A future accepted instant can make later genuine observations stale, including across providers. No clamping, tolerance, reset interface or source-specific timeline is authorized.

## Consequences and alternatives

Catalog/evidence publish together; lost replies recover through exact replay. Reads see committed complete states; omission retains records. Independent connection tests must cover revision 0, shared hierarchy, key swaps, final collisions and rollback. Migration checks preserve TASK-005 case/whitespace uniqueness and existing Ecto names.

Names/fact-only hashes cannot prove identity/lineage; scheduler locks or absent-row locks cannot prove publication exclusivity; a global lock couples unrelated scopes. Temporary placeholder keys add synthetic writes; dropping uniqueness weakens integrity; rejecting valid swaps changes approved behavior. Generated columns add small storage/write cost and migration locking; use normal reviewed migrations without source activation or production execution in architecture.

Evidence: active spec FR-003–013; research.md; [PostgreSQL 17 CREATE TABLE](https://www.postgresql.org/docs/17/sql-createtable.html) and [ALTER TABLE](https://www.postgresql.org/docs/17/sql-altertable.html). ADR-0013/0018 retain provider deadline, safety and live-access gates. Financial/quote/statistics/scheduling ownership is unchanged.

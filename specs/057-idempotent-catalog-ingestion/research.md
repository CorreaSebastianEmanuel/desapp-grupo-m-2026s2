# TASK-018 feature-specific research

## Delivery versus facts

Decision: exact delivery equality includes operation, normalized scope, provider, UTC retrieval instant, nullable fixture ID, resolved normalized facts and qualified bindings, with a versioned canonical serialization. Compare full canonical values after digest lookup. Football-row equality ignores retrieval/fixture evidence but uses resolved local identities and supplied mutable values.
Rationale: FR-010–012 and critic finding 1 prohibit losing observation lineage through fact-only convergence.
Alternatives considered: hashing raw DTOs makes refs/order significant; facts-only replay loses later observations. Explicit reconciliation instructions resolve identities but are not provider delivery fields; validate them independently before a replay.

## Absent scopes and shared hierarchy

Decision: absent accepted revision is 0; capture it before retrieval. Acquire per-scope PostgreSQL transaction advisory lock only for publication; exact replay precedes revision/time rejection. Use nondeferrable canonical league/season uniqueness with insert-do-nothing and re-read for distinct-scope races.
Rationale: existing provider fetch is read-only; locks held across retrieval or a global lock unnecessarily block unrelated scopes. All catalog/evidence writes remain a single transaction.
Alternatives considered: scheduler locks cannot supply domain guarantees; row locks alone cannot lock an absent scope. Collisions in hashed lock keys serialize harmlessly. Existing DB uniqueness remains the final integrity guard.

## Final-state normalized team uniqueness

Decision: replace only team normalized expression indexes with same-named deferrable unique constraints on stored generated `lower(btrim(...))` columns, initially immediate; defer explicitly in ingestion and force immediate before commit.
Rationale: current sequential updates cannot exchange codes/names. PostgreSQL 17 supports stored generated columns and deferrable uniqueness; deferred constraints cannot arbitrate ON CONFLICT, so teams use identity-directed writes. This is an architectural extension recorded in ADR-0019, preserving the existing business rule.
Alternatives considered: temporary fake names/codes require extra writes and reserved values; dropping uniqueness weakens integrity; rejecting valid swaps violates FR-007. Preserve remaining indexes/FKs and test the complete uniqueness matrix/migration regression.
Evidence: local migration `priv/repo/migrations/20260917090000_create_catalog_tables.exs`; [PostgreSQL 17 CREATE TABLE](https://www.postgresql.org/docs/17/sql-createtable.html) and [ALTER TABLE](https://www.postgresql.org/docs/17/sql-altertable.html). No broad stack research.

## Trusted observation clocks

Decision: preserve provider retrieval-time ordering exactly, including future-dated observations across providers. Show stale recovery limitation in outcomes/tests.
Rationale: critic finding 4 identifies an operational limitation, not authorization for clock correction.
Alternatives considered: tolerance, clamping, provider-specific clocks and reset controls would change product behavior and are excluded.

## Reused decisions

Current affiliation: ADR-0002. Provider shapes, deadlines and safe errors: ADR-0013 and merged `lib/football_market/providers*`. Offline access/completeness: ADR-0018 and TASK-055 feedback (including final publication revalidation). Local read/scheduler/TTL ownership: ADR-0016/0017 and docs/CP2_ARCHITECTURE.md. Separate profile discovery: test/support/test_profile_audit.ex; one module tag required, automatic file discovery. Toolchain and service baseline remain unchanged. No concrete unknown remains.

# Focused findings — TASK-025

Settled stack: [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md). Settled scoring/replay: ADR-0020/21/22 and [TASK-024 Feedback 1](../../backlog/feedback/TASK-024.md). Local code and approved behavior resolve the feature choices. A focused primary-documentation check below resolves the concrete post-lock snapshot risk; no stack survey or research agent is needed.

## Exact persistence

- **Decision**: schema-versioned typed JSONB; preserve integers versus canonical Decimals, all groups and unused mappings.
- **Rationale**: `valuation/evidence.ex` distinguishes integer and Decimal tags, canonicalizes equivalent Decimals/zero; exact arithmetic reads coefficient/exponent. Numeric equality alone cannot prove canonical round-trip.
- **Alternatives considered**: fixed-scale NUMERIC, JSON numbers, term blobs. They risk ceilings/type loss or unnecessary decoding trust. ADR-0023/data-model.md define the selected codec.

## Rule-only validation

- **Decision**: extract a reusable Request helper without changing existing prepare/evaluate behavior; formula modules derive requirements; save-time mapping checks use existing position UUIDs.
- **Rationale**: Request currently couples rules to subject/week; fake player/week validation would conceal errors. Existing Balanced/PositionAware already validate all-zero entries and malformed maps.
- **Alternatives considered**: duplicate validators or preparation with fake facts. Both diverge from inherited behavior.

## Immutability and activation

- **Decision**: database guards plus latest committed change as active authority, serialized with a seeded lock row and guarded change insertion.
- **Rationale**: ADR-0010 protects ordinary Repo writes. The anchor handles empty history; order must be assigned after locking. Expected identity remains value comparison, including A→B→A.
- **Alternatives considered**: context-only checks, pointer plus log, caller revisions. They weaken/enlarge enforcement or change approved behavior. ADR-0023 records the limit.

## Binding and durable tests

- **Decision**: UUID envelope around existing Descriptor; full rule comparison before inherited replay. Restart tests hold descriptors outside recreated Repo clients; isolated test namespaces permit committed races without deleting immutable fixtures.
- **Rationale**: existing evaluate/replay already implement exact scoring and authoritative facts. TASK-026 owns retention. Catalog race support shows distinct backends matter, but its deletion cleanup cannot apply here.
- **Alternatives considered**: quote tables here, shared Sandbox race, trigger-disabling cleanup. They expand scope or fail to establish durability/concurrency.

## Verification integration

- **Decision**: existing profile tags/discovery, targeted evidence and one final run of each full profile; no historical CP1 report/HTTP runtime check.
- **Rationale**: `test/support/test_profile_audit.ex` discovers tags automatically; integration preflight checks real Chromium. The feature declares no HTTP routes. Legacy scope gates need exact role-separated allowances.
- **Alternatives considered**: changing CI/profiles, repeating coverage profiles, relaxing formula purity. No concrete obligation supports them.

## Post-lock snapshot integrity

- **Decision**: history insertion uses a VOLATILE PL/pgSQL trigger at READ COMMITTED, locks the singleton in one statement and reads the predecessor in a subsequent statement. Reject other write isolation levels; read-only inspection may use a consistent stronger snapshot.
- **Rationale**: PostgreSQL documents per-query snapshots at READ COMMITTED and fresh snapshots for queries executed inside volatile functions. A pre-lock repeatable-read snapshot can conceal an intervening committed change. The guard is our design inference from these visibility rules, not a product revision token. Sources: [transaction isolation](https://www.postgresql.org/docs/18/transaction-iso.html), [function volatility](https://www.postgresql.org/docs/18/xfunc-volatility.html).
- **Alternatives considered**: trusting an unchanged lock row to refresh every isolation level, or adding an internal mutable revision. Explicit write-isolation enforcement preserves the smaller append-only authority and makes unsupported use fail visibly. Direct SQL regression tests must confirm it.

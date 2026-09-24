# Research: Development Seed Data

## Approved product decisions

- **Decision**: Preserve and reuse identity values that are equivalent under TASK-005 normalization, and prohibit production execution through an explicit development/test-only capability.
- **Rationale**: The current human check approved the recommendations in `handoffs/product-decision.md`. Semantic convergence satisfies normalized reuse without changing developer data; fail-closed execution protects authoritative catalogs.
- **Alternatives considered**: Rejecting variants contradicts normalized reuse. Rewriting them violates preservation. Permitting deliberate production use risks fictional live data. See `docs/adr/0004-development-seed-safety-and-semantic-convergence.md`.

## Entry point and error contract

- **Decision**: Expose only `mix catalog.seed`, backed by a typed catalog seed service. Success exits zero with target/created/reused counts; forbidden, conflict, validation, relationship, and persistence outcomes are sanitized nonzero failures containing entity type and manifest identity when applicable.
- **Rationale**: A dedicated Mix task is scriptable, explicit, and testable while keeping domain logic outside the adapter. Typed errors let automation distinguish outcomes without leaking raw database details.
- **Alternatives considered**: A standalone `priv/repo/seeds.exs` is less precise as a tested command contract. Setup/startup aliases violate explicit loading. HTTP and jobs add unauthorized interfaces.

## Transactional reconciliation

- **Decision**: Validate the immutable manifest, then reconcile it in dependency order inside one `Ecto.Multi` transaction. Look up every alternate business identity, reuse only one coherent match, create only when all identity lookups are absent, and abort on mismatch or persistence failure. Never update or delete.
- **Rationale**: One transaction provides all-or-nothing behavior, named multi steps retain entity/identity context, and existing Catalog changesets plus PostgreSQL constraints remain authoritative.
- **Alternatives considered**: Upserts can hide split-key or relationship conflicts. Pre-delete/reinsert changes IDs and local data. Independent transactions permit partial catalogs. A new ownership table duplicates manifest membership.

## Identity comparison

- **Decision**: Use TASK-005's `lower(btrim(...))` database queries/indexes as the sole string-identity oracle. Code/name pairs for leagues, teams, and positions must resolve to one row; season uses league and years; player uses season-scoped catalog identity. Only player display name is a non-identity text attribute and compares exactly. Relationships compare resolved UUIDs.
- **Rationale**: This gives every entity an explicit conflict matrix, preserves normalized-equivalent stored spelling and internal identity, and avoids a second normalization model.
- **Alternatives considered**: Elixir-only normalization can drift from PostgreSQL collation. Byte comparison rejects approved matches. Comparing only one alternate key could reuse the wrong record.

## Concurrent invocation

- **Decision**: Support one active invocation. If commands race, database constraints prevent duplicates and the losing transaction must roll back; callers may retry after the other invocation completes.
- **Rationale**: The specification requires repeatability, not simultaneous success. Explicitly bounding concurrency plus constraint-backed integrity is the smallest resolution of the critic's finding.
- **Alternatives considered**: Advisory locks, blocking waits, serializable isolation, and retry loops add PostgreSQL-specific behavior and new timeout/fairness policy without a requirement.

## Stable manifest

- **Decision**: Use the exact `Demo <league> Alpha/Beta FC` teams, `Demo <league> <position>` players, and `demo-2026-27-<league>-<position>` identities in `data-model.md`, with GK/DEF on Alpha and MID/FWD on Beta.
- **Rationale**: Values are stable, provider-neutral, visibly demonstrative, easy to audit, and unique even where the schema requires only scoped uniqueness.
- **Alternatives considered**: Real clubs/players create licensing and freshness ambiguity. Generated names undermine stability. More varied data adds no acceptance coverage.

## Performance oracle

- **Decision**: Measure the explicit command on a dedicated empty, migrated local PostgreSQL database with dependencies already compiled and the repository-pinned toolchain. Exclude database/service startup, dependency preparation, and migrations; include command/BEAM startup and reconciliation through process exit.
- **Rationale**: This creates a reproducible boundary for the ten-second success criterion and verifies the actual supported entry point.
- **Alternatives considered**: A unit-test duration assertion is hardware-sensitive and omits adapter startup; an unspecified stopwatch cannot be a pass/fail oracle.

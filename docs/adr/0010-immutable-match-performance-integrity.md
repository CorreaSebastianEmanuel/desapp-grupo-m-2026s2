# ADR-0010: Preserve Match Inputs with Relational Integrity

**Status**: Accepted for TASK-020 implementation
**Date**: 2026-10-03

## Context

The product challenge identified catalog mutation races that application prevalidation cannot prevent. ADR-0002 authorizes current team and position changes. Matches and performances must remain immutable, including through ordinary repository writes. This extends the architecture baseline with narrowly scoped database constraints and triggers, not another service.

## Decision

Use composite restrictive foreign keys for historical season relationships. Add unique keys on players(id, season_id), matches(id, season_id), and seasons(id, league_id, start_year, end_year); reuse teams(id, season_id). A match carries private integrity witness columns season_league_id, season_start_year and season_end_year copied from its season inside its creation transaction. Its composite season foreign key protects the competition/year meaning of a referenced season. Witnesses are not provider provenance or new caller inputs.

Performances carry a private season_id derived from the match and reference the match, player and event-time team using composite season keys. Restrict both deletion and key updates; never cascade. Ordinary current team/position updates remain allowed, and catalog display labels are not frozen.

A performance insertion trigger checks event-time team membership against the immutable match's home/away teams. Named BEFORE UPDATE/DELETE triggers reject all changes to matches and performances, including no-op replacements. Foreign keys arbitrate concurrent catalog key changes and inserts; unique keys arbitrate duplicate inserts. Map known constraint names to stable domain errors. Database owners and destructive DDL remain outside the trusted internal write contract.

## Consequences

No valid committed state can contain cross-season or orphaned facts. Catalog changes racing an insert may win first (the insert validates the resulting state or fails), or the insert wins (the incompatible key mutation fails). Tests must use separate database connections and actual commits; a shared Sandbox connection does not establish a race.

Future correction design must preserve old inputs. Late-arriving rows still change an interval's membership: TASK-022 and subsequent quote design must retain exact selected input IDs or equivalent immutable membership and test late arrival. This ADR does not select a quote snapshot, availability cutoff, ingestion policy or correction workflow.

## Alternatives

Application-only validation leaves races and direct writes unprotected. Freezing catalog rows blocks approved transfers. Explicit membership/snapshot entities and availability versions add scope before ingestion and valuation are specified. Private relational witnesses avoid a racy season metadata guard trigger.

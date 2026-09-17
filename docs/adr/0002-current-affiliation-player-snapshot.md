# ADR-0002: Represent a Player as a Current-Affiliation Season Snapshot

**Status**: Accepted

**Date**: 2026-09-17

## Context

TASK-005 gives each player exactly one team and one provider-neutral identity per league season, while transfer history and ingestion are out of scope. An in-season transfer cannot be represented without defining whether to mutate, multiply, or reject the affiliation. The product challenge identified this as material, and the required human check approved the recommended current-affiliation model.

## Decision

Within one league season, changing a player's team updates the existing player record. The internal ID and season-scoped catalog identity remain stable. Reassignment to a team in another season is rejected; that season uses a distinct player record.

The catalog does not store roster stints or effective dates in TASK-005. Future match/statistics data must retain its own event-time team context and must not reconstruct historical affiliation from the player's current team. Later ingestion may introduce dated roster history through a separately specified extension without changing this snapshot's meaning.

## Consequences

- Current catalog queries remain simple and accurate for present affiliation.
- Prior team affiliation is not recoverable from the TASK-005 player record.
- Team reassignment needs same-season validation and atomic persistence.
- Future provider reconciliation can update current affiliation, but future historical facts cannot rely solely on the mutable player-to-team relation.

## Alternatives rejected

- **Immutable roster stints** preserve history but add an entity, effective dates, and temporal rules outside TASK-005.
- **Reject in-season changes** is smaller mechanically but makes valid current-affiliation data stale.

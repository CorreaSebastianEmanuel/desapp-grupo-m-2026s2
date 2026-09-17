# Product Handoff: Football Catalog Domain Model

## Decisions

- Model the catalog as season-specific snapshots: a season belongs to one league, a team belongs to one season, and a player belongs to one team and one position. League and season are derived for players, avoiding contradictory duplicate associations.
- Use a provider-neutral player catalog identity unique within a league season. Provider identifiers remain outside this task so the domain does not leak adapter data.
- Keep the position taxonomy open as catalog data; this task defines identity and validity rules but does not choose or seed the position set.

## Unresolved Assumptions

- Planning should confirm a concrete, deterministic format or generation rule for the provider-neutral player catalog identity. This is reversible as long as the specified uniqueness scope remains intact.
- Planning should verify whether the persistence layer can enforce normalized case/whitespace uniqueness directly; otherwise it must provide equivalent race-safe behavior.

## Guidance

- Translate the specified business lookup paths into explicit persistence indexes during planning, including combined league/season/team/position access used by future catalog filters.
- Keep provider mappings, historical transfers, and cross-season reconciliation extensible but out of the current model; TASK-016 and TASK-018 own those behaviors.

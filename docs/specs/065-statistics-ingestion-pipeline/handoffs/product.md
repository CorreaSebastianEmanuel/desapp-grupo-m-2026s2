# Product handoff — TASK-021

## Decisions

- Substitute position is the unique mode across the player's accepted, known positions in earlier matches of the same season. Exclude the valued match and all later matches. Ties and no usable history remain unknown. Never substitute provider `usualPosition` or current profile position. Preserve direct starter positions and provenance for both direct and derived values.
- Successful complete imports atomically accept facts, provenance, and scope check state. Exact replays are safe; conflicting immutable facts fail without changing accepted history. Unknown optional counts remain distinct from zero.
- Use offline sanitized fixture lineage for deterministic traceability. TASK-055/ADR-0018 access and coverage gates still govern every live attempt; fixture success does not establish live readiness.

## Unresolved assumption / planning guidance

- TASK-016 FR-006/008 currently rejects source results without a recognized event-time position, and TASK-020 FR-003 currently requires a known persisted position. This decision requires ingestion to derive a substitute entrant's position from earlier history and preserve unknown after ties or insufficient history. Plan the minimum contract reconciliation across both boundaries before implementation. Do not change TASK-020's status, reopen its implementation, or mutate accepted facts; identify the adjustment explicitly in TASK-021's plan.
- `.specify/feature.json` was absent; the feature is bound to `specs/065-statistics-ingestion-pipeline` based on sequential feature numbering. No extension hooks are registered.
- Reuse TASK-016, TASK-019 and TASK-055 boundaries. Do not add freshness/UI, catalog sync, valuation formulas, quote insertion, or CP2 charts/conditional orders here.

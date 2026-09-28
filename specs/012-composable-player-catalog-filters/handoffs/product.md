# Product Handoff: Composable Player Catalog Filters

## Decisions

- No additional product decisions beyond the canonical spec.

## Unresolved Assumptions

- No material product question remains before planning.

## Guidance

- Inspect the existing player-list cursor and domain lookup paths before choosing how to represent a cursor's filter selection. Existing cursor payloads provide a concrete compatibility case.
- Use fixtures where team labels recur across seasons and player names vary only by case; they distinguish identity matching and expose pagination gaps.
- Coordinate the future TASK-013 contract update after implementation, using this spec as the source for behavior.

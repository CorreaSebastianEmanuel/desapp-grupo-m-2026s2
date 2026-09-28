# Data Model: Player Catalog Read API

## Persisted entities

No new entity or mutable state is introduced. The API reads the TASK-005 hierarchy:

- **Player**: `id` UUID, `catalog_identity` non-empty string unique by normalized value within a season, `display_name` non-empty string, required `team_id`, `season_id`, and `position_id`.
- **Position**: `id` UUID, non-empty `code` and `name`.
- **Team**: `id` UUID, non-empty `code` and `name`, required season.
- **Season**: `id` UUID, integer `start_year` and `end_year`, required league; end year equals start year or start year + 1.
- **League**: `id` UUID, non-empty supported `code` and `name`.

The composite team/season foreign key ensures a player's team belongs to the player's stored season. Reads derive season and league through `player.team.season.league`, never from request input or an independently substituted association.

## Read models

### PlayerCatalogRepresentation

| Field | JSON type | Null | Source |
|---|---|---:|---|
| `id` | canonical UUID string | no | player |
| `display_name` | string | no | player |
| `catalog_identity` | string | no | player; local season-scoped domain identity |
| `position` | object | no | player.position |
| `team` | object | no | player.team |
| `season` | object | no | player.team.season |
| `league` | object | no | player.team.season.league |

Nested objects use UUID-string `id`; string `code`, `short_code`, and `name`; and integer season years. `team.short_code` maps from persisted `team.code`. No field is nullable.

### CatalogPage

- `data`: ordered list of `PlayerCatalogRepresentation`, length 0..`page_size`.
- `page_size`: integer 1..100; default 25.
- `returned_count`: integer equal to `length(data)`.
- `has_more`: boolean derived from one extra matching row.
- `next_cursor`: non-empty encrypted token iff `has_more`; otherwise null.

### ContinuationCursor (internal plaintext before encryption)

- `version`: integer `1`.
- `scope`: exact string `players:list`.
- `normalized_display_name`: non-empty normalized ordering string.
- `player_id`: UUID.

The token is not persisted, is not bound to an actor or page size, and expires only through an intentional contract/key rotation. All decode/integrity/shape/scope failures collapse to `invalid_cursor`.

## Ordering and transitions

The page relation is lexicographic on `(lower(btrim(display_name)), id)`. A continuation selects tuples strictly greater than its anchor. There is no entity state transition and no snapshot lifecycle. On unchanged data, traversal is stable and complete; insertions obey their relative position; ordering-field updates or deletions can cause cross-page gaps or duplicates. Anchor deletion does not prevent decoding or continuation.

## Persistence change

Add a non-unique expression index on `players (lower(btrim(display_name)), id)` to support ordered seek and first-page queries. No table, column, cache, or cursor record is added.

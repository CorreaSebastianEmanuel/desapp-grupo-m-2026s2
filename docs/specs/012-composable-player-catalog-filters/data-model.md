# Data Model: Filtered Player Catalog

No new database entity, field, association, or state transition is required. The TASK-005 foreign keys and constraints remain authoritative.

## Persisted hierarchy

| Entity | Relevant fields | Relationship and filter meaning |
|---|---|---|
| Player | `id`, `display_name`, `team_id`, `season_id`, `position_id` | One current season-specific catalog record; returned in TASK-011 order |
| Team | `id`, `season_id`, `code`, `name` | `team_id` matches this exact record, including its season |
| Season | `id`, `league_id`, years | Reached through the player's team; composite player team/season FK prevents conflicting stored affiliation |
| League | `id`, `code`, `name` | `league_id` matches the team season's league |
| Position | `id`, `code`, `name` | `position_id` matches the player's position |

Existing indexes include `players_catalog_order_index` on `(lower(btrim(display_name)), id)`, player foreign-key indexes, `teams.season_id`, and `seasons.league_id`. No new index is planned without measured evidence.

## Request and read models

**FilterSet**: Map with zero to three distinct keys `league_id`, `team_id`, `position_id`, each containing one canonical lowercase UUID. Absent keys impose no restriction. Membership is the intersection of all present predicates. Syntactically valid unknown IDs and mutually inconsistent IDs remain valid filter sets and yield an empty result. There is no lookup/validation transition for existence.

**FilteredCatalogPage**: Existing TASK-011 `data` array and `pagination` object. Every data element satisfies FilterSet. The query orders matching rows by `lower(btrim(display_name)), id`, seeks after an optional anchor, and selects at most `page_size + 1` to determine continuation. `returned_count` equals the array length, and `next_cursor` is present only with further matches.

**ContinuationCursor**: Internal encrypted value. Unfiltered v1 retains the TASK-011 scope and ordering anchor. Filtered v2 contains the same anchor plus the canonical FilterSet. A decoded cursor is usable only when its embedded set equals the request's effective set. Page size is independent. A cursor is stateless and is not a historical snapshot; unchanged data gives deterministic traversal, while catalog changes retain TASK-011 semantics.

## Validation

Each supplied filter occurs once, is an unpadded 8-4-4-4-12 UUID string with ASCII hexadecimal digits, and is canonicalized after syntax validation. Duplicate or bracket-structured keys are invalid. Transport validation precedence is `page_size`, `league_id`, `team_id`, `position_id`, then `cursor`, after authentication. A valid but unmatched FilterSet does not reveal which relation is absent.

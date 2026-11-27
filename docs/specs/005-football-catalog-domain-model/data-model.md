# Data Model: Football Catalog

All tables use UUID primary keys, `utc_datetime` timestamps, non-null foreign keys, and restrictive foreign-key deletion. Required text is stored trimmed and guarded by `btrim(value) <> ''`. Business-key comparisons use `lower(btrim(value))`.

## League

- Fields: `id`, `name`, `code`, timestamps.
- Validation: exact application-owned name/code pair; neither blank.
- Uniqueness: normalized `name` globally; normalized `code` globally.
- Relationships: has many seasons.
- Deletion: rejected while seasons exist.

## Season

- Fields: `id`, `league_id`, `start_year`, `end_year`, timestamps.
- Validation: `end_year = start_year` or `end_year = start_year + 1`.
- Uniqueness: `(league_id, start_year, end_year)`.
- Relationships: belongs to league; has many teams.
- Deletion: rejected while teams exist.

## Team

- Fields: `id`, `season_id`, `name`, `short_code`, timestamps.
- Validation: name and short code non-blank.
- Uniqueness: normalized `name` within `season_id`; normalized `short_code` within `season_id`.
- Relationships: belongs to season; has many players.
- Derived values: league through season.
- Deletion: rejected while players exist.

## Position

- Fields: `id`, `name`, `code`, timestamps.
- Validation: name and code non-blank; taxonomy remains open.
- Uniqueness: normalized `name` globally; normalized `code` globally.
- Relationships: has many players.
- Deletion: rejected while players exist.

## Player

- Fields: `id`, `team_id`, database-constrained `season_id`, `position_id`, `display_name`, `catalog_identity`, timestamps.
- Validation: display name and catalog identity non-blank; team and position must exist.
- Uniqueness: normalized `catalog_identity` within the league season derived from team.
- Relationships: belongs to team and position; season and league are derived through team.
- Reassignment transition: `team A -> team B` is valid only if both teams share the same `season_id`; player ID, position, and catalog identity remain unchanged unless separately updated. A destination in another season is rejected.
- Deletion: allowed because no dependent catalog entity exists in this task.

## Enforcing season-scoped player identity

The player persists `season_id` solely as a constrained relationship key. A unique constraint on teams `(id, season_id)` plus composite foreign key `players(team_id, season_id) -> teams(id, season_id)` makes contradiction impossible; team season ownership is immutable after creation. A unique expression index on `(season_id, lower(btrim(catalog_identity)))` then rejects concurrent duplicates. The context derives `season_id` from the selected team and never accepts it as independent caller input. This is not an independently editable hierarchy value and therefore preserves FR-016.

## Indexes

- Unique expression indexes for both League identities, both Position identities, and both Team identities scoped by season.
- Unique season index `(league_id, start_year, end_year)`.
- Unique player identity index on `(season_id, lower(btrim(catalog_identity)))`, backed by the composite team/season foreign key.
- Foreign-key indexes: `seasons(league_id)`, `teams(season_id)`, `players(team_id)`, `players(position_id)`.
- Filter index: `players(team_id, position_id, id)`; primary/parent indexes support joined league and season filters.

## Integrity transitions

- Inserts/updates move from candidate to persisted only after changeset and database constraints pass.
- A failed constraint leaves the previous state unchanged.
- Parent deletion with dependents remains persisted and returns a relationship error.
- Any concrete multi-write command commits all writes or rolls all back through one transaction.

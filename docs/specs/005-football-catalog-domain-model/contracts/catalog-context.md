# Contract: `FootballMarket.Catalog`

This is an internal Elixir context contract, not an HTTP API.

## Commands

- `create_league(attrs)`, `create_season(attrs)`, `create_team(attrs)`, `create_position(attrs)`, `create_player(attrs)` return `{:ok, entity}` or `{:error, changeset}`.
- `update_player(player, attrs)` permits position/display changes and current-team reassignment only inside the existing season.
- `delete_league/1`, `delete_season/1`, `delete_team/1`, and `delete_position/1` return `{:error, changeset}` when dependents exist.
- Constraint errors identify the relevant field (`name`, `code`, `short_code`, `catalog_identity`, years) or relationship (`league`, `season`, `team`, `position`). Existing records are never replaced on conflict.

## Singular lookups

- Stable identity: `get_<entity>(uuid)` returns `{:ok, entity}` or `{:error, :not_found}`.
- League: code or name.
- Season: `league_id` plus `start_year` and `end_year`.
- Team: `season_id` plus code or name.
- Position: code or name.
- Player: `season_id` plus catalog identity; the query derives season through team.

Text business keys follow the normalization rule in `data-model.md`.

## Player collection lookup

`list_players(filters \\ %{})` accepts only `league_id`, `season_id`, `team_id`, and `position_id`. Supplied filters combine with AND. `%{}` returns all players. Unknown keys return `{:error, {:unknown_filters, keys}}`; well-formed unknown IDs return `{:ok, []}`. Results preload enough associations to resolve position, team, season, and league and are ordered by ascending player UUID.

No pagination, HTTP parameter grammar, provider identifier, ingestion payload, cache behavior, or transfer-history contract is defined here.

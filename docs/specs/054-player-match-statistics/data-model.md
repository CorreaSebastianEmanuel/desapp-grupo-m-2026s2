# Data Model — Player Match Statistics

Existing entities and current-affiliation behavior remain defined by TASK-005 and ADR-0002. All new IDs are generated UUIDs. Table names: matches and player_match_performances. Foreign keys use RESTRICT on delete/update; no cascades.

## Match

| Field | Type | Rule |
| --- | --- | --- |
| id | UUID | Stable local primary key |
| match_identity | text | Required trimmed provider-neutral completed-event identity |
| normalized_identity | generated text | Database-authoritative lowercased identity after removal of surrounding whitespace |
| kickoff_at | UTC timestamp(6) / :utc_datetime_usec | Required actual instant; ADR-0011 validation |
| season_id | UUID | Existing season |
| home_team_id, away_team_id | UUID | Distinct existing teams in season |
| season_league_id, season_start_year, season_end_year | UUID, integer, integer | Private witnesses copied from season; not accepted from caller |
| inserted_at | UTC microsecond timestamp | Persistence metadata, not kickoff or quote availability policy |

Normalize identity using `lower(statistics_trim_identity(match_identity))` for the generated key and season-scoped lookup. `statistics_trim_identity(text)` removes exactly the pinned String.trim/1 Unicode White_Space set: U+0009–000D, U+0020, U+0085, U+00A0, U+1680, U+2000–200A, U+2028, U+2029, U+202F, U+205F, U+3000. The corrective migration `20261004000000_align_statistics_identity_whitespace.exs` replaces the legacy locale-dependent POSIX expression transactionally. Keep existing unique/nonblank constraints and append-only guards enabled: legacy collisions or newly blank keys must abort without rewriting accepted facts. Test all 25 characters, mixed padding, Unicode blanks, internal whitespace retention, duplicate conflicts and scoped lookups; use database lowercase/collation consistently rather than another Elixir case rule. Reject invalid UTF-8 or U+0000 in original input before SQL as field-safe validation (ADR-0012). Nonblank check applies to the normalized key. Unique (season_id, normalized_identity), unique (id, season_id). Same identity across seasons and multiple matches on one day are valid. Match identity is caller supplied and never derived from date/teams.

Composite foreign keys (home_team_id, season_id) and (away_team_id, season_id) reference teams(id, season_id). Composite season witness key references seasons(id, league_id, start_year, end_year). Index season/normalized identity and kickoff/id for local lookups; do not claim a performance benchmark.

## PlayerMatchPerformance

| Field | Type | Rule |
| --- | --- | --- |
| id | UUID | Stable local primary key |
| match_id, player_id | UUID | Existing records; unique pair |
| season_id | UUID | Private derived match season |
| team_id | UUID | Explicit event-time participating team; independent of current team |
| position_id | UUID | Explicit existing event-time position; independent of current position |
| minutes_played | exact numeric / Count integer | Required nonnegative whole minutes; no 90/120 ceiling |
| goals, assists, shots_on_target | nullable exact numeric / Count | Nonnegative integer or unknown |
| tackles, interceptions, saves | nullable exact numeric / Count | Nonnegative integer or unknown |
| goals_conceded, yellow_cards, red_cards | nullable exact numeric / Count | Nonnegative integer or unknown |
| inserted_at | UTC microsecond timestamp | Persistence metadata |

FR-006 owns metric meanings. Zero minutes with positive counts is valid. No metric default; nil means unknown. Count casts only integers or optional nil, dumps exact Decimal, loads integer. PostgreSQL numeric columns have no declared precision/scale; constraints require finite, nonnegative and integral values (reject NaN/infinities explicitly). Ecto/custom validation rejects floats (including 1.0), booleans, strings, negative counts and unsupported keys before any coercion. Do not constrain counts using minutes or position; no missing performances are manufactured.

Composite FKs reference matches(id, season_id), players(id, season_id), teams(id, season_id), with a simple restrictive position FK. The insertion participation trigger reads home/away IDs and rejects other teams with a named relationship violation. Immutable matches make that predicate stable. A history index on (player_id, match_id) supports joins to matches; only add further indexes when an actual query needs them.

## State and mutation rules

Only absent -> accepted exists. Every update, delete and replacement of an accepted match/performance is rejected by context functions and database UPDATE/DELETE triggers. Accepted facts may be added for an older kickoff; this is not a frozen quote input set.

Catalog FK key changes that invalidate historical meaning and catalog deletion are rejected. Current player team/position and display-label updates stay supported. Teach existing Team, Season and Position deletion changesets about the new named FK constraints so supported Catalog functions return errors instead of raising. No player deletion API is introduced; repository deletion remains restricted.

Batch operations insert a list of new match envelopes and their performances in one Ecto.Multi transaction; failures roll back all inserts. A single performance may be inserted for an existing match. Unique constraints arbitrate concurrent duplicates without upsert. Named database violations become contract errors; unrelated infrastructure faults remain faults, never a success or fabricated validation error.

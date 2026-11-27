# Research: Football Catalog Domain Model

## Player transfer semantics

- **Decision**: Treat a player as a current-affiliation snapshot within one league season. Reassigning teams in that same season updates the existing record; changing season creates a distinct player record.
- **Rationale**: This is the approved human decision and the smallest model satisfying the existing entity boundary.
- **Alternatives considered**: Immutable roster stints add temporal scope; rejecting transfers leaves stale data. Both were rejected. See `docs/adr/0002-current-affiliation-player-snapshot.md`.

## Supported league identities

- **Decision**: Own the exact normalized pairs `PL`/Premier League, `BL1`/Bundesliga, `PD`/La Liga, `SA`/Serie A, and `FL1`/Ligue 1 in the Catalog context.
- **Rationale**: These stable football competition codes make FR-002/FR-003 executable and prevent arbitrary recognized-name/code combinations.
- **Alternatives considered**: Names alone are not stable codes; caller-defined pairs violate the closed set; seed-only enforcement is avoidable and race-prone.

## Normalized uniqueness

- **Decision**: Trim values before persistence and use PostgreSQL `lower(btrim(column))` expression unique indexes at the required global or parent scope. Named constraints are translated by changesets/context functions.
- **Rationale**: PostgreSQL becomes the one normalization oracle and rejects concurrent duplicates. `btrim` also supports database checks for whitespace-only values.
- **Alternatives considered**: Application-only checks race. Stored duplicate normalized columns can drift. `citext` adds an unnecessary database extension and still requires trimming.

## Provider-neutral player identity

- **Decision**: Require a caller-supplied opaque string, trim it, preserve it for display/debugging, and compare it with the same normalized rule. Its uniqueness scope is the league season derived from the player's team.
- **Rationale**: Generation belongs to the future source/import owner; accepting an opaque domain key avoids leaking provider IDs while preserving the specified uniqueness behavior.
- **Alternatives considered**: Generating from the player's name is collision-prone and mutable. A random UUID duplicates the internal stable ID and gives importers no idempotent business key.

## Lookup contract

- **Decision**: Define exact business keys and an internal context filter map. Player filters are AND-composed; an empty filter returns all players; unknown keys are errors; collection order is ascending UUID.
- **Rationale**: This makes FR-014/FR-015 deterministic without designing later HTTP/pagination behavior.
- **Alternatives considered**: Unordered Repo results are unstable. Pagination and public query syntax belong to TASK-011/TASK-012.

## Atomicity

- **Decision**: Do not invent a bulk operation. Use one Repo call for single-record commands and `Ecto.Multi` for any concrete multi-write context command that implementation proves necessary.
- **Rationale**: This meets FR-013 without expanding the API around hypothetical ingestion behavior.
- **Alternatives considered**: A speculative hierarchy-import command duplicates TASK-018 concerns.

## Performance evidence

- **Decision**: Create unique/FK/composite indexes for declared paths and validate index-capable plans on representative data. Defer the one-second percentile benchmark to TASK-043.
- **Rationale**: SC-007 lacks a reproducible runtime protocol; schema/index evidence is the reliable output of this task.
- **Alternatives considered**: Incidental local timings cannot establish a portable SLA.

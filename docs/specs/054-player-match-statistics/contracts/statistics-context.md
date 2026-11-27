# Internal Statistics Context Contract

Interface: FootballMarket.Statistics, consumed by trusted local domain callers. No HTTP route, controller, authorization role or provider adapter is added.

## Writes

- record_match(attrs) -> {:ok, match} | {:error, error}. Required keys: match_identity, kickoff_at, season_id, home_team_id, away_team_id. Optional keys: none. The function means a completed match; caller establishes finality. No lifecycle flag is inferred.
- record_performance(attrs) -> {:ok, performance} | {:error, error}. Required keys: match_id, player_id, team_id, position_id, minutes_played. Optional keys: the nine FR-006 metrics. nil is accepted only for optional metrics. No supplied id, season witness, score, timestamp metadata or provider field is accepted.
- record_batch(envelopes) -> {:ok, [%{match: match, performances: [...]}]} | {:error, error}. Each envelope is %{match: match_attrs, performances: [performance_attrs_without_match_id]}; entries refer to the newly created enclosing match. Empty list succeeds as {:ok, []}; a match with an empty performance list is valid. Validate container/key shapes; reject contradictory match_id in nested performance attrs. Preserve input order in the result. Insert everything in one transaction; rollback on any error. Existing-match inserts use record_performance/1; existing matches are never silently reused/upserted by a batch.
- update_match(id, attrs), delete_match(id), update_performance(id, attrs), delete_performance(id): valid known subject -> {:error, :immutable}; unknown subject -> {:error, :not_found}; malformed ID -> validation error. Even identical updates fail. These are explicit rejection interfaces, not a correction mechanism.

Match identity original input must be valid UTF-8 without U+0000; reject malformed text as kind :validation, field :match_identity, reason :invalid_identity before trimming, casting or SQL. Blank identities retain reason :required. Batch rejection includes the failing match_index with performance_index nil, rolls back valid earlier envelopes, and preserves all prior facts. Other encodable Unicode text remains supported.

Attribute maps may consistently use atom or string keys; mixed/duplicate-equivalent keys are rejected, and external strings are never converted into new atoms. Unsupported keys fail validation. Containers that are not maps/lists as specified fail validation rather than raising.

## Reads

- get_match(id) -> {:ok, match} | {:error, :not_found} | validation error.
- get_match(season_id, match_identity) -> same. A missing season is not_found; malformed ID/blank identity is validation failure. Invalid UTF-8 or embedded U+0000 is a match_identity/invalid_identity validation error before any SQL, as on writes; surrounding Unicode White_Space normalization follows data-model.md. Uses the same normalization expression as stored identity.
- get_performance(player_id, match_id) -> {:ok, performance} | {:error, :absent_performance} if both subjects exist | {:error, :not_found} if either is unknown | validation error.
- list_player_history(player_id, opts \ []) -> {:ok, [performance]} | {:error, :not_found} | validation error. Options: from, to only; omitted or nil means unbounded. Bounds follow ADR-0011 and are inclusive; from > to fails. Known player without rows returns []. Exact player UUID only; no grouping across season-specific catalog records.

History rows include immutable match fields and stored event-time team_id/position_id, minutes and optional metrics; do not attach current affiliation as historical evidence. Order by kickoff_at ascending then normalized_identity ascending using database collation. Pair uniqueness and fixed player season prevent unresolved ties. Reads never invoke adapters, cache or HTTP services. Equivalent offsets compare as the same instant; original offset formatting is not retained.

## Errors and atomicity

Validation/conflict error shape: {:error, %{kind: :validation | :conflict, field: atom, reason: atom, record: nil | %{match_index: nonnegative_integer, performance_index: nil | nonnegative_integer}}}. Reasons include required, invalid_identifier, invalid_instant, unsupported_precision, invalid_count, unsupported_field, invalid_shape, invalid_identity, missing_reference, season_mismatch, nonparticipant, identical_teams, invalid_interval and duplicate. Field identifies the caller's field/relationship; batch errors identify the input position. All indexes are zero based. Not-found/absent/immutable use atoms above. No SQL, constraint names, adapter data or raw provider payload appears in errors.

The changeset layer maps known named constraints into these errors. Database exceptions from immutable triggers have stable named codes translated at the context boundary. Supported Catalog deletion functions keep their established changeset return shape and add new relationship constraints rather than adopting Statistics errors.

Concurrent insertions: exactly one succeeds for a duplicate key; losing inserts return conflict, including identical submissions. A catalog key change and fact insert cannot both commit into an invalid state. No automatic retry, correction, provenance or reconciliation is part of this interface.

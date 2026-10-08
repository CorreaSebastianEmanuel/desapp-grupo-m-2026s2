# Ingestion data model

Existing Catalog League/Season/Team/Position/Player schemas and TASK-005 uniqueness remain authoritative. UUID internal IDs and player season-scoped catalog_identity remain stable; a new player's catalog_identity is an independent generated UUID string. A same-season transfer changes only current team, name and position. No cross-season person entity is added.

## CatalogScope (`catalog_ingestion_scopes`)

UUID id; canonical league_code, start_year, end_year (unique tuple); season_id FK; revision positive bigint; latest_observation_id nullable only while building a transaction. Revision 0 is a virtual absent scope, never a committed successful state. Successful insert/update requires revision >=1 and matching latest observation. Store observation ID/revision/scope cross-reference with composite FK, deferred only to resolve insertion cycle. Current pointer changes only in publication; failures leave no new scope. Season must match canonical code/year tuple, validated in publisher under transaction locks.

## SourceBinding (`catalog_source_bindings`)

UUID id; scope_id FK; provider text; kind enum league/season/team/player; opaque case-sensitive source_id text; one typed target: league_id, season_id, team_id or player_id. Check exactly one target is populated and agrees with kind. Each typed target uses restrictive FK, never unchecked polymorphic UUID. Unique `(scope_id, provider, kind, source_id)` and partial unique `(scope_id, provider, target_id)` for each kind prevent qualified duplication and same-provider collapse. League bindings target the scope's league, season bindings its season; team/player targets must belong to that season. Use composite scope/season and target/season FKs where applicable (add nondeferrable target composite indexes as necessary), plus publisher validation for canonical league identity. No position binding exists in the merged contract. Multiple providers can point to the same entity through distinct bindings. Binding targets and source keys never change; source replacement appends bindings.

## Observation (`catalog_ingestion_observations`)

UUID acceptance reference; scope_id; scope revision; operation fixed catalog; provider; retrieved_at and accepted_at UTC microseconds; fixture_id nullable; canonical_version integer; delivery_digest bytea; canonical_delivery JSONB of fixed-order safe arrays; created/updated/unchanged counts per league/season/team/player, nonnegative integer JSON with strict validated shape. Unique `(scope_id, revision)` and `(scope_id, delivery_digest)`; hash lookup also compares canonical values and treats a digest mismatch collision as safe conflict, never replay. Provider provenance is validated by merged contract; raw payload, credentials and diagnostic text excluded. Observations are immutable and retained. Latest pointer/reference constraints preserve scope/revision agreement.

## ObservationBinding (`catalog_ingestion_observation_bindings`)

Observation_id + binding_id composite primary key, restrictive FKs, scope_id included in composite references to prevent cross-scope membership. Every incoming binding, including unchanged league/season, is linked to the accepting observation. Retained omitted bindings remain linked only to previous observations unless supplied again. This establishes traceability without rewriting old evidence or requiring imported roster membership to remain current externally.

## Trusted instructions and Outcome (in-memory)

Instructions: provider/scope-qualified list of `{kind, source_id, target_id}` mappings plus `{kind: player, source_id}` new declarations. Reject duplicates, wrong kinds/scopes, absent incoming keys, nonexistent targets, foreign seasons, contradictory established bindings and many-to-one same-provider targets. Internal caller trust is inherited; no public editor or new permissions.

Outcome: status, scope, safe provider/fixture attribution, optional acceptance reference/revision/times, historical evidence counts, applied counts and recovery category/delay. Safe failure contains no success counts or accepted reference from that attempt. Replay returns original counts explicitly historical, applied counts all zero. See contracts/ingestion.md.

## State transitions

Absent(0) -> accepted(1); accepted(n) -> accepted(n+1) for a new complete observation, including unchanged or empty. Exact accepted delivery -> replay with no transition. Provider/persistence failure, conflict, stale and concurrent-change -> no transition. No automatic retry. Catalog omission never removes/deactivates anything. Publication and evidence are one transaction; accepted_at is local time taken during publication, never substituted for retrieved_at ordering.

## Team uniqueness extension

Add generated stored `normalized_code` and `normalized_name` with `lower(btrim(code/name))`. Replace the two original expression indexes by same-named UNIQUE `(season_id, normalized_*) DEFERRABLE INITIALLY IMMEDIATE` constraints. Preserve team `(id, season_id)` nondeferrable key and all FKs. Scope publication defers only these business constraints; existing Catalog normal writes enforce them immediately. Rollback migration restores original expression indexes without data rewriting. Ecto retains existing unique_constraint names; publisher catches forced deferred violations as reconciliation conflict and rolls back. SQL/persistence faults without a known domain conflict map to persistence failure.

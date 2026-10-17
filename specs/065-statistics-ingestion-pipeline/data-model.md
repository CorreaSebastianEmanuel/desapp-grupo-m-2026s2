# Statistics ingestion data model

Existing facts retain TASK-020 identities, count types, season FKs and immutable triggers (ADR-0010/0011/0012). Existing source catalog bindings remain ADR-0019-owned; ingestion never creates catalog entities. New UUID IDs are local, source strings remain qualified bindings.

## Existing performance extension

Add `position_basis` (closed string; legacy rows use DDL default legacy_direct), nullable `position_reason`, `participation` and immutable `position_evidence` map with policy version. position_id becomes nullable only with a CHECK covering the complete allowed combinations:

| basis | position_id | participation/reason/evidence |
|---|---|---|
| legacy_direct | nonnull | legacy direct-write shape; no derived claim |
| direct_source | nonnull | safe direct event-time evidence; no unknown reason |
| derived_history | nonnull | substitute_entered; policy v1; nonempty basis and unique greatest count |
| unknown_history | null | substitute_entered; reason tie or insufficient_history; policy v1 and basis/count evidence |

Legacy/direct callers still require position_id. New ingestion path validates evidence and role before insertion; raw inserts cannot create nil positions without the constrained exception. Evidence validation checks exact fields, referenced basis performances, same player/season, known positions, strict kickoff and counts using a BEFORE INSERT trigger in addition to application validation. Basis references are retained in a typed child table with restrictive FKs and append-only protection; use a deferred constraint trigger to check complete evidence at commit. Prevent forged empty evidence for a claimed tie or derived mode. Existing immutable update/delete triggers remain enabled throughout migration. Do not backfill legacy rows via UPDATE or change their IDs/counts/positions/timestamps. Migration on a populated database must preserve prior values and reject unsupported downgrade if nullable facts exist.

## Operation-qualified execution

Add operation=catalog default to synchronization_runs and catalog_delivery_receipts. Extend active uniqueness to operation + league/year scope, fenced receipt validation to operation, dispatch to worker kind. Keep existing table names, run/attempt/trigger relations and catalog wrappers. Canonical input version includes operation, safe effective source identity/digest, full scope and trusted mapping instructions. Receipt state prepared → confirmed or revoked; confirmed outcome is immutable acceptance proof. Domain run states/attempt budget stay TASK-019-defined.

## Statistics scope/check

- `statistics_import_scopes`: UUID, provider label/source identity namespace, league/season identity and local season FK; unique source namespace + local season; mutable last_checked_at and last_accepted_check_id. Lock a season-wide advisory key before this row, across selected sources and direct Statistics writers.
- `statistics_import_checks`: immutable UUID, scope/run/attempt FKs, accepted_at/retrieved_at UTC microseconds, complete evidence version/reference and canonical source-result material/digest; accepted_changes, accepted_unchanged, replay or accepted_empty; changed counts and prior replay check reference. Empty requires explicit complete-empty attestation. Success timestamp/pointer changes only inside fact acceptance transaction.
- Failed attempts remain in synchronization_attempts with closed safe outcome categories and recovery guidance, never in the accepted-check pointer. Inspection can distinguish execution state, import outcome and calculation state.

## Identity and provenance

- `statistics_match_bindings`: unique provider/kind/league/year/source_id → local match FK; same-scope constraints; no retarget/update/delete. Match identity uses versioned qualified encoding normalized under TASK-020, or a trusted explicit binding to an existing match. No name matching or cross-provider guesses.
- `statistics_fact_provenance`: immutable UUID, exactly one typed match_id or performance_id FK, unique per fact for first acceptance, accepted_check_id/run_id FKs, provider, retrieval UTC, qualified source identity (performance uses qualified match + qualified player), source material and fixture metadata FK when applicable. Per-check observation links may point to existing facts; never rewrite first provenance on replay.
- `statistics_fixture_artifacts`: immutable UUID; stable fixture_id, contained repo-relative path, SHA-256 bytes, origin, captured_at or synthetic_created_at, expected_case/rule IDs, non_live=true; unique fixture ID + digest. Reject path escapes and mismatch with admitted artifact digest. No raw live response or transport exception field.
- `statistics_position_basis`: subject performance FK + prior performance FK + position FK; unique subject/prior match; immutable counts/evidence reconcile with basis rows; restrict deletes. Zero usable history is explicit insufficient_history, tied counts retain all basis rows.

Canonical semantic comparison sorts qualified identities, normalizes UTC instants and exact integer counts, retains nil distinct from zero, and excludes retrieval time/result-local refs/list order. Keep source material separate from effective derived facts so replay can authenticate identical source without rederivation. Hash equality alone is insufficient: compare full canonical material. Changed immutable fields conflict atomically; lack of rows is not deletion.

## Calculation handoff

- `statistics_calculation_intents`: UUID, unique accepted_check_id, immutable changed performance ID membership, requested_at; delivery status pending/delivered/failed, bounded dispatch attempts/next attempt/recovery. Only nonempty changes create intent.
- `valuation_calculation_requests`: unique intent_id FK, accepted_check_id and exact input membership, accepted_at, state requested. This task records requests only; no completed quote/calculation state is invented. Duplicate identical accept returns existing request; mismatched membership conflicts.

Facts + provenance + check + pointer + delivery confirmation + calculation intent commit together. Receiving request/dispatch acknowledgment happens later. Crash recovery deduplicates intent/receiver identities. No Redis state, monetary column, financial audit mutation or quote creation is introduced.

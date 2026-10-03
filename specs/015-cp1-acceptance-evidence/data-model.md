# Data Model: CP1 Acceptance Evidence

This feature adds evidence artifacts, not persisted product entities.

## Acceptance Manifest

- `schema_version`: supported integer version.
- `checkpoint`: fixed `CP1`.
- `obligations`: exactly ten unique `Traceability Definition` items.

Validation: unknown, missing, or duplicate obligation IDs fail. No aggregate result or candidate SHA is stored here.

## Traceability Definition

- `id`: stable obligation identifier.
- `criterion`: unambiguous pass condition.
- `evidence_class`: one of `automated`, `demonstrated`, `hosted`.
- `required_receipts`: non-empty allowlist of receipt kinds.
- `references`: durable repository-relative or hosted locator definitions.

## Candidate Revision

- `sha`: full 40-hex Git commit.
- `source`: `committed` or `working_tree_snapshot`.
- `base_sha`, `diff_sha256`: required only for a snapshot.
- `clean`: Boolean derived by the evaluator.

Only `committed` plus clean exact-SHA evidence can produce final PASS.

## Evidence Receipt

- `kind`, `obligation_id`, `status`.
- `candidate_sha` and optional hosted `analysis_id`/`run_id`.
- `observed_at`: UTC timestamp.
- `observation`: allowlisted structured fields, never raw child output.
- `references`: durable links or repository-relative paths.
- `safety_scan`: pass flag and scanner version.

Validation: kind must be required by its obligation; status must be `pass` for acceptance; candidate SHA must match; all references and fields must satisfy their per-kind schema.

## Traceability Result

- Copies definition ID, criterion, and evidence class.
- Adds observed result, outcome (`PASS` or `NON_PASS`), provenance, and resolved evidence references.
- One-to-many relationship to evidence receipts.

Any missing, malformed, unsafe, inaccessible, stale, unpublished, or non-pass receipt yields `NON_PASS`.

## Acceptance Record

- `schema_version`, `checkpoint`, candidate revision, collection time.
- Exactly ten traceability results.
- `overall_result`: derived only; `PASS` iff all ten results pass and candidate source is a clean commit.
- `generator_version` and manifest hash.

JSON is authoritative; Markdown is a deterministic projection.

## Demo Run

- `candidate_sha`, `run_id`, start/end timestamps, supported environment.
- Fixed behavior IDs and pass/non-pass outcomes.
- Seed invariants before/after repeat: 5 leagues, 5 seasons, 10 teams, 4 positions, 20 players, 44 total.
- Safety scan result; no request/response or credential value.

State transition: `staging -> validated -> published`; any check failure moves to `invalid`, destroys unsafe staging, and cannot transition to published PASS.

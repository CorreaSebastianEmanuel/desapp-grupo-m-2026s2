# Feature Research — TASK-020

No unresolved material unknown remains. Stack choices reuse docs/ARCHITECTURE.md, mix.exs and compose.yaml; no technology survey or research agent was used.

## Catalog mutation races

- Decision: restrictive composite historical references, private season witnesses, append-only triggers and insertion participation validation (ADR-0010).
- Rationale: inspected TASK-005 migration and Catalog.update_player/2; current affiliation can change but season keys cannot drift under stored facts. Database foreign keys handle concurrent key changes, unlike a prevalidation query.
- Alternatives considered: application locks alone; freezing catalog records; new temporal roster entities. All either weaken integrity or exceed scope.
- Evidence: existing teams_id_season_id_index / players_team_season_fkey and [PostgreSQL foreign-key constraints](https://www.postgresql.org/docs/17/ddl-constraints.html). Composite referenced keys require unique indexes and restrictive updates.

## Precision

- Decision: accept at most microsecond precision and store canonical UTC losslessly (ADR-0011).
- Rationale: concrete uncertainty was whether Ecto's existing datetime representation retained fractional instants. Local adapter/type inspection plus [PostgreSQL timestamps](https://www.postgresql.org/docs/17/datatype-datetime.html) resolves it.
- Alternatives considered: whole-second truncation changes bounds; arbitrary precision adds a different representation without a requirement.

## Metric representation and semantics

- Decision: strict Elixir integer-or-nil input, exact PostgreSQL numeric columns with whole/nonnegative checks, custom Ecto Count type returning integers. No declared precision/scale or football duration cap; reject coercion before cast.
- Rationale: ordinary Ecto casts may accept strings or floats, while fixed integer storage can impose an unnecessary ceiling. Ecto's existing Decimal dependency supports exact persistence; no new package is needed. Semantics remain FR-006. Ingestion may report unknown for unsupported successful tackles or on-field goals conceded; it must not translate total team concessions or attempted tackles into these fields.
- Alternatives considered: JSON payloads lose field constraints; zero defaults erase unknowns; provider consultation cannot establish capabilities for an adapter not yet chosen in TASK-021.

## Reproducibility boundary

- Decision: retain the late-arrival obligation in the plan and architecture handoff for TASK-022; implement no quote/provenance mechanism here.
- Rationale: immutable individual facts do not freeze later history membership. PRODUCT invariant 7 still applies to valuation design.
- Alternatives considered: availability cutoffs and exact membership snapshots are later choices, both outside FR-013.

## Feedback 2: malformed text and Catalog connection ownership

- Decision: reject invalid UTF-8/NUL original identity inputs before database-backed normalization on every write and scoped read; add ordinary input/storage/integrity regressions (ADR-0012).
- Rationale: local Input.identity/1 checks String.valid?/trim but NUL is valid Unicode and reaches Query.trim_identity/1 or scoped SQL; the QA reproducer proves the unsafe exception shape. Keep Unicode whitespace handling from feedback 1; no new database representation is needed.
- Alternatives considered: catching all database exceptions hides infrastructure faults; restricting identities to ASCII narrows FR-002; removing NUL silently changes identity.
- Decision: bounded repair of existing Catalog concurrency tests and dedicated support only (ADR-0012).
- Rationale: inspected constraints_test.exs: workers inherit a parent unboxed context without explicit worker-owned checkout. Ownership causality remains a development diagnosis, with full-suite reproduction required; per-worker unboxed lifetimes, distinct backend assertions and barriers eliminate reliance on an exiting caller. Existing Statistics partition-driver pattern and config/test.exs provide reusable isolation without new infrastructure.
- Alternatives considered: shared Sandbox allowances serialize access; skipping the unchanged failing test or removing regression violates feedback; global DataCase/pool changes expand scope. No external research is needed for this local harness defect.

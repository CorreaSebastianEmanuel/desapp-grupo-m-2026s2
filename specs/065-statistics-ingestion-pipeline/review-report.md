# Review Report — TASK-021 (specs/065-statistics-ingestion-pipeline)

Independent final review of the diff, implementation, and fresh QA evidence. Not a repetition of QA: I confirm QA evidence is fresh and reproducible and resolve remaining risks by direct code inspection.

## Evidence basis

- Fresh QA (no `--reuse`, stage `qa`) passed all five manifest checks: preflight, format, compile, unit (58 audited modules) and integration (117 audited modules). The integration retry after the PATH correction stayed within the documented two-failure budget.
- Human feedback items 4 and 5 are satisfied: QA-01/02/03 remediations exist in code, QA re-executed all checks waiting in the foreground, and this report rewrites the stale review texts.
- Direct code cross-verification of each cited QA finding:
  - QA-01: `publisher.ex` resolves every team/player/match mapping (`:52-59`) and rolls back `:immutable_conflict` on changed canonical material (`:75-76`); replay retargeting regression at `replay_test.exs:73+`.
  - QA-02: migration `20261016000100` enforces `jsonb_typeof(frequencies) = 'object'` in the validate trigger (`:95`); typed-map integrity tests with positive control per QA evidence.
  - QA-03: `statistics_position_basis_insert_guard` (`:69-85`) rejects child basis rows against already-provenanced subjects; committed-connection regression per QA evidence.

## Design, architecture, and security

- Boundary discipline holds: providers (DTO/completeness validation), synchronization/Oban (operation-qualified dispatch, fences, recovery), statistics/ingestion (atomic publication), valuation (durable request acceptance only). No second scheduler/provider path; catalog schedules stay catalog-only; catalog delivery-receipt table remains a compatibility wrapper.
- Atomicity and immutability: fetch outside transaction; locks in consistent order (receipt, season advisory, scope); insert-only facts with first-acceptance provenance; constraint races re-read for equality or abort; calculation intent published canonically in the same commit; dispatch failure never rolls back or relabels imports.
- Position policy: derived history uses only already-committed known positions for strictly earlier same-season matches; the whole proposed batch is excluded; replay reuses retained evidence instead of rederiving; DB-level trigger validation independently enforces frequencies, mode uniqueness, and unknown reasons — defense in depth beyond tests.
- Security: no new route/controller/endpoint (FR-015); errors use closed outcome categories; no raw payloads or credentials retained; fixture artifacts are digest-pinned, contained, and marked non_live; local reads never call Providers (isolation test asserted transport == 1 while reads stay byte-equal).

## Targeted checks and risks

No full-suite rerun needed: QA evidence is fresh on the unchanged tree. Targeted observations:

1. `publisher.ex` `fixture_artifact!/1` evaluates the `test/fixtures/statistics_ingestion/*.exs` inventory at runtime. It is fixed-path and digest-pinned, satisfying FR-006/007 traceability, but coupling the production publisher to test-fixture paths is a maintainability smell if live fixture sources ever appear. Non-blocking; acceptable within this feature's explicitly offline scope.
2. Replay/unchanged classification is correct: same canonical material with a new retrieval instant records an `accepted_unchanged` check; materially equal replay records `replay` observations without fact duplication.
3. `CalculationRequests.accept/3` normalizes and sorts IDs on both sides, locks intent/request rows, and treats unique-violation races as idempotent re-reads — the ordered-list defect from develop is genuinely closed.

## Checkpoint and scope coverage

verification.json binds all 23 FR/SC identifiers to concrete test files; both audited profiles completed. `runtime_required=false` is justified — the diff touches no web layer. No forbidden additions (cache, freshness API, scoring, quotes, trading) are present. Spec, ADR-0028, quickstart, and tasks remain coherent; all T001–T030 checked with T031/T032 gate-owned.

## Backlog impact

One concrete integration point: TASK-026 now depends on a durable boundary that did not exist when it was written.

Backlog impact: TASK-026 — quote recalculation should specify consumption of the new durable `Valuation.CalculationRequests.accept/3` / dispatch boundary (FR-013 intent), rather than re-deriving triggers or recalculating synchronously at import time. Recommendation: record this integration expectation in TASK-026's planning when it leaves `todo`; no change to its priority, scope boundary, or dependency edges. No other backlog task is affected by this review's findings.

Verdict: PASS

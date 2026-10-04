# Tasks: Player Match Statistics Model

**Input**: `specs/054-player-match-statistics/` design artifacts.
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/statistics-context.md, quickstart.md and verification.json.
**Tests**: Required by FR-012 and repository rules. Write assertions first and observe an attributable failure before implementing behavior. All implementation and developer check tasks complete before downstream gates.
**Feedback 2 resume**: Preserve unchanged completed work; reopened checks have stale evidence after canonical/source changes. Start T003 and T016/T017 using existing fixtures, then T018/T019; close reopened T005/T010/T014 only after their corrected contracts pass, run T011/T020/T024–T027 and independent gates. Do not rebuild unaffected schemas or repeat settled research. IDs from former T016 onward shift by four to keep execution order; previous receipts cannot stand in for fresh checks.
**Format**: `- [ ] TNNN [P?] [USN?] Description with file path`. Paths are repository relative; gate tags appear after the QA/review title only.

## Phase 1: Setup

- [X] T001 Verify pinned toolchain and guarded test services using `scripts/check_toolchain.sh`, `scripts/local_services.sh` and `specs/054-player-match-statistics/quickstart.md`; run toolchain/prepare/preflight commands without changing dependencies or resetting databases.
- [X] T002 Create deterministic five-league/two-season fixture builders in `test/support/statistics_case.ex`, reusing `test/support/catalog_case.ex`; include distinct home/away teams, positions and season-specific players, zero/unknown metrics and same-day/tied kickoff examples; provide unique partition fixtures for committed race tests.

## Phase 2: Foundational (blocks implementation of all stories)

- [X] T003 [P] Write failing strict input/instant/key/container and integer Count tests in `test/football_market/statistics/input_test.exs` and `test/football_market/statistics/count_test.exs`; cover every FR-006 metric with positive/zero/negative/fraction/float 1.0/string/boolean/nil/omitted inputs, required minutes, mixed keys, unsupported fields, fractional precision above six and malformed IDs/DateTime values; tag modules unit. Feedback B2: add original identity matrices with NUL at start/middle/end, invalid UTF-8, Unicode blanks and otherwise valid Unicode; expect match_identity/invalid_identity for malformed text before any SQL and retain required for blanks.
- [X] T004 [P] Write failing baseline relational/append-only persistence tests in `test/football_market/statistics/integrity_test.exs` for composite seasons, season metadata mutation, nonparticipant team, distinct participants, immutable UPDATE/DELETE and catalog FK deletion protections; tag integration and use savepoints for SQL rejection assertions. These are US2 shared integrity prerequisites required before US1 migration.
- [X] T005 Implement original-type validation, UTC instant parsing, supported-key normalization and domain error translation in `lib/football_market/statistics/input.ex`, `lib/football_market/statistics/count.ex` and `lib/football_market/statistics/error.ex` against `specs/054-player-match-statistics/contracts/statistics-context.md`; feedback 2 closure is through T018 after T003/T016; make T003 pass without coercion or new atoms.

**Checkpoint**: Input contract executable; persistence guard assertions exist before database behavior is introduced.

## Phase 3: User Story 1 — Store Match Performance (P1, MVP)

**Goal**: Persist and independently retrieve every accepted fact, including unknown versus zero.
**Independent test**: US1.1–4/SC-001/SC-005 via storage and input checks; fixture coverage spans five leagues/two seasons and 0/90/123+ minutes.

### Tests first

- [X] T006 [US1] Write failing storage/contract roundtrip tests in `test/football_market/statistics/storage_test.exs` for match IDs/season identities, two performances, all nine metrics, nil/omitted versus zero, zero minutes with positive counts, matches without performances, 90/123+ minutes and exact offset/fractional instants; tag integration.

### Implementation

- [X] T007 [US1] Create `priv/repo/migrations/20261003000000_create_match_statistics.exs` with both UUID tables, exact numeric count constraints, normalized identity unique key, player-match unique key, indexes, private season witnesses, restrictive composite FK keys and named participation/UPDATE/DELETE triggers per `specs/054-player-match-statistics/data-model.md` and ADR-0010; no cascades, zero defaults or destructive data migration. Make T004 database assertions pass before proceeding. Feedback B1: add `priv/repo/migrations/20261004000000_align_statistics_identity_whitespace.exs` to align Unicode trimming in existing databases without changing accepted facts or disabling guards.
- [X] T008 [P] [US1] Define Match schema/changesets in `lib/football_market/statistics/match.ex`, including UTC microseconds, supported attributes and named database constraint mappings; private integrity witnesses derive from the referenced season rather than caller attrs.
- [X] T009 [P] [US1] Define Performance schema/changesets in `lib/football_market/statistics/performance.ex`, including Count fields, nullable metrics, explicit historical references and named constraint mappings; derive season_id from the match without copying current affiliation.
- [X] T010 [US1] Implement record_match/1 and record_performance/1 plus independent match/pair read APIs in `lib/football_market/statistics.ex` and exact lookup queries in `lib/football_market/statistics/query.ex`; enforce the context contract, normalized identity lookup and field-safe failure translation with transactions where related reads/inserts occur; feedback 2 closure through T018 must reject malformed original identities before scoped lookup SQL.
- [X] T011 [US1] Run input/storage and baseline integrity checks from `specs/054-player-match-statistics/verification.json`; confirm every US1 scenario passes and persist evidence later through final manifest execution after source stabilization.

**Checkpoint**: A storage MVP exists with fundamental integrity enforced, rather than a temporary overwrite-capable model. Remaining US2/US3 work is mandatory before delivery.

## Phase 4: User Story 2 — Protect Historical Input Integrity (P1)

**Goal**: Reject bad/conflicting submissions and mutation/deletion atomically, including under concurrency.
**Independent test**: US2.1–7/SC-002/SC-004 via integrity, concurrency and catalog_concurrency checks, asserting unchanged rows and field/record errors after each failure.

### Tests first

- [X] T012 [P] [US2] Extend `test/football_market/statistics/integrity_test.exs` with identical/conflicting match and pair duplicates, exact/case/space/tab/newline identities and cross-season reuse; all missing/cross-season references, invalid counts/kickoffs, explicit immutable APIs, protected Catalog deletions, atomic batch rollback including an early valid and later invalid envelope, and unchanged prior facts/errors without SQL internals.
- [X] T013 [P] [US2] Write real two-connection barrier-based races in `test/football_market/statistics/concurrency_test.exs`: simultaneous identical/conflicting normalized match and player-match inserts, plus referenced catalog key mutation versus insert in both orderings. Tag integration, async false; use dedicated guarded MIX_TEST_PARTITION=statistics_concurrency, committed uniquely scoped fixtures and unboxed connections. In default full-suite/profile runs, define a driver test that launches this same file with the dedicated partition, asserts nonempty successful results and clears inherited CP1_PROFILE/CP1_PROFILE_COVERAGE/CP1_PROFILE_RECEIPT/CP1_PROFILE_SENTINEL_PATH. In the partition define actual cases, never the driver. Reuse existing league/position rows, retain accepted facts, clean up connections/tasks and bound waits; assert one duplicate winner and no committed cross-season/orphaned state.

### Implementation

- [X] T014 [US2] Add record_batch/1, rejection-only update/delete APIs and deterministic conflict/validation translation in `lib/football_market/statistics.ex` and `lib/football_market/statistics/error.ex`; use one Ecto.Multi for all envelopes/performance inserts, return zero-based failing indexes including malformed original identity errors (feedback 2 closure through T018), reject nested contradictory match IDs and unsupported shapes without partial commits.
- [X] T015 [US2] Map new historical restrictive FK failures in existing deletion changesets in `lib/football_market/catalog/team.ex`, `lib/football_market/catalog/season.ex` and `lib/football_market/catalog/position.ex`; preserve established Catalog return types and valid current-affiliation/display mutations under ADR-0002.

### Feedback 2 corrective tests before repair

- [X] T016 [US2] Add maintained field-safe malformed-identity regressions in `test/football_market/statistics/storage_test.exs` and `test/football_market/statistics/integrity_test.exs`, adapted from `specs/054-player-match-statistics/qa-evidence/current/malformed_identity_test.exs`: assert record_match/scoped get_match return validation on NUL at start/middle/end and invalid UTF-8; a late invalid batch after valid match/performance envelopes returns match_index 1 with no partial rows or changed existing facts. Observe the attributable failure before T018; preserve B1 Unicode/migration matrices and immutable guards.
- [X] T017 [US2] Diagnose B3 in `test/football_market/catalog/constraints_test.exs` using focused and complete-regression commands from `specs/054-player-match-statistics/verification.json`; capture bounded owner-lifecycle causality for the exiting Sandbox owner and add failing distinct-backend/readiness/worker-error assertions for both existing concurrent tests before T019. Retain league/season/team/position/player exactly-one-success and conflict assertions, fixture-scoped count/original-row checks, no global cleanup or skips; record causal evidence in the sole `specs/054-player-match-statistics/handoffs/develop.md` at T027.

### Feedback 2 corrective implementation

- [X] T018 [US2] Repair original-input identity validation in `lib/football_market/statistics/input.ex` and, only as necessary, its call boundaries in `lib/football_market/statistics.ex`/`lib/football_market/statistics/query.ex`: valid UTF-8 without U+0000 is checked before any SQL; return match_identity/invalid_identity, retain blank required and batch indexes/rollback, preserve all encodable Unicode identities and B1 normalization, and make T003/T016 pass without broad Postgrex rescue.
- [X] T019 [US2] Repair only the existing Catalog concurrency module in `test/football_market/catalog/constraints_test.exs` with dedicated `test/support/catalog_concurrency_case.ex` support per ADR-0012: each worker owns/releases its unboxed connection, assert distinct backend PIDs and bounded barriers, await results and register cleanup before launch; run both actual races in guarded catalog_concurrency partition and use a nonrecursive asserting default-suite driver clearing inherited CP1 receipt/coverage variables. Preserve assertions, scope counts/cleanup to owned unreferenced Catalog fixtures, never reset databases or alter DataCase/pool/product behavior. Run focused Catalog cases twice, reporting errors rather than hiding them; unchanged full regression runs at T026 after T025 updates the exact scope allow-list.

- [X] T020 [US2] Run integrity/concurrency checks in `specs/054-player-match-statistics/verification.json`, including direct persisted key-change/delete attempts and concurrent insert arbitration; also run catalog_concurrency after T019; verify malformed write/scoped lookup/batch errors, no guard bypass, upsert, swallowed database fault or Sandbox-shared fake race remains.

**Checkpoint**: US2 errors and batch contract pass; all previously accepted facts remain intact. Stats reject retries; ingestion idempotency remains TASK-021.

## Phase 5: User Story 3 — Read Dated Performance History (P2)

**Goal**: Deterministic local history with event-time affiliation, exact identities and inclusive instant bounds.
**Independent test**: US3.1–5/SC-003–005 via history check with provider absent and current affiliation changed.

### Tests first

- [X] T021 [US3] Write failing history tests in `test/football_market/statistics/history_test.exs` for exact player/season isolation, kickoff then normalized identity tie order, same-day events, all bound omission combinations, equal/inverted/malformed bounds, exact boundaries and +/-1 microsecond facts, equivalent offsets, known empty/absent versus unknown results, and preserved team-A/position-P after current transfer followed by valid team-B performance; tag integration.

### Implementation

- [X] T022 [US3] Implement deterministic history and interval queries in `lib/football_market/statistics/query.ex`, joining stored match/event-time fields and comparing UTC microseconds; never read mutable affiliation to reconstruct historical facts or add arbitrary limits/windows.
- [X] T023 [US3] Expose list_player_history/2 and complete identifier/bounds validation and read-result distinctions in `lib/football_market/statistics.ex`; use the internal contract error shapes, return integer/nil metrics and never access providers/cache.
- [X] T024 [US3] Run history/storage regression checks using `specs/054-player-match-statistics/verification.json`; confirm repeated provider-free reads and transfers leave original rows/order unchanged while permitting valid later facts.

**Checkpoint**: All three user stories are independently testable using their focused commands.

## Phase 6: Polish and Cross-Cutting Verification

- [X] T025 Write and run scope/architecture dependency assertions in `test/football_market/statistics/scope_test.exs` that Statistics has no web/provider/cache/valuation dependencies, accepted fields contain no scores/money/provenance and product changes are restricted to the plan boundary; extend the exact allowed paths only for `test/football_market/catalog/constraints_test.exs` and `test/support/catalog_concurrency_case.ex` per ADR-0012, without allowing the entire Catalog/support tree; tag unit, reference FR-013 and the exact contract. Correct implementation only within that boundary if assertions fail.
- [X] T026 Execute every check through `scripts/agentflow_check.py` as listed in `specs/054-player-match-statistics/verification.json` after final source changes, including service preparation/preflight, format, warning-free compilation, focused matrices/races, separate profiles, informational coverage, full regression and diff validation; inspect failures and rerun all receipts after any source changes. Do not mark this done until every check succeeds.
- [X] T027 Reconcile completed tasks against named artifacts and write `specs/054-player-match-statistics/handoffs/develop.md` under 400 words with deltas, actual check outcomes and precise QA guidance; run `scripts/workflow_artifact_probe.py` develop --readiness only after all T001–T027 artifacts/checks are satisfied. Keep late-input quote reproducibility as TASK-022 guidance rather than adding quote/provenance code.
- [x] T028 Independent QA [gate:qa] rerun checks and challenge every acceptance scenario in `specs/054-player-match-statistics/qa-report.md` and `specs/054-player-match-statistics/handoffs/qa.md`; end reports with Verdict: PASS only on independent acceptance, otherwise report blockers without changing implementation.
- [x] T029 Final review [gate:review] inspect implementation and fresh QA evidence, resolve uncovered risks with targeted checks, and write `specs/054-player-match-statistics/review-report.md` and `specs/054-player-match-statistics/handoffs/review.md` including one backlog-impact entry and terminal Verdict: PASS only when ready for human review; never merge/publish in this stage.

## Dependencies and Execution Order

Setup T001 -> T002. Foundation T003 and T004 can be authored independently after fixtures; T005 depends on T003's observed failure. US1 T006 must fail before T007–T010; T007 depends on T004's observed failure, T008/T009 depend on T005/T007, T010 depends on both schemas, T011 on T010. US2 T012/T013 depend on US1 and precede T014/T015; T016/T017 use existing stable fixtures and must reproduce their failures before T018/T019 respectively. T018 also follows T003; reopened T005/T010/T014 close through T018 after failing T003/T016 evidence (reuse all unaffected code), and T011 reruns after that repair; T019 follows T017. T020 depends on T014/T015/T018/T019. Current resume executes these corrections before advancing; historical completion of unrelated tasks does not bypass them. US3 T021 depends on US1/US2 fixture integrity and must fail before T022/T023; T024 follows both. T025 follows all stories; T026 follows final source changes; T027 follows all successful checks; T028 follows every developer task and readiness; T029 follows independent QA PASS. T028/T029 are the only task_stages deferrals.

Graph: Setup -> Foundation -> US1(P1) -> US2(P1) -> US3(P2) -> scope/all checks/developer handoff -> Independent QA -> Final review.

## Parallel Execution Examples

- Foundation: T003 strict unit matrices and T004 database guard assertions use separate files after T002.
- US1: T008 Match and T009 Performance schemas can be written independently after migration/input prerequisites. T006 storage tests precede both.
- US2: T012 ordinary integrity tests and T013 independent-connection race tests can be authored independently after US1; feedback T016 malformed-input integration tests and T017 Catalog diagnosis/assertions concern separate files, but their service executions remain sequential; execute database mutation checks sequentially to keep evidence isolated.
- US3: T021 is one history test file, followed by sequential shared query/context edits. No safe intra-story code parallelism is marked; history fixture preparation can accompany test-case drafting without competing writes.

Parallel markers describe independent file work, not permission to launch agents. Implementation has one code owner.

## Implementation Strategy

Build the US1 storage MVP first with prerequisite persistence protections, then finish US2's atomic/error/race contract and US3's dated reads. Validate each increment locally; delivery still requires all 29 tasks through both independent gates. Do not implement ingestion, endpoints, quote snapshots, correction policy or other FR-013 exclusions. Existing CP1 profiles/coverage remain regression checks; this feature contributes CP2 persistence and deterministic valuation facts, not the complete checkpoint.

## Delivery amendment — pinned PostgreSQL parity (2026-10-04)

These tasks append a bounded CI correction to TASK-020. Preserve all earlier task history; previous independent reports apply to the revision they inspected and do not verify this amendment. The implementation boundary and exclusions are in the plan's delivery amendment.

- [x] T030 Add a focused regression to existing `test/ci/quality_baseline_contract_test.exs`: parse the workflow PostgreSQL service image, require the exact PostgreSQL 17.6 tag/digest from the plan, and assert equality with the PostgreSQL service image in `compose.yaml`; replace the obsolete PostgreSQL 16 assertion while preserving every other contract. Run it before changing CI and record the attributable mismatch failure. Permit only `test/ci/quality_baseline_contract_test.exs` and `test/ci/fixtures/quality-baseline.sha256` as additional exact paths in `test/football_market/statistics/scope_test.exs`.
- [x] T031 After T030's observed failure, change only the PostgreSQL service image in `.github/workflows/quality-baseline.yml` to `postgres:17.6-alpine@sha256:ef257d85f76e48da1c64832459b59fcaba1a4dac97bf5d7450c77753542eee94`. Inspect the workflow diff and refresh `test/ci/fixtures/quality-baseline.sha256` without weakening the existing SonarCloud fingerprint test; make the focused CI and fingerprint contracts pass. Do not modify migrations, product code, compose, CI commands, permissions or other services.
- [x] T032 Add a focused `ci_database_contract` check running existing quality-baseline and SonarCloud contracts to `specs/054-player-match-statistics/verification.json`, retain all current checks, and declare T033/T034 as QA/review task-stage deferrals. Execute the complete manifest after final stabilization, including PostgreSQL 17.6 migration preparation, statistics storage/integrity, scope and full regression. Update the bounded developer handoff with actual commands/results and the pending remote CI requirement; no old receipt or verdict establishes success for the changed revision.
- [x] T033 Independent QA [gate:qa] independently verify the amended final revision and all required checks, challenge exact local/CI image parity and migration compatibility, and refresh canonical QA evidence/report/handoff. End with `Verdict: PASS` only when the correction and unchanged feature acceptance are independently satisfied; do not modify implementation.
- [x] T034 Final review [gate:review] inspect the minimal workflow diff, refreshed fingerprint, focused regression, complete fresh QA evidence and unchanged product boundary; refresh canonical review report/handoff with terminal `Verdict: PASS` only when ready for human review. Publishing remains a separate authorized delivery action after both fresh gates; require green remote CI on the published PR revision before declaring delivery complete. Do not merge.

Amendment order: T030 (observed contract failure) -> T031 (minimal CI alignment) -> T032 (complete fresh developer checks) -> T033 (fresh independent QA) -> T034 (fresh independent final review) -> authorized publication and green remote CI. These appended tasks do not reopen product specification or authorize an additional backlog task.

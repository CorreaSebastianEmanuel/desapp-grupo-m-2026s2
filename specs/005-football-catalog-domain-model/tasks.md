# Tasks: Football Catalog Domain Model

**Input**: Design documents from `specs/005-football-catalog-domain-model/`

**Prerequisites**: TASK-002 PostgreSQL environment; `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/catalog-context.md`, and `quickstart.md`

**Tests**: Required by FR-018 and the constitution. In every story phase, write the listed tests first, run the focused test file, and record that the new tests fail for the expected missing behavior before implementing it.

**Scope boundary**: Domain and PostgreSQL persistence only. Do not add routes, controllers, authentication, seeds, provider identifiers/adapters, ingestion, statistics, valuation, tokens, trading, Redis behavior, pagination, or UI.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it changes a different file and has no dependency on another incomplete task in the phase
- **[Story]**: User-story traceability label
- Every task names the exact file it changes

## Phase 1: Setup (Shared Test Infrastructure)

**Purpose**: Provide database-backed test helpers without changing production behavior.

- [X] T001 Create `FootballMarket.DataCase` with SQL Sandbox checkout and changeset error helpers in `test/support/data_case.ex`
- [X] T002 [P] Add reusable, non-seeded catalog attribute and insertion helpers for tests in `test/support/catalog_case.ex`

**Checkpoint**: Catalog tests can use isolated PostgreSQL transactions and explicit fixtures.

---

## Phase 2: Foundational (Blocking Persistence Contract)

**Purpose**: Establish the shared relational constraints all three stories require.

**Critical**: Complete this phase before user-story implementation.

- [X] T003 Write migration contract tests that initially fail for all five tables, UUID keys, non-null fields, named checks, restrictive foreign keys, normalized unique indexes, the team/season composite foreign key, and lookup indexes in `test/football_market/catalog/constraints_test.exs`
- [X] T004 Run `MIX_ENV=test mix test test/football_market/catalog/constraints_test.exs` and record the expected pre-implementation failures in `specs/005-football-catalog-domain-model/quickstart.md`
- [X] T005 Implement the parent-first catalog migration with leagues, seasons, teams, positions, players, explicit constraint names, restrictive deletion, UUID keys, checks, expression uniqueness, composite team/season integrity, and lookup indexes in `priv/repo/migrations/*_create_catalog_tables.exs`
- [X] T006 Re-run the focused migration tests and document the passing migration preparation command in `specs/005-football-catalog-domain-model/quickstart.md`

**Checkpoint**: PostgreSQL independently protects structural integrity and race-sensitive identity boundaries.

---

## Phase 3: User Story 1 — Maintain a Valid Catalog Hierarchy (Priority: P1) MVP

**Goal**: Persist and retrieve the five supported leagues, their seasons, and season-specific teams while rejecting invalid, duplicate, or destructive changes.

**Independent Test**: Create all five exact league pairs, one valid season and team, retrieve the hierarchy, then prove invalid pairs, ranges, normalized duplicates, missing parents, and parent deletion are rejected without changing persisted data.

### Tests for User Story 1

- [X] T007 [US1] Write failing context tests for the five exact league pairs, mismatched/unsupported pairs, trimming, blank fields, valid same-year/consecutive-year seasons, invalid ranges, and missing league relationships in `test/football_market/catalog/catalog_test.exs`
- [X] T008 [P] [US1] Write failing persistence tests for exact/case/whitespace duplicate races across league, season, and team scopes plus restrictive league/season deletion in `test/football_market/catalog/constraints_test.exs`
- [X] T009 [P] [US1] Write failing singular business-lookup tests for league, season, and team, including normalized keys and not-found results, in `test/football_market/catalog/query_test.exs`
- [X] T010 [US1] Run the three focused catalog test files and record expected failures before US1 implementation in `specs/005-football-catalog-domain-model/quickstart.md`

### Implementation for User Story 1

- [X] T011 [P] [US1] Implement the League schema, exact name/code allowlist validation, trimming, named constraints, associations, and delete protection metadata in `lib/football_market/catalog/league.ex`
- [X] T012 [P] [US1] Implement the Season schema, year-span validation, immutable league ownership, named constraints, associations, and delete protection metadata in `lib/football_market/catalog/season.ex`
- [X] T013 [P] [US1] Implement the Team schema, trimming, immutable season ownership, named scoped constraints, associations, and delete protection metadata in `lib/football_market/catalog/team.ex`
- [X] T014 [US1] Implement league, season, and team create/delete commands plus stable-ID and normalized business lookups with stable changeset errors in `lib/football_market/catalog.ex`
- [X] T015 [US1] Re-run US1 focused tests and confirm invalid commands and concurrent conflicts preserve the original hierarchy in `test/football_market/catalog/catalog_test.exs`

**Checkpoint**: US1 works independently and supplies the MVP hierarchy required by later stories.

---

## Phase 4: User Story 2 — Maintain Valid Players and Positions (Priority: P2)

**Goal**: Persist positions and season-specific players with complete relationships and approved current-affiliation reassignment semantics.

**Independent Test**: Create a position and player for an existing team, retrieve the complete hierarchy, then prove missing relationships, normalized duplicates, protected parent deletion, inconsistent team/season pairs, and cross-season reassignment fail atomically while same-season reassignment preserves identity.

### Tests for User Story 2

- [X] T016 [US2] Write failing context tests for position/player creation, blanks, missing relationships, preloaded hierarchy, same-season reassignment, preserved player identity, and cross-season rejection in `test/football_market/catalog/catalog_test.exs`
- [X] T017 [P] [US2] Write failing persistence and SQL Sandbox concurrency tests for normalized position/player uniqueness, composite team/season integrity, and team/position deletion protection in `test/football_market/catalog/constraints_test.exs`
- [X] T018 [P] [US2] Write failing singular lookups for position and season-scoped player identity, including normalization and not-found behavior, in `test/football_market/catalog/query_test.exs`
- [X] T019 [US2] Run the focused tests and record expected failures before US2 implementation in `specs/005-football-catalog-domain-model/quickstart.md`

### Implementation for User Story 2

- [X] T020 [P] [US2] Implement the Position schema with trimming, normalized global constraints, associations, and delete protection metadata in `lib/football_market/catalog/position.ex`
- [X] T021 [P] [US2] Implement the Player schema with caller-opaque catalog identity, derived constrained season, required team/position, trimming, named constraints, and association preloads in `lib/football_market/catalog/player.ex`
- [X] T022 [US2] Implement position/player commands and same-season-only player updates while refusing caller-controlled season IDs and mapping named database violations to field or relationship errors in `lib/football_market/catalog.ex`
- [X] T023 [US2] Re-run US2 focused tests and confirm every rejected create/update/delete leaves all catalog records unchanged in `test/football_market/catalog/catalog_test.exs`

**Checkpoint**: US2 works independently on the US1 hierarchy without adding roster-history or provider concepts.

---

## Phase 5: User Story 3 — Retrieve Catalog Records by Business Lookup (Priority: P3)

**Goal**: Provide deterministic local catalog lookups by stable identity and by AND-composed league, season, team, and position filters.

**Independent Test**: Populate all five leagues, at least two seasons, multiple teams and positions, then verify each individual and combined filter returns only matching fully associated players in ascending UUID order; unknown keys error and unknown valid IDs return empty results.

### Tests for User Story 3

- [X] T024 [US3] Write failing query tests for stable-ID fetches, empty filters, each filter dimension, AND combinations, cross-season exclusion, association completeness, ascending UUID order, unknown keys, and unknown valid IDs in `test/football_market/catalog/query_test.exs`
- [X] T025 [US3] Run the focused query tests and record expected failures before US3 implementation in `specs/005-football-catalog-domain-model/quickstart.md`

### Implementation for User Story 3

- [X] T026 [US3] Implement private Ecto queries for stable/business identities and allowlisted AND-composed player filters with hierarchy preloads and ascending UUID order in `lib/football_market/catalog/query.ex`
- [X] T027 [US3] Expose only the contract-defined singular fetch and `list_players/1` functions through the context, with `:not_found` and unknown-filter error behavior, in `lib/football_market/catalog.ex`
- [X] T028 [US3] Re-run US3 tests and verify all results come only from PostgreSQL with no provider, web, or cache dependency in `test/football_market/catalog/query_test.exs`

**Checkpoint**: All three stories are independently testable through `FootballMarket.Catalog`.

---

## Phase 6: Documentation, Performance Evidence, and Verification

**Purpose**: Close cross-cutting traceability, scope, performance-plan, and checkpoint obligations.

- [X] T029 Write the representative 100,000-player tagged query-plan test covering league, season, team, position, and combined lookups without asserting machine-dependent latency in `test/football_market/catalog/query_test.exs`
- [X] T030 Run the tagged query-plan test, retain concise `EXPLAIN` index-capability evidence, and state that percentile SLA certification belongs to TASK-043 in `specs/005-football-catalog-domain-model/quickstart.md`
- [X] T031 [P] Document the Catalog context boundary, normalized identity oracle, supported league pairs, restrictive deletion, current-affiliation behavior, and explicit exclusions in `specs/005-football-catalog-domain-model/quickstart.md`
- [X] T032 [P] Verify requirements FR-001–FR-019 and outcomes SC-001–SC-007 against automated test names and add the traceability matrix in `specs/005-football-catalog-domain-model/quickstart.md`
- [X] T033 Run `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, `MIX_ENV=test mix test test/football_market/catalog`, the tagged performance-evidence test, and `MIX_ENV=test mix test`; record exact command results in `specs/005-football-catalog-domain-model/quickstart.md`
- [X] T034 Inspect the final diff for forbidden web/provider/seed/Redis/statistics/financial scope and document the scope audit result in `specs/005-football-catalog-domain-model/quickstart.md`
- [X] T035 Repair repository-relative artifact-glob resolution in `scripts/workflow_artifact_probe.py` and cover matching, unmatched, and repository-boundary behavior in `test/scripts/workflow_artifact_probe_test.py`

**Checkpoint**: The feature has executable evidence for CP1 minimum-model and unit-test obligations without claiming TASK-011 catalog API work or TASK-043 latency certification.

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 has no feature-local dependency beyond TASK-002 being operational.
- Phase 2 depends on Phase 1 and blocks all stories.
- US1 depends on Phase 2.
- US2 depends on Phase 2 and uses the hierarchy delivered by US1; its failing tests may be authored in parallel after Phase 2, but acceptance requires US1.
- US3 depends on the persisted entities from US1 and US2; its failing tests may be authored once their contracts are fixed.
- Phase 6 depends on all desired stories; T031 and T032 can run in parallel, while T030 follows T029 and T033 follows all implementation/evidence tasks.

### User Story Completion Order

`Setup -> Foundation -> US1 (MVP) -> US2 -> US3 -> Verification`

US1 is the first independently demonstrable increment. US2 extends the established hierarchy. US3 consumes both without changing their write semantics.

### Within Each User Story

1. Write tests and run them to establish the expected red state.
2. Implement schemas before context orchestration.
3. Keep all Repo/query access behind `FootballMarket.Catalog`.
4. Re-run the story's focused suite before advancing.
5. Database constraints remain authoritative under races; changesets provide stable early errors.

## Parallel Opportunities

- T002 can run alongside T001 after agreeing on helper boundaries.
- T008 and T009 can run in parallel after T007 defines shared fixtures; T011–T013 modify separate schemas in parallel.
- T017 and T018 can run in parallel after T016; T020 and T021 modify separate schemas in parallel.
- US2/US3 test authoring can overlap with prior implementation, but story acceptance follows the dependency order above.
- T031 and T032 can run in parallel after all story behavior is complete.

## Parallel Examples

### User Story 1

```text
Task T008: persistence/concurrency tests in test/football_market/catalog/constraints_test.exs
Task T009: business lookup tests in test/football_market/catalog/query_test.exs

Task T011: League schema in lib/football_market/catalog/league.ex
Task T012: Season schema in lib/football_market/catalog/season.ex
Task T013: Team schema in lib/football_market/catalog/team.ex
```

### User Story 2

```text
Task T017: integrity/concurrency tests in test/football_market/catalog/constraints_test.exs
Task T018: singular lookup tests in test/football_market/catalog/query_test.exs

Task T020: Position schema in lib/football_market/catalog/position.ex
Task T021: Player schema in lib/football_market/catalog/player.ex
```

### User Story 3

```text
Task T024: author the complete lookup contract in test/football_market/catalog/query_test.exs
Task T026: implement private queries in lib/football_market/catalog/query.ex after T024 is red
```

## Implementation Strategy

### MVP First

1. Complete Setup and Foundational phases.
2. Complete US1 test-first.
3. Stop and validate the five-league season/team hierarchy independently.

### Incremental Delivery

1. Add US2 and validate player/position integrity plus transfer semantics.
2. Add US3 and validate deterministic local lookup behavior.
3. Complete representative query-plan evidence, traceability, full regression, and scope audit.

## Notes

- Do not add a speculative bulk command solely to exercise FR-013; any concrete multi-write command introduced by implementation must use `Ecto.Multi` and receive a rollback test.
- PostgreSQL `lower(btrim(...))` under configured collation is the only identity-comparison oracle; do not duplicate case folding in Elixir.
- Stable UUID ordering is persistence determinism, not user-facing ranking.
- The accepted current-affiliation decision is durable in `docs/adr/0002-current-affiliation-player-snapshot.md`; do not add roster stints in this task.

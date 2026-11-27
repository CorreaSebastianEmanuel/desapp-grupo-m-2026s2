---

description: "Dependency-ordered implementation tasks for the player catalog list and detail API"
---

# Tasks: Player Catalog List and Detail API

**Input**: Design documents from `/specs/011-player-catalog-api/`

**Prerequisites**: TASK-005 catalog persistence and TASK-010 protected API policy are complete. `spec.md` is behavioral truth; `plan.md` and the normative transport contract bound implementation.

**Tests**: Required by FR-022 and the project constitution. In each story, write the listed tests first, run them, and confirm they fail for the intended missing behavior before implementation.

**Organization**: Tasks are grouped by independently testable user story. Exact public shapes come from `contracts/player-catalog-api.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches different files and has no dependency on another incomplete task in the same phase
- **[Story]**: Maps work to US1, US2, or US3 from `spec.md`

## Phase 1: Setup (Shared Test Infrastructure)

**Purpose**: Establish deterministic fixtures and observation points before protected routes exist.

- [X] T001 Extend catalog fixtures for bulk players, duplicate/case-variant names, and complete team-season-league hierarchies in `test/support/catalog_case.ex`
- [X] T002 [P] Add catalog-query and forbidden provider/cache invocation probes for authentication-precedence and local-only assertions in `test/support/player_catalog_probe.ex`

---

## Phase 2: Foundational (Blocking Persistence Support)

**Purpose**: Prove and add the database access path required for bounded keyset reads.

- [X] T003 Add a failing PostgreSQL index-definition/usage test for `lower(btrim(display_name)), id` in `test/football_market/catalog/player_catalog_index_test.exs`
- [X] T004 Add the non-unique player catalog ordering expression index in `priv/repo/migrations/20260927000000_add_player_catalog_order_index.exs` and make T003 pass

**Checkpoint**: Test support and indexed authoritative persistence are ready; no public behavior has been added.

---

## Phase 3: User Story 1 — Browse the Player Catalog in Pages (Priority: P1) 🎯 MVP

**Goal**: Authenticated callers traverse a bounded, deterministic, local catalog using opaque continuation cursors.

**Independent Test**: With more than 100 local players, authenticate by JWT and API key, follow cursors from the default page through completion, and prove exact-once ordered coverage, bounds, exact metadata, replay, validation, and no pre-authentication query.

### Tests for User Story 1

- [X] T005 [P] [US1] Add failing cursor round-trip, confidentiality, version/scope/type, malformed, foreign, and tampering tests in `test/football_market/catalog/player_cursor_test.exs`
- [X] T006 [P] [US1] Add failing page-query tests for normalized ordering, tie-breaking, sizes 1/25/100, `limit + 1`, boundaries, replay, changed page size, insertions around anchors, anchor deletion, and hierarchy preloads in `test/football_market/catalog/player_pagination_test.exs`
- [X] T007 [P] [US1] Add failing list-route contract tests for both credential methods, exact success/error shapes, empty pages, invalid/repeated supported parameters, error precedence, and behavior-neutral unknown parameters in `test/football_market_web/controllers/player_controller_test.exs`
- [ ] T008 [US1] Run T005–T007 and record the intended pre-implementation failures in `specs/011-player-catalog-api/verification.md`

### Implementation for User Story 1

- [X] T009 [US1] Implement endpoint-scoped versioned authenticated encryption, endpoint-secret key derivation, uniform `:invalid_cursor` failures, and sensitive-value-safe handling in `lib/football_market/catalog/player_cursor.ex`
- [X] T010 [US1] Implement the centralized `lower(btrim(display_name)), id` ordered seek query, complete hierarchy loading, and `page_size + 1` fetch in `lib/football_market/catalog/query.ex`
- [X] T011 [US1] Add the validation-neutral `list_player_page/1` context boundary and continuation metadata derivation in `lib/football_market/catalog.ex`
- [X] T012 [US1] Implement raw query-pair multiplicity checks, strict `page_size` parsing, page-size-before-cursor error precedence, and list orchestration in `lib/football_market_web/controllers/player_controller.ex`
- [X] T013 [US1] Render the exact shared public player object and exact list pagination envelope in `lib/football_market_web/controllers/player_json.ex`
- [X] T014 [US1] Add protected `GET /api/players` routing through the existing `:api_protected` pipeline in `lib/football_market_web/router.ex`
- [X] T015 [US1] Run T005–T007 and confirm all US1 tests pass, updating command evidence only in `specs/011-player-catalog-api/verification.md`

**Checkpoint**: US1 is independently usable as the bounded catalog-discovery MVP.

---

## Phase 4: User Story 2 — Inspect One Player (Priority: P2)

**Goal**: Authenticated callers retrieve exactly one locally persisted player and its authoritative hierarchy by stable internal UUID.

**Independent Test**: Request an existing player using both credential methods and compare the exact representation; prove malformed and absent UUIDs share the identical 404 response and unauthenticated callers cannot disclose existence.

### Tests for User Story 2

- [X] T016 [P] [US2] Add failing context tests for stable-ID lookup, complete authoritative hierarchy loading, and absent identity in `test/football_market/catalog/player_detail_test.exs`
- [X] T017 [P] [US2] Add failing detail-route tests for both credential methods, exact response keys/types, malformed/absent identity equivalence, and authentication-before-lookup in `test/football_market_web/controllers/player_detail_controller_test.exs`
- [ ] T018 [US2] Run T016–T017 and record the intended pre-implementation failures in `specs/011-player-catalog-api/verification.md`

### Implementation for User Story 2

- [X] T019 [US2] Harden stable-ID lookup to preload the public hierarchy and collapse malformed/absent IDs to one not-found result in `lib/football_market/catalog.ex`
- [X] T020 [US2] Add detail orchestration and the exact `player_not_found` response without cast-detail leakage in `lib/football_market_web/controllers/player_controller.ex`
- [X] T021 [US2] Render the detail envelope through the shared player representation in `lib/football_market_web/controllers/player_json.ex`
- [X] T022 [US2] Add protected `GET /api/players/:player_id` routing through the existing `:api_protected` pipeline in `lib/football_market_web/router.ex`
- [X] T023 [US2] Run T016–T017 plus US1 regression tests and record passing evidence in `specs/011-player-catalog-api/verification.md`

**Checkpoint**: List and detail are independently contract-testable and preserve one shared representation.

---

## Phase 5: User Story 3 — Read During Provider Unavailability (Priority: P3)

**Goal**: List, continuation, detail, not-found, and empty-catalog behavior remain entirely local when providers or cache are unavailable.

**Independent Test**: Configure provider/cache probes to raise on invocation, exercise every list/detail outcome with local fixtures, and prove expected HTTP results with zero forbidden calls.

### Tests for User Story 3

- [X] T024 [P] [US3] Add failing local-only tests covering list, continuation, empty catalog, existing detail, missing detail, and provider/cache failure sentinels in `test/football_market_web/controllers/player_catalog_security_test.exs`
- [X] T025 [P] [US3] Add failing authentication-precedence tests proving invalid credentials halt before parameter validation and catalog-query execution in `test/football_market_web/controllers/player_catalog_auth_precedence_test.exs`
- [X] T026 [US3] Run T024–T025 and record the intended failures or any already-satisfied invariant evidence in `specs/011-player-catalog-api/verification.md`

### Implementation for User Story 3

- [X] T027 [US3] Remove any discovered provider/cache/background-job path and keep controller-to-`Catalog` local-read orchestration explicit in `lib/football_market_web/controllers/player_controller.ex`
- [X] T028 [US3] Run T024–T025 plus all catalog API tests and record zero-call and authentication-precedence evidence in `specs/011-player-catalog-api/verification.md`

**Checkpoint**: The PRODUCT local-read invariant and the feature’s failure/non-disclosure behavior are verified across both endpoints.

---

## Phase 6: Polish, Documentation, and Verification

**Purpose**: Close CP1 evidence, security, performance diagnostics, and full-suite regression coverage without expanding into TASK-012 or TASK-013.

- [X] T029 [P] Add the tagged 100,000-player first-page, continuation-page, and detail diagnostic harness with 10 warm-ups and 100 measured requests per case in `test/football_market_web/controllers/player_catalog_performance_test.exs`
- [X] T030 [P] Reconcile implemented parameter, cursor-rotation, non-snapshot mutation, and exact transport behavior in `specs/011-player-catalog-api/contracts/player-catalog-api.md`
- [X] T031 [P] Reconcile runnable focused/full-suite commands and performance instructions in `specs/011-player-catalog-api/quickstart.md`
- [X] T032 Run the tagged performance diagnostic and record three separate p95 values plus machine/runtime/database context, without treating the result as a CP1 release gate, in `specs/011-player-catalog-api/verification.md`
- [X] T033 Run `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, all focused feature tests, and `MIX_ENV=test mix test`; record exact command outcomes in `specs/011-player-catalog-api/verification.md`
- [X] T034 Review final changes for no undocumented response fields, cursor/credential/anchor logging, filtering/search/OpenAPI scope creep, provider/cache calls, or architecture-boundary violations and record the review result in `specs/011-player-catalog-api/verification.md`
- [X] T035 Redact continuation cursor parameters and decoded seek anchors from logs, add capture-log regression coverage in `config/config.exs`, `lib/football_market/catalog.ex`, and `test/football_market_web/controllers/player_catalog_security_test.exs`, and repeat live HTTP verification

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** starts immediately.
- **Foundational (Phase 2)** depends on T001 for fixtures and blocks US1.
- **US1 (Phase 3)** depends on Setup and Foundational; it is the MVP.
- **US2 (Phase 4)** depends on US1’s shared controller/renderer, but its lookup behavior is independently testable.
- **US3 (Phase 5)** depends on US1 and US2 because it verifies the complete surfaces under provider/cache failure.
- **Polish (Phase 6)** depends on all selected stories; T029–T031 can proceed in parallel before T032–T034.

### Within Each User Story

- Write tests and confirm intended failures before implementation.
- Implement cursor/query/context behavior before controller routing that consumes it.
- Preserve authentication at the router pipeline before parsing, validation, or lookup.
- Run the story’s independent test set before beginning the next story.

### Parallel Opportunities

- T002 can run alongside T001; T005–T007, T016–T017, T024–T025, and T029–T031 are parallel groups.
- After US1, detail context tests and controller tests can be authored concurrently.
- Documentation and the diagnostic harness touch distinct files and can proceed concurrently after behavior stabilizes.

## Parallel Examples

### User Story 1

```text
T005: cursor unit tests in test/football_market/catalog/player_cursor_test.exs
T006: page-query tests in test/football_market/catalog/player_pagination_test.exs
T007: list HTTP contract tests in test/football_market_web/controllers/player_controller_test.exs
```

### User Story 2

```text
T016: detail context tests in test/football_market/catalog/player_detail_test.exs
T017: detail HTTP tests in test/football_market_web/controllers/player_detail_controller_test.exs
```

### User Story 3

```text
T024: provider/cache isolation tests in test/football_market_web/controllers/player_catalog_security_test.exs
T025: authentication-precedence tests in test/football_market_web/controllers/player_catalog_auth_precedence_test.exs
```

## Implementation Strategy

### MVP First

1. Complete Setup and Foundational work.
2. Complete US1 test-first and validate bounded traversal independently.
3. Stop at the US1 checkpoint if only the minimum catalog-discovery increment is required.

### Incremental Delivery

1. Add US2 without changing US1’s representation or ordering contract.
2. Add US3 verification across both completed surfaces.
3. Complete diagnostic, documentation, security review, and full verification.

## Notes

- Do not modify the existing filtered `Catalog.list_players/1` contract; TASK-012 owns filtering.
- Do not publish OpenAPI here; TASK-013 documents this already-established contract.
- Do not log credentials, cursors, decoded anchors, cryptographic errors, or authenticated actor details.
- A conditional implementation task such as T027 is complete only after inspection plus its tests prove no change is required, or after the discovered path is removed.

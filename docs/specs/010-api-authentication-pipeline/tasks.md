# Tasks: API Authentication Pipeline

**Input**: Design documents from `/specs/010-api-authentication-pipeline/`

**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/api-authentication.md`, and `quickstart.md`

**Tests**: Required by FR-014 and the constitution. In every phase, add the tests and observe the focused suite fail for the expected missing behavior before implementing that behavior.

**Organization**: Tasks are grouped by user story so each credential path and the route-policy boundary can be implemented and verified as an independent increment.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel because it touches a different file and has no dependency on another incomplete task
- **[Story]**: Maps the task to its user story (`US1`, `US2`, or `US3`)
- Every task names the exact file or focused command path it affects

## Phase 1: Setup (Shared Test Infrastructure)

**Purpose**: Provide a test-only API boundary that can prove actor propagation and downstream non-execution without shipping a production endpoint.

- [X] T001 Create the test-only public/protected router, probe handlers, validator seams, and invocation signal in `test/support/api_authentication_probe.ex`
- [X] T002 Load the authentication probe support while retaining the default `performance: true` exclusion in `test/test_helper.exs`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the shared, minimal trusted value used by both credential methods.

**⚠️ CRITICAL**: Complete this phase before either authentication method is implemented.

- [X] T003 Add a failing exact-shape and forbidden-field contract test for the authenticated actor in `test/football_market_web/api_authentication_test.exs`
- [ ] T004 Run the actor contract test and confirm it fails because the actor type is absent using `test/football_market_web/api_authentication_test.exs`
- [X] T005 Implement the enforced-key `%FootballMarket.Accounts.AuthenticatedActor{account_id, authentication_method, credential_id}` value with no extra fields in `lib/football_market/accounts/authenticated_actor.ex`

**Checkpoint**: The request-scoped actor contract exists, carries identity and credential provenance only, and its focused contract test passes.

---

## Phase 3: User Story 1 - Access with a JWT (Priority: P1) 🎯 MVP

**Goal**: A protected request with one valid Bearer token reaches downstream behavior exactly once with a trusted JWT actor; missing, malformed, invalid, or expired JWTs fail identically before that behavior.

**Independent Test**: Issue a real TASK-009 access token, call the protected test route, and assert the exact actor and probe invocation; then table-drive missing/malformed/invalid/expired JWT cases and assert the same halted `401`, Bearer challenge, absent actor, and zero probe invocations.

### Tests for User Story 1

- [X] T006 [P] [US1] Add JWT success, exact actor propagation, missing credential, malformed Bearer syntax, unsupported scheme, invalid token, expired token, and downstream non-execution tests in `test/football_market_web/api_authentication_test.exs`
- [X] T007 [P] [US1] Add JWT response, Logger, telemetry, exception, actor-inspection, and sentinel non-disclosure tests in `test/football_market_web/api_authentication_security_test.exs`
- [ ] T008 [US1] Run the JWT-focused tests and confirm they fail for the missing authentication Plug using `test/football_market_web/api_authentication_test.exs` and `test/football_market_web/api_authentication_security_test.exs`

### Implementation for User Story 1

- [X] T009 [US1] Implement exact Bearer header occurrence classification, strict case-insensitive scheme parsing without token normalization, delegation to `Accounts.validate_access_token/1`, JWT actor assignment, and the exact generic halted response in `lib/football_market_web/plugs/authenticate_api.ex`
- [X] T010 [US1] Make validator failures and safe validator exceptions converge without logging or exposing credential material in `lib/football_market_web/plugs/authenticate_api.ex`

**Checkpoint**: JWT authentication is independently functional and all JWT rejection classes are observationally equivalent.

---

## Phase 4: User Story 2 - Access with an API Key (Priority: P2)

**Goal**: A protected request with one active API key reaches downstream behavior with the owning account and key ID; unknown, malformed, or revoked keys fail exactly like all other unauthenticated requests.

**Independent Test**: Issue a real TASK-008 key, call the protected test route, and assert the API-key actor; revoke it in a committed operation and prove the next request fails while a second active key remains usable.

### Tests for User Story 2

- [X] T011 [P] [US2] Add active-key success, exact actor propagation, unknown/noncanonical key, immediate post-revocation rejection, second-key continuity, and downstream non-execution tests in `test/football_market_web/api_authentication_test.exs`
- [X] T012 [P] [US2] Add API-key response, query-log, telemetry, exception, actor-inspection, and sentinel non-disclosure tests in `test/football_market_web/api_authentication_security_test.exs`
- [ ] T013 [US2] Run the API-key-focused tests and confirm they fail for the absent API-key branch using `test/football_market_web/api_authentication_test.exs` and `test/football_market_web/api_authentication_security_test.exs`

### Implementation for User Story 2

- [X] T014 [US2] Add unchanged opaque API-key delegation to `Accounts.identify_api_key/1`, API-key actor assignment, and generic safe failure handling in `lib/football_market_web/plugs/authenticate_api.ex`

**Checkpoint**: API-key authentication and committed revocation behavior work independently without changing the JWT contract.

---

## Phase 5: User Story 3 - Apply a Predictable Route Policy (Priority: P3)

**Goal**: Every application-owned `/api` route has exactly one explicit public or protected policy; public routes ignore credentials, protected routes reject ambiguity and pass only verified actor context inward.

**Independent Test**: Audit the production route table, exercise both test policies with absent, valid, invalid, repeated, coalesced, non-binary, and dual credentials, and prove public requests never validate or emit authentication signals while protected failures remain identical.

### Tests for User Story 3

- [X] T015 [P] [US3] Add route-table classification, explicit public allowlist, exactly-one-policy, and handler source-boundary tests in `test/football_market_web/router_authentication_policy_test.exs`
- [X] T016 [P] [US3] Add public-route ignore behavior plus repeated header lines, coalesced values, dual credentials, blank values, extra Bearer parts, and direct non-binary Plug input tests in `test/football_market_web/api_authentication_test.exs`
- [X] T017 [P] [US3] Add complete authentication telemetry metadata, neutral missing/ambiguous method, duration, single-event, and ambiguity non-disclosure tests in `test/football_market_web/api_authentication_security_test.exs`
- [ ] T018 [US3] Run the route-policy and edge-case tests and confirm they fail for the unimplemented policy/telemetry behavior using `test/football_market_web/router_authentication_policy_test.exs`, `test/football_market_web/api_authentication_test.exs`, and `test/football_market_web/api_authentication_security_test.exs`

### Implementation for User Story 3

- [X] T019 [US3] Replace the generic API pipeline with explicit `:api_public` and `:api_protected` pipelines, placing `AuthenticateAPI` only in the protected pipeline, in `lib/football_market_web/router.ex`
- [X] T020 [US3] Fail closed before validation for repeated or dual credentials, preserve opaque coalesced values, and reject direct non-binary input in `lib/football_market_web/plugs/authenticate_api.ex`
- [X] T021 [US3] Emit one low-cardinality `[:football_market, :api, :authentication]` event per protected decision with duration and only the permitted policy, generic outcome, and unambiguous method metadata in `lib/football_market_web/plugs/authenticate_api.ex`

**Checkpoint**: Public and protected policies are explicit, auditable, fail closed, and independently testable without a production API probe.

---

## Phase 6: Polish & Cross-Cutting Verification

**Purpose**: Close measurable performance, documentation, full-suite, checkpoint, and scope evidence across all three stories.

- [X] T022 [P] Add the excluded-by-default five-warm-up/40-sample timing regression for both complete credential paths, including per-method threshold counts and p95 output, in `test/football_market_web/api_authentication_performance_test.exs`
- [X] T023 [P] Reconcile final actor, route-policy, failure, telemetry, test, and opt-in timing instructions with the implemented behavior in `specs/010-api-authentication-pipeline/contracts/api-authentication.md` and `specs/010-api-authentication-pipeline/quickstart.md`
- [X] T024 Run the focused functional, security, and route-policy suite from `specs/010-api-authentication-pipeline/quickstart.md`
- [X] T025 Run the opt-in latency regression and verify at least 38 of 40 decisions are below one second independently for JWT and API key using `test/football_market_web/api_authentication_performance_test.exs`
- [X] T026 Run formatting, warnings-as-errors compilation, and the complete default test suite from `specs/010-api-authentication-pipeline/quickstart.md`
- [X] T027 Audit FR-001 through FR-015, SC-001 through SC-007, CP1 coverage, architecture boundaries, and absence of authorization or credential-lifecycle scope, recording the final evidence in `specs/010-api-authentication-pipeline/checklists/requirements.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Starts immediately.
- **Foundational (Phase 2)**: Depends on Setup and blocks all stories.
- **US1 (Phase 3)**: Depends on Foundational and is the MVP credential path.
- **US2 (Phase 4)**: Depends on the shared Plug introduced by US1; it remains independently testable through the API-key scenarios.
- **US3 (Phase 5)**: Depends on both credential branches so ambiguity, policy, and telemetry tests cover the complete boundary.
- **Polish (Phase 6)**: Depends on all selected stories; T025 depends on T022, and T024–T027 validate the integrated result.

### Within Each User Story

1. Add all story tests marked `[P]`.
2. Run the focused files and observe failures caused by missing behavior, not test defects.
3. Implement the smallest behavior that satisfies the story.
4. Re-run that story's focused files before advancing.

### User Story Dependency Graph

```text
Setup -> Foundation -> US1 (JWT/MVP) -> US2 (API key) -> US3 (route policy) -> Polish
```

US2 and US3 are independently verifiable increments, but implementation is intentionally sequential because both extend the same security-sensitive Plug and US3 tests cross-method ambiguity.

### Parallel Opportunities

- T006 and T007 can run in parallel after T005.
- T011 and T012 can run in parallel after US1 passes.
- T015, T016, and T017 can run in parallel after US2 passes.
- T022 and T023 can run in parallel after all stories pass.

## Parallel Examples

### User Story 1

```text
Task T006: Functional JWT and exact-response tests in test/football_market_web/api_authentication_test.exs
Task T007: JWT non-disclosure tests in test/football_market_web/api_authentication_security_test.exs
```

### User Story 2

```text
Task T011: Functional API-key and revocation tests in test/football_market_web/api_authentication_test.exs
Task T012: API-key non-disclosure tests in test/football_market_web/api_authentication_security_test.exs
```

### User Story 3

```text
Task T015: Production route-policy audit in test/football_market_web/router_authentication_policy_test.exs
Task T016: Public and ambiguous-input tests in test/football_market_web/api_authentication_test.exs
Task T017: Telemetry and ambiguity privacy tests in test/football_market_web/api_authentication_security_test.exs
```

## Implementation Strategy

### MVP First

1. Complete Setup and Foundation.
2. Complete US1 and re-run its focused functional/security tests.
3. Stop and validate JWT actor propagation and generic rejection behavior independently.

### Incremental Delivery

1. Add US2 and validate active/revoked API keys without regressing JWTs.
2. Add US3 and validate the complete public/protected boundary and route audit.
3. Complete performance, documentation, repository checks, and CP1 evidence.

## Notes

- The test-only probe must never be registered in the production router.
- Tests use the real TASK-008/TASK-009 capabilities for integration evidence; seams exist only for deterministic call-count, exception, and public-ignore assertions.
- Invalid wire input rejected before Plug execution is a transport error and is not forced into the application-level `401` contract.
- Do not decode JWT claims, query API-key schemas from the web layer, introduce optional authentication, or add authorization behavior.

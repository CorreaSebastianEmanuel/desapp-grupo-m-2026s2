---

description: "Implementation tasks for TASK-013"
---

# Tasks: OpenAPI 3 Foundation and CP1 Contracts

**Input**: `specs/013-openapi-cp1-contracts/spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/cp1-openapi.md`, and `quickstart.md`.

**Scope**: Publish and verify the existing CP1 catalog HTTP contract. Do not alter authentication, catalog behavior, persistence, or provider adapters.

**Tests**: Required by FR-015 and the repository constitution. Write each story's tests before its implementation. Observe a relevant failure for missing behavior; for drift guards against already implemented behavior, prove detection with a disposable mutated copy. Never record credential values in test output.

## Phase 1: Setup

**Purpose**: Pin local documentation assets and test-only tooling.

- [X] T001 Add exact-version `swagger-ui-dist`, `@apidevtools/swagger-parser`, and `playwright-core` tooling dependencies and a reproducible lockfile in `tools/openapi/package.json` and `tools/openapi/package-lock.json`; keep them out of Phoenix runtime dependencies.
- [X] T002 Copy only required JS/CSS assets from the pinned official Swagger UI distribution into `priv/static/api-docs/`, including its license and a version/hash manifest at `priv/static/api-docs/ASSETS.md`; use no CDN or ignored `priv/static/assets/` path.

## Phase 2: Foundational

**Purpose**: Give the HTTP and browser checks deterministic, isolated fixtures without changing production behavior.

**Checkpoint**: Test support is ready before story tests are written.

- [X] T003 Add `test/support/openapi_case.ex` helpers using existing Accounts/Catalog fixtures for one populated page, an empty page, a detail player, and short-lived JWT/API-key credentials; support an isolated loopback endpoint with SQL sandbox sharing and cleanup on failure.

## Phase 3: User Story 1 — Discover and Try the CP1 Catalog (P1) 🎯 MVP

**Goal**: Public `/docs` renders the single `/openapi.json` contract, and a reader can execute the two existing catalog routes with a selected credential.

**Independent Test**: Open `/docs` without authentication, find both operations and their parameters, statuses, and examples, then execute list with JWT and detail with API key and compare the displayed results with live responses. An empty list retains all pagination fields.

### Tests — write and observe failure first

- [X] T004 [P] [US1] Add endpoint-level tests for public `/openapi.json` JSON content type, public `/docs`, exactly the two catalog method/path entries, five list parameters, success/empty/detail examples, and live 200 body shapes in `test/football_market_web/openapi_contract_test.exs`.
- [X] T005 [P] [US1] Add a browser acceptance test that loads `/docs` and `/openapi.json`, finds both operations, executes JWT list and API-key detail, compares statuses and response bodies, and shows a visible failure if the spec or an asset cannot load in `test/football_market_web/openapi_browser_test.exs`.

### Implementation

- [X] T006 [US1] Author `priv/static/openapi.json` as OpenAPI 3.0 with relative server `/`, exactly the two GET operations, all five list query parameters and detail UUID path parameter, both security alternatives, all applicable 200/400/401/404 responses, reusable exact player/page/error schemas, and required success/empty/detail/error examples from `specs/013-openapi-cp1-contracts/contracts/cp1-openapi.md`.
- [X] T007 [US1] Add `priv/static/openapi.json` and `api-docs` to `FootballMarketWeb.static_paths/0` in `lib/football_market_web.ex`; verify the endpoint's existing `Plug.Static` serves the JSON and local assets publicly without changing `/api` routing.
- [X] T008 [US1] Add the public `GET /docs` browser route in `lib/football_market_web/router.ex` and an HTML view in `lib/football_market_web/controllers/api_docs_controller.ex`, `lib/football_market_web/controllers/api_docs_html.ex`, and `lib/football_market_web/controllers/api_docs_html/docs.html.heex` that loads only same-origin `/openapi.json` and pinned local assets, with a visible spec/asset load error.
- [X] T009 [US1] Implement the Swagger UI bootstrapping, one masked credential-mode selector, and live request/response display in `priv/static/api-docs/docs.js`; make mode switches clear the entered value.
- [X] T010 [US1] Implement `tools/openapi/browser.mjs` to launch Chromium against the isolated server, exercise both operations, report only header presence and status, and always close the browser and server resources without emitting credential values.
- [X] T011 [US1] Run and make green the Story 1 focused ExUnit files `test/football_market_web/openapi_contract_test.exs` and `test/football_market_web/openapi_browser_test.exs` after first confirming their relevant assertions fail.

**Checkpoint**: US1 is usable from a browser and its public success and empty-page shapes are independently testable.

## Phase 4: User Story 2 — Understand Authentication and Failure Behavior (P2)

**Goal**: Readers can identify the alternative credential schemes and exact 401, 400, and 404 behavior, including precedence.

**Independent Test**: Inspect both operations' security and errors, then compare documented codes, challenge header, and validation order with unauthenticated, malformed, repeated, mixed-credential, invalid-list-input, and missing-player live requests.

### Tests — write and observe failure first

- [X] T012 [P] [US2] Extend `test/football_market_web/openapi_contract_test.exs` to assert OR-shaped security requirements, exact scheme headers, 401 challenge/body and authentication precedence, all five 400 codes and priority, malformed/absent-player 404, cursor/filter binding, and zero catalog reads on rejected requests where existing probes support it.
- [X] T013 [P] [US2] Extend `test/football_market_web/openapi_browser_test.exs` for JWT → API key → JWT switching, empty-credential 401, one outbound credential header only, same-origin restriction, and absence of secrets from URL, storage, UI commands/configuration, visible errors, screenshots, and failure output.

### Implementation

- [X] T014 [US2] Complete security, parameter, and failure descriptions and exact 400/401/404 code-constrained examples in `priv/static/openapi.json`, including header/scheme case rules, repeated/mixed rejection, authentication-first validation, filter intersection, error priority, and cursor semantics.
- [X] T015 [US2] Harden `priv/static/api-docs/docs.js`: suppress native authorization controls and mutated request commands, clear both credential headers case-insensitively, add only the selected header for same-origin catalog GETs, disable remote validation/configuration and credential persistence, and show load failures without revealing input.
- [X] T016 [US2] Add network-header and browser-state assertions to `tools/openapi/browser.mjs` that never print or persist credential values and that clean up even if an assertion or spec load fails.
- [X] T017 [US2] Run and make green the failure/security checks in `test/football_market_web/openapi_contract_test.exs` and `test/football_market_web/openapi_browser_test.exs` after confirming the new assertions fail.

**Checkpoint**: US2 failures and credential behavior match the existing protected API without changing its policy.

## Phase 5: User Story 3 — Consume a Machine-Readable Contract (P3)

**Goal**: The already published contract is independently valid OpenAPI 3 and remains aligned with the CP1 router and live response structures.

**Independent Test**: Retrieve `/openapi.json`, validate it with the pinned parser, compare its catalog method/path set and authentication policy with router metadata, and validate examples and live success/failure bodies against exact schemas.

### Tests — write and observe failure first

- [X] T018 [P] [US3] Add parser-gate tests for valid OpenAPI 3 and rejection of malformed or incomplete documents in `tools/openapi/validate.test.mjs`.
- [X] T019 [P] [US3] Extend `test/football_market_web/openapi_contract_test.exs` to compare documented catalog routes with every router route at `/api/players` or below and its `:api_protected` metadata; assert no extra operations, exact response statuses, media types, parameter bounds/requiredness, schema field requiredness/no extras, nullable `next_cursor`, and example/live-body conformance; prove drift detection with disposable mutated contract copies.

### Implementation

- [X] T020 [US3] Implement `tools/openapi/validate.mjs` with the pinned Swagger Parser so `node tools/openapi/validate.mjs priv/static/openapi.json` exits nonzero for invalid or non-OpenAPI-3 input.
- [X] T021 [US3] Complete schema constraints and semantic descriptions in `priv/static/openapi.json` until the parser and structural/live checks pass, including all exact nested Player fields, UUID/non-empty/integer constraints, pagination relationships, and no trading, quotes, or other unsupported operations.
- [X] T022 [US3] Run and make green `tools/openapi/validate.test.mjs`, the validator on `priv/static/openapi.json`, and `test/football_market_web/openapi_contract_test.exs` after confirming the new parser test fails without the validator and the drift tests reject disposable altered contracts.

**Checkpoint**: The machine contract parses and detects route, security, parameter, response, and schema drift.

## Phase 6: Polish and cross-cutting verification

**Purpose**: Make the addresses discoverable and execute the CP1 evidence gates.

- [X] T023 [P] Document `/docs`, `/openapi.json`, both credential methods, local setup, and a no-credential 401 walkthrough in `README.md`; use only nonfunctional credential placeholders.
- [X] T024 [P] Update `specs/013-openapi-cp1-contracts/quickstart.md` with exact installed-tool commands and the isolated browser-test setup/cleanup steps used by the implementation.
- [X] T025 Run `npm ci --prefix tools/openapi`, the parser and Node tests in `tools/openapi/`, focused ExUnit tests in `test/football_market_web/`, `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, and full `MIX_ENV=test mix test`; record actual results for independent QA without claiming unrun gates passed.
- [X] T026 Perform the three-minute discovery walkthrough from `README.md` against the running `/docs` page; check both credential paths and no-credential 401 against `specs/013-openapi-cp1-contracts/quickstart.md`, then provide evidence to independent QA and final review.

## Dependencies and execution order

- Setup (T001–T002) precedes foundational fixture support (T003), which precedes all story tests.
- US1 (T004–T011) produces the one served contract needed by the page. US2 (T012–T017) depends on it and closes failure/security semantics. US3 (T018–T022) depends on that same contract and closes machine validation and drift detection. Each phase has its own independent acceptance check.
- Polish (T023–T026) follows all desired stories. Independent QA and final review must each end in `Verdict: PASS` before Agentflow completion; this task list does not authorize merge.
- Within each story, write its test tasks, observe a relevant failure or prove drift detection with disposable mutated input, then implement in dependency order and rerun its checks. No story may use test-only OpenAPI request validation to change live controller or authentication behavior.

## Parallel execution examples

- **US1**: T004 and T005 can be written concurrently in separate ExUnit files; T006 must precede UI consumption in T009.
- **US2**: T012 and T013 can be written concurrently; T014, T015, and T016 touch separate contract, UI, and browser-runner files after the tests are red.
- **US3**: T018 and T019 can be written concurrently; T020 and T021 then address parser tooling and JSON content in separate files.
- **Polish**: T023 and T024 can be written concurrently after story acceptance; T025 and T026 use the resulting instructions.

## Implementation strategy

Complete Setup and Foundational work, then deliver US1 as the browser-facing MVP. Keep the single JSON contract in place while US2 adds exact failure/security evidence and US3 adds machine validation. After each story, run its independent check before proceeding. Complete the full regression and public walkthrough, then submit the work to independent QA and final review.

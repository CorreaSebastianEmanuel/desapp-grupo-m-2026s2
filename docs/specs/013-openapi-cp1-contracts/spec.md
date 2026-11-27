# Feature Specification: OpenAPI 3 Foundation and CP1 Contracts

**Feature Branch**: `013-openapi-3-foundation-and-cp1-contracts`

**Created**: 2026-09-28

**Status**: Draft

**Input**: TASK-013: "Publish interactive OpenAPI documentation for authentication and catalog behavior."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Discover and Try the CP1 Catalog (Priority: P1)

As an API consumer, I can open interactive documentation, inspect the player-list and player-detail contracts, and send a catalog request with one supported credential so that I can integrate without guessing request or response shapes.

**Why this priority**: CP1 needs a usable, published contract for its existing catalog operations.

**Independent Test**: Open the published documentation in a browser, find both player operations, supply either a valid JWT or a valid API key, execute a request, and compare the shown request and response with the live operation.

**Acceptance Scenarios**:

1. **Given** the application is available, **When** a reader opens its documented API documentation address, **Then** an interactive page loads and lists `GET /api/players` and `GET /api/players/{player_id}` with their methods, parameters, security requirement, response codes, and examples.
2. **Given** a valid JWT, **When** the reader authorizes and executes a player-list request, **Then** the page sends that credential as a Bearer token and displays the live response.
3. **Given** a valid API key, **When** the reader authorizes and executes a player-detail request, **Then** the page sends that credential in `X-API-Key` and displays the live response.
4. **Given** an empty or filtered catalog result, **When** the reader inspects the list contract, **Then** its schema and example show an empty `data` array and complete pagination metadata.

---

### User Story 2 - Understand Authentication and Failure Behavior (Priority: P2)

As an API consumer, I can see which credential forms are accepted and what failures mean so that I handle unauthenticated, invalid-input, and missing-player responses correctly.

**Why this priority**: A success-only document would leave clients unable to call or safely recover from the protected API.

**Independent Test**: Read the published contract, exercise unauthenticated and invalid-input cases, and compare its described status, challenge header, error code, and precedence with the live API.

**Acceptance Scenarios**:

1. **Given** either catalog operation, **When** its security section is inspected, **Then** JWT Bearer and API key appear as alternative single-credential methods with the correct header names, without suggesting both be sent together.
2. **Given** no usable credential, **When** a catalog operation is tried, **Then** documentation and live response agree on status 401, the Bearer challenge, and the generic `unauthenticated` error body.
3. **Given** a malformed list parameter or player identity, **When** the relevant operation is inspected, **Then** every applicable 400 or 404 response and its stable error code can be found without relying on a successful request.

---

### User Story 3 - Consume a Machine-Readable Contract (Priority: P3)

As an integrator, I can retrieve a valid OpenAPI 3 description of the same CP1 operations so that I can inspect it with documentation and client tooling.

**Why this priority**: The interactive page should have one inspectable contract, and CP1 explicitly requires OpenAPI 3.

**Independent Test**: Retrieve the published description, validate it as OpenAPI 3, inspect its operations, schemas, and security definitions, and compare one documented request and response for each operation with the running API.

**Acceptance Scenarios**:

1. **Given** the application is available, **When** the published contract address is retrieved, **Then** a valid OpenAPI 3 document is returned with exactly the currently supported CP1 catalog operations and their alternative authentication schemes.
2. **Given** the contract and interactive page, **When** their listed operations and schemas are compared, **Then** they describe the same parameters, responses, and security requirements.
3. **Given** an unsupported future product capability such as trading or quote history, **When** the CP1 contract is inspected, **Then** no operation claims that capability exists.

### Edge Cases

- A reader can load both documentation forms without an API credential. Executing a protected operation still requires exactly one valid credential and uses the established authentication policy.
- The page and examples contain no real token or key. A reader-supplied credential is used only for that reader's interactive request and is not placed in a shareable documentation URL.
- An invalid, expired, missing, repeated, or mixed credential produces the same generic 401 behavior. Authentication failure precedes query and path validation.
- The list documents omitted `page_size` as 25, accepted values 1 through 100, and `cursor` as an opaque continuation value. It does not imply snapshot pagination.
- Blank, malformed, structured, or repeated supported query values are invalid; an unknown query key is ignored. Valid but unknown or conflicting filter IDs produce an empty success page.
- A filtered cursor works only with the same effective filter set; changing only page size is permitted. The document does not invite clients to decode or manufacture cursors.
- A malformed or unknown `player_id` produces the same 404 response. A wrong or missing credential still produces 401 first.
- A documentation availability failure must be visible as such; it does not change either catalog operation's established runtime contract.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The application MUST publish an interactive API documentation page and a retrievable machine-readable OpenAPI 3 description at stable, discoverable addresses. Both MUST be readable without an API credential; trying protected operations still requires authentication.
- **FR-002**: The interactive page MUST render the published description and allow a reader to inspect operations, parameters, authentication, success and error responses, and examples, then submit requests to the live catalog operations and inspect their responses.
- **FR-003**: The description MUST document exactly the existing CP1 HTTP operations `GET /api/players` and `GET /api/players/{player_id}`. It MUST NOT present JWT login, user registration, API-key issuance, or other domain capabilities as HTTP operations when no corresponding route exists.
- **FR-004**: Both catalog operations MUST be marked as protected by either one JWT Bearer credential in `Authorization` or one API key in `X-API-Key`. These MUST be alternatives, never simultaneous requirements. An interactive request MUST send only the selected credential method. The documentation MUST explain that header names and the Bearer scheme are case-insensitive, credential values are exact, and missing, invalid, expired, repeated, and mixed credentials are rejected.
- **FR-005**: Each catalog operation MUST describe the generic unauthenticated response as status 401 with `WWW-Authenticate: Bearer realm="api"` and exact JSON body `{"error":{"code":"unauthenticated"}}`. It MUST state that authentication precedes parameter validation and catalog access.
- **FR-006**: The player-list operation MUST document optional `page_size`, `cursor`, `league_id`, `team_id`, and `position_id`. It MUST show default page size 25, inclusive bounds 1 and 100, one unsigned base-10 integer for an explicit page size, one non-empty opaque cursor, and each filter as one UUID without surrounding whitespace matching the corresponding nested player identity. It MUST describe blank, malformed, structured, and repeated supported parameter values as invalid.
- **FR-007**: The list description MUST explain that the three optional filters combine by intersection; omitted filters impose no restriction; valid but unknown or conflicting IDs return an empty successful page; unknown query keys are ignored; and query-key order does not affect results. It MUST identify the results as locally stored players, ordered by case-insensitive display name with stable player ID as the tie-breaker, without a live provider fetch.
- **FR-008**: The description MUST explain that a continuation cursor is bound to the effective filter set, equivalent UUID letter case and query-key order do not change that set, changing only `page_size` is allowed, and adding, removing, or changing a filter with an existing cursor yields `invalid_cursor`. It MUST describe cursor traversal as non-snapshot.
- **FR-009**: The list success response MUST be documented as status 200 with exactly `data` and `pagination`. `data` MUST be an array of no more player representations than the applied `page_size`. `pagination` MUST have exactly `page_size` (the applied size), `returned_count` (the length of `data`), `has_more` (whether another matching player follows), and `next_cursor` (a non-empty string exactly when `has_more` is true, otherwise null). An empty page MUST retain all pagination fields.
- **FR-010**: The documented player representation MUST have exactly `id`, `display_name`, `catalog_identity`, `position`, `team`, `season`, and `league`. The nested objects MUST respectively have exactly `id/code/name`, `id/short_code/name`, `id/start_year/end_year`, and `id/code/name`; identifiers MUST be UUID strings, season years integers, all other leaves non-empty strings, and no field nullable. No credential, actor, provider payload, or persistence field may appear.
- **FR-011**: Player detail MUST document the required `player_id` path parameter as the stable player UUID, a status-200 body with only `data` containing the same player representation, and status 404 with exact body `{"error":{"code":"player_not_found"}}` for malformed or absent identities.
- **FR-012**: The list MUST document status 400 and exact single-code body shape `{"error":{"code":"<code>"}}` for every applicable code: `invalid_page_size`, `invalid_league_id`, `invalid_team_id`, `invalid_position_id`, and `invalid_cursor`. It MUST state the error priority for an authenticated request with several invalid supported values: `page_size`, `league_id`, `team_id`, `position_id`, `cursor`.
- **FR-013**: Examples MUST be syntactically usable and representative of the documented shapes, including one list success, one empty page, one detail success, one invalid-input response, one not-found response, and the generic 401. Examples MUST use placeholders or nonfunctional sample credentials only.
- **FR-014**: The machine-readable description MUST be valid OpenAPI 3 and MUST faithfully express each operation's method, path, parameter location, requiredness, type and bounds, alternative security methods, status codes, response media type, field requiredness, and nullable continuation field. Semantic rules that cannot be expressed as schema constraints MUST appear in affected operation or parameter descriptions.
- **FR-015**: Published documentation MUST remain aligned with live CP1 routes and response contracts. Automated checks MUST detect a missing or extra documented operation, malformed OpenAPI description, incorrect security alternative, missing parameter or error code, and mismatch in documented response structure. A browser-level check MUST confirm that the interactive page loads the description and executes a protected catalog request.
- **FR-016**: Scope MUST be limited to publication of existing authentication and catalog HTTP contracts. This feature MUST NOT change catalog results, authentication policy, credential issuance, authorization, trading, valuation, ranking, persistence rules, or provider behavior.

### Key Entities

- **Published API Description**: The machine-readable OpenAPI 3 contract for existing CP1 catalog routes, authentication choices, parameters, responses, and examples.
- **Interactive Documentation**: The human-readable view of that description that can submit live requests with a reader-supplied credential.
- **Player Representation**: The shared public catalog shape used by list items and detail results.
- **Catalog Page**: A bounded list of players with continuation metadata and optional catalog filters.
- **Authentication Choice**: Exactly one of the supported Bearer token or API-key headers required by each catalog operation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A reader can find both catalog operations, their two alternative credential methods, all five list parameters, and all documented success and error responses from the interactive page within three minutes.
- **SC-002**: Using a valid credential of either supported type, a reader can execute a live catalog request from the interactive page and see its response; both credential methods work in the acceptance demonstration.
- **SC-003**: The published description passes an OpenAPI 3 validity check, and 100% of currently supported CP1 catalog routes, response codes, security choices, and required response fields are represented accurately in the contract check.
- **SC-004**: In acceptance comparisons, 100% of documented success, unauthenticated, invalid-list-input, and missing-player examples agree with observed status, body shape, and applicable challenge header.
- **SC-005**: A reader without a credential can open both documentation forms, while 100% of unauthenticated requests made through the page to protected operations receive the generic 401 without catalog data.

## Assumptions

- TASK-010 and TASK-012 are available as existing HTTP behavior to describe; TASK-011 supplies the list and detail shapes. Their contracts remain authoritative for runtime behavior while this specification is authoritative for documentation publication.
- Public read access to API documentation is the CP1 default for developer discovery. It grants no access to protected catalog data.
- CP1 has no public HTTP routes for registration, JWT login, or API-key lifecycle. These capabilities are background authentication guidance only, not callable operations.
- Stable documentation addresses may be chosen during planning and published in the project instructions; users must be able to discover and retrieve both forms without reverse engineering routes.

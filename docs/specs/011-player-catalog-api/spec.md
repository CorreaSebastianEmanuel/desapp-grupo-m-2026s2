# Feature Specification: Player Catalog List and Detail API

**Feature Branch**: `011-player-catalog-api`

**Created**: 2026-09-26

**Status**: Draft

**Input**: TASK-011: "Expose authenticated player list and detail endpoints backed only by local persistence, with bounded stable pagination for the player list."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse the Player Catalog in Pages (Priority: P1)

As an authenticated market user, I can traverse the player catalog in bounded, deterministic pages so that I can discover every footballer without receiving an unbounded response.

**Why this priority**: Catalog discovery is the minimum useful read capability, and an explicit continuation contract lets clients consume catalogs of any supported size safely.

**Independent Test**: Store more players than both the default and maximum page sizes, request pages with each supported authentication method, and follow each returned cursor until completion; verify that every player appears exactly once in the documented order and every page respects its requested bound.

**Acceptance Scenarios**:

1. **Given** more than 25 locally persisted players, **When** an authenticated user requests `GET /api/players` without pagination parameters, **Then** at most the first 25 players are returned in documented order with an unambiguous continuation cursor.
2. **Given** a requested `page_size` from 1 through 100, **When** the list is requested, **Then** no more than that number of players is returned and the response reports the applied page size, returned count, whether another page exists, and the cursor needed to request it.
3. **Given** an unchanged catalog containing duplicate and case-variant display names, **When** a caller follows cursors until `has_more` is false, **Then** every persisted player appears exactly once in case-insensitive display-name order with stable player identity breaking ties.
4. **Given** a page with no later player, **When** it is returned, **Then** `has_more` is false and `next_cursor` is null; otherwise `has_more` is true and `next_cursor` is a non-empty opaque value.
5. **Given** an empty local catalog, **When** an authenticated user requests the player list, **Then** the request succeeds with an empty `data` collection, a returned count of zero, `has_more` false, and `next_cursor` null.
6. **Given** a caller without one valid supported credential, **When** the player list is requested, **Then** the shared unauthenticated response is returned before any catalog read.

---

### User Story 2 - Inspect One Player (Priority: P2)

As an authenticated market user, I can retrieve one player by stable identity so that I can inspect the player's catalog context unambiguously.

**Why this priority**: Detail lookup lets clients move from discovery to a stable player resource without relying on names or provider-specific identifiers.

**Independent Test**: Store one player and its catalog hierarchy locally, request that player's stable identity, and verify the complete representation; request a well-formed absent identity and verify the generic not-found result.

**Acceptance Scenarios**:

1. **Given** a locally persisted player, **When** an authenticated user requests `GET /api/players/{player_id}` with that player's stable identity, **Then** the response contains exactly that player and its position, team, season, and league.
2. **Given** a well-formed stable player identity that is not present locally, **When** an authenticated user requests it, **Then** the request receives a not-found response with no player data.
3. **Given** a malformed player identity, **When** an authenticated user requests it, **Then** the request receives the same not-found response as an absent identity and no internal error is exposed.
4. **Given** a caller without one valid supported credential, **When** a player detail is requested, **Then** authentication fails before player existence is disclosed or local catalog data is read.

---

### User Story 3 - Read During Provider Unavailability (Priority: P3)

As an authenticated market user, I can browse and inspect players even when external football providers are unavailable so that the catalog remains dependable.

**Why this priority**: Local reads are a product invariant and prevent provider availability, latency, or payload changes from degrading the catalog experience.

**Independent Test**: Make every external-provider adapter fail if invoked, populate local catalog records, and verify that paginated list and detail requests return expected data without any provider interaction.

**Acceptance Scenarios**:

1. **Given** locally persisted catalog data and an unavailable external provider, **When** an authenticated user traverses the player list, **Then** every local page succeeds and no external-provider call occurs.
2. **Given** a locally persisted player and an unavailable external provider, **When** an authenticated user requests that player, **Then** the locally stored detail succeeds and no external-provider call occurs.
3. **Given** no matching local player but an external provider that could supply one, **When** authenticated detail is requested, **Then** the request returns not found without consulting or importing from the provider.

### Edge Cases

- `page_size` values below 1, above 100, non-integer, blank, or repeated are rejected rather than coerced, capped, or silently ignored.
- A missing cursor starts traversal at the beginning; a blank, malformed, tampered, repeated, or foreign cursor is rejected without returning catalog data.
- A valid cursor may be used with any valid page size; changing the page size does not change its position in the ordered catalog.
- Duplicate and case-variant display names do not collapse records; stable player identity breaks all ordering ties.
- A page ending exactly on the final player reports no continuation. The service may inspect one additional ordered record to determine this, but never returns more than the applied page size.
- For unchanged catalog data, replaying the same cursor and page size returns the same page. Pagination is not a historical snapshot: records inserted after a cursor is issued appear only if they sort strictly after its anchor, while records inserted before it do not appear in the remaining traversal.
- A well-formed but absent player identity and a malformed identity produce the same public not-found status and error body.
- Authentication is evaluated before parameter validation or lookup, so unauthenticated callers cannot use pagination errors to probe the protected operation.
- Every returned player's league and season are derived through its team relationship; contradictory or independently substituted hierarchy values are never returned.
- Provider outage, slowness, malformed provider data, or missing provider configuration has no effect on these reads because no provider is contacted.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST expose `GET /api/players` as the protected player-list endpoint and `GET /api/players/{player_id}` as the protected player-detail endpoint.
- **FR-002**: Both operations MUST use the protected-route authentication behavior supplied by TASK-010 and MUST accept either supported credential method according to that shared policy.
- **FR-003**: Authentication MUST complete successfully before pagination validation, catalog reads, or disclosure of whether any player exists.
- **FR-004**: The list operation MUST accept optional `page_size` and `cursor` query parameters. Omitting `page_size` MUST apply 25; valid explicit values MUST be integers from 1 through 100 inclusive; omitting `cursor` MUST start at the beginning of the ordered catalog.
- **FR-005**: List results MUST be ordered by display name ascending using the catalog's case-insensitive comparison semantics from TASK-005, with stable player identity ascending as the tie-breaker.
- **FR-006**: A cursor MUST be an opaque continuation issued by this endpoint and MUST identify the position immediately after the final player returned on its page according to FR-005. Clients MUST NOT need to parse or construct it.
- **FR-007**: For unchanged catalog data, following `next_cursor` values MUST return every persisted player exactly once, with no gaps, duplicates, or order changes. Replaying the same cursor with the same page size MUST return the same page.
- **FR-008**: Each list response MUST contain no more player representations than the applied page size. An empty catalog or a cursor positioned after the final player MUST return a successful empty page.
- **FR-009**: A successful list response MUST return HTTP status 200 with exactly two top-level fields: `data`, an ordered array of player representations, and `pagination`, an object containing exactly `page_size`, `returned_count`, `has_more`, and `next_cursor`.
- **FR-010**: `pagination.page_size` MUST equal the applied requested or default bound; `returned_count` MUST equal the number of items in `data`; `has_more` MUST be true exactly when at least one player follows the returned page; and `next_cursor` MUST be a non-empty opaque string exactly when `has_more` is true and null otherwise.
- **FR-011**: Invalid `page_size` input MUST return HTTP status 400 and `{"error":{"code":"invalid_page_size"}}`. Invalid cursor input MUST return HTTP status 400 and `{"error":{"code":"invalid_cursor"}}`. These responses MUST contain no catalog data or internal decoding detail.
- **FR-012**: The detail operation MUST select a player only by the stable internal player identity defined by TASK-005, not by display name, catalog identity, or an external-provider identifier.
- **FR-013**: A successful list item and successful detail result MUST use the same player representation with exactly these top-level fields: `id`, `display_name`, `catalog_identity`, `position`, `team`, `season`, and `league`.
- **FR-014**: The `position` object MUST contain exactly `id`, `code`, and `name`; the `team` object exactly `id`, `short_code`, and `name`; the `season` object exactly `id`, `start_year`, and `end_year`; and the `league` object exactly `id`, `code`, and `name`.
- **FR-015**: The returned league and season MUST be derived from the player's persisted team hierarchy, and the operations MUST NOT accept caller-supplied relationship values as substitutes.
- **FR-016**: The list operation MUST NOT filter, search, rank, or group players. Composable league, team, and position filtering belongs to TASK-012.
- **FR-017**: A successful detail response MUST return HTTP status 200 with a JSON object whose sole top-level field is `data`, containing one player representation.
- **FR-018**: A missing or malformed player identity MUST return HTTP status 404 and `{"error":{"code":"player_not_found"}}`, with no player data, internal error, or distinction between malformed and absent identities.
- **FR-019**: Authentication failures MUST retain the status, body, challenge, non-disclosure behavior, and protected-operation non-execution required by TASK-010.
- **FR-020**: Both endpoints MUST read exclusively from authoritative local persistence and MUST NOT invoke, wait for, fall back to, refresh from, or import through an external football provider, cache, or background job.
- **FR-021**: Responses MUST NOT expose persistence metadata, external-provider payloads or identifiers, authentication credentials, authenticated actor details, internal associations, cursor contents, or fields outside the representations required here.
- **FR-022**: Automated tests MUST cover authenticated list and detail success with both supported credential methods; default, minimum, maximum, and rejected page sizes; multi-page traversal; exact-boundary and empty pages; cursor replay, page-size changes, malformed and tampered cursors; deterministic ordering with duplicate and case-variant names; catalog changes around a cursor; absent and malformed identities; exact response shapes; hierarchy correctness; authentication precedence and non-disclosure; and zero provider interaction.
- **FR-023**: This feature MUST be limited to authenticated, locally persisted player list and detail reads with cursor pagination. Catalog mutation, filtering or search, provider access or ingestion, statistics, quotes, valuation, ranking, token inventory or trading, caching, user interfaces, and OpenAPI publication are outside scope.

### Key Entities

- **Player Catalog Representation**: The public read model for one locally persisted player, containing the player's stable and catalog identities, display name, and complete catalog context.
- **Player**: The season-specific footballer record defined by TASK-005, identified publicly by its stable internal identity for detail lookup and pagination tie-breaking.
- **Catalog Context**: The player's position and the team, season, and supported league reached through persisted catalog relationships.
- **Catalog Page**: A bounded ordered collection of player representations plus explicit continuation metadata.
- **Continuation Cursor**: An opaque marker for the ordered position after a returned page; it is meaningful only to this player-list operation and exposes no catalog or persistence detail.
- **Authenticated Actor**: The verified request identity supplied by TASK-010. It permits access to these protected reads but is not returned in catalog responses.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In automated traversal of unchanged catalogs larger than the maximum page size, 100% of locally persisted players appear exactly once and in documented order, and 100% of requested existing player identities return the correct player.
- **SC-002**: Across repeated reads of unchanged data, 100% of requests using the same cursor and page size return identical pages, including catalogs containing duplicate and case-variant display names.
- **SC-003**: In boundary tests, 100% of pages contain no more than their reported page size, all valid sizes from 1 through 100 are honored, and all out-of-range or malformed sizes are rejected without silent truncation or coercion.
- **SC-004**: For every page, the returned count equals the number of players, and `has_more` and `next_cursor` agree in 100% of first, middle, final, exact-boundary, after-final, and empty-catalog cases.
- **SC-005**: For every returned player, 100% of required player, position, team, season, and league fields match authoritative local catalog relationships, with zero contradictory hierarchy values.
- **SC-006**: With provider adapters configured to fail on invocation, 100% of list, continuation, existing-detail, missing-detail, and empty-catalog requests complete with expected outcomes and zero provider calls.
- **SC-007**: In automated verification, 0% of unauthenticated requests validate pagination or execute a catalog read, and 100% use the shared unauthenticated response.
- **SC-008**: Under normal local operating conditions with 100,000 persisted players, at least 95% of first-page, continuation-page, and detail requests complete within two seconds.
- **SC-009**: Contract inspection finds zero persistence metadata, provider data, credentials, actor details, cursor contents, statistics, quotes, valuations, token data, or undocumented fields in successful or error responses.

## Assumptions

- TASK-005 supplies locally persisted players and their complete position, team, season, and league relationships; TASK-010 supplies the shared protected-route policy and authenticated actor context.
- A default page size of 25 balances ordinary client usefulness with bounded responses; 100 is the maximum accepted page size for this initial catalog contract.
- Cursor traversal guarantees stability while ordering-relevant catalog data is unchanged. It does not create a historical snapshot across concurrent catalog mutations; the cursor resumes strictly after its recorded ordering position.
- Stable internal identities and continuation cursors are opaque to clients. Clients may retain and submit them but must not infer meaning from their format.
- The catalog data already satisfies TASK-005 integrity constraints. This read feature reports stored authoritative relationships and does not repair invalid records.
- Formal OpenAPI publication belongs to TASK-013 and must document, rather than redefine, the routes and response contract established here.

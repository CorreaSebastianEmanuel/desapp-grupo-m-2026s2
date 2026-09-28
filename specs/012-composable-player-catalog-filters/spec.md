# Feature Specification: Composable Player Catalog Filters

**Feature Branch**: `012-composable-player-catalog-filters`

**Created**: 2026-09-28

**Status**: Draft

**Input**: TASK-012: "Filter the catalog by league, team, and position individually and in combination."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Narrow Players by One Attribute (Priority: P1)

As an authenticated market user, I can narrow the player list to one league, team, or position so that I see relevant players.

**Why this priority**: Each filter is useful on its own and supports basic catalog discovery.

**Independent Test**: Populate players across several leagues, seasons, teams, and positions; apply each filter separately and compare results with stored relationships.

**Acceptance Scenarios**:

1. **Given** players in several leagues, **When** I request `GET /api/players?league_id=<id>`, **Then** every returned player's team belongs to a season of that league, and no player from another league appears.
2. **Given** teams with the same name or short code in different seasons, **When** I filter by one `team_id`, **Then** only players on that exact team record appear.
3. **Given** players in several positions, **When** I filter by one `position_id`, **Then** only players in that position appear.
4. **Given** a well-formed filter ID with no matching player, **When** I request the list, **Then** I receive a successful empty page.

---

### User Story 2 - Combine Catalog Filters (Priority: P2)

As an authenticated market user, I can combine league, team, and position filters so that I see players satisfying every selected criterion.

**Why this priority**: Combined filters provide the precise discovery requested by TASK-012.

**Independent Test**: Populate overlapping and disjoint player groups; request each two-filter pairing and all three filters; compare each result with the intersection of its single-filter results.

**Acceptance Scenarios**:

1. **Given** players across leagues, teams, and positions, **When** I supply any two or all three filter IDs, **Then** every result satisfies every supplied filter and every qualifying player appears during a complete traversal.
2. **Given** a team belonging to a different league than the requested `league_id`, **When** I submit both IDs, **Then** I receive a successful empty page.
3. **Given** the same filters in a different query-parameter order, **When** I request the list, **Then** the resulting sequence and pagination behavior are the same.

---

### User Story 3 - Traverse Filtered Pages (Priority: P3)

As an authenticated market user, I can follow filtered pages so that I can reach every match without losing my selections.

**Why this priority**: Filtering must work with the existing bounded catalog list.

**Independent Test**: Store more matches than the maximum page size, traverse with several filter sets and page sizes, and verify that changing a filter while reusing a cursor is rejected.

**Acceptance Scenarios**:

1. **Given** more matches than fit on one page, **When** I follow `next_cursor` with the same filters, **Then** every match appears exactly once in TASK-011 order, no nonmatch appears, and page bounds hold.
2. **Given** a cursor issued for a filtered page, **When** I change or remove a filter while reusing it, **Then** I receive the existing invalid-cursor response and no player data.
3. **Given** a cursor issued for an unfiltered page, **When** I add a filter, **Then** I receive the invalid-cursor response; using it without filters remains valid.
4. **Given** the same filters and cursor, **When** I change only `page_size`, **Then** continuation remains valid from the same ordered position.

### Edge Cases

- An omitted filter imposes no restriction. A blank, malformed, structured, or repeated filter value is rejected, even when repeated values are identical.
- A well-formed but unknown ID and mutually inconsistent valid IDs return a successful empty page; they do not reveal which relationship is absent.
- A team filter selects one season-specific team record, excluding other teams with the same name or short code.
- Equivalent valid UUID letter case identifies the same record and effective cursor filter set. Surrounding whitespace is invalid.
- Filtering precedes pagination, so nonmatching players do not shorten a page of available matches.
- The exact final matching page has no continuation. A cursor after the last match returns a successful empty page.
- A cursor is not a historical snapshot. Catalog membership or ordering changes between requests retain TASK-011's cursor semantics.
- Authentication failure precedes all query validation. For several invalid authenticated inputs, error priority is `page_size`, `league_id`, `team_id`, `position_id`, then `cursor`.
- Unsupported query parameters remain ignored and cannot affect results.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The protected TASK-011 `GET /api/players` operation MUST accept optional `league_id`, `team_id`, and `position_id` query parameters, singly or in any combination. Omitting all filters MUST preserve unfiltered behavior.
- **FR-002**: Each filter MUST use the corresponding stable internal ID shown in the TASK-011 player representation. `league_id` MUST match the league reached through the player's team and season; `team_id` MUST match the exact team record; `position_id` MUST match the player's position.
- **FR-003**: Filters MUST combine with logical AND. Query-parameter order MUST NOT affect result membership or sequence.
- **FR-004**: Each filter MUST occur at most once and contain one well-formed UUID without surrounding whitespace. Blank, malformed, structured, or repeated values MUST return HTTP 400 with exactly `{"error":{"code":"invalid_league_id"}}`, `{"error":{"code":"invalid_team_id"}}`, or `{"error":{"code":"invalid_position_id"}}`, as applicable. Equivalent valid UUID letter case MUST identify the same record.
- **FR-005**: A well-formed ID with no matching local record, a valid combination with no player, or conflicting valid IDs MUST return HTTP 200 with empty `data` and TASK-011 empty-page pagination metadata, without disclosing which relationship is absent.
- **FR-006**: Filtering MUST occur before TASK-011 ordering, page bounding, and continuation. Each returned player MUST satisfy all filters, and nonmatching players MUST NOT consume page capacity.
- **FR-007**: Filtered results MUST retain TASK-011's case-insensitive display-name order with stable ID tie-breaker, page-size bounds and defaults, response and player shapes, pagination metadata, and exact-final-page behavior.
- **FR-008**: A filtered `next_cursor` MUST continue only with the same effective filter names and IDs, regardless of query-parameter order or valid UUID letter case. Changing, adding, or removing a filter MUST return HTTP 400 with exactly `{"error":{"code":"invalid_cursor"}}` and no player data. Changing only `page_size` MUST remain valid.
- **FR-009**: Existing unfiltered TASK-011 cursors MUST remain usable on unfiltered requests and MUST be rejected with `invalid_cursor` if any filter is supplied. A filtered cursor MUST be rejected on an unfiltered request.
- **FR-010**: With unchanged catalog data, following filtered cursors MUST return every matching player exactly once in order, without nonmatches; replay with the same filters and page size MUST return the same page. Catalog changes retain TASK-011's non-snapshot behavior.
- **FR-011**: TASK-010 authentication MUST complete before filter, page-size, or cursor validation or catalog reads. Authentication failures MUST retain the shared status, body, challenge, and non-disclosure behavior.
- **FR-012**: For authenticated requests with several invalid inputs, public error priority MUST be `page_size`, `league_id`, `team_id`, `position_id`, then `cursor`. Other page-size and cursor errors MUST retain TASK-011's contract.
- **FR-013**: Filtered reads MUST use authoritative local catalog data only and MUST NOT call, wait for, refresh from, or import through providers, caches, or jobs. Provider unavailability MUST NOT alter results.
- **FR-014**: Filtered responses MUST NOT expose new player fields, cursor contents, persistence metadata, provider details, credentials, or actor details. Unknown query parameters MUST remain ignored without affecting results.
- **FR-015**: Automated tests MUST cover each single filter, each pair and all three together, all five leagues, same-named teams across seasons, unknown and conflicting IDs, invalid and repeated inputs, authentication and error priority, exact page boundaries and empty pages, cursor replay and mismatch, page-size changes, preserved unfiltered cursors, ordering ties, response shapes, and zero provider interaction.
- **FR-016**: Scope MUST be limited to filtering the existing protected player list. Player detail behavior, catalog mutation, season filtering, text search, ranking, statistics, quotes, trading, caching, user interface, and OpenAPI publication are outside scope.

### Key Entities

- **Player**: A season-specific catalog record with one team and position; its league follows through its team's season.
- **League, Team, and Position**: Local catalog classifications with stable internal IDs; a team ID selects one season-specific record.
- **Filter Set**: Zero to three selected IDs whose intersection determines list membership.
- **Filtered Catalog Page**: A bounded TASK-011 list response containing only players in the filter set.
- **Continuation Cursor**: An opaque TASK-011 page marker bound to its effective filter set.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In representative data spanning all five leagues, at least two seasons, multiple teams, and every configured position, 100% of single, paired, and three-filter requests return exactly the qualifying players.
- **SC-002**: With more than 100 matching players and unchanged data, 100% of complete filtered traversals return every match once in TASK-011 order, with zero nonmatches and no page larger than its requested size.
- **SC-003**: In boundary tests, 100% of unknown or conflicting valid IDs yield a successful empty result, while 100% of blank, malformed, structured, or repeated IDs yield the specified error and no player data.
- **SC-004**: In cursor tests, 100% of continuations with unchanged effective filters succeed, including page-size changes, and 100% with changed filters are rejected. Previously issued unfiltered cursors remain usable without filters.
- **SC-005**: During automated verification, 0% of unauthenticated requests validate filters or read catalog data, and provider adapters receive zero calls during filtered requests.
- **SC-006**: With 100,000 locally stored players, at least 95% of first-page and continuation-page filtered requests complete within two seconds under normal local operating conditions.
- **SC-007**: A user can narrow a populated catalog by any one, any two, or all three dimensions and reach every expected match through returned pages without encountering unrelated players or interpreting cursors.

## Assumptions

- TASK-011 supplies the protected list and cursor contract; TASK-005 supplies stable catalog identities and the team-to-season-to-league relationship.
- Filter IDs already appear in player representations. Team names and short codes are not unique across league seasons and are not filter identities.
- Users change filters by starting a new request without a cursor. The filter set stays fixed during one cursor traversal.
- No historical snapshot is promised across catalog changes; TASK-011's existing cursor behavior continues.
- TASK-013 will publish the expanded list contract without redefining it.

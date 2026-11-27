# Feature Specification: Football Catalog Domain Model

**Feature Branch**: `005-football-catalog-domain-model`

**Created**: 2026-09-17

**Status**: Draft

**Input**: User description: "TASK-005 Football catalog domain model — Persist leagues, seasons, teams, player positions, and players with constraints and indexes."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Maintain a Valid Catalog Hierarchy (Priority: P1)

As a catalog maintainer, I can store the supported leagues and their season-specific teams so that every player belongs to one coherent football competition snapshot.

**Why this priority**: A valid league, season, and team hierarchy is the foundation for all player catalog reads and later imports.

**Independent Test**: Create each supported league, add a season to one league, add a team to that season, and verify that the complete hierarchy can be retrieved while invalid or duplicate records are rejected.

**Acceptance Scenarios**:

1. **Given** an empty catalog, **When** the five supported leagues are recorded with distinct codes and names, **Then** all five can be retrieved unambiguously.
2. **Given** a supported league, **When** a season with valid start and end years is recorded for it, **Then** the season is associated with that league and can be found by league and season label.
3. **Given** a league season, **When** a team with a non-blank name and short code is recorded, **Then** the team is associated with exactly that league season.
4. **Given** an existing league, season, or team identity in the same uniqueness scope, **When** another record is submitted with that identity, **Then** the duplicate is rejected and the existing catalog remains unchanged.

---

### User Story 2 - Maintain Valid Players and Positions (Priority: P2)

As a catalog maintainer, I can store players with a team and a recognized playing position so that downstream catalog consumers receive complete, classifiable player records.

**Why this priority**: Players are the market's core subject, but they can only be trusted after the hierarchy they reference exists.

**Independent Test**: Record a recognized position and a player linked to an existing team, then retrieve the player with the expected league, season, team, and position; attempt each missing or invalid relationship and verify rejection.

**Acceptance Scenarios**:

1. **Given** a recognized player-position code and an existing team, **When** a player with a non-blank display name is recorded, **Then** the player can be retrieved with that position and the team's league season.
2. **Given** an existing player identity in the same league season, **When** another player is submitted with that identity, **Then** the duplicate is rejected and the original player remains unchanged.
3. **Given** a missing team or player position, **When** a player referencing it is submitted, **Then** the player is rejected without creating a partial catalog record.
4. **Given** a team, position, or league season that still has players, **When** deletion would orphan those players, **Then** the deletion is rejected.

---

### User Story 3 - Retrieve Catalog Records by Business Lookup (Priority: P3)

As a downstream catalog capability, I can efficiently locate players by league, team, position, and season so that later list, detail, filtering, and ingestion features have a dependable local source.

**Why this priority**: The CP1 player catalog depends on predictable local lookups, while the query interfaces themselves belong to later tasks.

**Independent Test**: Populate representative records across all five leagues, multiple teams, positions, and seasons, and verify that each supported lookup returns only matching records with stable results.

**Acceptance Scenarios**:

1. **Given** players across multiple leagues, **When** players are located by league, **Then** only players whose teams belong to a season of that league are returned.
2. **Given** players across multiple teams and positions, **When** players are located by team or position, **Then** only records with the requested relationship are returned.
3. **Given** the same league in multiple seasons, **When** teams or players are located for one season, **Then** records from other seasons are excluded.
4. **Given** a known catalog record identity, **When** it is looked up directly, **Then** at most one matching record is returned.

### Edge Cases

- League names, team names, position names, and player display names containing only whitespace are rejected; surrounding whitespace does not create a distinct identity.
- League, team, and position codes are compared without case differences, so case variants cannot bypass uniqueness rules.
- A season whose end year is earlier than its start year, or whose span is greater than one year, is rejected.
- The same team code or name may appear in different league seasons, but not twice within one league season.
- The same player identity may appear in different seasons, allowing a season-specific catalog snapshot, but not twice within one league season.
- A parent record cannot be removed while dependent catalog records exist; rejection must leave all records intact.
- A failed multi-record catalog operation must not leave a partially created hierarchy.
- Attempts to record a league outside the five supported competitions are rejected.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The catalog MUST persist leagues, seasons, teams, player positions, and players as distinct records with stable internal identities.
- **FR-002**: The catalog MUST accept exactly these supported leagues: Premier League, Bundesliga, La Liga, Serie A, and Ligue 1.
- **FR-003**: Each league MUST have a non-blank canonical name and a non-blank stable code; league names and codes MUST each be unique without regard to letter case or surrounding whitespace.
- **FR-004**: Each season MUST belong to exactly one league and MUST have a start year and end year where the end year equals the start year or the start year plus one.
- **FR-005**: A season's start-year/end-year pair MUST be unique within its league.
- **FR-006**: Each team MUST belong to exactly one season, and its league MUST be derived from that season rather than independently assigned.
- **FR-007**: Each team MUST have a non-blank canonical name and a non-blank stable short code; team names and short codes MUST each be unique within a season without regard to letter case or surrounding whitespace.
- **FR-008**: Each player position MUST have a non-blank canonical name and a non-blank stable code; position names and codes MUST each be globally unique without regard to letter case or surrounding whitespace.
- **FR-009**: Each player MUST belong to exactly one team and exactly one player position and MUST have a non-blank display name.
- **FR-010**: Each player MUST have a non-blank catalog identity that is unique within the league season derived from the player's team, without regard to letter case or surrounding whitespace.
- **FR-011**: The catalog MUST reject any record that references a league, season, team, or position that does not exist.
- **FR-012**: The catalog MUST prevent deletion of any league, season, team, or position while dependent catalog records exist.
- **FR-013**: Any operation that creates or changes multiple related catalog records MUST either preserve all stated relationships and constraints or leave the catalog unchanged.
- **FR-014**: The catalog MUST support deterministic direct lookup by each entity's stable identity and business identity.
- **FR-015**: The catalog MUST support player lookup by league, season, team, and position, individually and in combination, without inspecting external-provider data.
- **FR-016**: The catalog MUST preserve enough relationship information for a player result to identify its position, team, season, and league without duplicating independently editable hierarchy values on the player.
- **FR-017**: Constraint violations MUST be reported as domain-validity failures that identify the rejected field or relationship; they MUST NOT silently replace an existing record.
- **FR-018**: Automated tests MUST cover valid persistence, each required relationship, each uniqueness boundary, invalid season ranges, unsupported leagues, parent-deletion protection, atomic failure, and the lookup paths in FR-014 and FR-015.
- **FR-019**: This task MUST be limited to the football catalog domain model and its persistence behavior. Seed data, external-provider identifiers and payloads, ingestion/reconciliation, HTTP endpoints, authentication, statistics, valuation, token supply, trading, caching, and user-interface behavior are outside scope.
- **FR-020**: The local delivery gate MUST resolve task-declared repository-relative artifact globs to existing in-repository files, reject unmatched or escaping paths, and allow this task's timestamped migration artifact to be verified without hanging the workflow. This is delivery tooling only and MUST NOT expand product behavior.

### Key Entities

- **League**: One of the five supported top-level competitions, identified by a canonical name and stable code; it owns seasons.
- **Season**: A league-specific competition period identified by start and end years; it owns the teams participating in that league snapshot.
- **Team**: A club entry within one league season, identified there by canonical name and short code; it owns the players in that season snapshot.
- **Player Position**: A reusable football role classification with a canonical name and stable code.
- **Player**: A season-specific footballer catalog entry with a display name and catalog identity, belonging to one team and one position; its season and league follow from its team.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Automated verification accepts 100% of valid examples covering all five supported leagues and rejects 100% of examples for unsupported leagues, missing relationships, invalid season ranges, and blank required values.
- **SC-002**: For every defined uniqueness boundary, 100% of exact, case-only, and surrounding-whitespace duplicate attempts are rejected without altering the original record.
- **SC-003**: In representative data spanning all five leagues, at least two seasons, multiple teams, and all configured positions, 100% of league, season, team, position, and combined player lookups return exactly the expected records.
- **SC-004**: In 100% of tested parent-deletion and failed multi-record scenarios, no dependent record is orphaned and no partial catalog change remains.
- **SC-005**: Every persisted player in a catalog integrity audit resolves to exactly one team, one season, one supported league, and one player position, with zero broken or contradictory relationships.
- **SC-006**: Downstream catalog, filtering, seed-data, and ingestion planning can identify all required catalog entities, ownership relationships, identity rules, and lookup dimensions without introducing a new core entity or changing an existing relationship.
- **SC-007**: With a representative catalog of 100,000 players distributed across the supported leagues, `EXPLAIN` evidence confirms that direct and combined league, season, team, and position lookups have index-capable plans; reproducible percentile latency certification remains assigned to TASK-043.

## Assumptions

- TASK-002 provides the operational local persistence environment required by this dependent task.
- The catalog represents season-specific snapshots. A club and footballer may therefore have separate team/player records in different seasons, while duplicates within one league season are prohibited.
- A same-year season is valid for competitions represented within one calendar year; a cross-year season may span only consecutive years.
- The player catalog identity is provider-neutral and distinct from any future external-provider identifier. Its concrete format and generation are reversible planning decisions, provided its uniqueness behavior is preserved.
- Player positions are catalog data rather than a closed set fixed by this specification; seed content and the chosen position taxonomy belong to TASK-006 or later product input.
- Names are preserved for display after surrounding whitespace is removed; case-insensitive comparison applies only to validation and lookup identity.
- Physical deletion is acceptable only for records without dependents. Historical preservation requirements for quotes, financial activity, and audit records apply when those later features exist and are not expanded here.
- Performance targets and concrete index definitions are planning concerns; this specification defines the business lookup paths that those indexes must support.

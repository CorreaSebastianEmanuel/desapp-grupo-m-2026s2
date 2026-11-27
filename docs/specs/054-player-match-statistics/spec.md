# Feature Specification: Player Match Statistics Model

**Feature Branch**: `020-player-match-statistics-model`

**Created**: 2026-10-03

**Status**: Draft

**Input**: User description: "TASK-020 — Persist normalized per-player match statistics needed by valuation strategies. Checkpoint CP2; depends on TASK-005."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Store Match Performance (Priority: P1)

As a valuation consumer, I need locally stored, consistently defined player performances so future strategies can evaluate football facts without interpreting provider payloads.

**Why this priority**: Persisted performance inputs are a prerequisite for CP2 valuation.

**Independent Test**: Record a completed match and two player performances, then independently read every stored value and relationship.

**Acceptance Scenarios**:

1. **Given** two distinct teams in one catalog season, **When** a completed match is recorded with its competition-scoped identity and actual kickoff instant, **Then** it can be retrieved with the same identity, season, home/away participants and instant.
2. **Given** that match and players from its season, **When** performances with valid metrics, participating teams and recognized positions are recorded, **Then** each player has one independently retrievable performance retaining every submitted fact.
3. **Given** one omitted optional metric and another explicitly zero metric, **When** the performance is stored and read, **Then** the omitted value remains unknown and zero remains a known zero.
4. **Given** minutes of 0, 90 or 123 and non-negative whole-number counts, **When** otherwise valid performances in different matches are recorded, **Then** all are accepted without a fixed 90- or 120-minute ceiling.

---

### User Story 2 - Protect Historical Input Integrity (Priority: P1)

As a market maintainer, I need invalid and duplicate facts rejected so that matches are not counted twice and stored valuation inputs remain dependable.

**Why this priority**: Invalid references and overwritten facts threaten comparable and reproducible valuations.

**Independent Test**: Submit duplicate identities, invalid values/references and attempted changes/deletions; verify rejection and unchanged prior facts.

**Acceptance Scenarios**:

1. **Given** a stored player-match performance, **When** an identical or conflicting performance for that pair is submitted again, including concurrently, **Then** it is rejected and exactly one unchanged performance remains.
2. **Given** a match identity within a season, **When** another match uses that identity with different case or surrounding whitespace, **Then** it is rejected; the same identity in another season is allowed.
3. **Given** a missing reference, cross-season participants, identical home/away teams, a performance team outside the match, a player from another season or an unknown position, **When** the affected record is submitted, **Then** it is rejected with the invalid field/relationship identified and no partial record stored.
4. **Given** missing minutes, a negative, fractional, nonnumeric or boolean metric, an unsupported metric name or an invalid kickoff instant, **When** facts are submitted, **Then** they are rejected without changing prior records.
5. **Given** accepted facts, **When** their metrics, historical relationships or match identity/instant/participants are changed or deleted, **Then** the operation is rejected and original facts remain retrievable.
6. **Given** referenced catalog records, **When** deletion would orphan matches or performances, **Then** deletion is rejected without removing historical facts or their references.
7. **Given** a multi-record submission with an invalid fact, **When** it is processed, **Then** none of that submission's facts are stored.

---

### User Story 3 - Read Dated Performance History (Priority: P2)

As a valuation consumer, I need deterministic local history retaining event-time affiliation so later strategies can select inputs even when a provider is unavailable.

**Why this priority**: Strategies need stable dated inputs; scoring and normalization windows belong to TASK-022.

**Independent Test**: Populate histories across players and seasons, query date bounds, change current affiliation, and retrieve the original facts again.

**Acceptance Scenarios**:

1. **Given** performances across players and seasons, **When** one player's history is requested, **Then** only that exact catalog player's performances are returned in kickoff-instant ascending order, with normalized match identity ascending for ties.
2. **Given** facts before, at and after supplied bounds, **When** an inclusive kickoff interval is requested, **Then** only facts within both bounds are returned; either bound may be omitted and a lower bound later than the upper bound is rejected.
3. **Given** a known player without performances, **When** its history is requested, **Then** an empty history is returned; unknown subjects yield explicit not-found results, while a known player and match without a performance yield an explicit absent-performance result.
4. **Given** a performance for team A and position P, **When** current affiliation changes to team B in the same season or current position changes, **Then** the original performance retains team A and position P, and a valid subsequent performance for team B is allowed.
5. **Given** local facts and an unavailable provider, **When** histories are repeatedly read, **Then** identical facts and ordering are returned without provider access.

### Edge Cases

- An absent performance differs from a recorded zero-minute performance. No missing performance or metric is automatically manufactured.
- Zero reported minutes can coexist with positive counts because minute reporting can be rounded.
- Extra time and stoppage time have no arbitrary duration ceiling; individual minutes do not define whole-match duration.
- Multiple matches on the same day are valid. Dates and display names do not establish identity.
- Event-time affiliation may differ from current affiliation but must satisfy match participation and season consistency.
- Separate season-specific catalog entries for the same footballer retain separate histories.
- A match with no performances is valid and implies no player statistics.
- Malformed identifiers, blank match identities and invalid interval bounds produce validation failures.
- Equivalent instants expressed with different time-zone offsets have identical chronological and interval behavior.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST persist provider-neutral completed matches and player-match performances as distinct records with stable internal identities, independently of provider availability.
- **FR-002**: Each match MUST have a non-blank provider-neutral identity, an unambiguous actual kickoff instant, one existing season and distinct existing home/away teams from that season. Match identity MUST be unique within its season ignoring case and surrounding whitespace; it MUST NOT be inferred solely from date or participants.
- **FR-003**: Each performance MUST reference one existing match, one existing player, one event-time team participating in the match and one existing event-time position. Player and match seasons MUST agree. Current team/position MUST NOT substitute for or constrain otherwise valid event-time affiliation.
- **FR-004**: At most one performance MUST exist per player-match pair. Duplicate match/performance submissions, including concurrent and identical submissions, MUST be rejected without replacing prior facts. Import-level retry handling belongs to TASK-021.
- **FR-005**: Minutes played MUST be known and expressed as a non-negative whole number of minutes without a fixed 90- or 120-minute ceiling.
- **FR-006**: Optional metrics MUST be goals, assists, shots on target, tackles, interceptions, saves, goals conceded, yellow cards and red cards. Known values MUST be non-negative whole-number counts attributed to the player in that match. Goals conceded means opposition goals conceded by the player's team while that player was on the field; saves means goalkeeper saves; tackles means successful tackles; interceptions means intercepted opposition passes. Other counts use their standard football meanings. Stored facts MUST NOT contain weights, scores, monetary values, provider ratings or valuation aggregates.
- **FR-007**: Omitted or explicitly unknown optional metrics MUST remain unknown through persistence and reads, distinct from zero. Negative, fractional, nonnumeric or boolean metrics, unsupported metric names and missing required values MUST be rejected. Absence alone MUST NOT imply a performance or metric.
- **FR-008**: Accepted match/performance facts MUST be immutable in this task: updates, replacement and deletion MUST be rejected. Referenced catalog records MUST be protected against deletions that would orphan facts. Current team/position reassignment remains allowed under TASK-005 and ADR-0002 without altering history. Any later correction design MUST preserve prior valuation inputs.
- **FR-009**: Multi-record match/performance operations MUST accept all valid submitted facts atomically or leave existing facts unchanged on failure. Validation/conflict failures MUST identify the affected field or relationship without exposing provider payloads or persistence internals.
- **FR-010**: Local reads MUST support matches by internal identity or season-scoped match identity, performances by player-match pair and histories by exact catalog player identity with optional inclusive kickoff bounds. Invalid identifiers/bounds MUST yield validation failures. Unknown subjects MUST yield not-found results. Known players without performances MUST yield empty histories; known player-match pairs without a performance MUST yield absent-performance results.
- **FR-011**: Histories MUST preserve stored metrics, unknown values and event-time relationships, exclude other players/seasons, and order by kickoff instant ascending then normalized season-scoped match identity ascending. Equivalent time-zone representations MUST compare as the same instant. Reads MUST NOT call providers or reconstruct history from mutable affiliation.
- **FR-012**: Automated behavioral tests MUST cover every acceptance scenario and every metric's valid/invalid/unknown boundaries, concurrent duplicates, historical affiliation changes, atomic failure, deletion protection, read isolation, ordering and interval boundaries with deterministic local facts.
- **FR-013**: Scope MUST remain match/performance identity, metric semantics, persistence integrity and local reads. Provider adapters/identifiers/provenance/raw fixtures, ingestion scheduling/retries/reconciliation, correction workflows, seed commands, endpoints, authentication changes, scoring formulas, normalization windows, position groups, quotes, trading, ranking, caching and user interfaces are excluded. TASK-021 owns ingestion/provenance; TASK-022 owns scoring inputs/normalization policy; TASK-023/TASK-024 own strategy weighting.

### Key Entities

- **Match**: A completed football event with local and season-scoped identity, actual kickoff instant and home/away participants.
- **Player Match Performance**: One catalog player's recorded participation in one match, preserving event-time team/position, known minutes and optional counts.
- **Catalog References**: Existing seasons, teams, players and positions from TASK-005; current affiliation is not historical evidence.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Deterministic examples covering all five leagues and two seasons retain 100% of accepted identities, metrics, unknown values and relationships after independent local reads.
- **SC-002**: Every specified invalid-value, reference and duplicate case, including concurrency, is rejected with zero partial changes, duplicate performances or orphaned facts.
- **SC-003**: All tested player/interval lookups, including exact bounds and tied instants, return 100% of expected membership and ordering; repeated reads remain identical during provider unavailability.
- **SC-004**: All tested current-affiliation changes and attempted historical changes/deletions preserve 100% of prior event-time facts.
- **SC-005**: A valuation consumer can identify date, player, historical role/team, known metrics and unavailable metrics solely from local facts, without provider interpretation or invented missing values.

## Assumptions

- TASK-005 provides catalog relationships and season-scoped player identities. ADR-0002 governs mutable current affiliation and separate historical team context.
- Actors are trusted internal consumers; this task creates no public/admin role, permission or route.
- The bounded metric set is a baseline of common general and position-aware counting inputs, not a scoring formula. Unknown counts accommodate differing source coverage; adding metrics requires a specified extension.
- Only completed matches are accepted. Ingestion establishes finality; scheduled, live, postponed and abandoned event lifecycles are excluded.
- The kickoff instant is supplied by the caller, not derived from import time. Catalog seasons use year labels; no additional inferred kickoff-date boundaries are imposed.
- Provider translation, identity reconciliation, competing-source selection and correction policy belong to later ingestion design. This task conservatively rejects conflicts rather than silently overwriting inputs potentially used by historical quotes.
- Performance benchmarks, handling incomplete scoring inputs and cross-season aggregation require later specifications; this task introduces no arbitrary latency target or missing-value scoring rule.

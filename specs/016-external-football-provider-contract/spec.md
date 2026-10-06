# Feature Specification: External Football Provider Contract

**Feature Branch**: `016-external-football-provider-contract`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "TASK-016 — Define provider-neutral domain inputs, outputs, errors, timeouts, and test fixtures. Checkpoint CP2; depends on TASK-005."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Obtain Comparable Catalog Facts (Priority: P1)

As a catalog ingestion consumer, I can request a supported league season using football concepts and receive consistently defined records, so replacing the source does not change catalog rules.

**Why this priority**: TASK-018 needs a dependable boundary before importing catalog data.

**Independent Test**: Request equivalent synthetic catalogs from two fixture providers with different source identifiers and field names; compare football facts and validate every relationship without saving records.

**Acceptance Scenarios**:

1. **Given** either fixture provider and a supported league season, **When** its catalog is requested, **Then** both return equivalent normalized league, season, team, position and player facts; source information appears only in separate provenance.
2. **Given** a valid season without published entries, **When** its catalog is requested, **Then** a successful empty collection retains the requested context, distinguishable from an unknown season or unsupported capability.
3. **Given** an unsupported league, invalid season, malformed request or invalid timeout, **When** a request is submitted, **Then** invalid-request identifies the affected input and no provider work starts.
4. **Given** incomplete, contradictory or duplicate catalog records, **When** the response is evaluated, **Then** the whole request fails as invalid-response without partial success.

---

### User Story 2 - Obtain Dated Performance Inputs (Priority: P1)

As a statistics ingestion consumer, I can obtain completed matches and player performances with consistent meanings, so valuation preserves what the source actually knows.

**Why this priority**: CP2 valuation requires dated football facts rather than source-specific ratings or invented missing values.

**Independent Test**: Request fixture performances with date bounds, unknown and zero metrics, and historical affiliation differing from current affiliation; verify the normalized result without persistence or scoring.

**Acceptance Scenarios**:

1. **Given** completed matches before, at and after requested inclusive kickoff bounds, **When** performances are requested, **Then** only matches within the bounds and their supplied performances are returned; equivalent instants with different time-zone offsets compare equally.
2. **Given** known minutes, a zero optional count and an unavailable optional count, **When** facts are returned, **Then** zero remains zero and the unavailable count remains unknown; an absent performance is not manufactured.
3. **Given** a player currently on team B who played a historical match for team A, **When** that performance is returned, **Then** its event-time team and position are retained independently of current affiliation.
4. **Given** a source without player-performance capability, **When** performances are requested, **Then** unsupported-capability is returned; team totals, ratings or fabricated empty performances cannot substitute.
5. **Given** invalid metrics, unresolved references, duplicates or missing required facts, **When** the response is evaluated, **Then** invalid-response is returned without changing or inventing facts.

---

### User Story 3 - Handle Failure Within a Bounded Wait (Priority: P1)

As an ingestion operator, I can distinguish source failure from missing data and receive a bounded result, while market users continue reading their local catalog.

**Why this priority**: External failure must not corrupt imports or interrupt local reads.

**Independent Test**: Use controlled fixtures for every error and deadline boundary; compare local reads before and after failures.

**Acceptance Scenarios**:

1. **Given** authentication refusal, rate limiting, temporary unavailability, missing scope or unsupported capability, **When** the request ends, **Then** its normalized category and retry guidance are returned without secrets, raw payloads or transport details.
2. **Given** an omitted timeout, **When** no fully validated outcome is ready before 5,000 milliseconds elapse, **Then** timeout is returned and no later result becomes visible.
3. **Given** a configured positive whole-number timeout, **When** a result is ready just before, exactly at or after the deadline, **Then** only the result ready before the deadline succeeds; the others time out.
4. **Given** a logical response delivered in several source portions, **When** a later portion fails or the shared deadline expires, **Then** earlier portions are not exposed as success and no portion receives a fresh budget.
5. **Given** existing local catalog data, **When** any provider request fails and the catalog is read, **Then** prior records remain unchanged and reads perform no provider request.

---

### User Story 4 - Verify Replacement Sources Offline (Priority: P2)

As a maintainer, I can run the same deterministic acceptance examples against every provider implementation without a live service or subscription.

**Why this priority**: Offline evidence enables later adapters to prove compatibility with one contract.

**Independent Test**: Run the fixture collection twice using controlled time; compare normalized outcomes and confirm no external requests or credentials are required.

**Acceptance Scenarios**:

1. **Given** the fixture collection, **When** examples are repeated offline, **Then** outcomes are identical and every acceptance scenario has an explicit expected result.
2. **Given** two synthetic sources with different identifiers, field names and ordering for equivalent facts, **When** shared contract checks run, **Then** both satisfy the same rules without source-specific consumer branches.
3. **Given** a fixture, **When** its expected result is inspected, **Then** a stable fixture identifier links the source example, expected normalized facts or error, and acceptance rule exercised.

### Edge Cases

- Empty results, unknown scopes, unavailable optional counts and unsupported operations are distinct outcomes.
- Same-name footballers are not merged; matching source identifiers across providers, entity kinds or seasons are not interchangeable.
- Source identifiers do not establish local catalog identity; result references do not promise persistent identity.
- Unmapped required positions fail rather than receive guessed roles.
- Either kickoff bound may be omitted; a lower bound after the upper bound is invalid.
- Zero minutes, positive counts with zero rounded minutes, and minutes above 120 are valid; negative, fractional, boolean and nonnumeric counts are invalid.
- Completed matches without performances are valid. Scheduled, live, postponed and abandoned matches are excluded from successful performance results.
- Identical and conflicting duplicate records are invalid; no silent deduplication or last-record-wins behavior is allowed.
- Pagination, source delays and normalization share one deadline. Late work cannot publish results or change local state.
- Unknown optional counts do not permit missing minutes, relationships or kickoff facts. One malformed record fails the whole request.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The contract MUST define two read-only operations: obtain a catalog for one league season, and obtain completed matches with supplied player performances for one league season and optional kickoff bounds. Callers MUST use the same inputs, normalized outputs and errors for every provider. Provider selection is internal configuration, not a football fact.
- **FR-002**: Requests MUST identify a TASK-005 league by canonical code (`PL`, `BL1`, `PD`, `SA`, `FL1`) and a season by whole-number start/end years, excluding booleans, with end equal to start or start plus one. Whitespace and code case MUST normalize to the canonical code. Performance bounds MUST be unambiguous instants, inclusive, independently optional and ordered when both are supplied. Catalog requests MUST reject performance bounds. Missing required inputs, unknown input fields, invalid values and unsupported league codes MUST produce invalid-request before provider work begins.
- **FR-003**: Each request MUST end in exactly one complete success or one normalized error. Success MUST identify its operation, normalized requested scope and provenance, and contain fully validated facts. A valid empty collection MUST succeed; an unknown requested league season MUST yield not-found. Failure MUST contain no success records. Source pagination is internal: all portions needed to answer the request MUST complete within its single deadline, or the request MUST fail without partial results. Collections are unordered; comparisons MUST evaluate membership and relationships rather than source ordering.
- **FR-004**: Catalog success MUST contain the requested canonical league/season and collections of teams, positions and players. Teams MUST have non-blank names and short codes; positions MUST have non-blank canonical names and codes from the configured vocabulary; players MUST have non-blank display names and one referenced current team and position. All teams and players MUST belong to the requested season. Team names and short codes MUST each be unique in that season, and position names and codes MUST each be unique in the result, ignoring case and surrounding whitespace. Display values MUST be trimmed. Player names are not unique. Unlike persisted TASK-005 records, returned players have result references and source bindings rather than established catalog identities; this contract MUST NOT invent local identities or require prior persistence.
- **FR-005**: Each entity MUST have a non-blank, unique result-local reference within its entity kind; relationships MUST resolve within the same result. References are opaque, distinct from source identifiers, and imply no persistent identity across requests. Separate provenance bindings MUST associate each league, season, team, player and match reference with an opaque non-blank source identifier qualified by provider, entity kind and requested league season. Positions use canonical codes and need no source identifiers. Distinct entities MUST NOT share a qualified source binding. Matching names or identifiers from other scopes MUST NOT imply identity. Persistent reconciliation belongs to TASK-018/TASK-021.
- **FR-006**: Performance success MUST include the requested league/season and a reference directory of teams, players and positions needed to interpret matches and performances, using FR-004/FR-005 semantics. This directory describes referenced entities, not a complete current catalog. Each match MUST have its own reference, completed status, actual kickoff instant and distinct home/away teams from that season. Each performance MUST reference one returned match, one player from that season, an event-time participating team and a recognized event-time position. Current affiliation MUST NOT replace or constrain valid historical affiliation. Only completed matches within the requested bounds MUST be included.
- **FR-007**: Performances MUST have known non-negative whole-number minutes, excluding booleans, without a fixed 90/120-minute ceiling. Optional counts MUST be goals, assists, shots on target, tackles, interceptions, saves, goals conceded, yellow cards and red cards, attributed to that player in that match. Tackles mean successful tackles; interceptions mean intercepted opposition passes; saves mean goalkeeper saves; goals conceded mean opposition goals conceded by the player's team while that player was on the field. Other counts use their standard football meanings. These meanings align with TASK-020 FR-006 in [the statistics specification](../054-player-match-statistics/spec.md). Known counts MUST be non-negative whole numbers, excluding booleans. Omitted or explicitly unknown counts MUST remain unknown, distinct from zero. Invalid values, unsupported metric names and missing required facts MUST yield invalid-response. Weights, scores, money, provider ratings and team totals MUST NOT substitute for player facts; no missing performance or count may be manufactured.
- **FR-008**: Required fields, result-reference uniqueness, source-binding uniqueness, catalog business uniqueness, scope consistency and referential integrity MUST be validated before success. At most one performance MUST exist per player-match pair. Duplicate records, dangling references, unsupported leagues, unmapped required positions, cross-season relationships and contradictory match participation MUST fail the whole request as invalid-response. No invalid record may be silently dropped, merged or repaired. Unrelated source fields may be ignored during translation but MUST NOT appear in normalized football facts.
- **FR-009**: Errors MUST identify one category from the table below, requested operation and scope where valid, a safe explanation, retry eligibility and optional affected field/reference. Rate-limit errors MAY carry a positive whole-number retry delay in milliseconds if supplied by the source; an absent delay MUST remain unknown. Categories MUST be independent of vendor codes or transport status. Deadline exhaustion takes precedence over outcomes not fully ready before the deadline; otherwise an observed failure MUST retain its specific category.

| Category | Meaning | Retry eligibility |
| --- | --- | --- |
| invalid-request | Caller input violates the contract. | No, until corrected. |
| unsupported-capability | Provider cannot supply the operation or coverage for an otherwise valid scope. | No, with unchanged capability. |
| not-found | Provider recognizes the operation but the requested league season does not exist. | No, with unchanged scope. |
| authentication-failed | Credentials are absent, invalid or lack required access. | No, until access is corrected. |
| rate-limited | Quota/rate limit temporarily prevents work. | Yes, respecting any supplied delay. |
| unavailable | Temporary connectivity or provider-service failure prevents completion. | Yes. |
| timeout | Deadline expires before a validated outcome is ready. | Yes. |
| invalid-response | Source facts are malformed, incomplete or violate normalization rules. | No, until facts or translation are corrected. |

- **FR-010**: Timeout MUST default to 5,000 milliseconds and MAY be overridden per request by a positive whole-number millisecond value. Zero, negative, fractional, boolean or nonnumeric values MUST yield invalid-request. The budget MUST start immediately before provider work and cover all source portions and normalization. An outcome MUST be fully ready strictly before the deadline. At or after the deadline the caller MUST receive timeout without waiting for further work; late work MUST NOT publish results or write local data. Deadline behavior MUST be testable with controlled elapsed time rather than real multi-second waits.
- **FR-011**: The contract MUST perform no automatic retries, backoff, fallback, persistence or reconciliation. Retry eligibility guides a later caller and does not promise success. Each call is an isolated read; failures MUST leave the existing catalog unchanged. Local reads MUST remain independent of provider availability.
- **FR-012**: Provenance MUST retain a stable provider label, retrieval instant, qualified source bindings and, for fixture-backed results, a stable fixture identifier. Retrieval time and kickoff time MUST be separately identified, even when their values happen to coincide. Vendor payloads, credentials, authorization values, transport headers, secret-bearing URLs and raw exception text MUST NOT appear in normalized football facts or caller-facing errors. Synthetic fixture identifiers and safe source identifiers are permitted only in provenance. Raw-source retention and durable provenance storage belong to later ingestion.
- **FR-013**: This task MUST provide deterministic synthetic fixtures and shared checks covering every acceptance scenario, all five leagues, at least two seasons, same-name distinct players, equivalent facts from two differently shaped sources, empty results, all error categories, unknown versus zero counts, historical affiliation, invalid values/references/duplicates, complete multi-portion success and later-portion failure, default/custom deadline boundaries and rejection before provider work. Fixtures MUST link source examples and expected outcomes by stable identifiers, contain no real secrets or personal contact data, and run without live services, credentials or network access. Tests MUST verify unchanged local reads/state after failures and zero provider calls during local reads.
- **FR-014**: Scope MUST remain the provider-neutral contract, normalization/validation behavior, bounded request handling and deterministic test support. Live integration/configuration and transport translation belong to TASK-017; catalog reconciliation/persistence to TASK-018; statistics persistence to TASK-020; scheduled ingestion, retries and durable source/raw-fixture traceability to TASK-021. Public endpoints, permission changes, scoring, quotes, trading, ranking, caching, UI and new infrastructure are excluded.

### Key Entities

- **Provider Request**: One league-season operation, optional performance bounds and one timeout budget.
- **Normalized Catalog**: League-season facts, teams, canonical positions and players with current relationships.
- **Normalized Performance Collection**: Completed matches and player performances with event-time relationships and known/unknown counts.
- **Result Reference**: An opaque entity reference within one result, not an established local identity.
- **Provenance**: Source label, retrieval instant, qualified source bindings and optional fixture identifier, separate from football facts.
- **Provider Error**: Stable failure category with safe context and retry guidance, without partial success.
- **Contract Fixture**: Synthetic source example with a stable identifier and explicit expected result or error.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Two differently shaped fixture sources produce equivalent football facts for 100% of shared valid examples across all five leagues and at least two seasons, without source-specific rules in consuming acceptance examples.
- **SC-002**: Every specified invalid request, invalid response and provider failure yields its expected category with zero partial successes, invented metrics or changes to existing local records.
- **SC-003**: Every deadline example produces the expected success or timeout, including the 5,000-millisecond default, custom budgets and multi-portion responses; no late outcome becomes visible.
- **SC-004**: Repeating the fixture collection twice offline produces identical outcomes, covers every acceptance scenario and requires zero live-service calls or credentials.
- **SC-005**: Ingestion maintainers can determine scope, relationships, event-time facts, unknown counts, provenance and retry eligibility solely from the contract result without interpreting vendor payloads.
- **SC-006**: All tested local catalog reads return the same records before and after each provider failure, with zero provider requests initiated by those reads.

## Assumptions

- TASK-005 supplies catalog semantics and local reads. [ADR-0002](../../docs/adr/0002-current-affiliation-player-snapshot.md) governs current affiliation; TASK-020 supplies already specified performance meanings. These references authorize no changes to either task.
- Callers are trusted internal ingestion consumers. This task introduces no role, route or permission policy and requires no real provider subscription.
- Two logical retrieval operations satisfy the current downstream outcomes. Concrete names, representations and fixture mechanics are reversible planning decisions; additional operations require an explicit scope change.
- The 5,000-millisecond default is a conservative configurable internal wait budget, not a market-page latency target or live-service guarantee.
- A selected source may lack required facts. Unsupported-capability or invalid-response is preferable to fabrication; this specification does not claim any named vendor supplies all required statistics.
- Source identifiers are opaque and case-sensitive, with blank values rejected. Translation establishes canonical codes and result references; later ingestion establishes local identity and handles transfers, conflicts and repeat imports.
- The application supplies the configured position vocabulary to normalization. No fixed taxonomy, correction policy or cross-source matching rule is introduced here.

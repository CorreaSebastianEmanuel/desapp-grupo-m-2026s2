# Feature Specification: Idempotent Catalog Ingestion

**Feature Branch**: `018-idempotent-catalog-ingestion`

**Created**: 2026-10-08

**Status**: Draft — ready for independent product challenge; live source activation remains gated.

**Task**: TASK-018 · CP2 · depends on TASK-005, merged TASK-016 and TASK-055.

**Input**: Import and reconcile external catalog data without duplicates or partial corruption, using the merged provider contract and selected scraper. TASK-017 is an optional catalog adapter, not a mandatory statistics source.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Publish One Complete Local Catalog (Priority: P1)

As an ingestion operator, I can import a complete supported league season so market users find coherent local players independently of source availability.

**Why this priority**: Later market capabilities depend on a trustworthy local catalog.

**Independent Test**: Import a complete offline catalog into an empty scope and compare all local facts, relationships, source correspondences and acceptance evidence with independently authored expectations.

**Acceptance Scenarios**:

1. **Given** a complete catalog for any supported league, **When** ingestion succeeds, **Then** its league, season, teams, configured positions and players are locally available with valid relationships and durable source correspondences; the outcome reports created, updated and unchanged entity counts.
2. **Given** local data and a complete update with a new player, a renamed player and an in-season transfer, **When** ingestion succeeds, **Then** the new player is added and matched players retain internal and catalog identities while their name, current team and position reflect accepted facts.
3. **Given** a missing later source portion, malformed relationship, duplicate source record or persistence failure after some changes were attempted, **When** ingestion ends, **Then** no catalog changes, correspondences or successful acceptance evidence from that attempt are published.
4. **Given** an accepted catalog, **When** users search, filter or read details while the source is unavailable, **Then** reads use local records and initiate zero source requests.

---

### User Story 2 - Repeat and Reconcile Without Duplicate Identities (Priority: P1)

As an ingestion operator, I can safely repeat deliveries and concurrent requests, and distinguish proven identity from coincidental names.

**Why this priority**: Retries must never multiply players or detach existing market references.

**Independent Test**: Repeat and concurrently deliver fixtures, then exercise same-name players, different seasons, ambiguous existing records and explicit source replacement correspondences.

**Acceptance Scenarios**:

1. **Given** an accepted delivery, **When** it is repeated ten times, **Then** each replay returns its original acceptance reference and creates no additional catalog records, correspondences or acceptance records.
2. **Given** equivalent facts with reordered collections or different result-local references, **When** reconciled, **Then** ordering and reference spelling do not change persistent identity or cause updates; a later retrieval can record observation evidence without duplicating entities.
3. **Given** two same-name players with distinct qualified source bindings, **When** imported, **Then** they remain distinct; an identical source identifier in another provider, entity kind or season does not prove identity.
4. **Given** an unbound existing player whose name matches an incoming player, or a replacement provider for an already sourced player scope without explicit correspondence, **When** import is attempted, **Then** the whole import reports a reconciliation conflict and leaves the scope unchanged; names neither merge players nor authorize replacement duplication.
5. **Given** trusted explicit correspondences from a replacement provider to existing players, **When** that source is imported, **Then** existing player identities remain stable and new source bindings are retained separately.
6. **Given** two attempts based on the same accepted scope revision, **When** publication overlaps, **Then** equivalent deliveries converge to one acceptance; differing deliveries cannot both publish against that revision, and the losing attempt reports concurrent change without partial writes.

---

### User Story 3 - Preserve Accepted State and Explain Outcomes (Priority: P1)

As an ingestion operator, I can distinguish accepted, unchanged, replayed, stale, conflicting and failed imports without mistaking fixtures for live readiness or statistics freshness.

**Why this priority**: Safe failure and an understandable recovery path are necessary to operate ingestion.

**Independent Test**: Seed a catalog, then deliver older, empty, omitted-record, conflicting and failed examples; inspect state and safe outcomes after each attempt.

**Acceptance Scenarios**:

1. **Given** a newer accepted observation, **When** an older unaccepted observation arrives, **Then** it is rejected as stale without reverting affiliation or acceptance state; an already accepted older delivery remains a no-op replay.
2. **Given** accepted data, **When** a complete response omits an existing player or team, **Then** omitted records and relationships remain available; no deletion, deactivation or inferred transfer occurs.
3. **Given** a valid complete empty response, **When** imported, **Then** scope and observation evidence are accepted with zero team/player changes; unknown, unsupported and incomplete scopes remain distinct failures.
4. **Given** accepted observation evidence and different facts claiming the same retrieval instant, **When** imported, **Then** a reconciliation conflict preserves accepted state.
5. **Given** provider refusal, rate limiting, unavailability, timeout or invalid facts, **When** ingestion fails, **Then** it preserves the provider's safe category and retry guidance, exposes no partial success or sensitive diagnostics, and leaves the prior catalog and accepted evidence unchanged.
6. **Given** a fixture import or a live request blocked by the scraper, **When** the outcome is inspected, **Then** fixture lineage or the access blocker is explicit; neither establishes live readiness, statistics freshness or a recalculated quote.

### Edge Cases

- Duplicate source records are invalid even when identical; repeated deliveries between requests are a different case.
- Source identifiers are opaque and case-sensitive. Local business uniqueness follows TASK-005's case/whitespace rules; result-local references are not persistent identities.
- A binding pointing outside the requested scope, distinct same-provider entities collapsing onto one target, or an explicit instruction contradicting an established binding fails the whole import.
- A team code matching one existing team while its name matches another is a conflict, not permission to merge them.
- Source identifier changes cannot be inferred from names. Ambiguous unbound identities require explicit correspondence before retry.
- Another season uses a distinct player record; cross-season reassignment cannot mutate an existing player.
- Omitted entities remain retained; no roster membership status, deletion synchronization or roster history is introduced.
- Positions outside the configured vocabulary cannot create or redefine it. Canonical league and position naming conflicts fail.
- Failed first imports leave no orphan hierarchy, binding or acceptance record; failed updates preserve prior values.
- Crashes before publication leave no accepted change. A lost reply after publication is recoverable through replay.
- Late provider work cannot publish ingestion. The provider deadline does not establish a persistence latency promise.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Ingestion MUST obtain one complete catalog for one explicitly requested league season through the merged [TASK-016 contract](../016-external-football-provider-contract/spec.md). Its request validation, normalized facts, errors, deadlines and provenance remain authoritative. Ingestion MUST NOT use a performance reference directory as a full catalog, scrape arbitrary player names, introduce another provider boundary or repair invalid provider facts.
- **FR-002**: Supported leagues, season rules, relationships and business uniqueness MUST remain those of [TASK-005](../005-football-catalog-domain-model/spec.md). Leagues and positions MUST resolve by canonical code with compatible canonical names. Missing supported leagues and valid seasons MAY be created in the successful import. Positions MUST already belong to the configured local vocabulary; ingestion MUST NOT expand or rename it.
- **FR-003**: Every imported league, season, team and player MUST retain a durable correspondence between its stable local identity and its source identifier qualified by provider, entity kind and requested league season. Each qualified binding MUST target exactly one local entity. Within a provider/kind/scope, distinct entities MUST NOT collapse onto one target. Result-local references MUST resolve only the current response's relationships; source IDs MUST NOT become local player catalog identities.
- **FR-004**: Established correspondences MUST take precedence over adoption or creation. Without a binding, league and season resolve by canonical business identity; a team MAY adopt a unique existing season team only when both normalized name and short code agree. Collision on only one team key, contradictory binding or incompatible canonical name MUST fail as a reconciliation conflict. Otherwise a new team MAY be created.
- **FR-005**: Player names MUST NOT establish identity. Unbound incoming players MAY receive new provider-neutral catalog identities during first-source ingestion or as additions from the established source. A name collision with an existing unbound player MUST block publication pending explicit correspondence. Same-name players with distinct established bindings MUST remain distinct. Introducing another provider into a scope with existing player source bindings MUST require trusted explicit correspondences for incoming players, or explicit declarations that unmatched incoming players are new; names alone MUST NOT authorize either matching or duplication.
- **FR-006**: Explicit correspondences and new-player declarations MUST be trusted internal inputs scoped to provider and league season. Target existence, entity kind, season, uniqueness and consistency with established bindings MUST be validated before publication. Invalid or ambiguous instructions MUST fail the whole import. This task adds no public mapping editor, permission, fuzzy matching or automatic fallback.
- **FR-007**: Matched teams MAY update supplied name and short code if TASK-005 uniqueness is preserved. Matched players MUST update supplied display name, current same-season team and configured position while retaining internal ID and catalog identity, following [ADR-0002](../../docs/adr/0002-current-affiliation-player-snapshot.md). Other-season players MUST remain distinct. Match facts, historical relationships, quotes, financial operations and audit records MUST NOT be rewritten.
- **FR-008**: Omission MUST NOT delete, deactivate or reassign existing entities or remove correspondences. A fully validated empty catalog MUST be accepted as a zero-team/player-change observation, distinct from not-found, unsupported-capability and invalid-response. Retained entities are not asserted to remain externally rostered.
- **FR-009**: All catalog changes, correspondences and successful acceptance evidence MUST publish together or none may publish. Readers MUST NOT observe a partially imported hierarchy. Validation, uniqueness, correspondence and persistence failures MUST preserve prior catalog and accepted observation state. Success MUST NOT be reported before durable publication.
- **FR-010**: Delivery identity MUST include operation, normalized scope, provider, retrieval instant, fixture identifier when present, and complete normalized facts with qualified bindings. Collection order and result-reference spelling MUST NOT affect equivalence. An accepted delivery replay MUST return its original acceptance reference without reapplying changes or creating another acceptance record. A later observation with identical facts MAY add observation evidence but MUST update zero unchanged catalog entities. Replay after intervening updates MUST NOT restore old facts.
- **FR-011**: Publication MUST protect the whole league-season reconciliation boundary. Attempts MUST reconcile against the accepted revision observed before retrieval began. If that revision changes, an equivalent delivery MAY converge to existing acceptance; a differing delivery MUST return concurrent-change without writes and require a new attempt. Different scopes MUST NOT overwrite each other's affiliations or bindings; shared canonical entities MUST still satisfy uniqueness.
- **FR-012**: Accepted observation ordering MUST use the validated provider retrieval instant, separate from local acceptance time. An unaccepted older observation MUST return stale without writes. Equal instants with non-equivalent facts or attribution MUST return reconciliation conflict. Accepted delivery replay MUST take precedence over stale rejection. Retrieval time does not prove source publication order.
- **FR-013**: Durable successful evidence MUST identify accepted scope revision, provider, retrieval instant, local acceptance instant, fixture identifier when present, delivery identity and created/updated/unchanged counts by entity kind. Each imported entity MUST be traceable through its binding to an accepted observation. Older successful evidence MUST be retained; replay returns original evidence. Raw source content and secrets MUST NOT be retained as ingestion evidence. Fixture attribution MUST remain explicit even if fixtures share a provider label with a future live source.
- **FR-014**: Safe outcomes MUST distinguish accepted-with-changes, accepted-unchanged, replay, provider failure, reconciliation conflict, stale observation, concurrent change and persistence failure. Counts MUST describe incoming entities created, changed or already equivalent; omitted retained entities are excluded. Replays MUST label original counts as historical evidence and identify zero applied changes this time. Provider errors MUST preserve TASK-016 categories, retry eligibility and valid supplied delays. Persistence failures and concurrent changes MAY be retried by the caller; conflicts require corrected facts/instructions and stale observations require new retrieval. Ingestion MUST perform no automatic retry or backoff.
- **FR-015**: TASK-055's selected scraper MUST retain access and completeness gates under [ADR-0018](../../docs/adr/0018-offline-scraper-access-and-completeness.md). Offline imports MUST need no credentials or live calls and MUST retain fixture attribution. TASK-017 MAY be explicitly selected as a compatible optional catalog adapter but MUST NOT be required, automatically substituted or treated as a statistics source. Fixture success MUST NOT activate live retrieval or mark statistics fresh.
- **FR-016**: Local catalog reads MUST initiate zero provider calls and remain usable during source failure and ingestion. Ingestion MUST NOT mint tokens, change balances, import performances, calculate valuation, insert quotes, execute orders or mark statistics freshness. Web endpoints, UI, scheduling, job history, cache and new infrastructure are excluded. [CP2 architecture](../../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../../docs/adr/0017-cp2-charts-and-conditional-orders.md) govern downstream ownership.
- **FR-017**: Every acceptance scenario and reconciliation rule MUST have automated deterministic offline evidence with independently authored expected records and outcomes. Coverage MUST include five leagues, two seasons, exact replay, reordered/re-referenced facts, same-name players, team-key conflicts, explicit source replacement, transfer stability, retained omissions, empty success, stale/equal-time conflicts, concurrency, every provider failure category, late provider completion, failure during publication and lost-reply replay. Checks MUST assert unchanged unrelated scopes and financial/historical state, usable local reads and zero external calls. Repeated controlled runs MUST produce equivalent outcomes.

### Key Entities

- **Catalog Scope**: One supported league season containing current-affiliation team/player snapshots with TASK-005 identities.
- **Source Correspondence**: A qualified opaque source identifier linked to a stable local entity independently of names and result references.
- **Explicit Reconciliation Instruction**: A trusted correspondence or new-player declaration resolving source replacement or unbound identity ambiguity.
- **Accepted Catalog Observation**: Durable evidence of complete publication with source/acceptance times, lineage, semantic delivery identity, scope revision and entity counts.
- **Ingestion Outcome**: Safe acceptance, unchanged, replay or recovery-relevant failure result without partial success.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Across five leagues and two seasons, 100% of accepted examples resolve each player to exactly one valid current team, season, league and configured position, with zero duplicate local identities or broken references.
- **SC-002**: Ten exact redeliveries of every replay example create zero additional entities, bindings or acceptance records; reordered/re-referenced examples preserve 100% of identities.
- **SC-003**: In 100% of provider, reconciliation and publication failure examples, prior catalog facts and accepted evidence remain unchanged; conflicting concurrent attempts yield at most one publication against a given revision.
- **SC-004**: Every tested same-season transfer preserves player identities; all stale, cross-season and ambiguous-source examples preserve historical/financial facts without guessed identity matches.
- **SC-005**: Operators can identify source, scope, fixture attribution, status, counts and recovery action from 100% of outcome examples without interpreting raw source material.
- **SC-006**: Local searches and details remain usable before, during and after failed imports with zero source calls; deterministic verification requires zero external requests or credentials.
- **SC-007**: Every acceptance scenario has an explicit offline expected outcome; two controlled runs reproduce equivalent catalog and outcome evidence. No blocked live scope is reported as ready or statistically fresh.

## Assumptions

- Actors are trusted internal consumers/operators. TASK-019 owns initial/manual/scheduled job entry points, durable job history, deduplication and bounded retries. This feature supplies domain idempotency and successful catalog acceptance evidence.
- TASK-021 owns statistics persistence and source/raw-fixture traceability; TASK-056 owns statistics TTL. Catalog observation time is lineage, not statistics freshness.
- TASK-055 delivered an offline scraper through the merged contract. Live access remains blocked as documented; current external readiness is not required for these acceptance tests.
- Conservative additive reconciliation preserves local references. Authoritative removal, roster status/history, cross-season person identity and automatic cross-provider matching need separately specified behavior.
- Explicit correspondence is a conservative internal escape hatch for ambiguous legacy records and source replacement. Its representation, local identity format and storage are planning decisions; operator UI is excluded.
- Retrieval instants are trusted within the validated contract. Ordering prevents known older observations from reverting state but establishes neither source event chronology nor clock synchronization guarantees.
- This specification is the complete TASK-018 behavioral authority. Independent product challenge precedes planning; specification checklist completion does not claim implementation, independent QA/review or task completion.

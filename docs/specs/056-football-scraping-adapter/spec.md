# Feature Specification: Football Scraping Adapter

**Feature Branch**: `055-football-scraping-adapter`

**Created**: 2026-10-07

**Status**: Draft — ready for independent product challenge and planning; recurring live access not established.

**Task**: TASK-055 · CP2 · depends on merged TASK-016.

**Input**: Implement a replaceable scraper through the merged provider contract; evaluate FotMob access and coverage, preserve unknowns and provenance, and verify offline before implementation.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Know Whether a Source Can Be Used (Priority: P1)

As an ingestion operator, I can distinguish a technically extractable source from one permitted and sufficiently covered for recurring use, so the market does not depend on unapproved access or misleading completeness claims.

**Why this priority**: Successful exploratory retrieval does not authorize recurring access or demonstrate usable player-performance coverage.

**Independent Test**: Inspect the source assessment and attempt retrieval with missing, expired, withdrawn and valid access evidence using controlled source examples. No external service is needed.

**Acceptance Scenarios**:

1. **Given** FotMob's current assessment, **When** recurring live retrieval is requested, **Then** it is disabled and returns unsupported-capability without contacting the source; offline examples remain usable and explicitly identified as fixtures.
2. **Given** applicable access evidence and verified coverage for an operation and league season, **When** that scope is enabled, **Then** only that assessed operation and scope may be requested within the documented access limits.
3. **Given** missing, expired or withdrawn permission, or unverified required coverage, **When** a request is attempted, **Then** no live retrieval starts and no success, freshness or valuation claim is made.
4. **Given** a permission or coverage assessment, **When** a maintainer reviews it, **Then** its evidence, review date, permitted use, operations, seasons, limits, unknowns and blocking reasons are distinguishable; a fixture pass cannot promote its live readiness.

---

### User Story 2 - Obtain Complete Catalog Facts for a Known Scope (Priority: P1)

As a catalog ingestion consumer, I can obtain a selected league season through the existing provider contract, so source replacement preserves catalog meaning and identity evidence.

**Why this priority**: Downstream ingestion needs complete, validated records and must not infer identities from player names or accidentally import the current season instead of the requested one.

**Independent Test**: Replay offline season, team and roster examples through the existing catalog operation and compare independently specified football facts and source bindings.

**Acceptance Scenarios**:

1. **Given** a supported league season and complete source portions, **When** its catalog is requested, **Then** the result contains the correct league, season, teams, canonical positions and players with current affiliations and qualified provenance under TASK-016.
2. **Given** a valid published empty scope, **When** retrieval completes, **Then** it returns empty success; an unknown scope returns not-found and a declared unsupported season returns unsupported-capability.
3. **Given** a wrong-season response, same-name distinct players, unresolved roster entries, conflicting or identical duplicates, or an incomplete later portion, **When** the result is checked, **Then** distinct valid players remain distinct and every invalid or incomplete result fails as a whole without silently merging or dropping records.

---

### User Story 3 - Obtain Honest Dated Player Performances (Priority: P1)

As a statistics ingestion consumer, I receive completed matches and supplied performances whose minutes, positions, affiliation and optional metrics have the meanings required by TASK-016, so later valuation does not treat unavailable facts as measured zeroes.

**Why this priority**: Player facts, rather than ratings or team totals, are the inputs needed for reproducible valuation.

**Independent Test**: Replay completed matches, substitutes, transfers, goalkeeper changes, own goals and incomplete evidence; compare explicit expected facts or errors without persistence or valuation.

**Acceptance Scenarios**:

1. **Given** completed and non-completed matches and inclusive kickoff bounds, **When** performances are requested, **Then** only eligible completed matches and their supplied performances are returned with actual kickoff and event-time affiliation, following TASK-016 filtering rules.
2. **Given** a published zero, an unavailable optional count and a semantically unverified optional metric, **When** facts are translated, **Then** the zero remains zero and both unavailable and unverified metrics remain unknown; the source assessment explains the unverified mapping.
3. **Given** a valid measured performance with a known event-time position differing from the player's current position, **When** it is returned, **Then** the event-time position is preserved and mapped to the configured canonical vocabulary.
4. **Given** an eligible performance lacking minutes or a required event-time position, **When** a scope declared supported is evaluated, **Then** the complete request fails as invalid-response, rather than dropping the player, inventing zero minutes or substituting the player's usual position.
5. **Given** a scope whose required performance capability is known to be unavailable, **When** it is requested, **Then** unsupported-capability is returned; a catalog or match schedule is not presented as performance coverage.
6. **Given** incomplete event evidence, an own goal or a mid-match goalkeeper change, **When** optional counts are translated, **Then** only verified player-attributed facts with contract meanings are returned; no whole-team total or assumed zero replaces unknown data.

---

### User Story 4 - Verify Replacement and Failures Offline (Priority: P2)

As a maintainer, I can verify the adapter and its failure behavior repeatedly without source availability, credentials or recurring scraping, while local market reads remain usable.

**Why this priority**: Deterministic evidence must protect source replacement and downstream development even while live access is unavailable.

**Independent Test**: Run the same stable examples twice offline through TASK-016, including controlled failures and deadline boundaries, and inspect local state before and after.

**Acceptance Scenarios**:

1. **Given** differently shaped source examples representing equivalent facts, **When** the scraper and an existing reference fixture source are checked, **Then** equivalent normalized football facts satisfy the same consumer checks; provider-specific bindings remain separate.
2. **Given** access refusal, rate limiting, temporary failure, missing scope, malformed content or deadline exhaustion, **When** retrieval ends, **Then** the corresponding TASK-016 error and retry guidance are returned without raw payloads, secrets or partial facts.
3. **Given** several source portions under one timeout, **When** a later portion fails or the validated result becomes ready at or after the deadline, **Then** the whole request fails, no late result appears and no local state changes.
4. **Given** all offline examples and controlled time, **When** verification runs twice, **Then** outcomes are identical and zero external requests or credentials are required; local reads start zero source requests before and after every failure.

### Edge Cases

- A successful exploratory request, public page, accessible data response or permissive crawler entry is not evidence of permission for this application's recurring use.
- Access evidence can authorize catalog use while performance coverage remains blocked, or cover one season without covering another.
- An incomplete roster, truncated schedule, missing required detail, repeated portion or undecidable completeness is not a valid empty collection.
- A redirected historical match returning another match or season fails identity validation; display names are not identity substitutes.
- Scheduled, live, postponed and abandoned matches are excluded according to TASK-016; unknown status and undecidable eligibility fail.
- Absent appearances are not invented. A published zero-minute appearance with required facts remains valid; minutes have no fixed 90/120 ceiling.
- Unknown optional counts differ from invalid published values. A negative, fractional, boolean or malformed claimed count fails validation; it is not converted to unknown.
- Unverified tackle labels are not assumed to mean successful tackles. Whole-team goals conceded are not assumed to equal goals conceded while a particular player was on the field.
- Own goals are not ordinary player goals or ordinary shots. Reconstruction from incomplete event lists cannot establish zeroes.
- A substitute's usual profile position does not establish a match position or a most-frequent historical position.
- Source markup or field changes, challenges, access refusals and missing portions produce safe errors; no automatic source switch or control circumvention is allowed.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The scraper MUST be replaceable through the merged TASK-016 contract and its existing catalog and performance operations. All request validation, normalized facts, error categories, deadline semantics and provenance rules in [TASK-016 spec.md](../016-external-football-provider-contract/spec.md) remain authoritative. No duplicate consumer contract, player-name search operation or provider-specific consumer rule may be introduced.
- **FR-002**: Before any live operation is enabled, the source MUST have a dated, reviewable assessment showing affirmative applicable permission for recurring retrieval and intended data use, covered operations and league seasons, access method, attribution/retention conditions where applicable, documented cadence and volume/concurrency limits, and expiry or revalidation conditions. Unresolved mandatory conditions MUST block access; successful retrieval alone MUST NOT satisfy this requirement. This task does not authorize contacting a provider or purchasing access.
- **FR-003**: Live retrieval MUST be disabled by default. Missing, inapplicable, expired or withdrawn access evidence, or unverified required coverage for the requested operation/scope, MUST return TASK-016 unsupported-capability before contacting the source. Valid caller-input rejection still takes precedence as defined by TASK-016. Fixture verification MUST be available independently of live enablement. Enabling a configuration switch alone MUST NOT override a failed assessment.
- **FR-004**: The assessment MUST cover `PL`, `BL1`, `PD`, `SA` and `FL1` separately, with explicit season coverage for catalog and performances. For each assessed scope it MUST identify evidence and mark required facts and each of the nine optional counts as verified, unavailable or unverified, including the exact football meaning used for each verified mapping. No claim of all-league, historical or complete-season readiness may be inferred from a sample. A scope without evidence MUST remain unverified.
- **FR-005**: Catalog results MUST validate the requested competition and season throughout discovery and roster retrieval; supplied teams, positions, players and source bindings MUST satisfy TASK-016. A schedule or list of players observed in selected matches MUST NOT be represented as a complete current catalog. Ambiguous identities, unresolved required positions and incomplete rosters MUST fail without name-based guessing or partial success.
- **FR-006**: Performance retrieval MUST discover and finish all source portions needed for the requested league season and optional kickoff bounds. Match identity, scope, completion, actual kickoff, participating teams and required player facts MUST be verifiable. A published empty result requires evidence that the requested collection was completely checked. Missing required portions or undecidable completeness MUST fail as invalid-response; observed access/availability failures retain their specific TASK-016 categories. Proven irrelevant records MUST follow the existing contract's filtering rules rather than create new exclusions.
- **FR-007**: Returned performances MUST preserve measured non-negative whole-number minutes and historical team/position facts under TASK-016. Current affiliation MUST NOT rewrite historical affiliation. Missing required event-time positions MUST NOT be filled from profile positions, later matches or invented frequency. Known unsupported required coverage MUST produce unsupported-capability; missing required facts in a supposedly supported response MUST produce invalid-response. TASK-021 owns the unresolved substitute-position derivation policy and any prerequisite contract reconciliation.
- **FR-008**: The optional counts are goals, assists, shots on target, successful tackles, interceptions, goalkeeper saves, goals conceded while the player was on the field, yellow cards and red cards, with TASK-016 meanings and normalized names. Only semantically verified player-match counts may be returned as known. Unavailable or unverified mappings MUST remain unknown; published verified zero MUST remain zero. Ratings, season aggregates, team totals and guessed event-derived zeroes MUST NOT substitute. Derived optional counts require documented complete evidence and independently checked examples for their attribution; otherwise they remain unknown. Invalid claimed values MUST fail rather than be repaired.
- **FR-009**: Results MUST retain TASK-016's stable source label, retrieval instant, qualified source bindings and stable fixture identifier for fixture results, separate from football facts. Source IDs MUST remain qualified by entity kind and league season and MUST NOT become assumed local identities. Source material underlying each offline example MUST be traceable to its stable identifier, origin, capture or synthetic creation date, content fingerprint, expected outcome and exercised acceptance rules; unsafe fields MUST be removed before retention. Durable ingestion lineage and historical reconciliation are outside this task.
- **FR-010**: All portions, translation and validation MUST share TASK-016's single deadline, including its default and every accepted positive whole-number timeout override. Complete outcomes ready strictly before the deadline may succeed; equality and later readiness MUST time out. Cancellation MUST end source work and prevent late publication. No internal retry, backoff, detached retrieval or automatic source fallback is introduced; later workers own retry scheduling and respecting access limits.
- **FR-011**: Observed authentication refusal, source rate limits, temporary unavailability, absent scopes and malformed results MUST retain TASK-016's normalized error categories and safe explanations. Source-provided valid retry delay MAY be retained as specified by that contract; absent delay remains unknown. Raw source content, transport diagnostics, credential-bearing addresses, credentials and exception text MUST NOT appear in returned facts or errors. Access controls MUST NOT be bypassed.
- **FR-012**: Both operations MUST be read-only. Successful and failed retrievals MUST perform no persistence, identity reconciliation, freshness update, scoring or financial action. Existing local reads MUST remain independent of source availability and initiate zero retrievals. Fixtures and controlled demos MUST be identified as such and MUST NOT establish permission, live coverage, current freshness or a recalculated quote.
- **FR-013**: Deterministic offline fixtures MUST cover both operations, all five leagues, at least two explicitly distinguished seasons, a historical request returning a wrong current scope, same-name distinct players, transfers, required-position mapping and absence, unknown/zero/invalid counts, own goals, goalkeeper substitution, valid empty and missing scopes, partial discovery/details, duplicate/conflicting records, all contract error categories, access-gate refusal and shared-deadline boundaries. Every acceptance scenario MUST have a stable example and explicit independently authored expected outcome. Contract regressions MUST remain intact; unavailable source capabilities MUST be declared instead of fabricated.
- **FR-014**: Verification MUST run twice with controlled time and source responses, without external requests or real credentials, through the existing TASK-016 consumer boundary. Source-shaped examples MUST exercise the scraper's translation rather than bypass it with already normalized results. At least one equivalence example per operation MUST compare facts with an existing reference fixture provider while expecting distinct qualified provenance. Expected outcomes MUST NOT be computed by the translator being tested.
- **FR-015**: Delivery evidence MUST distinguish an implemented, offline-verified adapter from a live-ready source. A live-ready claim requires both access and coverage gates to pass for every claimed scope; blocked scopes and remaining evidence MUST remain visible. If FotMob cannot meet these gates, the adapter can remain offline-only; choosing another source or changing required performance facts needs a separate documented product decision, not silent substitution. Specification and plan MUST precede implementation. The user-authorized verification-helper corrections in FR-016–018 are included; downstream jobs, catalog/statistics persistence, TTL, valuation, quotes, trading, charts, conditional orders, public endpoints, cache and new infrastructure are excluded under [CP2 architecture](../../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../../docs/adr/0017-cp2-charts-and-conditional-orders.md).

- **FR-016**: Per the user's 2026-10-07 correction, TASK-055 verification MUST retain unit and integration regression but MUST NOT invoke the historical CP1 coverage report as an additional mandatory gate. Existing coverage infrastructure and CI are preserved; independent QA and final review remain mandatory.
- **FR-017**: Development MAY explicitly reuse a successful check only with the same command, source and canonical design inputs and intact local output evidence from development. Independent QA MUST execute its checks anew and MUST NOT reuse developer receipts. Generated handoffs and QA/review reports MUST NOT invalidate evidence, while source/specification/plan changes MUST invalidate it.
- **FR-018**: The check helper MUST refuse a third execution after two failed attempts in the same stage with unchanged command/source/design inputs. It MUST report the failure count, elapsed check time and evidence reference. A changed input permits a new corrective attempt; independent stages have separate counters. The agent MUST stop and diagnose this limit rather than repeat commands or alter inputs solely to bypass it.

### Key Entities

- **Source Access Assessment**: Dated evidence of permitted recurring use, applicable scopes, constraints, revalidation conditions and blockers. It is not a football fact or caller permission change.
- **Coverage Assessment**: Evidence per operation, league season, required fact and optional metric, with verified meanings and explicit missing or unverified capabilities.
- **Catalog and Performance Results**: Existing TASK-016 football facts and errors; this feature introduces no second representation for consumers.
- **Provenance and Source Bindings**: Existing TASK-016 source attribution, retrieval instant and qualified identity evidence, independent of local persistent identity.
- **Offline Source Example**: Retained safe source-shaped input, stable identifier, origin/date/fingerprint, explicit expected facts or error and acceptance-rule mapping.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An operator can determine access and coverage readiness for each of the five leagues and every assessed season/operation from the assessment alone; 100% of missing or failed gate examples produce zero live requests and zero misleading success claims.
- **SC-002**: 100% of accepted catalog and performance examples preserve requested scope, required relationships and provenance; 100% of incomplete or invalid examples return their expected complete failure with no dropped retained records or fabricated facts.
- **SC-003**: Every optional metric is classified in the assessment; 100% of unknown, verified-zero, invalid-value and missing-required-position examples preserve their distinct expected outcomes.
- **SC-004**: Every acceptance scenario has explicit offline evidence across both operations, five leagues and at least two seasons. Two verification runs produce identical outcomes and require zero external requests or real credentials.
- **SC-005**: Both operation equivalence checks allow consumers to interpret the same football facts without source-specific rules, while retaining independently expected source attribution.
- **SC-006**: Every failure and deadline example leaves local records unchanged; local reads initiate zero source requests, and no result ready at or after the deadline becomes visible.
- **SC-007**: Reviewers can distinguish offline verification from live readiness in delivery evidence; no assessed blocked scope is described as live-ready or complete.

## Assumptions

- Internal ingestion consumers are the actors. This task adds no user-facing route or permission and does not implement a recurring scheduler. TASK-018 owns catalog ingestion, TASK-019 jobs, TASK-021 statistics ingestion/provenance and TASK-056 freshness, following current CP2 ownership rather than historical ownership wording in TASK-016.
- FotMob is a candidate, not a committed source. Its [terms of use](https://www.fotmob.com/terms), reviewed 2026-10-07, state that automatic and systematic or regular use is not permitted. Its [crawler instructions](https://www.fotmob.com/robots.txt), reviewed the same date, disallow general access to its data interface. No applicable recurring-use permission has been established; the baseline access gate therefore fails. These observations establish a conservative product gate, not a legal opinion.
- The 2026-10-04 exploratory report at `/private/tmp/fotmob-scraping-feasibility.md` is preliminary evidence only: five season schedules and seven match details were sampled; complete rosters, complete-season detail coverage and recurring access were not established. Its 216 observed performances included 62 without match-specific position. It does not prove production readiness, and temporary files are not required for offline verification.
- TASK-021 feedback leaves the historical window, ties and insufficient-history handling for substitutes' most-frequent position unresolved. This feature derives no such position and does not weaken the merged contract. Rejecting missing required positions is the conservative existing behavior; resolving derivation belongs to that later task.
- Synthetic source-shaped examples may demonstrate valid mappings and failure handling without asserting that FotMob currently publishes those facts. Retained real samples require applicable retention permission and sanitization; neither type establishes live coverage on its own.
- Source-specific field mapping, bounded retrieval mechanics and assessment configuration are planning decisions. The plan must identify how access limits and cancellation are enforced without adding operations or altering consumer rules. Unknown live cadence and coverage remain activation blockers rather than invented defaults.

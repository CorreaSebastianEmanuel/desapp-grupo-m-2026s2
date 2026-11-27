# Feature Specification: Statistics Ingestion Pipeline

**Feature Branch**: `021-statistics-ingestion-pipeline`

**Created**: 2026-10-16

**Status**: Draft

**Input**: TASK-021 — Import statistics idempotently through Oban with provenance and raw-fixture traceability. Validate completeness and atomically preserve accepted data/check state; unknown values are not zero. Do not overwrite immutable facts. Resolve substitute-position window/ties/insufficient history from feedback before deriving most frequent historical position.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Import a complete statistics scope safely (Priority: P1)

As a market maintainer, I need a completed statistics import for a specific league season to be accepted as one complete unit, so local performance history never presents a partial or misleading view of a source check.

**Why this priority**: Valuation depends on locally available match performances, and incomplete inputs cannot be treated as a successful history.

**Independent Test**: Run a deterministic offline import for a bounded league-season scope with multiple matches and performances, then inspect accepted facts, check outcome, and source attribution; repeat with an incomplete fixture and verify no partial facts or successful check state are published.

**Acceptance Scenarios**:

1. **Given** a supported league-season scope and a complete, validated result from the explicitly selected source, **When** its queued import runs, **Then** all valid new match and performance facts are accepted together with the check outcome and provenance for the same scope.
2. **Given** a result with a missing required portion, unresolved required identity, malformed required fact, or unproven completeness, **When** it is validated, **Then** the import fails as a whole, existing facts remain unchanged, and the check is not recorded as successful.
3. **Given** a complete result that contains no changes, **When** it is accepted, **Then** the successful unchanged check is recorded without creating duplicate facts.
4. **Given** an explicitly identified complete empty scope, **When** it is accepted, **Then** the successful empty outcome is distinguishable from missing scope data or incomplete retrieval.

---

### User Story 2 - Retry or replay without duplicating historical facts (Priority: P1)

As a market maintainer, I need retries and repeated imports to be safe, so delivery interruptions do not duplicate performances or replace immutable football facts.

**Why this priority**: Duplicate or silently revised inputs can change historical valuations and make results irreproducible.

**Independent Test**: Submit an identical completed result repeatedly and concurrently, then submit a conflicting result for an already accepted immutable identity; inspect fact counts, values, provenance, and import outcomes.

**Acceptance Scenarios**:

1. **Given** an accepted match and performance set, **When** an identical result is replayed, **Then** the run is classified as replay or unchanged, the existing facts remain byte-for-byte equivalent in meaning, and no duplicate fact is added.
2. **Given** a previously accepted match or performance identity with changed immutable content, **When** a later import conflicts with it, **Then** the conflicting import is rejected, the accepted fact and its provenance remain unchanged, and no successful check state is recorded for that attempt.
3. **Given** two deliveries of the same scope overlap or a job is redelivered, **When** they reach persistence, **Then** at most one copy of each fact is accepted and run/check outcomes remain consistent with the accepted data.
4. **Given** a temporary failure before acceptance, **When** the bounded retry policy permits another attempt, **Then** the new attempt can safely accept the result once; an exhausted or non-retryable failure remains visible without changing the last accepted facts or successful check state.

---

### User Story 3 - Trace imported facts and preserve unknowns (Priority: P1)

As a valuation consumer, I need to know where each accepted match and performance came from and whether a value is actually known, so I can distinguish source facts, derived positions, unavailable values, and zero.

**Why this priority**: Provenance and explicit unknowns are necessary to audit fixture-backed results and prevent invented statistical inputs.

**Independent Test**: Import controlled source-shaped fixtures containing known zeroes, omitted optional counts, direct positions, substitute positions with unique historical modes, ties, and insufficient history; trace each stored fact to its fixture/source lineage and inspect its position basis.

**Acceptance Scenarios**:

1. **Given** a sanitized offline fixture import, **When** it is accepted, **Then** each imported match/performance can be traced to a stable fixture reference and content fingerprint, origin and capture or synthetic-creation date, and the expected fixture case; the fixture is explicitly identified as non-live evidence.
2. **Given** an accepted live-capable result, **When** it is retained, **Then** each fact remains attributable to the selected provider, retrieval instant, and qualified provider identity under the existing provider contract, without exposing raw payloads or credentials.
3. **Given** an optional count is absent or explicitly unknown, **When** imported and read, **Then** it remains unknown; an explicit zero remains a known zero.
4. **Given** a starting player with a provider-supplied event-time position, **When** imported, **Then** that effective position is preserved with direct-source provenance and is not silently replaced by a derived position.
5. **Given** a substitute enters the match and has one uniquely most frequent position across their earlier accepted performances in the same season, **When** the current performance is imported, **Then** that position is stored with derived-history provenance; only matches before the match being valued count, and the current match and later matches do not.
6. **Given** that substitute has no earlier same-season performance or there is a tie for the most frequent earlier position, **When** the performance is imported, **Then** its position remains unknown with the reason recorded; a published usual-position/profile value is not treated as historical frequency.

## Edge Cases

- A complete response with zero performances is distinct from a response whose match details were never retrieved or whose collection completeness is unknown.
- Missing optional counts remain unknown; only an explicit validated zero is zero.
- A conflict in any match or performance makes the entire proposed scope update fail without changing previously accepted facts.
- Replaying a result after a process interruption must not duplicate facts even if the prior job completion record was not confirmed.
- Two imports for different scopes must not suppress one another; equivalent duplicate requests may be coalesced by the existing job workflow.
- Provenance records identify the provider/fixture and source identity but do not make provider IDs local domain identities.
- Raw external payloads may contain unsafe or restricted material and are not retained as provenance; sanitized, stable fixture artifacts are traceable by reference and fingerprint.
- A later match already present in storage must not influence a substitute's historical-position calculation for an earlier match.
- A derived-position tie remains unknown rather than choosing by provider order, identifier order, current position, or usualPosition.
- If an otherwise valid performance has an unknown position under this policy, the imported record must retain that unknown state; it must not be fabricated to satisfy the earlier required-position contract. See the TASK-020 reconciliation guidance in the product handoff before planning persistence changes.
- A successful import and a later valuation/quote calculation are separate outcomes; import success must not be represented as a completed quote recalculation.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: An accepted statistics import MUST identify one normalized supported league-season scope and one explicitly selected effective source or offline fixture. The selection MUST NOT be inferred from a player name, silently changed, or replaced by an alternate provider.
- **FR-002**: Statistics imports MUST run as durable background work through the existing Oban runtime. Each accepted request MUST remain associated with its scope and safe source/fixture reference across retries and restarts. Equivalent active work may be coalesced according to TASK-019; incompatible inputs MUST NOT be silently adopted by an existing run.
- **FR-003**: Before persistence, the complete requested result MUST satisfy the existing TASK-016 contract and the selected source's applicable completeness evidence, with only the explicitly specified substitute-position reconciliation in FR-010/FR-011. Required match identity, scope, completion status, actual kickoff, teams, player identity, minutes, and position evidence MUST be validated. Missing required portions or undecidable completeness MUST fail the whole import; no partial success is allowed.
- **FR-004**: An accepted import MUST persist all newly accepted match/performance facts, their provenance, and the successful check outcome for that scope atomically. Failed, incomplete, conflicting, or exhausted attempts MUST NOT update the successful-check state. A complete unchanged or replayed result MAY record a successful check without duplicating facts.
- **FR-005**: Match and performance identities MUST reuse TASK-016 and TASK-020 identity rules. Exact replays MUST be idempotent, including concurrent submissions and job redelivery. Conflicting content for an accepted immutable fact MUST fail without replacement, deletion, or partial acceptance. A conflict MUST NOT be disguised as a replay.
- **FR-006**: Each accepted fact MUST retain provider attribution, retrieval instant, qualified source identity binding, and accepted import reference as available under TASK-016. Fixture-backed facts MUST additionally retain a stable fixture identifier and content fingerprint, fixture origin and capture or synthetic-creation date, and the expected fixture outcome/rule coverage. Fixture provenance MUST be visibly distinguishable from live-source provenance.
- **FR-007**: Provenance MUST NOT require retaining unsafe raw provider responses. Only approved/sanitized stable fixture artifacts may be retained for deterministic offline traceability. Credentials, raw payloads, transport diagnostics, and exception text MUST NOT be exposed in domain facts, import history, or errors.
- **FR-008**: Unknown or unavailable optional metrics MUST remain unknown through import and reads, distinct from explicit zero. Ingestion MUST NOT infer zero from omission, unsupported coverage, missing records, failed details, aggregate data, or inability to observe an event.
- **FR-009**: For a player who starts and has a provider-supplied match-specific event-time position, ingestion MUST preserve that position unchanged as the effective position and mark it as direct-source provenance. Current profile position MUST NOT rewrite it.
- **FR-010**: When the selected source identifies a player as a substitute who entered and does not provide a trusted match-specific event-time position, the effective position MUST be the uniquely most frequent position across that player's accepted performances in the same season strictly before the match being valued. The subject match and any later match MUST be excluded. Frequency MUST count prior matches, not minutes or another provider's published usual-position field. The selected position MUST be stored with the performance and its derived-history provenance, including the historical basis sufficient to explain the selection. A provider's `usualPosition` is not a trusted match-specific position.
- **FR-011**: When a substitute has no prior same-season performance with a known position, or when multiple positions share the greatest prior-match frequency, the effective position MUST remain unknown and its reason MUST be recorded. No arbitrary tie-breaker, current affiliation, later history, or published usualPosition may fill it. For a missing position in any other circumstance, ingestion MUST fail validation rather than derive or guess. TASK-016's source-result required-position rule and TASK-020's persisted required-position rule MUST be reconciled before implementation so the specified substitute derivation and explicit unknown can be represented without overwriting accepted facts.
- **FR-012**: A scope import MUST produce a safe, inspectable outcome distinguishing accepted-with-changes, accepted-unchanged, replay, invalid/incomplete result, immutable-fact conflict, source capability/access refusal, retryable temporary failure, exhausted retry, and interruption where applicable. Import status MUST remain independent from downstream valuation or quote status.
- **FR-013**: After accepted data changes commit, ingestion MUST request downstream calculation through the established retry-safe domain boundary. A calculation request or failure MUST NOT roll back accepted statistics or be represented as a failed import; import and quote outcomes MUST remain separately observable. This feature MUST NOT define scoring formulas or create/overwrite quotes.
- **FR-014**: Retry only failures classified retryable by TASK-016 and transient persistence/execution conditions, subject to TASK-019's finite attempt budget and delay rules. Access denial, unsupported capability, incomplete or invalid data, and immutable-fact conflict MUST NOT be retried as transient failures. No live access may be enabled by a schedule, fixture success, or configuration switch alone; TASK-055 and ADR-0018 access and coverage gates apply to every attempt.
- **FR-015**: Ingestion MUST preserve local reads during provider failure and MUST NOT make provider calls during local history reads. It MUST NOT add a provider boundary, public endpoint, new user permission, cache, Redis processing ledger, catalog synchronization, freshness-request/read API, scoring/normalization policy, quote logic, trading, charts, or conditional-order behavior.
- **FR-016**: Automated deterministic offline evidence MUST cover complete, incomplete, empty, unchanged, replayed and conflicting imports; atomic rollback; retries, redelivery and concurrent duplicates; source and fixture lineage; every optional metric's unknown-versus-zero behavior; and direct, unique-derived, tied and insufficient-history substitute positions. Fixture/source-shaped evidence MUST be independently expected and MUST perform zero live requests or require real credentials.

### Key Entities *(include if feature involves data)*

- **Statistics Import Run**: One requested league-season check with selected source/fixture, safe lifecycle/outcome, attempt history, and accepted-scope reference.
- **Imported Match and Performance**: TASK-020 football facts accepted from a completed source result, immutable after acceptance, and deduplicated by their domain identities.
- **Fact Provenance**: Provider or fixture attribution for an accepted fact, including retrieval/source identity or fixture reference/fingerprint and import relationship.
- **Position Evidence**: The effective event-time position plus whether it came directly from the match source or was derived from the player's prior same-season history; unknown reason and derivation basis when no unique position exists.
- **Scope Check Outcome**: The result of a complete accepted check or a safe failure; it is distinct from job execution state and downstream valuation state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Across deterministic complete-scope examples, 100% of accepted matches, performances, provenance links, and check outcomes are independently readable and refer to the requested scope.
- **SC-002**: Replaying an accepted import any number of times, including concurrent redelivery, produces zero duplicate facts and preserves 100% of previously accepted immutable content.
- **SC-003**: Every incomplete, invalid, conflicting, or non-retryable example results in zero partial fact changes and zero advancement of successful-check state.
- **SC-004**: All optional metric examples preserve the distinction between unknown and explicit zero, and all substitute-position examples yield the unique prior-season mode or an explicit unknown for ties/insufficient history.
- **SC-005**: Every accepted fixture-backed fact is traceable to a stable sanitized fixture reference and fingerprint; every accepted provider-backed fact retains the provider/source attribution available under the shared contract.
- **SC-006**: Import and quote-calculation outcomes can be independently identified for every tested success and failure path; no import success is reported as a completed quote calculation.
- **SC-007**: The full deterministic offline acceptance set runs with zero external source calls, zero real credentials, and no claim of live readiness where access or coverage is unverified.

## Assumptions

- TASK-016 is the sole provider-neutral retrieval/provenance contract; TASK-055 owns source translation, access, and coverage evidence; TASK-018 and TASK-020 own catalog and immutable match/performance domain facts; TASK-019 owns the durable local Oban runtime and finite retry policy.
- The specified unit of completeness/check state is the requested league-season statistics scope for the explicitly selected source or fixture. A smaller request must not be presented as a complete season check.
- A complete accepted check with no changes may update its successful-check time/state; freshness read and request behavior belongs to TASK-056.
- Statistics imported from fixtures are suitable for deterministic offline development and demonstration only. They do not establish provider permission, source coverage, freshness, or a recalculated quote.
- Historical position frequency uses only already accepted, known event-time positions for the same catalog player and season in strictly earlier matches. The source must identify a player as a substitute entrant before this derivation applies. No season-boundary inference beyond catalog season identity is added.
- Existing TASK-016 and TASK-020 contracts require known event-time positions. Planning must specify the smallest compatible reconciliation that permits source omission for identified substitutes, the approved historical derivation, and an unknown effective position for ties/insufficient history without mutating existing immutable facts or silently reopening TASK-020 implementation.
- This feature imports facts and requests downstream calculation after accepted changes; it does not choose or implement valuation behavior, quotes, or the CP2 charts and conditional-order feature.

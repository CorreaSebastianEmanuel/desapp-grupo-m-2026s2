# Feature Specification: Quote Recalculation and Immutable History

**Feature Branch**: `026-quote-recalculation-and-immutable-history`

**Created**: 2026-10-17

**Status**: Draft

**Input**: TASK-026 — Calculate quotes from accepted persisted statistics and versioned strategies; append reproducible immutable history. Emit durable follow-up evaluation after confirmed quote changes for TASK-060. Retry safely and track calculation separately from statistics import.

## User Scenarios & Testing *(mandatory)*

The actors are trusted market maintainers and internal calculation consumers. This feature values an existing issued player's accepted performance history. TASK-021 remains the authority for import acceptance and immutable statistics; TASK-025 remains the authority for strategy versions and active selection. A calculation fixes one strategy version and one player/season/week scope and never changes the underlying football facts or strategy configuration.

### User Story 1 - Recalculate a Player Quote from Accepted Performance (Priority: P1)

As a market maintainer, I need a player's quote calculated from accepted local performance facts and one explicitly identifiable saved strategy version, so the market price reflects reviewed football evidence and rules.

**Why this priority**: Dated performance-based quotes are a core CP2 market capability and are required for trading, ranking, and conditional order evaluation.

**Independent Test**: Calculate a quote for an issued player with deterministic accepted weekly statistics and a saved strategy version; independently verify the exact resulting price, effective time, selected facts, and strategy identity without provider access.

**Acceptance Scenarios**:

1. **Given** an initialized player, an accepted player/season/week statistics set, and a valid active saved strategy version, **When** a calculation is requested, **Then** it fixes that version before selecting facts, calculates from the accepted local facts under the existing valuation contract, and records the resulting quote with its effective time and strategy identity/version.
2. **Given** a calculation has fixed strategy version A and version B becomes active before it completes, **When** that calculation is recorded, **Then** its quote and retained evidence remain bound to A; a later calculation may use B.
3. **Given** an explicit request names a saved inactive strategy version, **When** the calculation is requested, **Then** that version is used and retained without changing the active selection.
4. **Given** accepted facts are amended neither by import nor calculation, **When** the quote is calculated, **Then** its evidence identifies the exact original fact membership and reproduces the same score and quote from the retained rules and facts.
5. **Given** the selected mapping version has an exact scale of 1.25 and the strategy score is 2.000000, **When** the price is converted, **Then** the quote is 2.50; a score at or below zero or a converted result that rounds to zero or below records a no-quote outcome without a price or floor.

### User Story 2 - Preserve Quote and Calculation History (Priority: P1)

As a market-history consumer, I need every confirmed calculated quote and its calculation evidence to remain available unchanged, so I can inspect and reproduce historical market valuations after later facts or strategy selections arrive.

**Why this priority**: Quotes affect financial transactions and must remain auditable; latest values must not erase past prices or their inputs.

**Independent Test**: Record a calculation, then activate another strategy and make a later fresh calculation for the same scope; read both records and reproduce the original calculation after a fresh application restart.

**Acceptance Scenarios**:

1. **Given** a successful fresh calculation produces a quote, **When** later calculations produce different quotes, **Then** each quote remains separately retrievable with its own effective time, strategy configuration identity, and reproducible evidence; no prior quote is edited or removed.
2. **Given** a calculation is retried after its durable result committed but before job completion was observed, **When** the retry runs, **Then** it returns the already recorded calculation outcome and does not append duplicate quote or downstream work.
3. **Given** a late accepted fact changes the selected membership for a previously valued week, **When** a fresh calculation is explicitly requested, **Then** it creates a new result based on the new complete accepted membership and preserves the original result and membership for replay.
4. **Given** a calculation cannot produce a score because data is absent, insufficient, unsupported, or inconsistent, **When** its outcome is recorded, **Then** it remains a distinct no-quote result and does not replace or fabricate a quote.

### User Story 3 - Track Recalculation and Trigger Durable Follow-up (Priority: P1)

As a market maintainer and a downstream conditional-order evaluator, I need calculation progress and outcomes to be independent of statistics-import status, and confirmed quote updates to leave durable follow-up work, so retries and interruptions cannot silently skip evaluation.

**Why this priority**: A successful import is not proof that a quote exists, and TASK-060 must be able to recover evaluation work after committed quote changes.

**Independent Test**: Accept changed statistics, interrupt or fail quote calculation, then retry; separately confirm a quote and interrupt before the follow-up worker runs; inspect independent statuses and recover the durable follow-up without duplicating it.

**Acceptance Scenarios**:

1. **Given** a statistics import is accepted with changes, **When** downstream calculation is requested, **Then** the import remains accepted independently while calculation has its own pending, running, successful, no-quote, or failed outcome.
2. **Given** accepted statistics are unchanged or replayed, **When** import completes, **Then** it does not create duplicate quote calculations merely because the same import was redelivered.
3. **Given** a new quote is committed, **When** the transaction completes, **Then** durable follow-up evaluation work for that confirmed quote is recorded atomically and is discoverable after process restart.
4. **Given** follow-up evaluation work is retried or delivered more than once, **When** it is processed, **Then** each downstream evaluation refers to the confirmed quote and duplicate delivery does not create duplicate effective work.
5. **Given** quote calculation encounters a retryable temporary failure, **When** its bounded retry policy permits another attempt, **Then** it retries without duplicating a committed quote; invalid data, unsupported strategy, or unreproducible evidence yields an explicit non-retryable calculation outcome and no quote.

### Edge Cases

- There is no active strategy, the selected configuration is missing, or a requested strategy identity is malformed or unsupported.
- Accepted statistics for the requested player/season/week are empty, incomplete under the accepted contract, have unknown required metrics, or cannot be replayed from original facts.
- A prior quote exists from initial issuance but no performance quote exists yet; no initialization quote is overwritten.
- Repeated or concurrent requests refer to the same logical calculation, or overlap while a different strategy version is selected.
- A fresh calculation reproduces the same unit price as the current quote; history and downstream event semantics must remain unambiguous.
- A calculation commits but its worker acknowledgement is lost, or a quote commits while the process stops before in-memory notification.
- Strategy scoring returns zero or a negative value, or a positive converted value rounds to zero at the required quote precision.
- A temporary database/worker failure occurs after facts are read but before the quote and follow-up work commit.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST calculate a market quote only for an existing initialized player and a defined player/season/week valuation scope, using accepted locally persisted statistics and the TASK-025 active strategy version or a valid explicitly requested saved version. It MUST NOT fetch provider data while calculating.
- **FR-002**: Every calculation MUST fix and retain one complete immutable strategy configuration identity before selecting facts. A concurrent active-selection change MUST affect only calculations that have not yet fixed their strategy version.
- **FR-003**: The calculation MUST use the existing approved valuation/scoring contract, including its canonical fact selection, exact arithmetic, rounding, safe errors, and original-replay rules. This feature MUST NOT introduce or alter a scoring formula.
- **FR-004**: Every successful quote or explicit no-quote calculation MUST retain enough protected evidence to identify the player, season/week, effective calculation time, selected accepted fact identities and values or immutable references, full original strategy/configuration identity and rules, score, and quote-conversion mapping identity/version, exact scale, and rounding rule. Replaying the retained calculation MUST use the original membership and original rules, never current strategy selection or later facts. If required original facts or rules cannot be recovered or verified, replay MUST fail explicitly rather than substitute current data.
- **FR-005**: Every successful fresh calculation MUST append an immutable dated quote-history record containing the exact unit price, player, strategy identity and version, saved configuration identity, quote-conversion mapping identity and version, effective time, and link to its retained calculation evidence. Initial issuance history MUST remain intact. A fresh calculation MAY append a quote at the same unit price as the current quote when its facts, strategy configuration, or conversion mapping differ; exact retries of the same logical calculation MUST NOT append a second quote.
- **FR-006**: A strategy score MUST be converted to a unit quote by multiplying it by the strictly positive exact-decimal scale fixed in a versioned quote-conversion mapping, then rounding the product to two decimal places using nearest with ties away from zero. The mapping identity/version, exact scale, and rounding rule MUST be retained in calculation evidence. The mapping MUST be deterministic and monotonic for positive scores and MUST NOT use binary floating-point arithmetic. If the raw score is zero or negative, or the rounded converted result is zero or negative, the calculation MUST record an explicit non-quote outcome with no unit price; it MUST NOT apply a floor or invent a positive price. No production scale/default is implied by illustrative fixtures: the selected mapping version MUST carry its explicit scale.
- **FR-007**: Each logical calculation MUST have a durable, inspectable outcome separate from its originating statistics import. Outcomes MUST distinguish at least pending/running, successful quote, valid no-score/no-quote, validation or unsupported-strategy failure, unreproducible evidence, retryable temporary failure, and exhausted retry where applicable. An accepted import MUST remain accepted if later valuation fails.
- **FR-008**: Acceptance of imported facts that change a valuation scope MUST durably create or make recoverable a valuation request as part of the same accepted-import operation, so interruption cannot leave accepted changed facts without inspectable pending calculation work. Replayed or unchanged import requests MUST NOT create duplicate logical calculations. A trusted explicit recalculation MAY request valuation for a changed fact membership, saved strategy configuration, or conversion mapping version.
- **FR-009**: A newly committed quote MUST create durable downstream evaluation work for TASK-060 as part of the same atomic confirmation, so a crash cannot leave a quote without its required follow-up. Follow-up delivery MUST be safe to retry and MUST identify the exact confirmed quote. No downstream evaluation is emitted for a failed or no-quote calculation.
- **FR-010**: A logical calculation MUST be identified by the player, season/week scope, canonical immutable accepted-fact membership, saved strategy configuration identity/version, and quote-conversion mapping identity/version. Duplicate requests, concurrent calculations, job redelivery, and interrupted completion acknowledgements for that identity MUST yield at most one committed quote and one durable follow-up. Changed membership, strategy configuration, or conversion mapping MUST produce a distinct logical calculation; repeating identical inputs is a retry and MUST NOT create a second dated quote.
- **FR-011**: A failed calculation MUST NOT change quote history, current quote selection, accepted statistics, saved strategy configurations or selections, token holdings, balances, trades, or prior calculation evidence.
- **FR-012**: Local quote/history reads and calculation replay MUST work without external-provider availability. A provider failure MUST NOT alter prior quotes or make local reads fail.
- **FR-013**: Calculation and downstream follow-up failures MUST be safely inspectable without exposing credentials, raw provider payloads, exception contents, or unsafe diagnostics. Import, calculation, quote, and follow-up states MUST remain distinguishable.
- **FR-014**: This feature MUST be limited to calculation orchestration, strategy-bound quote evidence, immutable performance quote history, calculation outcomes, and durable follow-up for TASK-060. It MUST NOT redefine strategy formulas/configuration lifecycle, statistics ingestion, public quote APIs, trading, charting, ranking, conditional-order rules or UI, provider access, market initialization, or administrative permissions.
- **FR-015**: Automated deterministic acceptance evidence MUST cover exact decimal conversion and ties-away rounding; zero/negative score and zero/negative converted-result no-quote outcomes; strategy fixation across concurrent selection change; active and explicit-version calculation; missing/unknown/unsupported data; immutable original replay after late facts and strategy changes; calculation/import status separation and recovery after interruption at import acceptance; sequential/concurrent duplicate requests; retry after pre-commit failure and lost acknowledgement; atomic quote/follow-up persistence; and safe local behavior without provider calls.

### Key Entities *(include if feature involves data)*

- **Quote Calculation**: One durable attempt/result for a player, season/week, accepted fact membership, and fixed strategy configuration; records safe status, timing, and retry lineage.
- **Calculation Evidence**: Protected original facts or immutable fact references, complete strategy/configuration identity and rules, score, conversion mapping identity/version and exact scale, rounding rule, and reproducibility information for one successful quote or no-quote calculation.
- **Performance Quote**: An append-only dated unit price for one player, linked to the calculation that produced it and labeled with the strategy and configuration used.
- **Quote Evaluation Request**: Durable follow-up identifying a newly confirmed quote for downstream conditional-order evaluation; retries refer to the same confirmed quote.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In 100% of successful acceptance cases, the exact quote is independently derivable from the retained accepted facts, complete saved strategy version, and approved conversion rule, with no provider call.
- **SC-002**: In 100% of tested strategy-switch and restart cases, each quote replays to its original score and exact unit price using its original fact membership and rules; missing originals fail explicitly.
- **SC-003**: In every duplicate or concurrent retry case, each canonical logical calculation identity has at most one quote and one durable follow-up, while changed facts, strategy versions, or conversion mapping versions are represented by distinct immutable results.
- **SC-004**: In every simulated crash boundary after quote confirmation, exactly one recoverable durable follow-up exists for that quote; pre-commit failures leave no quote or follow-up.
- **SC-005**: For every tested import and calculation path, import and calculation outcomes are independently inspectable; successful statistics import is never reported as completed quote calculation.
- **SC-006**: In 100% of conversion cases, the positive score is multiplied by the exact scale from its retained mapping version and rounded to two decimal places using nearest/ties-away-from-zero; zero or negative scores and zero or negative rounded results produce an explicit non-quote outcome with no price or floor.
- **SC-007**: Every no-score, invalid, unsupported, unreproducible, or exhausted calculation leaves prior quote history and all financial state unchanged.

## Assumptions

- TASK-021 owns acceptance, provenance, and immutability of statistics; TASK-025 owns immutable strategy configuration, active selection, and version-bound managed scoring; their canonical specifications and contracts remain authoritative.
- The stable player identity and existing market quote history established by TASK-028 are reused. A performance quote supplements the fixed initial quote; it does not rewrite or replace the initial issuance record.
- One quote calculation is scoped to a player's accepted statistics for one season/week. Any different scope definition requires updating this spec before implementation.
- Calculation triggered by accepted changed statistics uses the active strategy fixed when that calculation begins. Explicit trusted recalculation can target a saved inactive version without changing market-wide selection.
- Accepted statistics and strategy versions are immutable; corrected/late accepted inputs or a different strategy are represented by a fresh calculation, not by rewriting an earlier quote.
- No approved production strategy preset or calibration scale is implied by test fixtures. A production quote-conversion mapping must explicitly set its positive scale; strategy versions, scales, scores, and quote prices remain exact decimal values and never use binary floating-point arithmetic.
- Calculation attempts and quote persistence are separate from statistics import completion; quote follow-up durability is required for TASK-060 while user notifications remain outside this feature.

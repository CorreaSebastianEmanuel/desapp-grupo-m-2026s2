# Feature Specification: Active Strategy Player Ranking

**Feature Branch**: `033-active-strategy-player-ranking`

**Created**: 2026-10-26

**Status**: Draft

**Input**: TASK-033 — Expose deterministic ranking based on the active strategy and latest valid quotes.

## User Scenarios & Testing

The actors are authenticated market users who want to compare players using the market's currently selected valuation strategy. The ranking is a read of retained quote history and the active strategy selection. It does not calculate or change quotes.

### User Story 1 - View the Active Strategy Ranking (Priority: P1)

As a market user, I want players ordered by their latest valid quote under the active strategy, so I can compare their current market values consistently.

**Why this priority**: Active-strategy ranking is a retained CP2 market capability and makes strategy-based quotes comparable in one market view.

**Independent Test**: Set an active strategy configuration and provide successful, non-successful, initial, and inactive-strategy quote records for multiple issued players. Read the ranking and verify eligible players, each selected quote, ordering, and strategy identity without provider access or writes.

**Acceptance Scenarios**:

1. **Given** an active saved strategy configuration and issued players with successful performance quotes bound to it, **When** an authenticated user reads the ranking, **Then** each player with at least one eligible quote appears once, represented by that player's latest eligible quote, and the response identifies the active strategy configuration used.
2. **Given** eligible quotes with different unit prices, **When** the ranking is read, **Then** players are ordered by unit price from highest to lowest and receive consecutive positions beginning at 1.
3. **Given** players whose selected quotes have equal unit prices, **When** the ranking is read repeatedly, **Then** their order is stable by ascending canonical player identifier and their positions remain consecutive and deterministic.
4. **Given** a player has multiple eligible quotes with equal effective times, **When** the ranking selects that player's latest quote, **Then** the quote with the greater per-player performance sequence is selected.
5. **Given** a player's newest overall quote belongs to another strategy configuration but the player has an earlier successful quote for the active configuration, **When** the ranking is read, **Then** the latest quote for the active configuration is selected; a quote from another configuration never changes the active-strategy ranking.
6. **Given** a player has only an initial issuance quote, a quote for another configuration, or no successful performance quote for the active configuration, **When** the ranking is read, **Then** that player is omitted.
7. **Given** no strategy configuration is active, **When** an authenticated user reads the ranking, **Then** the system returns a distinct no-active-configuration outcome and does not present an empty ranking as if it were a valid active-strategy result.
8. **Given** there is an active configuration but no eligible quotes, **When** an authenticated user reads the ranking, **Then** the system returns a successful empty ranking that identifies the active configuration.
9. **Given** the active configuration changes while the ranking is being read, **When** the read completes, **Then** the ranking and its reported configuration reflect one consistent read snapshot and never mix quotes from different active configurations.

### Edge Cases

- No quote for a player is not a zero-valued quote and does not create a ranking entry.
- A successful quote must be selected only from quotes bound to the exact active saved configuration identity and version; matching a strategy name alone is insufficient.
- Explicit calculations using an inactive saved version remain valid history but are ineligible unless that exact configuration becomes active.
- Same-price players are not assigned shared positions; identifier ordering gives a total order and consecutive positions.
- Storage or active-configuration read failures remain visible errors and must not be converted into a successful empty ranking.
- Provider unavailability does not affect ranking because its facts come from locally retained quote history.

## Requirements

### Functional Requirements

- **FR-001**: The system MUST provide an authenticated, read-only player ranking based on the currently active saved strategy configuration and retained valid quote history.
- **FR-002**: A ranking read MUST use one consistent view of the active configuration and quote history. Its result MUST identify the configuration identity and strategy identity/version used to determine eligibility.
- **FR-003**: A quote is eligible only when it is a successfully committed positive performance quote bound to the exact active saved configuration identity/version. Initial issuance quotes, no-quote outcomes, failed or incomplete calculations, and quotes bound to any other configuration MUST NOT qualify.
- **FR-004**: For each issued player, the system MUST select the latest eligible quote by greatest effective time, breaking equal-time ties by greatest per-player performance sequence. Each eligible player MUST appear once with that quote's unit price and effective time.
- **FR-005**: The ranking MUST order selected players by unit price descending, then by ascending canonical player identifier for equal prices. It MUST assign consecutive one-based positions in the resulting order, without gaps or shared tie positions.
- **FR-006**: Players with no eligible quote MUST be omitted; missing quotes MUST NOT be represented as zero, inferred, calculated, or replaced with an issuance quote.
- **FR-007**: If no strategy configuration is active, the system MUST return a distinct no-active-configuration outcome. If an active configuration exists and no quotes qualify, it MUST return a successful empty ranking identifying that configuration.
- **FR-008**: The ranking read MUST NOT recalculate or append quotes, change strategy activation, access external football providers, enqueue jobs, or modify financial, valuation, or audit records.
- **FR-009**: Authentication, quote precision, immutable quote history, strategy configuration identity, and safe infrastructure-error behavior MUST preserve the existing market contracts. Storage failures MUST remain distinguishable from a valid empty result.
- **FR-010**: Behavioral tests MUST cover active and absent strategy, matching and nonmatching configuration identities, initial-only/no-quote players, latest selection across seasons and quote times, equal-time sequence tie-breaking, descending price order, equal-price identifier order, consecutive positions, consistent configuration snapshot, provider independence, read-only behavior, and visible storage failure.
- **FR-011**: Scope MUST remain the authenticated ranking read and its deterministic selection/order semantics. Strategy formulas and activation belong to their existing strategy contracts; quote creation and immutable history belong to TASK-026; individual quote reads/history belong to TASK-027; ranking presentation belongs to TASK-047; caching belongs to TASK-041. No recalculation, strategy-management, trading, charts, conditional orders, provider, or UI behavior is added here.

### Key Entities

- **Active Strategy Configuration**: The currently selected immutable strategy configuration identity, including the strategy identity and formula version that bound market quotes.
- **Eligible Performance Quote**: A successfully committed, positive, dated quote with an immutable link to the exact strategy configuration that produced it.
- **Ranking Entry**: One issued player, its selected eligible quote, the quote's effective time, and its consecutive ranking position.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Every eligible player appears exactly once and every ineligible player appears zero times in 100% of specified ranking cases.
- **SC-002**: Repeated reads over unchanged active configuration and quote history produce identical entries, selected quote identities, and ordering in 100% of cases.
- **SC-003**: For every ranking with N eligible players, positions are exactly the consecutive integers 1 through N, ordered by descending quote price and ascending player identifier for ties.
- **SC-004**: Ranking reads cause zero quote, strategy, provider, job, or financial writes and require zero external-provider availability.
- **SC-005**: Users can distinguish a valid empty ranking from an unavailable active configuration and from an infrastructure failure in every defined outcome.

## Assumptions

- Authenticated market users may read the ranking under the existing protected market-read access policy; the feature introduces no new role or permission tier.
- “Latest valid quote” means the latest successful performance quote matching the exact active saved configuration. A newer quote from an inactive configuration does not replace an older quote from the active one.
- Quote effective time is the primary recency ordering across all available quote history for a player, including different seasons; per-player performance sequence breaks only equal effective times.
- A change in active configuration can temporarily reduce or empty the ranking until successful quotes exist for players under that configuration. The ranking does not trigger automatic repricing or fall back to another configuration.
- The deterministic player identifier tie-break is an ordering rule, not a user-visible quality score or claim that tied players have different performance.
- Ranking is a market read of quote values, not a separate calculation of valuation scores or financial return.

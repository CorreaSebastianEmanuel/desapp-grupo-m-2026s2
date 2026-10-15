# Feature Specification: Initial Player Token Issuance

**Feature Branch**: `028-initial-player-token-issuance`

**Created**: 2026-10-14

**Status**: Draft

**Input**: User description: "TASK-028 — Issue exactly 100 tokens per player to the superuser at the initial quote."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Establish a Player's Initial Market Inventory (Priority: P1)

As the market operator, I can initialize an existing catalog player so that the market starts with exactly 100 tokens, all owned by the designated superuser, at one credit per token.

**Why this priority**: Fixed initial supply and ownership are prerequisites for buying, selling, and valuing a player's tokens.

**Independent Test**: Initialize an unissued catalog player using an existing designated superuser. Verify total supply, ownership, the exact initial quote, and the issuance record together, then retrieve the same facts after a fresh read.

**Acceptance Scenarios**:

1. **Given** an existing catalog player with no issuance, holdings, or quote history and one existing designated superuser, **When** trusted market initialization is requested for that player, **Then** exactly 100 whole tokens are issued, the superuser owns all 100, every other user owns zero, and the initial quote is exactly one credit per token.
2. **Given** successful initialization, **When** the initial market state is read again, **Then** the player, superuser, quantity of 100, unit quote of one credit, initial inventory value of 100 credits, effective date, and version of the initialization valuation rule remain identifiable from durable records.
3. **Given** multiple distinct unissued catalog players, **When** each is initialized, **Then** each has its own supply of 100 and its own issuance record, all initially owned by the same designated superuser; tokens for one player are never counted toward another player's supply.
4. **Given** the superuser and other users have existing credit balances, **When** issuance succeeds, **Then** those balances remain unchanged because initial allocation is not a purchase or a sale.

---

### User Story 2 - Safely Repeat or Resume Initialization (Priority: P1)

As the market operator, I can retry initialization after a repeated request, competing request, or interrupted attempt without minting extra tokens or resetting market state.

**Why this priority**: Repeated setup must preserve the fixed supply and immutable history throughout the player's market lifetime.

**Independent Test**: Repeat and concurrently request initialization for one player, and retry an attempt interrupted before completion. Verify that there is only one successful issuance and that retries return the established issuance or a clear failure without further effects.

**Acceptance Scenarios**:

1. **Given** an initialized player, **When** initialization is requested again with the same designated superuser, **Then** the result identifies the existing issuance as already completed and adds no tokens, holdings, quotes, or issuance records.
2. **Given** an unissued player, **When** two requests attempt to initialize it concurrently, **Then** at most one new issuance completes; every successful result refers to that same issuance, and final supply is exactly 100.
3. **Given** an attempt fails before initialization completes, **When** the state is inspected and initialization is retried after the failure is resolved, **Then** the failed attempt left no issuance effects and the retry can create exactly one complete issuance.
4. **Given** the player was initialized and later valid trading has distributed 20 tokens to another user while the superuser retains 80, **When** initialization is requested again, **Then** those holdings and all balances remain unchanged, total supply stays 100, and the original issuance is returned.
5. **Given** the player was initialized at one credit and later has additional dated quotes, **When** initialization is requested again, **Then** all quote history and the then-current quote remain unchanged, and the original initial quote is still associated with the issuance.

---

### User Story 3 - Reject Unsafe Initialization with Clear Feedback (Priority: P2)

As the market operator, I receive a clear failure when initialization prerequisites or existing market state are invalid, so that setup cannot silently assign ownership incorrectly or hide a supply inconsistency.

**Why this priority**: Bad setup must be recoverable without creating or rewriting financial history.

**Independent Test**: Attempt initialization with a missing player, invalid superuser designation, conflicting recipient, and inconsistent existing market state. Verify the rejection reason and absence of issuance effects in each case.

**Acceptance Scenarios**:

1. **Given** a player identity that does not exist, **When** initialization is requested, **Then** the result identifies the missing player and no market state is created.
2. **Given** no designated superuser, multiple designated recipients, or a designation referring to a nonexistent user, **When** initialization is requested, **Then** the result identifies the invalid superuser designation and no market state or user account is created.
3. **Given** one existing designated superuser, **When** initialization requests allocation to a different user or requests a quantity or initial unit price other than 100 and one credit, **Then** the request is rejected without changing ownership, supply, quotes, or balances.
4. **Given** holdings or quote history exist without a completed issuance, or a completed issuance exists with total holdings other than 100 or missing required issuance facts, **When** initialization is requested, **Then** an inconsistent-state failure is reported and the existing state is left unchanged rather than repaired or topped up.
5. **Given** a player was issued to one superuser, **When** initialization is repeated with a different designated recipient, **Then** a recipient-conflict failure is reported and no tokens are reassigned.
6. **Given** one player was issued to superuser A and another player remains unissued, **When** the market designation is changed to user B and initialization of the unissued player is requested, **Then** a market-wide recipient-conflict failure is reported and the unissued player's market state remains unchanged.
7. **Given** a completed issuance for the requested player and its original recipient, **When** initialization is retried while the superuser designation is invalid or the existing market state is inconsistent, **Then** the applicable validation failure is reported instead of an already-completed success, and no market state is changed.

### Edge Cases

- First initialization may proceed without imported player statistics or an active performance-valuation strategy: the fixed one-credit starting rule supplies the initial quote.
- A player with no completed issuance has no issued market inventory and cannot be represented as an initialized player with a zero-token supply.
- Reinitializing a player whose superuser now owns zero tokens does not replenish that superuser; the original issuance and total holdings across all owners govern the result.
- A changed display name, catalog refresh, or repeated request for the same stable player identity does not create another issuance. Distinct season-specific player records retain the distinct identities established by TASK-005.
- Concurrent attempts with conflicting recipient designations cannot both allocate inventory; a recipient conflict or an invalid designation is reported without a second issuance.
- Concurrent first issuances for different players cannot establish different market-wide superusers; only the consistent recipient's issuance may complete.
- Failure while creating the initial quote, holdings, or issuance record leaves none of those effects visible as a completed initialization.
- A later quote of a different value never changes the recorded initial unit quote or its effective date and rule version.
- Existing incomplete or contradictory market records are reported for investigation; initialization does not delete them, manufacture missing tokens, or rewrite history.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST support trusted market initialization for an existing catalog player's stable identity. Initialization MUST use exactly one market-wide designated existing superuser as the recipient; ordinary market users MUST NOT be able to select themselves or another account as an issuance recipient. Once any initial issuance completes, its original recipient MUST remain the initial recipient for every player's issuance, including concurrent first issuances for different players. A subsequent designation of a different account MUST cause a recipient-conflict failure rather than a new allocation.
- **FR-002**: First successful initialization MUST issue exactly 100 whole tokens for that player, with all 100 initially owned by the designated superuser and zero allocated to any other user. Initial quantity MUST NOT be caller-configurable.
- **FR-003**: First successful initialization MUST establish a durable initial quote of exactly one credit per token and associate it with the issuance. The quote MUST identify its effective date and the version of the fixed initialization valuation rule; the issuance MUST record when it completed. The effective date MUST represent initialization, not a supplied historical performance date.
- **FR-004**: Token quantities MUST be whole numbers. Initial unit quote and inventory value MUST retain exact credit values without floating-point arithmetic: 100 tokens at one credit each have an initial value of exactly 100 credits.
- **FR-005**: Initial allocation MUST NOT debit or credit any user's money balance or record a purchase or sale. One credit is the starting valuation of each token, not a payment by the superuser.
- **FR-006**: Initial supply, superuser holdings, initial quote, and the completed issuance record MUST become durable together. A failed attempt MUST leave no new supply, holdings, quotes, completed issuance record, or balance changes from that attempt.
- **FR-007**: There MUST be at most one completed initial issuance per stable player identity, including under concurrent requests and repeated requests with different invocation identifiers. Once initialized, the player's total holdings across all owners MUST sum to exactly 100; initialization MUST never increase, reduce, or replenish that supply.
- **FR-008**: Repeating initialization for an already initialized player and its original superuser MUST return the existing issuance with an unambiguous already-completed outcome only when the current designation is valid and consistent and the existing market state passes FR-011. Invalid prerequisites, recipient conflicts, or inconsistent state MUST produce the applicable failure instead. A valid retry MUST NOT change current holdings, balances, current or historical quotes, the original recipient, or the original issuance facts, even after later valid trading or valuation changes.
- **FR-009**: The successful issuance record MUST durably identify the player, original recipient, issued quantity, exact initial unit quote, associated initial quote, and completion time. Issuance and quote history MUST be append-only; neither first initialization nor retries may overwrite historical records. These facts MUST remain retrievable for verification of initial ownership and valuation.
- **FR-010**: Initialization MUST reject a missing player, absent or ambiguous superuser designation, nonexistent designated account, a requested recipient inconsistent with that designation, noncanonical requested quantity or price, or a recipient conflicting with any existing initial issuance in the market. Failures MUST identify the rejected prerequisite or conflict and leave market state unchanged. These checks MUST apply to both first issuance and retries, before an already-completed success can be returned; where multiple failures coexist, reporting any applicable failure is sufficient.
- **FR-011**: First initialization MUST require an absence of prior holdings and quote history for that unissued player. Initialization MUST reject inconsistent state, including holdings or quotes without completed issuance, a completed issuance missing its required facts, or total holdings inconsistent with the fixed supply. It MUST report that condition without automatically repairing ownership, supply, or history.
- **FR-012**: Initialization MUST rely on existing local player and user identities and the fixed starting rule; external-provider availability, imported statistics, and performance-valuation configuration MUST NOT be prerequisites.
- **FR-013**: Automated behavioral tests MUST cover every acceptance scenario and edge case, including exact initial quantity and price, original ownership, unchanged balances, independent players, durable issuance facts, sequential and concurrent duplicate attempts, retry after failure, market-wide recipient consistency across sequential and concurrent issuances, invalid prerequisites, inconsistent state, failure precedence over already-completed success, and preservation after later holdings and quote changes. Later market states may be supplied as controlled test fixtures; this task does not implement trading or quote recalculation.
- **FR-014**: This feature MUST be limited to initial token supply, initial ownership, the fixed starting quote, issuance evidence, and safe initialization outcomes. User creation, credential changes, a general role-management system, automatic catalog-ingestion hooks, new public initialization interfaces, token purchases or sales, user balance funding, performance-based valuation, quote-query interfaces, portfolio presentation, ranking, and conditional orders are outside scope.

### Key Entities

- **Player**: An existing season-specific catalog player identified by TASK-005's stable internal identity; one identity defines one token supply.
- **Superuser**: The single existing user designated by trusted market setup to receive initial allocations; a request cannot choose an arbitrary recipient.
- **Player Token Supply**: The fixed issuance of 100 whole tokens for one initialized player, conserved across all owners.
- **Holding**: A user's quantity of a player's tokens; the superuser's initial quantity is 100 and holdings can subsequently be distributed by separate trading features.
- **Initial Quote**: The exact starting valuation of one credit per token, with an effective date and initialization-rule version, permanently associated with the initial issuance.
- **Initial Issuance Record**: Immutable evidence of the one-time allocation, identifying its player, original recipient, quantity, initial valuation, associated quote, and completion time; distinct from a purchase or sale.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For 100% of valid first-initialization cases, each player has exactly 100 tokens, all held by the same designated superuser, an exact one-credit initial unit quote, and an exact 100-credit initial inventory value.
- **SC-002**: In 100% of sequential retry and concurrent initialization cases, there is exactly one completed issuance per player, no additional supply, and no duplicated initial quote or issuance evidence.
- **SC-003**: In 100% of rejected or interrupted initialization cases, no new issuance effects or credit balance changes remain; a later valid retry of a failed first attempt can complete exactly one issuance.
- **SC-004**: In 100% of retries after representative later ownership and quote changes, all current holdings, balances, and quote history are preserved while the original issuance remains retrievable.
- **SC-005**: For every completed issuance, a reviewer can unambiguously establish who originally received the tokens, how many were issued, the exact starting quote and value, the effective date and rule version, and when initialization completed from retained market records.
- **SC-006**: Every tested invalid prerequisite, recipient conflict, and inconsistent-state case yields a reason that distinguishes that failure from successful first issuance and already-completed initialization, with no automatic correction of financial history.

## Assumptions

- TASK-005 supplies persisted season-specific catalog players and stable identities; TASK-007 supplies persisted user accounts. The existing catalog identity defines the supply boundary; cross-season consolidation of a real-world footballer is outside this task.
- The market operator supplies one existing account's identity through trusted setup as the superuser designation. This feature validates that designation and its recipient consistency; it does not create an account, promote ordinary registrations, or introduce general administrative roles.
- Initialization is an explicit trusted setup capability for each existing player. Scheduling it for all catalog entries or automatically invoking it during ingestion is separate work. Only successfully initialized players have issued inventory.
- The initial quote means the fixed one-credit starting value mandated by `docs/PRODUCT.md`, not a calculated current performance quote. Its fixed rule must be version-identifiable without requiring TASK-026's later strategy calculations.
- A new player's market starts from no holdings or quote history. Preexisting orphan or conflicting financial records require investigation outside this feature rather than implicit reconciliation during issuance.
- TASK-026 owns later performance quote calculation and immutable history; TASK-029 and TASK-030 own purchases and sales. Those features must preserve this specification's original issuance and fixed supply when they add later market activity.

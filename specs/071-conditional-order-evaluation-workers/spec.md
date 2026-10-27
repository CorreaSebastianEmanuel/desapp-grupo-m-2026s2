# Feature Specification: Conditional Order Evaluation Workers

**Feature Branch**: `060-conditional-order-evaluation-workers`

**Created**: 2026-10-27

**Status**: Draft

**Input**: TASK-060 — Evaluate active orders asynchronously after committed quotes through durable Oban jobs, use authoritative PostgreSQL prices/funds/inventory, recover missed evaluations and prevent duplicate purchases.

## User Scenarios & Testing

This feature completes the evaluation side of conditional buy orders. An order is evaluated after creation and when a new valid quote is confirmed for its player. Evaluation uses the order lifecycle and purchase rules defined in TASK-059. It may execute the full order, leave it pending, or record a terminal outcome. A delayed or repeated job cannot use an obsolete event price or purchase twice.

### User Story 1 - Evaluate Orders Against Confirmed Quotes (Priority: P1)

As a market user with an active conditional order, I want it evaluated after a quote is confirmed, so that a qualifying order can complete without me watching the market.

**Why this priority**: Evaluation is the action that fulfills the conditional purchase instruction and the core value of the feature.

**Independent Test**: Create an order and confirm a qualifying quote, then process its evaluation and verify it uses the current price, funds, and available inventory and either completes the full purchase or records the applicable order outcome.

**Acceptance Scenarios**:

1. **Given** an order is created, **When** its creation is committed, **Then** a durable evaluation is requested even if its price condition is already met.
2. **Given** a valid quote for a player is confirmed, **When** the confirmation commits, **Then** durable evaluation work for that confirmed quote is recorded as part of the same commit.
3. **Given** an evaluation is delivered for a quote, **When** it runs, **Then** the job's quote data identifies the trigger only; eligibility and any purchase use the authoritative current valid quote, current user credits, and currently available inventory at the serialized decision point.
4. **Given** the current quote is above the order's maximum, absent, invalid, or nonpositive, **When** the order is evaluated, **Then** it remains pending and no financial or inventory changes occur.
5. **Given** the current quote qualifies and the full purchase is possible, **When** the order is evaluated, **Then** the existing all-or-nothing purchase rules complete the order and purchase atomically at that current quote.
6. **Given** a qualifying order cannot be filled in full because credits or inventory are insufficient, **When** it is evaluated, **Then** it becomes rejected with the applicable reason and no partial financial, inventory, or purchase-operation changes occur.

### User Story 2 - Recover Missed Work Safely (Priority: P1)

As a market user, I want missed or interrupted evaluations to be recovered, so that an active order does not remain unevaluated solely because a delivery was lost or the application restarted.

**Why this priority**: Durable recovery is necessary for users to rely on orders when workers or the application are temporarily unavailable.

**Independent Test**: Leave an eligible order without its original evaluation delivery, restart or interrupt processing, run recovery, and verify it is revisited; repeat delivery and recovery and verify only one purchase can result.

**Acceptance Scenarios**:

1. **Given** a confirmed quote and its evaluation delivery is missed or interrupted, **When** recovery runs, **Then** the affected pending orders are revisited using current authoritative state.
2. **Given** pending orders have reached or passed expiry, **When** recovery runs, **Then** due orders are durably transitioned to expired and cannot execute.
3. **Given** a worker fails temporarily before or during evaluation, **When** the work is retried, **Then** the transaction leaves no partial purchase and the order remains safely eligible unless a committed terminal outcome already exists.
4. **Given** work is delivered repeatedly, concurrently, or after an ambiguous acknowledgement, **When** it is processed, **Then** it observes the committed order outcome and creates no duplicate purchase or financial effect.
5. **Given** multiple pending orders compete for the same user credits or player inventory, **When** they are evaluated, **Then** each is all-or-nothing and the combined results do not overspend or exceed the fixed token supply.

### User Story 3 - Observe Committed Evaluation Outcomes (Priority: P2)

As a user viewing an order, I want connected screens to be notified after an evaluation changes its state and want the stored order to remain authoritative, so that I can see results and recover them after reconnecting.

**Why this priority**: Timely state visibility supports trust, while durable reads ensure a transient notification cannot hide or invent an outcome.

**Independent Test**: Complete, reject, or expire an order; verify a connected view can be prompted to reload after commit, then reconnect and read the same persisted outcome.

**Acceptance Scenarios**:

1. **Given** an evaluation commits an order transition, **When** the transaction completes, **Then** the system attempts a best-effort PubSub reload hint for connected interested views after commit; delivery is not guaranteed.
2. **Given** a notification is lost or a user reconnects, **When** the order is read, **Then** the persisted lifecycle status and terminal details remain available and authoritative.

### Edge Cases

- A newer quote commits after the event that enqueued the job but before the purchase decision; the old event price cannot authorize a purchase.
- Evaluation races quote confirmation, cancellation, expiry, or another evaluation; the existing TASK-059 serialization rules determine the single outcome.
- A quote and its durable follow-up either both commit or neither commits.
- A crash occurs after a purchase commits but before the worker acknowledges completion; retry observes the existing terminal outcome.
- Temporary infrastructure failure is not a business rejection. If bounded retries are exhausted, pending orders remain recoverable and may be revisited later.
- Recovery revisits both eligible pending orders and pending orders due for expiry; it does not mutate state merely by reading or listing orders.
- Repeated quote confirmations or overlapping recovery runs may create redundant evaluation attempts, but cannot cause redundant financial effects.
- No execution-time or global priority guarantee is made; orders are evaluated with bounded concurrency and reproducible ordering as specified by ADR-0017.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST request evaluation when a conditional order is committed and when a new valid quote is confirmed for the order's player.
- **FR-002**: Durable evaluation work for a newly confirmed quote MUST be recorded atomically with quote confirmation and MUST identify that confirmed quote, so a committed quote cannot be left without recoverable follow-up.
- **FR-003**: Evaluation MUST treat the triggering quote as a reason to revisit orders, not as purchase authorization. It MUST use the authoritative current quote, current time, user credits, and available inventory at one serialized purchase decision. Current quote identity and validity MUST reuse Quotes.latest and the existing TASK-059 purchase quote validator; no alternative quote selection or fallback is introduced.
- **FR-004**: Evaluation MUST follow TASK-059 for ownership, order eligibility, expiry, maximum-price comparison, all-or-nothing purchase, rejection reasons, terminal states, and cancellation/execution races. It MUST NOT redefine those rules.
- **FR-005**: Repeated, concurrent, recovered, or retried evaluation MUST produce at most one purchase and one set of associated financial, inventory, and immutable operation effects for an order.
- **FR-006**: A temporary failure MUST leave no partial purchase or financial effects and MUST be retried safely under a bounded retry policy. Exhausting immediate retries MUST NOT convert a pending order into a business rejection; pending work MUST remain eligible for later recovery.
- **FR-007**: The system MUST periodically recover pending orders, including eligible orders whose triggering delivery was missed and orders due for expiry. Recovery MUST be durable across application restart and MUST NOT depend on Redis or an in-memory notification.
- **FR-008**: Recovery and quote-triggered evaluation MUST be safe when repeated or overlapping and MUST respect current order status, expiry, quote, funds, and inventory on every attempt.
- **FR-009**: Competing eligible orders MUST be evaluated with bounded concurrency and reproducible ordering by creation time and stable order identity within each captured evaluation pass. Orders in a pass that compete for credits or inventory are decided in that order; concurrent deliveries MUST NOT reverse it. Orders committed after the pass snapshot are revisited in a later pass. The system MUST preserve balance and fixed-supply invariants without promising strict global priority.
- **FR-010**: After an order transition commits, the system MUST attempt a best-effort post-commit PubSub notification to connected interested views; delivery is not guaranteed. Notifications are hints to reload; persisted order state is authoritative and reconnection MUST recover the same outcome.
- **FR-011**: Evaluation MUST NOT reserve funds or inventory for pending orders, partially fill an order, change order terms, or create another financial product flow.
- **FR-012**: A confirmed quote whose price does not qualify MUST leave an unexpired order pending; an absent or invalid quote MUST NOT be treated as a zero price or trigger execution.
- **FR-013**: Evaluation and recovery MUST be inspectable through safe order outcomes without exposing internal exceptions, credentials, or unsafe diagnostics to users.
- **FR-014**: This feature covers evaluation, durable scheduling, retry, missed-work and expiry recovery, duplicate safety, and post-commit state notification. Order creation, cancellation, reads, list behavior, quote calculation, purchase rules, and user interface presentation remain governed by their existing task specifications.

### Key Entities

- **Order Evaluation**: A repeatable attempt to assess a pending order using its current authoritative terms and market state.
- **Quote Evaluation Request**: Durable follow-up associated with one confirmed quote and safe to redeliver.
- **Recovery Run**: A recurring revisit of pending orders that discovers missed evaluation work and due expiries.
- **Order Outcome**: The persisted pending or terminal lifecycle result and any purchase or rejection details defined by TASK-059.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In every quote-confirmation interruption scenario, the confirmed quote has recoverable evaluation work or the quote and follow-up are both absent.
- **SC-002**: In 100% of duplicate, concurrent, retry, and recovery acceptance scenarios, each order produces no more than one purchase and one set of financial effects.
- **SC-003**: In every eligibility scenario, execution uses the current authoritative quote and current funds and inventory at the serialized decision point; an obsolete event price never authorizes purchase.
- **SC-004**: Every pending order whose delivery was missed or whose expiry is due is revisited by recovery, with no fixed execution-time promise.
- **SC-005**: Across every order evaluation outcome, no order is partially filled, no account is overspent, and total player token supply never exceeds 100.
- **SC-006**: In every lost-notification and reconnect scenario, the user can recover the same committed order outcome from persisted order state.

## Assumptions

- TASK-059 is the canonical behavioral contract for order lifecycle, ownership, price eligibility, cancellation, expiry, and purchase outcomes; this feature consumes those rules without changing them.
- A durable job system persists work in PostgreSQL and workers run within the application, consistent with the agreed CP2 architecture; Redis and PubSub are not durable work ledgers.
- Recovery has no promised execution deadline. The application revisits pending orders periodically, while immediate evaluation attempts use bounded retries.
- The existing purchase path is the authority for exact money arithmetic, inventory sourcing, account balances, and immutable operation history.
- User-facing order views and detailed presentation are delivered by TASK-061; this feature only provides committed state and post-commit notification signals.

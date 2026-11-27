# Internal evaluation contracts

No public route or OpenAPI shape is added. Existing creation/read/cancellation routes retain TASK-059 status/header/body contracts; real HTTP must exercise those routes with scheduling enabled.

## Worker input and domain boundary
ConditionalOrderEvaluation accepts JSON maps containing a source (`order`, `quote`, `recovery`, `continuation`) and optional canonical order_id/event_id. IDs identify triggers only. Ignore no financial fields: reject malformed/unknown argument fields safely rather than accepting an event price, owner, quantity or balance. Workers call Market.OrderEvaluation only; they never call PurchaseTransaction, write balances or issue quotes.

Producer creation commits order plus wake atomically. Quote confirmation commits its quote, existing quote event and event-ID wake atomically; preserve confirm! return shape. PostgreSQL wake persistence is required even with workers stopped. Oban uniqueness is an optimization, not duplicate-purchase protection.

Quote event acceptance uses Quotes.Recovery.claim_evaluation and acknowledge_evaluation in an outer transaction with wake insertion. Receipt is `conditional-evaluation:<event_uuid>`; repeat receipt succeeds, conflicting receipt/stale fence fails. Acknowledgement certifies durable work acceptance. Recovery revisits all pending orders independently of event acknowledgement, so accepted/discarded jobs cannot strand financial work.

Domain step locks pass -> one order -> conditional identity -> player -> sorted users/balances. There is no skip-locked reordering. Global pending snapshot order is (created_at, UUID); ordinal progress commits with the order outcome. New arrivals are deferred, including backdated commits. Direct purchases/cancellation retain their existing lock/race rules; no strict global priority.

Worker returns success only after work is committed or recognized terminal; transient safe error retries up to three attempts (5/30-second backoffs). Exhaustion leaves durable recovery input. Recovery runs each minute and at startup, handles bounded pages/continuations and includes expiry without quotes. Jobs process at most 100 steps then persist continuation before success. Overlap across nodes shares PostgreSQL serialization.

## State notification
Topic: `conditional_orders:<owner_uuid>`; message: `{:conditional_order_changed, order_uuid}`. Resolve owner from stored state. Attempt once after a newly committed transition, including evaluation expiry/rejection/execution and cancellation; no broadcast for rollback, unchanged pending or terminal replay. Failure/loss is acceptable; it never changes a committed financial result. Consumers treat it as a reload hint and use owned persisted reads on initial load/reconnect. No financial payload, exceptions, credentials or exception-derived public reason.

## Acceptance controls
See plan.md scenario matrix and verification.json. Contract tests must reject event-price authorization and prove create/work rollback, quote/work rollback, stale fences, deterministic snapshot contention, bounded retries, pure reads, and lost-hint reconnect. TASK-061 owns UI subscription/rendering.

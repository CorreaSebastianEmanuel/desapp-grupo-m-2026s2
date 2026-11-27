# Evaluation persistence changes

## Existing records retained
market_conditional_buy_orders and market_purchases keep TASK-059 fields, validations, terminal immutability and reciprocal unique purchase linkage (ADR-0036). No reservation, terms or monetary schema change. quote_evaluation_requests retains its quote/calculation/player linkage, stable idempotency key, lease fence/expiry and consumer receipt from TASK-026. Oban jobs remain PostgreSQL durable records.

## EvaluationPass (singleton table market_order_evaluation_passes)
- id: integer primary key constrained to 1; migration inserts the row.
- generation: nonnegative bigint advanced per new pass.
- state: idle/running, constrained; cursor_ordinal nonnegative bigint.
- upper_created_at UTC microseconds and upper_order_id UUID: optional diagnostic maximum tuple; both null while idle.
- rescan_requested: nonnull boolean default false; started_at/updated_at UTC database time.
- Row FOR UPDATE serializes snapshot capture, one evaluation, cursor progression and pass completion across all instances. No producer holding a player lock acquires it.

## EvaluationMember (market_order_evaluation_members)
- pass_generation bigint; ordinal positive bigint; order_id UUID references retained order; captured_created_at UTC microseconds.
- primary key (pass_generation, ordinal); unique (pass_generation, order_id); order created_at/id determine ascending ordinal.
- Capture ALL visible pending order IDs in one INSERT SELECT under one READ COMMITTED statement snapshot while holding singleton. Concurrent commits belong to a later pass. No money, price or eligibility snapshot is stored.
- cursor points to the last committed member. Evaluation and advancement commit together. Current eligibility always comes from locked live rows.
- Only one active generation; completed member rows may be deleted with pass completion. These are scheduler projections, not append-only financial facts. Migration constraints and tests enforce valid cursor/state/member ownership.

## Transitions
idle -> running: snapshot pending IDs; empty snapshot stays idle. running -> running: one member decided or terminal replayed, cursor advanced atomically. Infrastructure failure leaves cursor and order unchanged. running -> idle: no members remain, delete completed membership; a requested rescan starts a new snapshot. Startup/cron resumes running generation or starts a new one. Three failed Oban attempts never set an order to rejected.

Pending -> executed/rejected/expired and cancellation remain exactly TASK-059. Expiry is sampled after lock acquisition. GET/list never writes these tables or Oban jobs.

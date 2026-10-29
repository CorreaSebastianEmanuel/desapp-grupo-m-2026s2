---
id: TASK-079
title: Defer player quote recalculation to nightly batch
type: task
checkpoint: CP2
priority: medium
workflow: thinflow-v1
status: todo
depends_on: TASK-026, TASK-056, TASK-019
active_run: none
---

## Outcome

Make the daily rhythm explicit: statistics may be ingested during the day through the existing deduplicated demand refresh (TASK-056) and the nightly catalog/statistics sync, but stored statistics must NOT trigger quote calculation immediately. Quote recalculation becomes a nightly batch pass at the scheduled cycle (recurrence 0 0 * * *, configurable per league/season): the pass recalculates every eligible player whose performance facts changed since the previous close (and, as backstop, every player due by TTL), inserts immutable versioned quotes and the conditional-order evaluation event in the same transaction as today, and the existing Oban evaluation chain proceeds unchanged. Adjust the quote calculation request pipeline so stats confirmation only records a pending calculation instead of dispatching it, and the scheduler/market-close pass admits those pending requests. Preserve invariants: quotes immutable, versioned, reproducible from stored inputs; financial transactional guarantees untouched. Consequence to document: during the day the price is the previous close; users see freshest data with a clear last-valuation timestamp. Update affected specs/tests (quote trigger pipeline, retention of pending calculation requests, crash recovery must not lose pending calculations bounded by TTL). Rationale: official daily closing price, like fund NAV; simpler off-peak batch; roadmap alternative (match-driven recalculation) stays documented in CP2 presentation docs as future follow-up. Checkpoint CP2.

---
id: TASK-079
title: Defer player quote recalculation to nightly batch
type: task
checkpoint: CP2
priority: medium
workflow: thinflow-v1
status: done
depends_on: TASK-026, TASK-056, TASK-019
active_run: none
---

## Outcome

Make the daily rhythm explicit: statistics may be ingested and made readable during the day through the existing deduplicated demand refresh (TASK-056) and the nightly catalog/statistics sync, but accepted statistics must only record pending quote-calculation work; they must NOT dispatch quote calculation immediately. A search-triggered refresh updates statistics, not the market price. Quote recalculation becomes a nightly batch pass at the scheduled cycle (recurrence 0 0 * * *, configurable per league/season): the pass recalculates every eligible player whose performance facts changed since the previous close (and, as backstop, every player due by TTL), inserts immutable versioned quotes and the conditional-order evaluation event in the same transaction as today, and the existing Oban evaluation chain proceeds unchanged. Completed matches do not trigger quote calculation; match-driven recalculation is a future roadmap alternative, not this task's behavior. Adjust the quote calculation request pipeline so stats confirmation only records a pending calculation instead of dispatching it, and the scheduler/market-close pass admits those pending requests. Preserve invariants: quotes immutable, versioned, reproducible from stored inputs; financial transactional guarantees untouched. Consequence to document: during the day the price is the previous close; player detail returns the current quote value and its last-valuation timestamp beside statistics freshness. Update affected specs, search/refresh documentation, CP2 architecture and presentation materials, and focused tests (quote trigger pipeline, retention of pending calculation requests, crash recovery must not lose pending calculations bounded by TTL). Rationale: official daily closing price, like fund NAV; simpler off-peak batch; roadmap alternative (match-driven recalculation) stays documented in CP2 presentation docs as future follow-up. Checkpoint CP2.

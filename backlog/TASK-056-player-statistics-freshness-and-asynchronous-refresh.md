---
id: TASK-056
title: Player statistics freshness and asynchronous refresh
type: task
checkpoint: CP2
priority: medium
status: todo
depends_on: TASK-011, TASK-019, TASK-021
active_run: none
---

## Outcome

Expose scoped last_checked_at and configurable freshness TTL with deduplicated Oban refresh requests, nonblocking local reads and explicit import/valuation status. Supporting enhancement, not a replacement for mandatory CP2 features.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md). Generate specification and plan before implementation.

The TTL starts at the last complete, validated, atomically accepted check for the exact scope. No-change checks renew it; failed/incomplete checks do not. A cached search cannot skip detail freshness checking. Do not overwrite historical facts. Initial proposed TTL is 24 hours configurable.

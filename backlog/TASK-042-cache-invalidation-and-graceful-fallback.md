---
id: TASK-042
title: Cache invalidation and graceful fallback
type: task
checkpoint: CP3
priority: critical
status: todo
depends_on: TASK-018, TASK-026, TASK-041, TASK-056
active_run: none
---

## Outcome

Invalidate affected cached reads after committed catalog/statistics/quote changes and preserve local reads when Redis fails. Retry failed invalidations; cache expiry bounds stale data. Trading always uses PostgreSQL.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

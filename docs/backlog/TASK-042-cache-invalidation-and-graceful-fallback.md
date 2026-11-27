---
id: TASK-042
title: Cache invalidation and graceful fallback
type: task
checkpoint: CP3
priority: critical
status: done
workflow: thinflow-v1
depends_on: TASK-018, TASK-026, TASK-041, TASK-056
active_run: none
---

## Outcome

Own ranking-cache coherence separately from TASK-041's cache read/write path: invalidate affected ranking entries only after committed quote or active-strategy changes; ensure failed invalidation cannot leave stale ranking data beyond the configured TTL. Verify that invalidation failures and Redis outages fall back to PostgreSQL. Trading and financial decisions always use PostgreSQL and never cached values. Add focused tests for commit/rollback ordering, invalidation scope, fallback, and expiry.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

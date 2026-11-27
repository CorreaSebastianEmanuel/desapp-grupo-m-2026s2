---
id: TASK-041
title: Redis active-strategy ranking cache
type: task
checkpoint: CP3
priority: critical
status: done
workflow: thinflow-v1
depends_on: TASK-002, TASK-011, TASK-012, TASK-033
active_run: none
---

## Outcome

Optimize high-frequency active-strategy ranking reads using the existing Redis infrastructure and explicit ranking keys that include the active strategy/configuration version. Use a bounded TTL and fall back to the authoritative PostgreSQL ranking when the cache misses or Redis is unavailable. Measure ranking cache hits/misses sufficiently to demonstrate the optimization. Do not expand this task to catalog search caching.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

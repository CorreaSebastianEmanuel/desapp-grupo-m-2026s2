---
id: TASK-041
title: Redis ranking and catalog search cache
type: task
checkpoint: CP3
priority: critical
status: todo
depends_on: TASK-002, TASK-011, TASK-012, TASK-033
active_run: none
---

## Outcome

Cache high-frequency ranking and catalog search reads with explicit scoped keys, TTLs and measurable hits. Redis TTL differs from statistics freshness TTL; misses/failure fall back to PostgreSQL without scraping names.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

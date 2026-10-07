---
id: TASK-026
title: Quote recalculation and immutable history
type: task
checkpoint: CP2
priority: critical
status: todo
depends_on: TASK-021, TASK-025
active_run: none
---

## Outcome

Calculate quotes from accepted persisted statistics and versioned strategies; append reproducible immutable history. Emit durable follow-up evaluation after confirmed quote changes for TASK-060. Retry safely and track calculation separately from statistics import.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

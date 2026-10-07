---
id: TASK-044
title: External provider resilience
type: task
checkpoint: CP3
priority: high
status: todo
depends_on: TASK-019, TASK-021
active_run: none
---

## Outcome

Add advanced provider resilience and observability on top of CP2 bounded retries and safe local fallback. Denied access or malformed data do not trigger unbounded retries or bypass.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

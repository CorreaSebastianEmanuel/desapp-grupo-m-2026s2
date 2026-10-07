---
id: TASK-060
title: Conditional order evaluation workers
type: task
checkpoint: CP2
priority: critical
status: todo
depends_on: TASK-019, TASK-026, TASK-059
active_run: none
---

## Outcome

Evaluate active orders asynchronously after committed quotes through durable Oban jobs, use authoritative PostgreSQL prices/funds/inventory, recover missed evaluations and prevent duplicate purchases.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md). Generate specification and plan before implementation.

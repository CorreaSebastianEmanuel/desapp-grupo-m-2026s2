---
id: TASK-019
title: Scheduled synchronization jobs
type: task
checkpoint: CP2
priority: high
status: todo
depends_on: TASK-002, TASK-018
active_run: none
---

## Outcome

Run local Oban initial/manual/scheduled catalog synchronization with jobs in PostgreSQL, durable history, deduplication and bounded retries. Domain idempotency remains required; Redis does not own processed state. Reuse job infrastructure for statistics and conditional orders.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

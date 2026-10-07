---
id: TASK-021
title: Statistics ingestion pipeline
type: task
checkpoint: CP2
priority: critical
status: todo
depends_on: TASK-055, TASK-018, TASK-019, TASK-020
active_run: none
---

## Outcome

Import statistics idempotently through Oban with provenance and raw-fixture traceability. Validate completeness and atomically preserve accepted data/check state; unknown values are not zero. Do not overwrite immutable facts. Resolve substitute-position window/ties/insufficient history from feedback before deriving most frequent historical position.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

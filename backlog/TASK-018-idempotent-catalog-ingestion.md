---
id: TASK-018
title: Idempotent catalog ingestion
type: task
checkpoint: CP2
priority: critical
status: todo
depends_on: TASK-005, TASK-016, TASK-055
active_run: none
---

## Outcome

Import and reconcile external catalog data without duplicates or partial corruption, using the merged provider contract and selected scraper. TASK-017 is an optional catalog adapter, not a mandatory statistics source.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

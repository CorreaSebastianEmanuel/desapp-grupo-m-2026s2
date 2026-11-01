---
id: TASK-034
title: CP2 integration and end-to-end suite
type: task
checkpoint: CP2
priority: critical
status: todo
workflow: thinflow-v1
depends_on: TASK-019, TASK-027, TASK-030, TASK-032, TASK-033, TASK-058, TASK-060, TASK-061, TASK-063, TASK-078, TASK-079, TASK-077
active_run: none
---

## Outcome

Test valuation, trading concurrency/idempotency, portfolio, history, ranking, user charts and conditional-order lifecycle, including reconnect, expiry, cancellation and failed execution. Include the CP2 closing-price rhythm and search scouting: nightly batch admitting pending quote calculations (prices move only at the close; demand refresh stores statistics without triggering immediate calculation), search scouting policy (dedup by normalized name, request budget, negative cache, catalog-only side effects and non-blocking search). Preserve the distinct unit and actual E2E profiles.

Follow [CP2 architecture](../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../docs/adr/0017-cp2-charts-and-conditional-orders.md).

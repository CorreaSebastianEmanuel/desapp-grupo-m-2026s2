---
id: TASK-093
title: Initial statistics preload and scheduled background refresh with preparing cards
type: task
checkpoint: CP3
priority: high
workflow: thinflow-v1
status: todo
depends_on: TASK-092
active_run: none
---

## Outcome

Preload verified player statistics asynchronously and refresh them on a schedule, recovering durable pending work at server startup. Reuse the existing provider, accepted-statistics, durable jobs and first-performance-quote boundaries from TASK-092. Deduplicate and rate-limit work; keep page reads local and independent of provider failures. While imports are active, show preparing states with automatic card updates instead of the no-statistics empty state. Preserve explicit missing-data/failure states and administrator-selected valuation configuration. This is the separate second delivery authorized with TASK-092; do not implement it as part of TASK-092.

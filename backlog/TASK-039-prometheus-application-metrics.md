---
id: TASK-039
title: Prometheus application metrics
type: task
checkpoint: CP3
priority: high
status: todo
workflow: thinflow-v1
depends_on: TASK-036, TASK-038
active_run: none
---

## Outcome

Expose a Prometheus scrape endpoint in the Phoenix application and connect a Prometheus-compatible exporter/reporter to Telemetry. The endpoint must return valid Prometheus text exposition with stable metric names/types and bounded labels for request count/error/latency, database, VM, and job activity. Reuse the existing Telemetry measurements where applicable; instrumentation without an externally scrapeable endpoint does not complete this task. Add HTTP tests for content type, exposition, required metric families, and absence of user IDs, raw paths, or other unbounded/high-cardinality labels. Document the scrape path and required deployment configuration.


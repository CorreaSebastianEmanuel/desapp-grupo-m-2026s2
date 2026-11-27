---
id: TASK-040
title: Advanced business metrics API
type: task
checkpoint: CP3
priority: high
status: done
workflow: thinflow-v1
depends_on: TASK-039
active_run: none
---

## Outcome

Expose an authenticated, administrator-authorized API endpoint for aggregate business metrics covering quotes, conditional orders, portfolio activity, ingestion, and job outcomes. Return safe aggregates and explicit empty/unavailable states; never expose user-level financial data, identifiers, credentials, or provider payloads. Document the response contract and add authorization, correctness, failure-state, and HTTP contract tests. TASK-073 may consume this endpoint for its read-only dashboard and must not duplicate metric calculations.


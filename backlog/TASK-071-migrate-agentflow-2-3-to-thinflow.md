---
id: TASK-071
title: Migrate Agentflow 2.3 to ThinFlow
type: task
checkpoint: CP1
priority: critical
workflow: thinflow-v1
status: review
depends_on: none
active_run: none
---

## Outcome

Replace the default six-stage Agentflow with a risk-tiered, single-builder delivery harness that uses minimal outcome specs, deterministic targeted checks, one required CI gate, one independent evaluator, bounded repair loops, and no workflow metadata coupling to application behavior; deliver the migration in one reviewable PR with tests and documentation.

---
id: TASK-070
title: Agentflow preflight and efficient failure recovery
type: task
checkpoint: CP2
priority: high
status: review
depends_on: none
active_run: 6095b64e
---

## Outcome

Run a deterministic, non-destructive preflight for the effective child environment before start or resume; emit actionable safe failure diagnostics and partial QA reports; continue independent checks after isolated failures while enforcing the same-input retry limit; align feedback-cycle governance; audit and remove avoidable duplicate local full-profile executions without weakening CI, independent QA, or real HTTP acceptance.

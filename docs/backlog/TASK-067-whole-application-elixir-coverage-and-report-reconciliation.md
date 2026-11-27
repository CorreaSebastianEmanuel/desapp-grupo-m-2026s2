---
id: TASK-067
title: Whole-application Elixir coverage and report reconciliation
type: task
checkpoint: CP2
priority: medium
status: done
depends_on: TASK-065
active_run: none
---

## Outcome

Generate coverage for the agreed first-party Elixir application scope with documented exclusions and reconcile every included and excluded file. Build on TASK-065 source accounting and existing audited unit/integration profiles; preserve their ownership, receipts, existing CP1 reports, JavaScript coverage and gates. Collect only the necessary native exports and combine them without losing partitions or double-counting executable lines. Add focused tests for coverage accounting, missing/incomplete exports, malformed reports and genuine failure propagation. Document measured coverage and limitations without introducing an arbitrary threshold. No SonarCloud import, Dialyzer work, application behavior changes or test-runner redesign is included. The archived broad TASK-065 draft may be reviewed for useful pieces only after this task has its own approved specification and plan; historical results do not count as current evidence.

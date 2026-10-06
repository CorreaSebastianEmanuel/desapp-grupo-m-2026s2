---
id: TASK-054
title: Agentflow task feature directory binding
type: task
checkpoint: CP1
priority: high
status: review
depends_on: none
active_run: e2263724
---

## Outcome

Fix Agentflow's incorrect assumption that backlog task numbers equal Spec Kit directory numbers, including local feature discovery/publication and post-merge reconciliation. Use a durable versioned association (canonical spec.md Feature Branch and/or validated task metadata), never ignored .specify/feature.json or newest/mtime guesses. Add shared unambiguous resolution and meaningful regressions for TASK-017 on branch 017-football-data-api-adapter with specs/055-football-data-api-adapter, TASK-020 with specs/054-player-match-statistics, legacy equal-number layouts, missing/ambiguous/conflicting associations and refused completion unless independent QA/review terminal verdicts are PASS. Preserve task/branch identity, unrelated backlog files, report validation, workflow permissions and human merge authority. Keep Elixir, provider implementation, TASK-017 feature artifacts and broader Actions optimizations untouched. Test the post-merge command against an isolated copy of the actual TASK-017 artifacts without marking the real task done. Create a separate PR intended to be merged before PR #28. Assess only checks relevant to this Python/workflow correction; do not rerun unrelated Elixir suites unless evidence requires it.

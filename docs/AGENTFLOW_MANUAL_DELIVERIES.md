# Reconciling the manual deliveries

TASK-027 and TASK-056 were implemented outside Agentflow and are already present
on main. Their application code is retained. This reconciliation adds canonical
feature ownership, retrospective specifications and implementation inventories,
reproducible verification manifests, and fresh independent QA and review.
It does not claim that the original product, challenge, architecture or
development stages ran, create synthetic run IDs, or reuse historical receipts.

The original delivery evidence is recorded alongside each feature:

- [TASK-027 provenance](../specs/027-current-historical-and-dated-quote-apis/reconciliation.md):
  direct implementation commit, with no invented implementation PR.
- [TASK-056 provenance](../specs/056-player-statistics-freshness-and-asynchronous-refresh/reconciliation.md):
  merged PR #53 used `056-player-statistics-freshness`, whereas the task's
  canonical branch key is `056-player-statistics-freshness-and-asynchronous-refresh`.
  That mismatch caused its original merge-finalization run to fail. That run
  remains historical evidence; this repair does not rename it or claim it passed.

Explicit `feature_directory` metadata binds each task to its own canonical
specification. The older `specs/056-football-scraping-adapter` directory still
belongs to TASK-055. Repository maintenance PR #54 has no backlog task and needs
no invented task or workflow run.

After fresh independent QA and final review report `Verdict: PASS`, each accepted
task enters `review` and is completed using the ordinary `./agentflow complete`
command. `active_run: none` remains truthful because neither delivery has an
active Agentflow run. Completion makes dependent work available without
weakening branch ownership, evidence checks or the normal workflow.

## Continuing work with Agentflow

Once the reconciliation PR is merged, update local main from the remote. Bring
that baseline into an existing feature branch using the team's normal integration
policy, then continue its existing Agentflow run. Do not delete run state, reset
another task, manufacture receipts, or restart implemented tasks to repair these
records. A baseline change can invalidate verification fingerprints; regenerate
affected checks through the normal workflow rather than copying old receipts.

TASK-029 and TASK-033 metadata and feature work are not changed by this repair.
Fresh dry-run checks of both tasks verify dependency selection without starting
their agents or overwriting their local work. Their local run state, if any,
remains on their respective developers' machines.

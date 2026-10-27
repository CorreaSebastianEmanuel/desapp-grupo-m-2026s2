---
name: start
description: Start a backlog task through the repository's ThinFlow delivery harness. Use when the user asks to begin, execute, implement, or run a TASK identifier.
---

# Start task

From the repository root run `./agentflow start $ARGUMENTS` on POSIX or `.\agentflow.ps1 start $ARGUMENTS` on Windows. New `thinflow-v1` tasks use one builder, deterministic risk-selected checks, and one fresh independent evaluator. The command commits, pushes, and creates one PR after local readiness; hosted `ThinFlow required` and human merge remain mandatory. Use `--no-pr` only when the user requests local-only work. Never merge automatically.

Read `docs/THINFLOW.md` and `docs/AGENTFLOW_MODELS.md`. A new task file is the only dirty bootstrap path accepted by start; all other pre-existing changes refuse. Dry-run never launches a child. Pending feedback blocks progress.

Do not manufacture plan/tasks/handoffs for ThinFlow. The builder maintains the compact outcome spec and uses focused tests. The harness classifies the actual diff, fails closed on unmapped paths, runs the selected checks once inputs stabilize, and stores receipts locally. One grouped repair cycle is allowed; then request a human decision or split the task. Saved Agentflow 2.3 runs keep their captured workflow and are resumed, never silently converted.

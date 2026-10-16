---
name: start
description: Start a backlog task through the complete local multi-agent SDD workflow. Use when the user asks to begin, execute, implement, or run a TASK identifier.
---

# Start task

From the repository root run `./agentflow start $ARGUMENTS` on POSIX or `.\agentflow.ps1 start $ARGUMENTS` on Windows. This invokes fresh product, architecture, development, QA, and review stages, then creates a PR only after both gates pass. Never merge automatically. Use `--no-pr` only when the user requests a local-only run.

Read docs/AGENTFLOW_MODELS.md for dry-run inspection, per-field precedence and explicit development overrides. Normal resume preserves saved settings; selection changes require --adopt-models for future attempts with a new session. Unknown legacy settings require explicit selection. Never relabel historical observations or switch automatically after failure. Pending feedback blocks dependent stages. Apply current artifact/readiness guards even to saved workflow snapshots.

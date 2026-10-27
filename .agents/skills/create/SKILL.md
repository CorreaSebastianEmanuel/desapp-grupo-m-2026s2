---
name: create
description: Create a new local Agentflow backlog task. Use when the user wants to add, capture, or define work without implementing it yet.
---

# Create task

From the repository root run `./agentflow create "$ARGUMENTS"` on POSIX or `.\agentflow.ps1 create "$ARGUMENTS"` on Windows. Supply `--outcome` for non-interactive use. New tasks default to `workflow: thinflow-v1`; use `--legacy` only for an explicitly requested Agentflow 2.3 task. Report the created task ID and do not start it unless the user also asked for implementation.

---
name: start
description: Start a backlog task through the complete local multi-agent SDD workflow. Use when the user asks to begin, execute, implement, or run a TASK identifier.
---

# Start task

From the repository root run `./agentflow start $ARGUMENTS` on POSIX or `.\agentflow.ps1 start $ARGUMENTS` on Windows. This invokes fresh product, architecture, development, QA, and review stages, then creates a PR only after both gates pass. Never merge automatically. Use `--no-pr` only when the user requests a local-only run.

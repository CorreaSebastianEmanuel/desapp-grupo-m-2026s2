---
name: feedback
description: Record human feedback for a ThinFlow or legacy Agentflow backlog task and route repair to its accountable owner.
---

# Add task feedback

Run `./agentflow feedback $ARGUMENTS` on POSIX or `.\agentflow.ps1 feedback $ARGUMENTS` on Windows.

Use repeatable `--impact product|architecture|verification|implementation|qa|review` to classify the finding. Omitted impact records pending feedback and blocks resume. ThinFlow routes classified feedback to the same builder and reruns deterministic checks plus a fresh evaluator; it does not recreate product, architecture, or review sessions. Do not edit run state manually.

ThinFlow permits one grouped repair cycle; a second blocker requires a human decision or task split. Legacy 2.3 snapshots retain three cycles. Two unchanged check failures always refuse a third; unrelated edits reset neither budget.

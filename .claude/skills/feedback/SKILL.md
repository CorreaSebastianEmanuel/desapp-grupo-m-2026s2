---
name: feedback
description: Record human feedback for an Agentflow backlog task and rewind its SDD workflow to the affected stage. Use when a user comments on product scope, architecture, implementation, QA, or final review and wants later agents to incorporate it.
---

# Add task feedback

Run `./agentflow feedback $ARGUMENTS` on POSIX or `.\agentflow.ps1 feedback $ARGUMENTS` on Windows.

Use `--stage product|architecture|development|qa|review` to select the earliest affected stage. Do not edit run state manually. After recording feedback, use `resume` when Agentflow reports that the workflow was rewound.

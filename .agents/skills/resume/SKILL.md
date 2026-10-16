---
name: resume
description: Resume an interrupted or paused Agentflow Spec Kit run. Use when a task has an active run ID and should continue.
---

# Resume task

Run `./agentflow resume $ARGUMENTS` on POSIX or `.\agentflow.ps1 resume $ARGUMENTS` on Windows. Preserve the existing spec and run state.

Read docs/AGENTFLOW_MODELS.md for dry-run inspection, per-field precedence and explicit development overrides. Normal resume preserves saved settings; selection changes require --adopt-models for future attempts with a new session. Unknown legacy settings require explicit selection. Never relabel historical observations or switch automatically after failure. Pending feedback blocks dependent stages. Apply current artifact/readiness guards even to saved workflow snapshots.

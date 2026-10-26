---
name: resume
description: Resume an interrupted or paused Agentflow Spec Kit run. Use when a task has an active run ID and should continue.
---

# Resume task

Run `./agentflow resume $ARGUMENTS` on POSIX or `.\agentflow.ps1 resume $ARGUMENTS` on Windows. Preserve the existing spec and run state.

Read docs/AGENTFLOW_MODELS.md for dry-run inspection, per-field precedence and explicit development overrides. Normal resume preserves saved settings; selection changes require --adopt-models for future attempts with a new session. Unknown legacy settings require explicit selection. Never relabel historical observations or switch automatically after failure. Pending feedback blocks dependent stages. Apply current artifact/readiness guards even to saved workflow snapshots.

Run read-only preflight against the final child environment before resuming a stage and again in provider shims immediately before their process launch. Preflight refusal does not count as an attempt. Use the ordered manifest runner for safe continuation and partial QA outcomes; QA always runs fresh checks. The local baseline is wrapper/CI parity only. Preserve the three-cycle feedback cap and durable attempt history across resumes.

---
name: verify
description: Independently verify an Agentflow task against its specification, tests, architecture, and checkpoint. Use for QA, acceptance, or pre-merge review.
---

# Verify task

Run `./agentflow verify $ARGUMENTS` on POSIX or `.\agentflow.ps1 verify $ARGUMENTS` on Windows. Do not implement fixes during independent verification.

QA executes independently without developer receipt reuse. New receipts are ignored schema-2 workspace/stage evidence. Review uses fresh QA and targeted risk checks. Both exact terminal PASS reports and post-review compact evidence finalization precede publication. Missing local evidence requires execution; a portable summary cannot grant readiness. Stop after two unchanged relevant-input failures.

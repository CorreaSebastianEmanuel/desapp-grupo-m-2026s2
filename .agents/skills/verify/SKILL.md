---
name: verify
description: Independently verify an Agentflow task against its specification, tests, architecture, and checkpoint. Use for QA, acceptance, or pre-merge review.
---

# Verify task

Run `./agentflow verify $ARGUMENTS` on POSIX or `.\agentflow.ps1 verify $ARGUMENTS` on Windows. Do not implement fixes during independent verification.

For ThinFlow, one fresh evaluator reads the outcome contract, diff, implementation, selected risk, and current local receipts; it writes only `evaluation.md`. It runs targeted checks only for a concrete discrepancy or uncovered risk. Exact terminal `Verdict: PASS` is required. Missing, stale, failed, skipped, empty, or interrupted evidence cannot grant readiness.

Legacy Agentflow 2.3 tasks retain their QA and final-review reports and ordered manifest runner. Never convert historical evidence to the ThinFlow format implicitly.

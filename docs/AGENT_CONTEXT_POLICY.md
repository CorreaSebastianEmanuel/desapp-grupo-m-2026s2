# Agent context policy

## ThinFlow tasks

- Read the active backlog task, compact `spec.md`, current feedback, governing
  product/architecture/checkpoint documents, constitution, and relevant code.
- Expand context only for a concrete dependency, uncertainty, or failure. Do
  not scan unrelated specs, the whole backlog, generated bundles, or complete
  logs.
- The builder owns implementation and focused iteration. Keep settled decisions
  in `spec.md`; use an ADR only for a durable architectural decision.
- Do not create plan/tasks/research/data-model/quickstart/handoffs by default.
- The evaluator reads the contract, diff, implementation, ThinFlow selection,
  and named local receipts. It does not modify code and does not rerun the full
  suite without a concrete uncovered risk.
- Summarize command exit status, totals, elapsed time, and relevant failures;
  retain bounded raw output locally. Never expose credentials.
- After two unchanged check failures, stop. After one grouped feedback repair,
  a repeated blocker requires a human decision or task split.

## Legacy tasks

When `workflow: agentflow-2.3` or a saved snapshot selects 2.3, its captured
stage prompts, artifacts, freshness rules, and feedback budget remain
authoritative. Do not inspect `.agentflow/runs/` or
`.specify/workflows/runs/` unless diagnosing that runner or reading an evidence
path explicitly named by the active gate.

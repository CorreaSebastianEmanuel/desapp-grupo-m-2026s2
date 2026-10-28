# Agent rules

This repository uses Spec-Driven Development. User instructions take precedence.

1. Work on one `backlog/` task at a time.
2. Read `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, `docs/CHECKPOINTS.md`, `docs/WORKFLOW_LESSONS.md`, and the SDD constitution before decisions.
3. Treat the compact `spec.md` as behavioral truth. Add an ADR or design note only when a durable decision or interface cannot fit there; ThinFlow does not require `plan.md` or `tasks.md`.
4. Do not silently expand scope. Add tests for every behavioral change.
5. Never claim a check passed without running it.
6. Keep web, domain, persistence, and external adapters separated.
7. `agentflow start` explicitly authorizes Agentflow to commit, push its generated feature branch, and create one PR after risk-selected local checks and the independent evaluation pass. Agents never merge, expose credentials, or run destructive commands.
8. Completion requires one independent `evaluation.md` ending in `Verdict: PASS`, the exact PR head passing `ThinFlow required`, and human merge. Saved Agentflow 2.3 runs retain their two historical gates.
9. Continue autonomously for documented, routine, or reversible choices. Request a human product check only when an unresolved decision materially changes observable behavior, a business rule, scope, permissions, security, data integrity, or a costly and difficult-to-reverse technical choice. State the decision, impact, alternatives, and recommendation precisely.
10. Keep context and evidence proportional. Never inspect `.agentflow/runs/` or `.specify/workflows/runs/` except for targeted harness diagnosis or evaluator evidence named by ThinFlow. Do not create handoffs or duplicate canonical artifacts for new ThinFlow tasks.
11. When a task is completed or human feedback is recorded, append at most three lines to `docs/WORKFLOW_LESSONS.md`: the repeating pattern, the actionable rule, and the task IDs where it occurred. Never duplicate or rewrite per-task `backlog/feedback/` entries there.
12. ThinFlow classifies the actual diff with `.agentflow/thinflow.json`. Unmapped paths fail closed; higher-risk signals win. Local selection never waives hosted CI, independent evaluation, or human merge.

# Agent rules

This repository uses Spec-Driven Development. User instructions take precedence.

1. Work on one `backlog/` task at a time.
2. Read `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, `docs/CHECKPOINTS.md`, and the SDD constitution before decisions.
3. Treat `spec.md` as behavioral truth and `plan.md` as the implementation boundary.
4. Do not silently expand scope. Add tests for every behavioral change.
5. Never claim a check passed without running it.
6. Keep web, domain, persistence, and external adapters separated.
7. `agentflow start` explicitly authorizes Agentflow to commit, push its generated feature branch, and create a PR after both verification gates pass. Agents never merge, expose credentials, or run destructive commands.
8. Completion requires independent QA and final review with `Verdict: PASS`.

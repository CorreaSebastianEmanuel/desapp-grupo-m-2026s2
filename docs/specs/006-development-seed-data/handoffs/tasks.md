# Tasks Handoff

## Resolutions

- The later `research.md` and `plan.md` are treated as the approved resolution of the earlier product-decision handoff: normalized-equivalent identities are reused without rewriting literal values, and seed execution fails closed outside checked-in development/test capability.
- “Same target dataset” therefore means semantic equality under TASK-005 business identities plus exact non-identity attributes and relationships, not byte-identical identity spelling.
- Concurrency guarantees integrity and retry convergence; simultaneous success is not required. The losing transaction must be sanitized and fully rolled back.
- Security and failure behavior are acceptance work, not polish: denial precedes application/database startup, all failures are nonzero, and public diagnostics are allowlisted.

## Remaining risks

- No `backlog/feedback/TASK-006.md` or `.agentflow/feedback/TASK-006.md` exists, although later design artifacts state that human approval occurred. This is an audit-traceability gap, not permission to change the approved behavior during implementation.
- The race test requires separate unsandboxed database connections and may need careful ownership cleanup to avoid contaminating other ExUnit cases.
- Performance evidence depends on the precise precompiled, already-running PostgreSQL boundary in `quickstart.md`.

## Sequencing guidance

Preserve the manifest/config safety foundation before story work. Treat each story checkpoint as a regression gate. Run concurrency only after deterministic conflict and rollback behavior is green, and run scope inspection after documentation so accidental setup/startup coupling is caught before verification handoff.

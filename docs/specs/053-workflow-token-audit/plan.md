# Implementation boundary

Add a standard-library read-only audit script restricted to backlog metadata, specs Markdown volume/verdicts, and TASK-001–015 live logs. Produce deterministic JSON for a documented audit table. Do not inspect account session stores or print raw log content. Add synthetic parser and missing-data regression tests.

Add a compact repository context policy referenced in the seven existing workflow prompts. Keep stages, gates, permissions, models, task feedback, and artifact requirements unchanged. Bump the workflow patch version and synchronize its installed repository definition. No saved-run migrations or publication.

Document findings and prioritized further experiments. Independent QA reruns scoped tests; final review inspects the changes and QA evidence in a fresh session. Neither modifies implementation.

## Stage analysis extension

Extend only the diagnostic script, its tests, and audit documentation. Parse logs as a stream, isolate headers and the initial user prompt, classify existing skill invocations and explicit roles conservatively, and reconcile footers against the original totals. Keep raw prompts and session identifiers internal. Separate repeated metered stage executions from first metered executions and expose tasks with reused session identities. Do not modify workflow definitions, snapshots, CLI models, or capture account session stores. Revalidate in fresh QA/review sessions.

## Authorized optimization boundary

Combine planning by requesting speckit-plan then speckit-tasks in the same architecture agent session; remove only the standalone tasks agent. Preserve plan_ready/tasks_ready and both verification sessions. Narrow speckit-plan's research guidance while preserving hooks and artifacts. Add a small standard-library runtime module, CLI wrapper and check runner. Explicit stage markers come from the workflow; stdout filtering occurs in the supervisor and leaves human gates outside agent sections. The wrapper forwards existing Codex permissions/models and adds JSON output solely for events/metrics. Store raw output under ignored run paths, not canonical handoffs.

Verification manifest and receipts are required only by new workflow flags. Manifest commands/coverage are canonical planning data; executed receipts carry exit code, evidence path and source fingerprint. Fail readiness on stale receipts, incomplete implementation tasks or uncovered requirement IDs. Legacy snapshots remain usable without the new manifest. Detect HTTP runtime obligation from planned contracts/spec and require explicit runtime classification in the manifest.

Rewind indexes derive from the frozen workflow instead of the global step map; never silently copy a newer workflow into the saved run. Test legacy and current order/gates using fixtures. Capture metrics via explicit emitted markers and JSON usage events, preserving nulls and private session hashes without raw prompts, command content or session IDs in public output. Test a mock end-to-end pipeline with human input, failed checks and token events; no real task delivery, publication or live service mutation.

### Challenge synthesis

Accept the critic's freshness/coverage/input recommendations. Source fingerprints cover git-listed tracked and untracked inputs (including deletion markers), exclude run outputs, backlog/spec reporting and disposable tmp, and separately bind canonical spec/plan/tasks plus verification manifest hashes. Evidence logs are hashed. Checks invalidate old receipts before execution and reject source changes during execution. Tags for downstream tasks must agree with an explicit QA/review task-stage map; independent QA retains semantic coverage responsibility. HTTP methods/routes in spec/contracts independently trigger a runtime requirement with explicit assertion guidance.

Console filtering uses explicit agent start/end events and buffered byte fragments; gate input stays with the supervising runner while noninteractive Codex gets no gate stdin. New exec threads establish their own usage baseline; resumed threads without local baseline and regressing/partial dimensions remain unknown. Public metric summaries omit even private session hashes. Snapshot rewinds retain nested human gate results only for stages before the rewind point; rewinding product discards the old approval. No automatic snapshot upgrades.

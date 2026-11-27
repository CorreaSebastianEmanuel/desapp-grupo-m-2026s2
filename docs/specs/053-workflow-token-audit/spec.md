# Workflow token audit and context efficiency

Audit TASK-001–TASK-015 before resuming TASK-015. Preserve its existing edits and run state.

## Acceptance

1. Report every task’s current status, canonical artifact volume, handoff volume, terminal QA/review verdicts, retained completed-session token totals, and runner invocations. Missing logs yield unknown usage, never zero.
2. Metrics expose only allowlisted metadata and numbers, never raw transcripts or feedback. Accept grouped integer counts using comma or dot and ANSI-colored labels. Ignore malformed counts.
3. Distinguish reported token counts from billing, missing/incomplete sessions, actual prompt sizes, and estimated causes. No unsupported savings percentage.
4. Guide all seven agent stages to bounded, relevant exploration and concise command evidence without truncating behavioral truth, skipping required checks, or weakening independence.
5. Keep both workflow definitions identical and leave TASK-015’s saved workflow unchanged. Document adoption on future runs and explicit migration requirements for resumes.

## Stage analysis extension

6. Attribute retained counts using only each session's initial user prompt, not later tool output. Unknown or ambiguous roles remain unknown; reconcile stage totals with the original audit and report coverage. Preserve the default output; expose detailed analysis through `--stages`.
7. Report first metered execution and subsequent metered executions per task/stage without claiming repetitions are waste. Unmetered attempts remain visible and are never assigned zero consumption.
8. Detect reused session identities without exposing identifiers. Provide a comparison cohort excluding affected tasks, since cumulative versus incremental counts cannot be established from these logs. Do not claim billing totals or input/output/context percentages.
9. Document every stage and task, including missing logs, gates without an agent session, and priorities grounded in measured stage shares.

## Authorized delivery optimizations (supersedes the prior unchanged-stage boundary)

10. New runs use six fresh agent sessions: product, independent critic, combined architecture/tasks, implementation, independent QA and final independent review. Both planning artifacts and their gates remain required. Material human decisions and human merge authority remain unchanged.
11. New runs require a verification manifest mapping every FR/AC/SC identifier in spec.md to concrete required commands. Before QA, validate the manifest, completed implementation tasks, successful command receipts, artifact hashes and source freshness. Fail cheaply on absent, stale, failed or uncovered evidence. Deferred QA/review tasks must be explicitly tagged; this gate never substitutes for independent QA. Legacy saved workflows retain their prior artifact requirements.
12. Checks execute as argument arrays, without implicit shell evaluation, capture output locally, and expose concise status/evidence references. Missing evidence or service/runtime failure prevents readiness; HTTP changes require a runtime check in the manifest plus real HTTP in independent QA.
13. Summary console is the default; full local transcripts remain available and verbose output is opt-in. Gate messages, choice prompts (including fragments without newline), stdin, failure status and heartbeats remain usable. Agent prompts and tool output are suppressed in summary mode.
14. Capture task/stage/attempt, elapsed time and available CLI JSON token counts using explicit stage markers. Metrics contain only allowlisted data. Track private hashed session identity and counter deltas; missing or decreasing usage remains unknown, with resumed threads lacking baseline treated conservatively. Missing optional usage dimensions remain null. No billing or exact-context-share claims.
15. Feedback uses the saved workflow's step order and preserves its snapshot, prior approved gate decisions, and unaffected artifacts. New planning feedback reruns combined planning; legacy runs retain separate planning. No mutation or execution of TASK-015 during this work.
16. Research is scoped to concrete unresolved feature questions. No automatic technology survey or research-agent fan-out for already settled choices. Documentation remains complete and proportional; no model or permission changes.

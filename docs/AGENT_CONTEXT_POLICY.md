# Agent context and evidence

Apply this policy in addition to the active stage instructions and repository rules.

- Read required canonical artifacts in full once per session. Re-read changed files or specific sections when needed. Never replace acceptance criteria, security rules, or human feedback with a summary.
- Resolve the active feature using `.specify/feature.json`. Discover relevant paths with scoped `rg --files` and inspect bounded file sections. Expand exploration only for a concrete dependency, uncertainty, or failure; explain the reason briefly.
- Do not dump whole directories, historical specs, full test logs, generated bundles, or entire diffs into context. Inspect every relevant diff in file-sized chunks. Retain full command output locally when needed and surface exit status, totals, and relevant failures. Keep credentials out of both evidence and output.
- Keep canonical facts in their owning artifact. Supporting research and design documents contain only feature-specific decisions or interfaces; cite existing architecture and contracts instead of rewriting them. Do not skip artifacts required by the active skill or tasks.
- Handoffs contain only new decisions, risks, and next-stage guidance. A stage's final message references its artifact paths and gives a brief outcome instead of copying the report.
- Run every applicable check. Re-run after changes or failures; do not repeat an unchanged passing check within the same stage without a reason. QA runs independent checks; final review uses fresh QA evidence and runs targeted checks for uncovered risks.
- Finish code/design edits before final verification. Development may explicitly request current receipt reuse with `--reuse`; QA never reuses developer receipts. After two failures for unchanged inputs, stop and report the cause, elapsed check time and evidence instead of repeating full suites. Do not modify unrelated inputs to reset the limit. Historical CP1 coverage is not a default additional CP2 gate; current human feedback governs explicit omissions.
- On feedback, preserve unaffected artifacts. Rewind to the earliest affected stage; fix the cited discrepancy and run its regressions plus required checks without reopening settled product or architecture decisions unless evidence requires it.

Word limits govern handoffs and reports, not the completeness of specifications.

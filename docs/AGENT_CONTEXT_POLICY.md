# Agent context and evidence

Apply this policy in addition to the active stage instructions and repository rules.

- Read required canonical artifacts in full once per session. Re-read changed files or specific sections when needed. Never replace acceptance criteria, security rules, or human feedback with a summary.
- Resolve the active feature using `.specify/feature.json`. Discover relevant paths with scoped `rg --files` and inspect bounded file sections. Expand exploration only for a concrete dependency, uncertainty, or failure; explain the reason briefly.
- Do not dump whole directories, historical specs, full test logs, generated bundles, or entire diffs into context. Inspect every relevant diff in file-sized chunks. Retain full command output locally when needed and surface exit status, totals, and relevant failures. Keep credentials out of both evidence and output.
- Keep canonical facts in their owning artifact. Supporting research and design documents contain only feature-specific decisions or interfaces; cite existing architecture and contracts instead of rewriting them. Do not skip artifacts required by the active skill or tasks.
- Handoffs contain only new decisions, risks, and next-stage guidance. A stage's final message references its artifact paths and gives a brief outcome instead of copying the report.
- Run every applicable check. Re-run after changes or failures; do not repeat an unchanged passing check within the same stage without a reason. QA runs independent checks; final review uses fresh QA evidence and runs targeted checks for uncovered risks.
- Finish code/design edits before final verification. Development may explicitly request current receipt reuse with `--reuse`; QA never reuses developer receipts. After two failures for unchanged inputs, stop and report the cause, elapsed check time and evidence instead of repeating full suites. Do not modify unrelated inputs to reset the limit. Historical CP1 coverage is not a default additional CP2 gate; current human feedback governs explicit omissions.
- Within a stage, continue only checks whose independence is explicit in the manifest; block dependent or unknown-effect work after a failure. QA records every required check, including blocked and unexecuted outcomes, and cannot report PASS for an incomplete run.
- Human feedback permits three durable repair cycles (the third may complete); refuse a fourth while retaining feedback and evidence. This is separate from the two-failure stage and per-check limits. A relevant-input repair may permit another attempt; unrelated edits do not.
- On feedback, preserve unaffected artifacts. Rewind to the earliest affected stage; fix the cited discrepancy and run its regressions plus required checks without reopening settled product or architecture decisions unless evidence requires it.

Word limits govern handoffs and reports, not the completeness of specifications.

- Supporting-document applicability is plan-owned and validated by scripts/agentflow_artifacts.py across direct skills, hooks and resumes. Preserve canonical completeness; omit only justified inapplicable supporting documents.
- New attempt evidence is ignored locally. Version only the bounded post-review summary; never delete historical evidence. Keep configured/resolved assignment and observed identity distinct. See docs/AGENTFLOW_MODELS.md and docs/AGENTFLOW_PILOT.md.

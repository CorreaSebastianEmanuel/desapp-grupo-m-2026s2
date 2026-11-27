# Feedback — TASK-060

## Feedback 1

- Time: 2026-10-27T19:02:14+00:00
- Author: sebo
- Restart from: architecture
- Impact: verification
- Required regressions: cited discrepancy plus required manifest checks

Agentflow coordinator finding during the authorized TASK-060 run; this records an operational verification discrepancy, not a new human product decision.

Run 254b0a20 reached evidence_ready after 19/19 development checks, 19/19 fresh QA checks, and independent QA/review reports ending Verdict: PASS. The final gate refused publication with `Stale check evidence: toolchain`. Reproduced through scripts.agentflow_evidence.finalize with the actual resolved workspace-write launch metadata. scripts/agentflow_verification.py:source_fingerprint excludes the registered report/handoff output names but includes specs/071-conditional-order-evaluation-workers/qa-evidence/*. QA added ordered-checks.json, runtime-result.json, runtime-probe.patch, README.md and http-responses.jsonl there after the development checks. These output additions change the source fingerprint; do not weaken the gate or relabel old receipts.

Preserve the approved spec, ADR-0036/0037, purchase/lifecycle behavior, UI boundary, existing models, sandbox selection, independent sessions and retry limits. Refine only the verification output-placement contract in the plan/handoffs. Keep supplemental portable QA evidence in an already excluded output namespace, for example a bounded structured handoffs/check-qa-supplement.json bundle containing the replay patch/instructions, recorded responses, runtime result and ordered check references. Archive the original supplemental files under ignored tmp/ before the next final development verification, preserving their contents; do not delete historical evidence. QA must subsequently update only excluded report/evidence outputs, never recreate qa-evidence/ as an input directory. Do not change fingerprint/receipt tooling or application behavior to fix packaging.

Finish canonical packaging, feedback and workflow-lesson edits before regenerating development evidence. Regenerate required development receipts, then run fresh independent QA and final review through Agentflow. Explicitly check that source/input fingerprints stay unchanged when QA finalizes its output bundle and reports. Update report links to the retained bundle. Treat any real source change as requiring normal re-verification; never fabricate/stamp receipt or report provenance. Preserve actual workspace-write metadata and per-command approved browser execution. The process-scoped Codex 0.164.0 compatibility settings remain in tmp/task060-agentflow-launch.py; no global configuration changes are authorized or needed.



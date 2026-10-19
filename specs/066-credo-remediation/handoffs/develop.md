# Development handoff — TASK-066

Credo 1.7.19 is pinned dev/test only, runtime false. The cleanup previously
measured zero findings across 413 maintained inputs; all 877 original case
identities and assignments remain. TASK-065 depends on TASK-066 and remains blocked.

See [remediation.md](remediation.md) for finding/hunk decisions, causal regressions,
and the CI fixture diagnosis. The occupied-port fixture now reserves each port on the same Docker daemon
as Compose, checks its publication, and retains both refusal assertions. The prior
stopped-container workaround was insufficient alone. Each case also removes its
stopped service containers to require a new daemon port allocation.
Application lifecycle behavior, financial/authentication rules, ownership guards,
and CI commands are unchanged. Native scope permits only the exact additional
shell test and rejects unknown shell paths.

All 16 final manifest checks passed on the repaired source. Historical results
above do not replace these fresh receipts.
Current repair command summaries: `tmp/task066/repair-check-results.json`.

Use PostgreSQL port 55432, Redis 6379 and prepared partition task066. QA must
independently execute every manifest ID without reuse, using its own safe partition
and locked dependencies/Node24/Chromium. Challenge transaction/error ordering,
financial/authentication hunks, native ownership/provenance refusals, nested E2E
subset patterns and both occupied-port cases. Developer receipts cannot replace QA.

T020/T021 remain independent gates. No completion, commit, push, PR or merge is
claimed until the required verification succeeds. No model assignments changed.

The prior exact CI command completed its profiles but failed Agentflow stdout JSON
parsing. The script now preserves diagnostics/sentinel on stderr and emits JSON
only after both profiles and original receipt validation pass. Existing seven-case
contract tests preserve failure exits, redaction and sentinel checks; they now
parse all success stdout as JSON and reject any failure success-output. Red test
against HEAD and repaired green run confirmed; four workflow gate tests also pass.
No workflow snapshot or saved verdict changes. Final receipts are being refreshed.

Confirmed environment mismatch: WSL-local sockets allowed successful Compose
startup; Docker-published blockers produced real collision failures for both ports.
Five consecutive isolated daemon-fixture executions passed in one project,
including both original conflict assertions each time; owned cleanup exited 0.
Full validation still must pass before CI and independent QA.

Final verification: all 16 manifest commands passed through the canonical helper;
check IDs, durations, exit statuses and evidence references are recorded in
`tmp/task066/repair-check-results.json`. Readiness and CI run next before QA.

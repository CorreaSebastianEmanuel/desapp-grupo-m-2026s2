# Independent QA delta — TASK-046 B1

Fresh QA on corrected frozen source passed all eight checks independently via `python3 scripts/agentflow_check.py CHECK_ID --stage qa`, no reuse and sequential DB suites. Loopback bind/connect passed first. Timings: preflight 4.621s, format 1.265s, compile 0.732s, openapi 0.835s, unit 27.507s, integration 183.295s, foundation 1.722s, feature 9.289s. Zero current failures/retries; source and canonical input fingerprints remained unchanged. Exact fingerprints, receipt hashes and evidence references are in `qa-evidence/b1-independent-20261016/manifest-results.json` and qa-report.md.

B1 resolved: actual Chromium cookie removal is asserted before protected navigation, rather than merely advancing the server clock. Controller regression covers both protected destinations, no-store/private-content exclusion and notice-free direct sign-in. Supplemental independent real HTTP/Chromium probe passed in 3.239s, covering missing/tampered HTTP cookies and actual offline cookie removal on both destinations, visible recovery without private identity and successful sign-in to each safe return. Sources/summary are in the same evidence directory. No marker, retention extension or authority/API change.

All FR/SC mappings and acceptance edges reassessed against executed coverage. Existing two-tab deadlines, retained-cookie expiry, exclusive server boundary, no replay, history/reconnect isolation, denial recovery, CSRF/origin, forged websocket, secrets and keyboard evidence remain passing. Exact allowances/config fingerprint preserved on integrated main 7f8d4ba.

Historical unexplained integration failure remains a reproducibility limitation; this invocation had none. Deterministic cookie removal is not a fifteen-minute browser soak; accessibility is automated desktop evidence. Future financial actions still need transactional context authorization.

T028 completed; T029 remains for separate final review. Review should assess B1 against these fresh receipts, not stale historical QA/review conclusions. No implementation or workflow-state changes/publication.

Verdict: PASS

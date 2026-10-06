# Feedback — TASK-016

## Feedback 1

- Time: 2026-10-06T03:49:35+00:00
- Author: sebo
- Restart from: develop

Independent QA blockers B1/B2 from specs/016-external-football-provider-contract/qa-report.md and handoffs/qa.md; this is implementation correction, not new product scope. B1: production runtime raises ErlangError :timeout_value for accepted timeout_ms values 4294968000 and 10000000000000 in both operations, even with immediate not-found adapters. Preserve FR-003/FR-010 positive-integer timeout acceptance; handle VM receive timeout limits without imposing a new request ceiling, preserve the absolute deadline and cancellation/mailbox guarantees, and add real production-runtime regressions including both operations and immediate error/success paths. B2: valid PL/2025-2026 scope is lost when timeout_ms is 0, -1, nil or true. Preserve independently validated football scope in invalid-request errors while never reflecting malformed scope, per FR-009/SC-005; correct the contradictory fixture oracle and test both operations, invalid timeout types and invalid scope. Reuse /tmp/qa-task016-20261006/adversarial.exs and repro.exs as evidence. Keep specification and plan boundaries, retain all prior behavior and independent fixtures, rerun every stale/current manifest check and the readiness gate, then obtain fresh independent QA and final review PASS before publication.


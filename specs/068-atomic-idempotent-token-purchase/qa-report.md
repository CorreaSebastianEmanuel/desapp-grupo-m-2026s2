# Independent QA — TASK-029

Evidence directory: `qa-evidence/independent-20261024-final/` (E below). Read current spec, plan, tasks, architecture/develop handoffs, feedback 1–5, manifest, relevant contracts/ADRs and file-sized implementation/test/tooling diffs. No implementation edits, receipt reuse, Agentflow invocation, delegation or historical workflow-log inspection. `inputs.json` and `closure.json` confirm all 44 changed tracked inputs stayed unchanged.

## Blocking finding

**B1 — permanent invalid request reported as transient infrastructure failure.** Real authenticated `POST /api/purchases` with otherwise valid details and JSON `request_key: "bad\u0000key"` returns **503**, `Content-Type: application/json; charset=utf-8`, `{"error":{"code":"temporarily_unavailable"}}`. Expected malformed-key outcome is **400 invalid_request** under contracts/purchase.md / FR-012 / SC-006. The string passes PurchaseInput.valid_key?/1 (lines 29–30), then cannot be represented in PostgreSQL text. Retrying identical input cannot repair it. Financial snapshots remain equal.

Reproduction: with the manifest environment, run `mise exec -- mix run specs/068-atomic-idempotent-token-purchase/qa-evidence/independent-20261024-final/http-key-boundary.exs`. Both unchanged request attempts exited 1; E/http-key-boundary.log and E/http-key-boundary-attempt2.log record `left: 503, right: 400`. The second adds response/state instrumentation only: `state_unchanged:true`. Approximate elapsed times: 7.0s and 6.7s (E/key-boundary-results.json). Stopped this obligation at two failures; no remediation.

## Verification matrix

Every manifest argv was independently executed with its declared environment, local TMPDIR and system Chrome; E/results.json records commands, exit codes and duration. No developer receipt substitutes for acceptance.

| Check / obligation | Independent evidence / outcome |
| --- | --- |
| toolchain, prepare, services, format, compile, credo, openapi, inventory, assets | PASS, respective E/*.log; inventory: 1,019 cases. |
| unit | PASS, E/unit.log: expected/discovered/executed/passed **509**, audit_count 69; 298.3s. Includes input, diagnostic, retry-identity and scope regressions. |
| integration | Initial attempt blocked before ExUnit: browser `launch-failed`, 54.9s. Direct outside-sandbox browser probe passed. Outside-sandbox second attempt was stopped via its supervisor at the acceptance retry limit, exit 143 after 631.3s; **not** an implementation assertion failure or passing suite. E/integration*.log/json. |
| e2e | Initial attempt blocked before cases: browser `permission-denied`, 53.4s, E/e2e.log. Queued second attempt canceled before launch when QA stopped. No E2E pass claimed. |
| purchase-runtime | PASS, E/purchase-runtime.log: real Endpoint, PostgreSQL/Redis readiness and persisted-effect assertions; 6.7s. |
| expanded real HTTP | PASS, `mix run E/http-adversarial.exs`, exit 0; E/http-adversarial.log records **40** status/header/body observations: 6×200, 21×400, 1×401, 1×404, 10×409, 1×503. First probe had a wrong missing-player expectation because it reused a completed key; corrected only that input, preserving first log and notes. |
| malformed NUL key | **FAIL B1**, twice; no further attempts. |

## Acceptance matrix

PASS below is limited to observed cases; uncompleted suites prevent overall acceptance.

| Spec criteria | Evidence and result |
| --- | --- |
| US1.1–2; FR-001–006,009; SC-001,005 | HTTP success transfers 3 tokens at 1.00 for 3.00; buyer 7.25, recipient 3.00; supply 100; one operation/transfer and two entries. Response retains identities, quote/version/time and exact strings. Replay after later activity retains original evidence. PASS for runtime cases; restart retrieval unverified. |
| US1.3–4; FR-003,007; SC-004 | Multiple-initialized-player isolation and both committed quote-order races inspected in transfer/quote_order/concurrency tests. **Not independently verified**: full integration incomplete. |
| US2.1,3; FR-010,013 | Identical HTTP replay returns same body; changed quantity/player with completed key gives 409 key_conflict, including before changed eligibility. PASS. |
| US2.2,4; FR-011; SC-002 | Concurrent duplicate/buyer-scoped races and lost-ack/fresh-process persistence need completed integration evidence. **Not verified**; sequential replay passed. |
| US3.1–5; FR-008,012; SC-006 | HTTP funds/inventory/quote/player/uninitialized/self-purchase refusals, malformed JSON/UUID/quantity, authority overrides and missing auth passed. 401 includes Bearer challenge. Key bounds 128/129 passed, but **B1 fails malformed-key classification**. |
| US3.6–7; FR-006,011; SC-003 | Injected insert failure gives 503 with unchanged snapshots; previously funds-rejected key succeeds after provisioning. PASS observed cases. Deferred rollback and restored-inventory retry remain **unverified** pending integration. |
| FR-002,005,009,014,015 | Source-only transfer and no credit creation observed; append-only guards, restart and full races inspected but unverified. Inventory preserves existing cases; NUL regression missing. Diff adds no funding/sales/history endpoint; scope PASS. |

Additional nonblocking tooling observation: a standalone PROFILE_DISCREPANCY record yields `{}` from safe_failure_diagnostics because its early-return condition omits discrepancies; E/diagnostic-probe*. It does not invalidate the closed browser-cause tests.

Blockers: B1; incomplete independent integration/E2E and corresponding acceptance evidence. Return through Agentflow feedback to development; QA made no fixes.

Verdict: FAIL

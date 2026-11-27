# Independent evaluation — TASK-050

Reviewed the compact spec, backlog task, current feedback, REVIEW.md, repository principles, complete candidate diff, affected implementation and tests, and ThinFlow's named candidate/check evidence. No implementation changes or additional agents. The current feedback repair is limited to exact Sobelow root normalization, its positive/negative controls and profile registration; the previous path discrepancy is resolved.

## Acceptance and evidence

| Acceptance | Evidence and assessment |
| --- | --- |
| Sign-in IP and normalized identifier quotas; success release; concurrency | Configuration sets 30/IP and 10/identifier per 15 minutes. SessionController uses body credentials and shared User normalization, hashes identifiers, reserves before verification, and releases successful/unavailable checks. The serialized RequestQuota server enforces admission and fences late releases by timer generation. Session regressions passed for boundaries, cross-peer normalization, successful release, concurrent reservations and expiry. PASS. |
| Registration and account-wide API quotas | Registration controller plug takes five/IP/15 minutes. AuthenticateAPI applies 120/account/minute only after valid credentials; JWT subjects are canonicalized. API tests passed for shared JWT/key/routes quota, rejected credentials and account isolation; registration boundary test passed. PASS. |
| Generic 429, positive Retry-After and outage policy | Both quota response paths set Retry-After and no-store. Browser plugs return 503 on outage; authenticated API continues with a fixed diagnostic. Targeted response/header and stopped-supervisor regressions passed, including rejection of unauthenticated API requests during outage. PASS. |
| Peer/proxy trust | Source uses connection peer, canonicalizes mapped IPv4, consults only explicitly configured proxies, validates the entire forwarded chain and selects the rightmost untrusted hop. Tests passed for spoofed untrusted headers, multiple trusted hops, malformed-chain fallback and mapped-address equivalence. Runtime proxy configuration rejects invalid addresses. PASS. |
| Malformed inputs, UUID and authorization boundaries | Form bodies exclude query credentials; invalid email representations fail safely. Trade input rejects binary UUID representations; JWT claims require textual UUIDs and canonicalize them. LiveView guards/fallbacks safely handle tested malformed form values and missing state. Cross-owner order reads/cancellation and non-administrator access remain denied. Affected session, account, API and LiveView tests passed. PASS. |
| Diagnostics, valid responses, public/metrics policy | Phoenix's keep-empty filter also governs LiveView parameter logging; RequestJSON replaces decoder exceptions containing raw input with a fixed error. Structured request logging retains its existing typed allowlist. Debug-log/API malformed-JSON controls passed; outage diagnostic excludes credentials. Existing valid browser/API/admin/business-metrics/OpenAPI cases passed. Router public/metrics policies are unchanged; public health remains accessible when an account is limited. PASS. |
| Defensive regression coverage | New behavior cases are registered as integration tests; Sobelow control is registered as unit. Focused execution below ran all seven affected application test files. PASS. |
| Sobelow exact root variants and blocking policy | normalize_finding_paths strips only slash-delimited configured/resolved/relative roots and the exact relative-root variant with leading parent segments removed. New negative controls preserve similar/unrelated paths. The native finding/recovery test asserts lib/probe.ex and still requires unsafe analysis to fail. Both required Python check sets passed. PASS. |

## Risk, architecture and deterministic evidence

High risk is appropriate for authentication and availability changes. Recomputed selection matches the candidate: application, delivery-docs and delivery-harness rules; no unmapped paths. Policy and gates are unchanged. The quota server and HTTP responses stay in the web boundary; account normalization/authentication remain in Accounts. No persistence schema, financial transaction, provider adapter or ownership policy changes.

Called `thinflow.readiness(..., require_evaluation=False)` against the actual workspace. It verified task/branch, recomputed selection and material digest, exact check membership, successful exit codes and every evidence SHA-256. Candidate digest: `06353deb6019674b8ba6ef410173f3c6c4416ecbe11f50e35445b21e6c3fc88c`.

| Required local check | Verified result |
| --- | --- |
| format | Exit 0; silent output is normal for check-formatted. |
| compile | Exit 0; silent incremental compilation. |
| unit-profile | Complete receipt: 461 expected/discovered/executed/passed; audit_count 8. |
| ci-contracts | 36 tests, OK. |
| harness-tests | 389 tests, OK, including Sobelow fixture controls. |

Only the named deterministic check evidence was inspected; no workflow logs or builder summaries were used as proof. Negative-fixture diagnostics inside successful harness runs are expected assertions, not failed candidate checks.

The selected unit profile does not execute the newly added integration cases. To resolve this concrete evidence gap, independently ran:

`MIX_OS_CONCURRENCY_LOCK=0 MIX_ENV=test mix test test/accounts_test.exs test/web/session_test.exs test/web/api_test.exs test/web/workspace_live_test.exs test/web/admin_live_test.exs test/web/openapi_contract_test.exs test/business_metrics_test.exs`

Result: **29 passed**, seed 873173, exit 0. No full-suite rerun.

## Blocking findings

None.

## Advisory findings

None.

## Residual risks

- Quotas are deliberately process-local and reset on application restart; distributed enforcement is outside the approved scope. Proxy protection depends on correct deployment trust configuration.
- Full integration/browser profiles and hosted security/quality gates were not rerun by this evaluator. The exact PR head still requires `ThinFlow required` and human merge; this report establishes candidate readiness, not task completion.

Verdict: PASS

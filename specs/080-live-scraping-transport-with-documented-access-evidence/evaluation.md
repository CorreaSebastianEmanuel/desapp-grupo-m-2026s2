# Independent evaluation — TASK-080

Re-review of the repair to the three blocking findings in the prior evaluation. Inspected the compact spec and task, feedback, `REVIEW.md`, governing repository documents, current diff, affected admission/transport/source code and tests, and current ThinFlow candidate evidence. No implementation code was changed, no other evaluator or skill was invoked, no workflow logs were inspected, and no real network was contacted.

## Acceptance

| Acceptance | Evidence | Assessment |
| --- | --- | --- |
| Deny missing, expired, withdrawn, incompatible or scope-mismatched live evidence before contact | `Assessment.actual/0` remains missing/unverified; `admit_snapshot/3` checks current UTC for live mode, permission, expiry, revision and exact scope. `HttpTransport.fetch/3` obtains a newly admitted snapshot before endpoint resolution and request start. Tests cover actual-deny, expiry/future review, withdrawal/revision/scope changes and zero HTTP callback contact. | Met. The stale fixed fixture clock is retained only for fixture mode; explicit clock injection remains available for deterministic checks. |
| Fetch assessed HTTPS documents through the existing pipeline, capped at 2 MB | Endpoint derives only from the admitted row's document map and must match an approved HTTPS origin. Production `httpc` request disables redirects, verifies TLS peer/hostname, sets `max_body_size`, and streams one chunk at a time. Declared lengths and accumulated streamed bytes are checked; excess cancels the request. `Source` continues decoding, translating and publishing through the established path. | Met by implementation and deterministic stream-boundary test. |
| Shared lease, volume/concurrency controls, deadline and safe failure behavior | `HttpTransport.acquire/3` requires the shared admission table; absent/unavailable state returns `rate_limited`. Application starts the shared owner. Tests cover fail-closed absence, volume exhaustion, concurrent leases and timeout cancellation. Transport checks the absolute deadline and cancels on size, error, parent termination and timeout. | Met. |
| Deterministic tests cover both operations, denial, revalidation, budgets, bounds, cancellation and failures | `assessment_test.exs` covers catalog and performances, no-contact denials, evidence changes, shared limits, streamed oversize cancellation, callback cancellation and provider failure. No live credentials or external requests are used. | Met. |
| Checked-in assessment stays deny-by-default pending reviewed evidence | `Assessment.actual/0` has missing permission, unreviewed conditions, no expiry/destinations and unverified scopes. Spec records activation prerequisites. | Met. |

## Re-review of prior findings

- **B1 resolved:** live evidence now uses `DateTime.utc_now/0` unless a test clock is explicitly injected. Each HTTP fetch calls `admit_snapshot/3`, which validates the current full assessment and returns the exact row and revision used to resolve its document URL and destination. Changed or withdrawn evidence is rejected before `start_request/4` can contact the URL. Regression tests assert zero callback contact for expired/future evidence and changed evidence.
- **B2 resolved:** live acquisition no longer treats missing admission state as unshared. It obtains the application-owned ETS table or fails closed; `FixtureTransport` enforces shared volume, cadence and lease concurrency. The application supervises the table owner and tests exercise missing state and concurrent acquisition.
- **B3 resolved:** the production request is asynchronous and streamed. `max_body_size` constrains the HTTP client, declared content length is rejected before requesting a body chunk, accumulated chunk size is checked before requesting the next chunk, and over-limit/timeout/error paths cancel the request. The new streamed-response test proves cancellation occurs and no next chunk is requested. The previous complete-body allocation finding no longer describes the production retrieval path.

No additional blocking issue was found in the repaired surfaces. The HTTP adapter remains isolated from persistence and local reads; existing provider decoding/provenance behavior is reused. The current assessment intentionally enables no real source.

## ThinFlow evidence

Inspected the current `.agentflow/runs/thinflow/TASK-080/candidate.json` and its referenced check outputs. The read-only `scripts.thinflow.readiness(Path.cwd(), 'TASK-080', require_evaluation=False)` validator returned `ready: true`, tier `high`, with `ci-contracts`, `harness-tests`, `format`, `compile` and `unit-profile`; it reported no missing or stale candidate evidence. Candidate outputs record successful exit codes for all five required checks, including the complete unit profile. This is the current candidate evidence; hosted `ThinFlow required` on the exact PR head and human merge remain subsequent gates.

## Blocking findings

None. No blocking findings remain.

Verdict: PASS

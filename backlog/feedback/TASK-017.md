# Feedback — TASK-017

## Feedback 1

- Time: 2026-10-06T18:48:11+00:00
- Author: sebo
- Restart from: architecture

Independent QA blocker B1, not a new product preference: specs/017-football-data-api-adapter/qa-report.md and /tmp/task017-independent-qa/delay-acceptance.exs plus delay-http.exs reproduce stale retry_after_ms after complete normalized readiness. Retry-After 2 seconds with 1/2/3-second readiness yields 1500/1000/500 ms instead of 1000/nil/nil; real HTTPS Retry-After 1 second plus 1200 ms normalization pause emits about 999 ms after expiry. FR-011 and FR-015 require known future waits and end-to-end expiry evidence. Reconcile the plan boundary explicitly before implementation because it currently forbids Runner/Error changes: design the smallest source-anchored expiry mechanism preserving the public TASK-016 contract, other adapters' behavior, all 217 fixture cases/fingerprints, deadline/cancellation rules and safe diagnostics. Do not weaken source-independent assertions or blanket-remove byte guards. Map any narrowly necessary internal seam and guard updates in plan/tasks/contracts/verification. Preserve unrelated product/architecture decisions. Add complete-boundary tests for delta seconds, HTTP-date and reset headers, positive-but-overstated waits and expired waits, with time consumed both during parsing and after it; preserve and rerun the independent QA probes. Implement the correction, rerun required checks with fresh evidence, and obtain fresh independent QA and final review PASS before publication.

## Feedback 2

- Time: 2026-10-06T19:37:42+00:00
- Author: sebo
- Restart from: develop

Independent final-review blocker B1 (P2), no new product/architecture decision: specs/017-football-data-api-adapter/review-report.md and preserved /tmp/task017-review/http-date-precision.exs reproduce premature millisecond truncation in FootballData.Errors date parsing. At receipt UTC 2026-10-06T12:00:00.000999Z and Retry-After Tue, 06 Oct 2026 12:00:02 GMT, complete normalized readiness offsets 999001/1998001 microseconds emit 999/nil instead of 1000/1 milliseconds; the expired control passes. Fix within the existing authorized Errors/Runner plan: preserve original microsecond date differences in source expiries and floor only the remaining public milliseconds at normalized readiness. Add portable full-boundary fractional-receipt tests splitting parsing and normalization time, independently varying fractional UTC and monotonic origins, covering positive, exact 1-ms and sub-ms/expired waits. Do not derive expected results from production helpers, widen tolerances, alter fallback semantics, relax TASK-016 fixtures/public Error/deadline/Runner protections, or reopen settled product/architecture. Preserve and rerun the independent review probe and original QA probes. Refresh all manifest checks, readiness, independent QA and final review PASS before publication. Also keep git diff --check clean, including feedback EOF formatting.
## Feedback 3

- Time: 2026-10-06T20:43:13+00:00
- Author: sebo
- Restart from: develop

GitHub PR #28 Quality baseline run 37526996207 failed in a clean checkout: 398/400 tests passed (4 excluded), with two Providers.ScopeTest failures at lines 25/125 because adapter_active?/0 unconditionally reads ignored .specify/feature.json. Correct TASK-017 scope guards so committed adapter expectations do not depend on local feature state; preserve exact allowed paths, baseline protection, discovery and Runner constraints. Review the related statistics guard for the same hidden-state assumption. Reproduce the missing .specify metadata case in a separate clean shallow checkout without renaming/removing local workflow state, and run scripts/ci_unit_tests.sh there. Do not modify implementation, public behavior, Actions, dependency pins or broaden scope. Add clean-checkout portability evidence to acceptance/verification as appropriate and independently rerun QA and final review; retain all 217 fixtures and the original expiry/precision probes. Existing PR #28 must be updated, never create a duplicate. The canonical verified feature stays specs/017-football-data-api-adapter on branch 017-football-data-api-adapter.

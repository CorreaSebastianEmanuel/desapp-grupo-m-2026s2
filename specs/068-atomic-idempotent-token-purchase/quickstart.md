# Purchase validation guide

Use the pinned toolchain and existing service configuration from docs/TEST_PROFILES.md. Set PATH to the installed Elixir 1.20.3 / OTP 29.0.6 toolchain, ERL_FLAGS='+S 4:4', MIX_ENV=test, and an isolated MIX_TEST_PARTITION. Configure PostgreSQL/Redis through existing environment variables; do not reset an old database. Docker and Chromium are required by the existing integration/E2E profiles. No provider credentials are needed.

After implementation, prepare/check the services and database using the manifest's toolchain, prepare and services checks. The services command is MIX_ENV=test mix infrastructure.verify; the runtime runner repeats SELECT 1/Redis PING and actual endpoint readiness. Missing services fail. Build existing browser assets before the E2E profile.

Use `mise exec -- python3 scripts/agentflow_check.py CHECK_ID --reuse` to select the installed pinned toolchain. The manifest selects the isolated `_task029_20261023` partition; prepare creates it without resetting existing stores.

Run every check ID in verification.json through `python3 scripts/agentflow_check.py CHECK_ID --reuse`, in manifest order, after final edits. Reuse only valid development receipts; runtime/services always execute. Update config/test_profiles.json for new unit and integration cases before final checks; inventory updates are implementation work, not check-time mutations. Do not run ci_unit_tests.sh or historical coverage wrappers in addition to the already required unit/integration pair.

For a focused development demo after those tests exist:

```sh
MIX_ENV=test mix test test/football_market/market/purchases/transfer_test.exs
MIX_ENV=test mix test test/football_market/market/purchases/idempotency_test.exs
MIX_ENV=test mix test test/football_market/market/purchases/rejection_test.exs
MIX_ENV=test mix test test/football_market/market/purchases/concurrency_test.exs
MIX_ENV=test mix run test/runtime/purchase_http.exs
```

The fixture initializes an eligible player through existing Market initialization, sets the designated recipient, provisions buyer balance as test setup and retains a valid exact quote. At 1.25 with quantity 3 the debit and credit are 3.75, buyer receives three tokens and player supply is 100. The HTTP runner creates its own fixtures and live loopback endpoint, derives a real test credential, asserts 200 JSON exact strings, retries the same key for the identical result, checks changed-details 409, checks a business refusal and unauthenticated 401 challenge, and verifies one persisted operation/transfer/ledger pair. No token or secret is printed.

The runtime runner must own its migrated schema, endpoint port and cleanup registry. All success and failure paths clean only its resources; real startup/request/readiness failures exit nonzero. For quote races, barrier tests prove both lock orders; do not attempt to demonstrate concurrency with manual request timing. Rerun QA independently with --stage qa and no --reuse. QA/review reports are produced only by their owning stages and must end Verdict: PASS.

Feedback-2 recovery: implement the test-first diagnostic correction from plan.md and contracts/profile-diagnostics.md before retrying integration. Preserve prior failed attempts; do not clear counters or manufacture receipts. Use deterministic targeted unittest selections in test/scripts/test_profile_runner_test.py and test/scripts/agentflow_evidence_test.py while developing, then update native unit inventory. These tests run inside the one final unit profile; no extra full-profile check is added. On a browser prerequisite failure, inspect only the helper's allowlisted browser_prerequisite_causes; unknown cause remains launch-failed. Never publish raw Playwright output. After all source/design edits, execute the complete manifest with helper freshness checks, then development readiness. Independent QA starts only after owner readiness, superseding the old develop handoff's diagnosis-first QA suggestion.

The native cases are `test_browser_preflight_classifies_only_closed_causes_and_keeps_raw_errors_private`, `test_supervisor_forwards_only_complete_safe_browser_records`, `test_browser_preflight_supervisor_timeout_emits_safe_timeout_cause`, and `test_safe_diagnostics_accept_only_closed_browser_cause_records`. They exercise injected Chromium launch outcomes, retry-environment identity and controlled children; integration/E2E remain the real installed-browser checks. Set `CHROMIUM_PATH` before Agentflow starts when the agent sandbox needs an explicit launchable browser. The integration/E2E manifests hash this declared value into check identity without storing it raw.

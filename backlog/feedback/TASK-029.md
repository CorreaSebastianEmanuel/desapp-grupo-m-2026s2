# Feedback — TASK-029

## Feedback 1

- Time: 2026-10-23T16:25:13+00:00
- Author: ezequielgonzalez
- Restart from: product
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

Product decision: buyers may purchase only from credits already provisioned in their account. Funding, deposits, withdrawals, and credit grants are outside TASK-029; tests may provision buyer balances as setup.

## Feedback 2

- Time: 2026-10-23T18:42:47+00:00
- Author: ezequielgonzalez
- Restart from: architecture
- Impact: verification
- Required regressions: cited discrepancy plus required manifest checks

Human authorization: complete TASK-029, including a narrowly scoped change to shared test-profile browser preflight diagnostics needed to make browser-prerequisite failures actionable. The integration check failed twice before ExUnit execution with category browser-prerequisite; the handoff names both attempts. Reproduced the exact Node 24.21.0, TMPDIR, and integration environment locally and Chromium launch now passes. Extend the profile runner and safe evidence reporting to emit only allowlisted, non-sensitive launch cause categories, add regression tests, and update TASK-029 workflow scope/plan/verification accordingly. Do not expose raw Playwright errors, alter application purchase behavior, bypass or reset retry guards, or mark checks complete without execution. Once this relevant source change is made, rerun integration and all remaining checks through the existing helper; reach development readiness before independent QA/review.

## Feedback 3

- Time: 2026-10-23T19:30:36+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Development feedback: the allowlisted diagnostics now identify integration and E2E failure cause permission-denied before browser acceptance. The exact pinned Node 24.21.0 profile environment can launch Chromium from the parent shell, and /Applications/Google Chrome.app/Contents/MacOS/Google Chrome also launches successfully. The existing OpenAPI browser adapter already honors CHROMIUM_PATH. Extend the profile-runner preflight to use CHROMIUM_PATH when set and preserve Playwright's pinned default when unset; add red/green regression coverage for both paths, update exact TASK-029 scope and inventory/verification as needed, then resume with inherited CHROMIUM_PATH set to the verified system Chrome. Preserve all browser gates and retry limits; do not weaken checks or alter purchase behavior.

## Feedback 4

- Time: 2026-10-23T21:41:52+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: UNIT, INTEGRATION, E2E

QA remediation authorized: classify Node real module-resolution failures (including Cannot find module / MODULE_NOT_FOUND) as dependency-missing with a regression; add the missing concurrent quote-first purchase ordering test. Reproduce QA unit and browser failures with TMPDIR set to the repository local tmp directory and CHROMIUM_PATH set to the launchable workspace Chromium; correct invocation/environment causes without editing unrelated coverage behavior or weakening profile gates. Run current required manifests and reach fresh independent QA/review.

## Feedback 5

- Time: 2026-10-24T00:41:25+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: INTEGRATION

QA final integration failed only at catalog.seed subprocess assertions; local focused rerun with the same QA partition and local TMPDIR passed. Diagnose the isolated QA runner difference and make nested Mix invocation deterministic while preserving all disabled capability and production startup assertions. Add focused regression; run integration and current manifest checks before fresh QA/review.

## Feedback 6

- Time: 2026-10-24T04:55:31+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: UNIT, INTEGRATION, E2E

Fresh QA found a real malformed-key defect: authenticated POST with request_key containing NUL returns 503 although spec FR-012/SC-006 requires 400 invalid_request; the byte reaches PostgreSQL text storage. Validate unsupported text bytes before persistence and add focused domain plus real HTTP regressions, asserting unchanged snapshots. QA also found safe_failure_diagnostics returns {} for PROFILE_DISCREPANCY because its early-return omits parsed discrepancies; fix and test strict allowlisting. Finally diagnose QA child Chromium launch-failed/permission-denied: preserve browser gates, reproduce exact nested profile environment, and make the configured launch work or report the concrete blocker without bypass. Rerun required manifests and fresh independent gates.

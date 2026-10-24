# ADR-0034: Bind relevant environment values to check identity

**Status**: Accepted for TASK-029 verification recovery
**Date**: 2026-10-23

## Context

The integration and E2E checks launch a browser using `CHROMIUM_PATH` when it is set. Changing that path changes the executable under test, but the retry guard previously bound source, design inputs, command and static manifest environment only. It could therefore refuse a legitimate retry after the browser path changed, while a passing receipt could be reused under a different browser.

## Decision

Allow a check to declare a `retry_env` list of relevant, nonsecret environment variable names. Validate names, reject duplicates and reject overlap with static check `env`. Include only the declared current values in the hashed check identity used by retry budgets and receipt freshness. Never store or print the raw values. TASK-029 declares `CHROMIUM_PATH` for integration and E2E only.

## Consequences

Changing a declared value starts a distinct retry scope and invalidates receipts for that check. Unrelated environment changes do not affect retries. The default remains an empty list, preserving existing manifests. Tests must cover value changes, invalid declarations, no raw-value leakage and unchanged failure limits.

No product behavior, test command, retry count or application permission changes. The browser prerequisite remains mandatory and its failures remain failures.

## Outcome

Harden existing API and browser entry points against malformed inputs, unauthorized access, credential disclosure, and repeated requests.

## Acceptance

- [ ] Browser sign-in POSTs allow 30 attempts per source IP in 15 minutes. Credential failures also consume one of 10 attempts per normalized login identifier in 15 minutes, shared across IPs. Successful credential checks do not consume or erase failed attempts. Concurrent checks cannot overrun the identifier quota.
- [ ] Browser registration POSTs allow five requests per source IP in 15 minutes. Authenticated API routes allow 120 requests per account per minute across that account's JWTs and API keys. Rejected API credentials do not consume an account's quota.
- [ ] Exhausted quotas return a generic 429 and a positive Retry-After in seconds. A limiter outage returns 503 on sign-in and registration POSTs. Authenticated API requests continue and emit a credential-free diagnostic.
- [ ] Source IP defaults to the connection peer. X-Forwarded-For is used only for explicitly trusted proxy peers. Select the first untrusted hop from the right and fall back to the peer for an invalid chain.
- [ ] Browser credentials are read from the form body. Malformed form inputs and LiveView events are rejected safely. External account and resource IDs observe their existing UUID contracts. Keep authentication and owner/administrator checks in force, including when another account's resource ID is supplied.
- [ ] Request diagnostics do not include credential values or arbitrary form, API, or LiveView parameter values. Valid requests preserve their existing responses, and public and metrics endpoints retain their current access policies.
- [ ] Focused regressions exercise quota boundaries, expiry, proxy handling, outage behavior, malformed inputs, authorization, and redaction.
- [ ] Sobelow summary links use source-relative paths when the analyzer reports the exact fixture root with or without leading parent segments. Similar paths retain their original values, and blocking findings still fail the scan.

## Scope

Existing browser sign-in and registration POSTs, authenticated API routes, input boundaries on existing browser and API interfaces, and request diagnostics.

Correct the Sobelow fixture path normalization identified during verification.

## Non-goals

New public routes, password-to-JWT endpoints, quotas for other public routes or LiveView events, distributed rate limiting, and changes to Sobelow findings policy or delivery gates.

## Risk

High. The change touches application authentication, HTTP request handling, and availability under load.

## Decisions

Use a configurable, supervised, in-memory limiter for one application instance. Each window starts at its first counted attempt and resets on expiry. Browser origin and CSRF checks run before the quotas. Use the same trim-and-lowercase normalization as account lookup. A successful credential check releases its reservation even if the browser session subsequently fails to start.

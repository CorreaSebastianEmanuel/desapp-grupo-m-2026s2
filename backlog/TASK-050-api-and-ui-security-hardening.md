---
id: TASK-050
title: API and UI security hardening
type: task
checkpoint: CP3
priority: critical
status: review
workflow: thinflow-v1
depends_on: TASK-013, TASK-030, TASK-046
active_run: b04ce297
---

## Outcome

Complete input validation, authorization, secret handling, rate limiting, and security tests.

## Approved scope and policy

Harden existing API and browser entry points against malformed inputs, unauthorized access and credential disclosure. Preserve valid API responses and existing authentication, public-route and metrics access policies. Add defensive regression tests for each behavior change.

Use a configurable in-memory limiter for one application instance. On the existing browser sign-in route, enforce 10 failed attempts per normalized login identifier in 15 minutes and a separate quota of 30 attempts per source IP in 15 minutes. Limit existing browser registration to 5 requests per source IP in 15 minutes. Limit existing authenticated API routes to 120 requests per account per minute, shared across its credentials. Use the connection IP and only honor forwarded headers through explicitly configured trusted proxies. Return a generic HTTP 429 with Retry-After on exhaustion. If the limiter is unavailable, return 503 for sign-in and registration and let already-authenticated API requests continue with a diagnostic that contains no credentials.

Existing browser sign-in is the only password sign-in surface in scope. Keep new public routes, password-to-JWT endpoints, general public-route quotas, and LiveView event quotas out of scope. The scope and failure behavior above are approved product decisions.

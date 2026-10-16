# ADR-0026: Revocable browser sessions separate from API credentials

**Status**: Accepted design for TASK-046
**Date**: 2026-10-15

## Context

The existing cookie-only Phoenix session cannot revoke copied authority or terminate other tabs. TASK-046 requires fixed exclusive 15-minute expiry, current-session logout, safe outages and no change to API credential policy. The product challenge additionally requires truthful invalidation failure, stale-form account isolation, separate authorization/display deadlines and real-browser evidence.

## Decision

Add an Accounts-owned PostgreSQL browser_sessions table with digested random handles, anonymous/authenticated/revoked states and immutable authenticated start/deadline. Use encrypted signed HttpOnly cookie transport, Secure in deployment, CSRF and origin protections. Retire anonymous authority and insert fresh authenticated authority atomically under a row lock; concurrent stale submissions fail closed. Authenticated sign-in submissions redirect without replacement or renewal. Factor credential verification from API token issuance while preserving all API results/lifecycles.

Revocation commits before success/notification. On failure conceal local private content and offer retry without claiming logout; retain only HttpOnly retry authority. Independent sessions/API credentials remain unaffected. PubSub notifications plus <=1-second authoritative checks and an expiry timer remove connected content within two seconds; every authorization independently enforces now < expires_at. Subscribe then validate closes notification races. Missing users and backend failures fail closed.

Never serialize raw authority into LiveView mount payloads. Connected mounts authenticate using server-side connect_info cookie, not caller session IDs. Conceal private DOM on disconnect/pagehide and force validated full reload on reconnect/pageshow; destroy old LiveSocket before recovery to prevent replay. Use no-store headers and real-browser tests for history, account switching, tabs and expiry. Test-only clock/failure controls are not shipped as routes.

## Consequences and alternatives

This extends cookie-only sessions using existing PostgreSQL, not new infrastructure. DB availability is required for private access; a failed revoke cannot guarantee remote termination while reads still work, so the UI explicitly withholds confirmation until retry succeeds. Redis authority, JWT revocation changes, cookie deletion alone, timer-only expiry and server-only browser evidence were rejected because they expand infrastructure or fail stated guarantees. Later resource/trading contexts must authorize at their own atomic boundary; this shell adds no business mutations. Existing architecture, credential ADR-0003 and API-policy ADR-0006 remain authoritative.

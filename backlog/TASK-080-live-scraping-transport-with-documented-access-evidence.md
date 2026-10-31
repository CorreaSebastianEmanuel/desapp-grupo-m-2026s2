---
id: TASK-080
title: Live scraping transport with documented access evidence
type: task
checkpoint: CP2
priority: critical
workflow: thinflow-v1
status: review
depends_on: TASK-016, TASK-055, TASK-056, TASK-019
active_run: 25d64a66
---

## Outcome

Add an HTTPS document transport to the existing TASK-016 provider contract and TASK-055 scraper pipeline. It may contact a source only when the current reviewed assessment admits that exact operation, league and season, and names each requested document URL under an approved HTTPS destination. Checked-in actual evidence stays missing and all live scopes stay denied. Accepted documents continue through the existing decode, translation, provenance and ingestion path; local reads remain independent of scraping.

## Acceptance

- Live catalog and performances requests with missing, expired, withdrawn, incompatible or scope-mismatched evidence return `unsupported_capability` before transport contact.
- An admitted request fetches only assessed HTTPS documents (maximum 2 MB per response) and then uses the existing source decoding, translation, provenance and provider contract without adding persistence or ingestion behavior.
- Retrieval uses the shared assessment lease/volume/concurrency controls and absolute provider deadline; no transport retry loop or alternate source is added. Timeout, cancellation, budget exhaustion and provider failure return safe errors without partial results.
- Deterministic recorded/injected HTTP tests cover both operations, denial before contact, assessment revalidation, shared budget exhaustion, bounded failure behavior and transport isolation. Tests use no real network or credentials.
- The checked-in assessment remains deny-by-default until permission and coverage evidence are reviewed and entered for a precise scope.

## Scope

- Add an HTTP transport adapter and the smallest assessment wiring to enable reviewed per-operation/league/season HTTPS document maps.
- Add focused tests and document the denied actual assessment and activation prerequisites in this spec.

## Non-goals

- Contacting a real provider or claiming any current scope is ready.
- Changing TASK-016 request, fact, error or provenance contracts; adding another provider boundary, persistence path, scheduler, transport-owned retries, arbitrary page parsing or live-to-fixture fallback.
- Changing local catalog, statistics or market read behavior.

## Risk

High: unauthorized source contact, unbounded requests and incomplete source coverage could mislead users. Keep default deny, enforce scope and HTTPS destination checks before each fetch, revalidate before publication, and apply the shared request budget and absolute deadline.

## Decisions

- FotMob remains a candidate only. Recurring-use permission is absent and no operation/season is live-ready; configuration cannot promote fixture evidence or bypass the reviewed actual assessment.
- Use recorded fixtures and injected local HTTP responses during development and demo preparation. Add a live scope only after permission, coverage, review date and documented request limits are entered for that exact scope.

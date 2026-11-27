# Live scraping transport with documented access evidence

## Outcome

Add an HTTPS document transport to the existing TASK-016 provider contract and TASK-055 scraper pipeline. It may contact a source only when the current reviewed assessment admits that exact operation, league and season, and names each requested document URL under an approved HTTPS destination. The checked-in actual assessment has no affirmative permission or verified scopes, so live requests remain denied with zero external contact. Accepted documents continue through the existing decoding, translation, provenance and provider path; local reads remain independent of scraping availability.

## Acceptance

- [x] Given a live request with no current permission and coverage evidence, when the scraper runs, then it returns `unsupported_capability` without making an HTTP request.
- Live catalog and performances requests with missing, expired, withdrawn, incompatible or scope-mismatched evidence return `unsupported_capability` before transport contact.
- An admitted request fetches only assessed HTTPS documents, capped at 2 MB each, then uses the existing source decoding, translation, provenance and provider contract without adding persistence or ingestion behavior.
- Retrieval uses the shared assessment lease, volume and concurrency controls and the absolute provider deadline. The transport adds no retry loop, scheduler or fallback source. Timeout, cancellation, budget exhaustion and provider failure return safe errors without partial results.
- Deterministic injected HTTP tests cover both operations, denial before contact, post-fetch evidence revalidation, shared budget exhaustion, body-size rejection, cancellation and provider failure. Tests use no real network or credentials.
- The checked-in actual assessment remains deny-by-default until permission and coverage evidence are documented and reviewed for a precise scope. Each admitted scope names its HTTPS destination and document URL map.

## Scope

- Add the HTTPS transport and the minimum assessment wiring needed to admit only evidence-backed operation, league and season scopes through existing admission and deadline controls.
- Add focused tests and document the denied actual assessment and activation prerequisites here.
- Record the confirmed hosted Credo/oracle workflow lesson in `docs/WORKFLOW_LESSONS.md`.

## Non-goals

- Contacting a real provider or claiming any current scope is ready.
- Changing TASK-016 request, fact, error or provenance contracts; adding another provider boundary, persistence path, scheduler, transport-owned retries, arbitrary page parsing or live-to-fixture fallback.
- Changing local catalog, statistics or market read behavior.

## Risk

High: unauthorized source contact, unbounded requests and incomplete coverage could produce misleading football facts. Keep default deny, check scope and HTTPS destinations before each fetch, revalidate before publication, and apply shared request budgets and the absolute deadline.

## Decisions

- FotMob remains a candidate only. Recurring-use permission is absent and no operation/season is live-ready; configuration cannot bypass reviewed permission and coverage evidence or promote fixture evidence.
- Use recorded fixtures and injected local HTTP responses during development and demo preparation. Add a live scope only after permission, coverage, review date and documented request limits are entered for that exact scope.

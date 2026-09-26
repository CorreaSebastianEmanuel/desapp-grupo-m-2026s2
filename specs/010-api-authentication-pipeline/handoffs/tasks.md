# Tasks handoff: API authentication pipeline

## Resolutions

- Shared work was sequenced rather than duplicated: the minimal actor is foundational, JWT establishes the Plug, API-key support extends it, and route-policy/ambiguity/telemetry closes the boundary.
- Test-first is explicit at each stage: author focused tests, observe the expected missing-behavior failure, then implement. The performance check remains opt-in and is not a default CI gate.
- The apparent lack of a production protected route is intentional. Integration uses a test-only router/probe while a production route-table audit enforces future classification; TASK-011 owns the first catalog endpoint.
- The application contract begins only after Plug receives a request. Invalid wire bytes rejected by the HTTP server may remain transport-level `400` responses.

## Remaining risks

- Phoenix route metadata must expose enough pipeline information for an exactly-one-policy audit. If representation differs, preserve the behavioral audit and ADR decision rather than using source comments.
- Exception handling must be narrow enough to keep expected validator failures generic without masking unrelated programming defects.
- Timing evidence depends on a healthy local PostgreSQL instance and is intentionally unsuitable as a noisy default gate.

## Sequencing guidance

Keep changes to `AuthenticateAPI` sequential because all stories converge there. Security tests in separate files can be authored in parallel with functional tests. Re-run the already completed credential story after each Plug extension, and complete the route/source audit before accepting any new `/api` route.

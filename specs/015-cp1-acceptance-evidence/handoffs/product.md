# Product Handoff: CP1 Acceptance Evidence

## Decisions

- Treat CP1 acceptance as a fail-closed, revision-bound decision: every enumerated checkpoint obligation must pass for the same candidate commit.
- Use one acceptance record as the reviewer entry point and a separate ordered demo guide as the reproduction path.
- Count ten explicit obligations: repository, green quality build, SonarCloud threshold, JWT, OpenAPI 3, minimum model, unit tests, user creation, API-key lifecycle, and protected player catalog.
- Include integration-profile and coverage results as supporting verification, without inventing a CP1 coverage threshold.
- Require evidence to identify whether it is automated, observed during the demo, or externally hosted.
- Prefer durable hosted links and version-controlled relative references; authorization requirements are acceptable, machine-local-only evidence is not.
- A missing, inaccessible, stale, skipped, or unsafe artifact is non-passing rather than “not applicable.”
- Use TASK-006 deterministic seed data and require two-run repeatability as the proof against hidden setup and duplicate catalog data.

## Unresolved assumptions

- Planning should select the canonical filenames and exact repository location for the acceptance record and demo guide.
- The concrete candidate commit and hosted evidence URLs will be known only when acceptance is executed; templates must make missing values visibly non-passing.
- Existing project documentation is expected to expose all prerequisite commands. Planning may consolidate links but must not silently create new product behavior.

## Guidance

- Keep captured outputs minimal and sanitized; prefer links plus concise observed facts over pasted logs.
- Preserve exact prerequisite-task contracts when choosing demo cases. The demo verifies them and must not redefine their status codes, payloads, or credential rules.

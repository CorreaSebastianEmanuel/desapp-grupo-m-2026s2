# Architecture Handoff

## Decisions

- No ADR is required because the design implements the existing Phoenix/Ecto/PostgreSQL/Redis modular-monolith baseline. Add a reviewed ADR if implementation introduces another service, cache authority, a public health API, or bypasses application-owned clients.
- The test-database guard is a safety boundary and must run before every test-mode connection or schema mutation, including aliases/direct preparation.
- The migration probe is product-disposable; only migration and acceptance verification may depend on it.

## Risks

- Mix normally boots the application before tasks; a failed supervised dependency could prevent aggregated diagnostics. The verification task must control startup and report both probes independently.
- Tags are mutable: resolve and commit valid multi-architecture official-image digests while retaining readable tags.
- Compose naming varies by checkout directory unless fixed; every lifecycle action, especially reset, must use the same explicit project/volumes.
- URLs and Ecto connection errors can leak credentials; test sanitization and disable sensitive connection display.

## Implementation Guidance

- Keep parsing, safety validation, result aggregation, and target formatting pure and unit-tested.
- Use a small internal probe-result type so two dependency outcomes are rendered before exit selection.
- Failure tests restore services/config in cleanup handlers and touch only repository-scoped resources.
- QA retains transcripts outside version control and references commands/results rather than workflow logs.


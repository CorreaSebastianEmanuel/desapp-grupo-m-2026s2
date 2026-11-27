# Architecture Handoff

## Decisions not repeated in the plan

- Treat controller query parsing as security-sensitive: inspect raw pairs before decoded maps so duplicate supported keys cannot collapse. Ignore unknown query keys; prove they do not alter results or become accidental filtering semantics.
- Derive cursor keys from the endpoint deployment secret with a feature-specific salt. Never log tokens, decoded anchors, credential values, or crypto errors. Collapse all cursor failures to `:invalid_cursor`.
- Cursor contract/version rotation is an intentional compatibility break. Do not add expiry unless product later supplies observable expiry behavior.

## Risks

- PostgreSQL expression equality/order must exactly match cursor normalization. Centralize the expression and add query tests; an Elixir-only normalization can drift on Unicode/collation behavior.
- A join/preload page query can accidentally apply `limit` after row multiplication if future relationships become one-to-many. The current joins are to-one; keep pagination anchored on player rows.
- The diagnostic benchmark can become flaky if embedded in the ordinary suite. Mark it explicitly and report environment plus three separate p95 values; do not present it as production capacity.
- Concurrent display-name edits or deletion can produce non-snapshot gaps/duplicates. This is accepted and must remain visible in API documentation.

## Implementation guidance

- Preserve `Catalog.list_players/1` for existing filtered callers; add a focused page query rather than changing its ordering contract.
- Ensure malformed UUID detail requests reach the same renderer/body as absent UUIDs and do not generate Ecto cast errors.
- Use a failing provider/cache probe plus query-call instrumentation to prove local-only reads and authentication precedence, not merely module-call assumptions.

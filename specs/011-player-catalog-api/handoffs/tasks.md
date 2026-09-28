# Tasks Handoff

## Resolutions

- Security and observability probes are sequenced before route implementation so authentication precedence and zero provider/cache access are measured rather than inferred.
- Cursor, persistence, and HTTP tests precede their implementations. The expression-index test also precedes its migration, preserving test-first ordering for the database access path.
- The existing filtered `Catalog.list_players/1` remains unchanged; the new page operation is separate, preventing TASK-012 scope from leaking into this feature.
- Provider-unavailability verification follows list and detail because it exercises both completed surfaces. It adds no adapter, cache, or fallback path.
- SC-008 is implemented as tagged diagnostic evidence with three separately reported p95 values, not as a CP1 release gate.

## Remaining risks

- PostgreSQL `lower(btrim(...))` comparison must stay identical between seek predicates, ordering, cursor anchors, and the expression index; Unicode/collation drift remains the main correctness risk.
- Raw query-pair inspection must happen after authentication but before decoded maps collapse duplicate supported keys.
- Key rotation intentionally invalidates old cursors. Cursor material, decoded anchors, credentials, and cryptographic failures must never enter logs or responses.
- Non-snapshot traversal can gap or duplicate after ordering-field edits/deletes; documentation must retain that limitation.

## Sequencing guidance

Run each story’s failing-test checkpoint before implementation and its focused regression checkpoint afterward. Treat US1 as the MVP. Complete the tagged diagnostic, full suite, and final scope/security review only after all three stories pass independently.

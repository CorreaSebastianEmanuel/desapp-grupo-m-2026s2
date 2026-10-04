# ADR-0012: Original Identity Safety and Bounded Catalog Race Harness Repair

**Status**: Accepted under TASK-020 feedback 2
**Date**: 2026-10-03

## Context

Authoritative feedback 2 rewinds architecture for QA B2 (NUL identities exposing Postgrex errors) and B3 (full regression failing in existing CatalogConcurrencyTest because a Sandbox owner exits). B1 Unicode normalization is verified and must remain intact. The product challenge is already resolved by ADR-0010/0011; product scope remains FR-013.

## Decision

Validate original identity text as valid UTF-8 without embedded U+0000 before any database-backed trim or lookup. Both record and scoped read return the ordinary match_identity/invalid_identity validation shape; batches retain failing envelope indexes and atomic rollback. Preserve Unicode blanks/whitespace normalization and all other encodable identity content. Do not rewrite malformed identity or broadly rescue persistence exceptions.

Extend the test-only implementation boundary to `test/football_market/catalog/constraints_test.exs` (concurrency module), `test/support/catalog_concurrency_case.ex` (dedicated helper), and exact allow-list updates in Statistics scope tests. First reproduce the exiting-owner causality; unchanged source is not evidence that the regression is unrelated. Each worker owns its unboxed connection for its entire lifetime, with distinct backend PID assertions, readiness barriers, bounded waits and registered task/connection cleanup. Preserve every unique-write assertion and original-row check. Isolate real Catalog races in a guarded catalog_concurrency partition, with a nonrecursive asserting default-suite driver modeled on the existing Statistics driver. Clear inherited CP1 profile/coverage receipt variables in children. Use fixture-scoped counts and cleanup of only unreferenced Catalog fixtures; never reset databases, disable guards or delete historical facts.

No production Catalog changes, shared DataCase default changes, pool tuning, skip tags, new services or weakened test assertions are authorized. Existing complete regression, profiles and coverage remain mandatory. Add a focused executable Catalog check to verification.json. Implementation executes all checks after final source stabilization; QA independently reruns them and final review requires fresh PASS evidence.

## Consequences and alternatives

The boundary extension repairs executable evidence without changing product behavior or settled architecture. Original-input rejection prevents malformed text from reaching PostgreSQL while leaving infrastructure errors visible. Catch-all exception translation, ASCII-only identities, shared Sandbox pseudo-races and omission of failing regression were rejected because they violate field-safe errors, Unicode semantics, independent connections or authoritative feedback.

## Evidence

See `backlog/feedback/TASK-020.md` feedback 2, the QA B2 reproducer `specs/054-player-match-statistics/qa-evidence/current/malformed_identity_test.exs`, `lib/football_market/statistics/input.ex`, `query.ex`, and the CatalogConcurrencyTest parent unboxed_run/Task.async_stream structure. Local inspection motivates the repair; causal reproduction and passing regression are implementation obligations, not claimed architecture results.

# QA Report — TASK-011 Player Catalog API

Date: 2026-09-28

Scope: independent acceptance review of `011-player-catalog-list-and-detail-api`. Reviewed `spec.md`, `plan.md`, `tasks.md`, architecture/development handoffs, current TASK-011 human feedback, canonical project guidance, and the complete working-tree diff. No implementation code was modified.

## Evidence matrix

| Acceptance area | Direct evidence | Result |
|---|---|---|
| Build hygiene | `git diff --check`; `mix format --check-formatted`; `MIX_ENV=test mix compile --warnings-as-errors` all exited 0. | PASS |
| FR-001–003, FR-019 / auth and precedence | Focused suite on fresh `football_market_testqa12`: auth-precedence and router-policy tests passed. Live unauthenticated `GET /api/players?page_size=bad&cursor=bad` returned `401`, `WWW-Authenticate: Bearer realm="api"`, JSON `{"error":{"code":"unauthenticated"}}`. | PASS |
| FR-004–011 / bounded list contract | Live JWT request `GET /api/players?page_size=2` returned `200 application/json`, exactly `data` and `pagination`, two records, `returned_count: 2`, `has_more: true`, and non-empty opaque cursor. API-key continuation returned `200`, the remaining two records, `has_more: false`, `next_cursor: null`. Live invalid size/cursor returned exact `400` codes `invalid_page_size` and `invalid_cursor`. Focused tests cover defaults, sizes 1/100, repeated/structured/blank values, exact boundary, empty/after-final pages, replay, changed size, and unknown parameters. | PASS |
| FR-005–007 / deterministic traversal | Live names traversed as `alpha`, `ALPHA`, `beta`, `Gamma`; duplicate case-folded names remained distinct and UUID tie-breaking was deterministic. Pagination tests passed for exact-once traversal, replay, insertion around anchors, and anchor deletion. Cursor tests passed tamper, malformed, foreign scope/version/shape/type, round-trip, and plaintext non-disclosure cases. | PASS |
| FR-012–018 / detail contract | Live JWT detail returned `200 application/json`, sole top-level `data`, correct stable UUID, and authoritative team/season/league hierarchy. Malformed and absent UUIDs both returned `404` with exact `{"error":{"code":"player_not_found"}}`. Both JWT and API-key detail tests passed. | PASS |
| FR-013–015, FR-021, SC-009 / exact representation | Live list item keys were exactly `catalog_identity`, `display_name`, `id`, `league`, `position`, `season`, `team`; detail hierarchy matched committed local fixtures. Exact nested-key/type tests passed. Diff inspection found no extra serializer fields, actor/credential/provider/persistence metadata, statistics, quote, valuation, or token fields. | PASS |
| FR-016, FR-020, FR-023 / boundaries and local-only reads | Diff/call-path inspection of controller, context, query, cursor, renderer, and routes found no provider, Redis, cache, job, filtering, search, ranking, mutation, or OpenAPI path. Local-only/security tests passed for list, continuation, detail, missing detail, empty catalog, and pre-auth query suppression. | PASS |
| FR-022 / automated coverage | Fresh-partition focused command covering catalog cursor/index/pagination/detail, list/detail controllers, security, auth precedence, configuration, and router policy: `29 passed`. A complete fresh-partition suite completed successfully before live fixtures were committed; 151 tests were discovered with 4 performance-tagged exclusions. The shared default DB and the post-HTTP qa12 DB were demonstrably fixture-contaminated and are not treated as clean-suite evidence. | PASS |
| Feedback 2–3 / log redaction | Effective Phoenix filter test passed for `password`, `token`, and `cursor`; capture-log continuation test passed and rejects full cursor, normalized anchor name, and anchor UUID. Continuation Ecto logging is disabled. | PASS |
| SC-008 / 100,000-player diagnostic | `MIX_ENV=test MIX_TEST_PARTITION=qa12 mix test --include performance ...`: 1 passed; p95 first page `15.655 ms`, continuation `17.66 ms`, detail `10.374 ms`, all below 2 seconds. | PASS |

## Residual risks

- `T008` and `T018` remain unchecked because the tests and implementation were already co-present; this is a test-first history gap, not missing acceptance behavior.
- Pagination is intentionally non-snapshot for ordering-field edits/deletes, as specified.
- Live HTTP fixtures remain only in isolated database `football_market_testqa12`; they contaminated later empty-catalog reruns but not the clean focused or initial clean full-suite results.

Verdict: PASS

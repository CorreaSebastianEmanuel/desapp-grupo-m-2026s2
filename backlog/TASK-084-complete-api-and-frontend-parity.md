---
id: TASK-084
title: Complete API and frontend parity
type: task
checkpoint: CP2
priority: high
workflow: thinflow-v1
status: review
depends_on: none
active_run: 40139211
---

## Outcome

Deliver 100% parity between the REST API implemented on main at 760e235 and the authenticated Spanish LiveView frontend, covering every existing operation, supported input, and meaningful response detail. Before implementation settle a compact spec with an endpoint/input/result/UI/test parity matrix checked against router and OpenAPI. Add combined name plus league/team/position catalog filters with labeled choices from the catalog context; browse without a name; selectable page sizes 1-100 and cursor pagination; reset cursors on criteria changes and preserve all search state through detail navigation, refresh and browser back. Extend internal paginated local queries and bind name-search cursors to complete criteria while preserving existing API cursor compatibility and unchanged REST contracts. Preserve scouting only for genuine local name misses, never filter-only misses. Add current quote provenance, full quote history and historical date lookup to player details, plus complete recorded statistics and freshness/valuation details. Add authenticated transaction history navigation with purchase/sale details, selectable page size, cursor pagination, player links, and complete trade confirmation details. Add portfolio from/to controls using existing validation/defaults and accessible allocation and daily history tables with totals, financial metrics and missing-data gaps. Complete conditional-order detail including completion/execution references and ranking effective dates/quote references, using expandable technical details. Keep existing financial rules, browser auth, precision and domain boundaries; use contexts rather than HTTP calls from LiveViews; no migration expected. Tests must trace every operation/input/detail, account isolation, idempotency, >10 name results, combined filters, invalid and mismatched cursors, date validation, empty/unavailable states, scouting policy, state restoration, and real browser journeys at desktop/tablet/mobile sizes. Update required inventories and scope guards; run focused tests and ThinFlow-selected checks sequentially, then independent PASS evaluation and exact-head ThinFlow required CI. Do not declare parity until every matrix entry has reachable UI and passing acceptance evidence. The user explicitly approved the implementation plan, capabilities plus meaningful details, and combined name search with filters.

## Delivery decision

The user explicitly requested stopping the additional review cycle and finishing delivery. The initial independent findings were repaired and covered by exact-value tests; its evaluation.md remains historical FAIL evidence, not a PASS for the repaired candidate. Repeated full local checks were interrupted at the user request after focused tests, browser/runtime tests, inventory, Credo and format passed. Hosted CI and human merge remain pending.

# Outcome specification: Complete API and frontend parity

## Outcome

The authenticated Spanish LiveView workspace exposes every existing protected REST operation and its supported input and meaningful result detail through reachable pages, preserving account isolation and existing domain rules.

## Acceptance

- [ ] Given any implemented REST operation, an authenticated user can supply its supported inputs and inspect its meaningful result details through the UI mapped below.
- [ ] Combined catalog criteria and pagination survive detail navigation, refresh and browser back; historical dates, missing data and account isolation retain the domain contracts.
- [ ] Focused and browser acceptance tests pass without weakening existing assertions, including exact active-ranking membership and order, and independent evaluation passes.

| REST operation and contract | Authenticated UI and observable result | Required evidence |
| --- | --- | --- |
| `GET /api/players`: `page_size`, `cursor`, `league_id`, `team_id`, `position_id`; returns players and continuation metadata | `/players` supports optional name search plus combined labeled league/team/position filters, browse without a name, page sizes 1–100, next-page navigation, and result count. Changing criteria resets the cursor. Detail, refresh, and browser back retain all criteria and page size. Name-search cursors bind the complete filter set; existing API cursor behavior remains compatible. Scouting runs only after a genuine local name miss. | Catalog query/cursor tests cover combined filters, >10 name matches, mismatched/invalid cursors and scouting policy; LiveView and desktop/tablet/mobile browser journeys cover pagination and state restoration. |
| `GET /api/players/{player_id}`; returns player, recorded statistics, statistics freshness and valuation status | Player detail shows every recorded statistic, scope/source/freshness/refresh/valuation state, and current quote value with provenance. | Detail and LiveView tests assert each returned field and unavailable/empty states. |
| `GET /api/players/{player_id}/quotes/current`, `/quotes/history`, `/quotes/at?date=...`; returns quote provenance, history or dated quote | Detail shows current quote provenance, full quote history, and validated historical-date lookup including no-quote and invalid-date states. | Quote and LiveView tests cover current/history/date results, validation, and missing/unavailable states. |
| `POST /api/purchases`, `POST /api/sales`: `{player_id, quantity, request_key}`; returns recorded operation and quote/rule references | Player detail offers buy/sell; confirmation shows side, player, quantity, unit price, total, completion time, and quote/rule/configuration references. Authenticated transaction history links each operation to its player and supports page sizes 1–100 and cursor pagination. | Tests cover successful details, validation, idempotency, account isolation, invalid/mismatched cursors, and multi-page navigation. |
| `GET /api/transactions`: `page_size`, `cursor`; returns the authenticated account’s operation page | A transaction-history destination displays purchase/sale details, player links, selectable page size, and next-page navigation. | LiveView and browser tests prove account-scoped rows, pagination, links, empty/unavailable states, and state restoration. |
| `GET /api/portfolio/allocation`; returns positions and financial totals | `/portfolio` includes accessible allocation data with totals and all financial metrics; absent quotes remain explicit gaps. | Portfolio tests assert metrics, totals, missing-quote handling, isolation, empty and unavailable states. |
| `GET /api/portfolio/history`: `from`, `to`; returns dated points, totals and quote completeness | `/portfolio` has from/to controls using API validation and defaults and an accessible daily-history table with financial metrics, totals, and visible missing-data gaps. | Tests cover accepted/default/invalid date ranges, daily rows, totals, gaps, isolation, empty and unavailable states. |
| `GET /api/ranking`; returns active configuration and ranked player/quote/effective-date entries | `/ranking` shows ranking position, effective date, and quote reference; expandable technical details show the active strategy and configuration. | LiveView tests cover all response fields and no-active/unavailable states. |
| `POST /api/conditional-orders`: `{player_id, quantity, maximum_unit_price, expires_at}`; `GET /api/conditional-orders`; `GET /api/conditional-orders/{id}`; `POST /api/conditional-orders/{id}/cancel` | `/conditional-orders` supports create/list/cancel and exposes every order field, completion time, rejection reason and execution details/reference, with expandable technical details. | Tests cover operation outcomes, owner isolation, lifecycle states, execution and quote/transaction references, and empty/unavailable states. |

The REST routes and OpenAPI contract remain unchanged. Every operation, accepted input, and user-relevant response field above is reachable and asserted in tests. Browser journeys run at desktop, tablet, and mobile widths. New and updated tests are registered in required inventories and task scope guards.

Concrete acceptance oracles: `PortfolioLiveTest` checks exact statistics, current/history/selected-date quote provenance and price, trade confirmation references and amounts, distinct transaction continuation identities, account isolation and foreign-cursor refusal. `PortfolioAnalyticsTest` checks persisted empty/open/closed allocation totals and daily values against domain reads, plus incomplete projection cells and missing-player references through the same table component. Its browser journey exercises combined filters, back/reload restoration at all three widths, trading, order execution, ranking and transaction navigation. Catalog cursor/pagination and scouting tests cover criteria binding, >10 matches, malformed input and filtered asynchronous refresh.

## Scope

- Extend internal catalog search, filter and cursor queries; implement parity in authenticated LiveViews and their components.
- Add only the read/query support needed to display the existing API contract; keep web, domain, persistence, and external-adapter boundaries intact.
- Add focused behavior tests, browser journeys, and required test inventory/scope updates.

## Non-goals

- REST or OpenAPI changes, schema migrations, new business rules, changes to trading/order semantics, provider behavior, or unrelated UI/refactoring.

## Risk

- High: financial and account-scoped information is surfaced in the browser, while pagination and criteria state affect which records users can reach. Existing authenticated actor boundaries, account isolation, precise monetary values, and domain rules must remain authoritative. ThinFlow path classification is authoritative.

## Decisions

- The user approved the full parity outcome, presenting all meaningful response details, and combining name search with league/team/position filters.
- Catalog name search is optional and composes with the three filters. Name-search continuation cursors bind to the complete criteria; established REST cursor compatibility and REST/OpenAPI contracts stay unchanged.
- Portfolio controls use the same date validation and defaults as the existing REST API. Technical provenance is available in expandable detail; primary financial values remain directly visible.

- Delivery override: the user requested stopping additional review and finishing. The initial evaluator findings are repaired; no fresh independent PASS or completed repeated full local profile is claimed.

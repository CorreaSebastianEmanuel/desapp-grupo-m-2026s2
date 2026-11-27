## Outcome

Deliver a minimal player card, immediate buy/sell actions, and read-only active-strategy ranking inside the existing authenticated workspace LiveView for TASK-077.

## Acceptance

- [ ] Authenticated users can search the local catalog and open a player card showing player identity, position, club, league and season.
- [ ] The card shows the authoritative current quote and its effective-at timestamp, or an explicit missing/unavailable state. Statistics freshness and valuation status reuse the same domain interfaces as the existing player-detail API; local reads remain usable when external data is unavailable.
- [ ] The card and player-detail API share one domain read for catalog-season recorded-match count and totals for minutes played, goals and assists from locally stored performance facts. A total is unknown when no facts exist or any recorded fact lacks that metric; zero is shown only when explicitly recorded. Label these as recorded local data, without claiming complete season coverage.
- [ ] Users can buy or sell an integer quantity through the existing atomic, idempotent domain operations. Forms display safe validation/business errors and confirmed outcomes; retries must not duplicate a financial operation.
- [ ] Successful trades refresh the signed-in user's positions immediately. Workspace reload hints and reconnects reload authoritative, owner-scoped data, including purchases executed by conditional orders.
- [ ] Users can open a ranking view showing the active strategy label and entries in the exact order returned by the existing ranking context. Empty, unconfigured and unavailable results have explicit states.
- [ ] Preserve the catalog-to-conditional-order journey. Focused automated tests cover player details and missing data, trading errors and retry safety, owner-scoped position reloads, ranking order/strategy, and unauthenticated redirects. Actual browser E2E coverage demonstrates search-to-order-to-purchase visibility, selling owned tokens, and active-strategy ranking.
- [ ] Portfolio and trading UI tests restore the exact prior initial-issuance configuration after each test, preserving absent settings. A module-completion assertion detects configuration leaks without weakening the market's fail-closed default check.

## Scope

- Existing workspace LiveView, shared components and authenticated browser routes.
- Reuse catalog detail, quote, statistics freshness, trading, portfolio, conditional-order notification and ranking domain interfaces. Keep persistence queries and business rules outside the LiveView.
- Directly required tests and test-profile inventory registration.

## Non-goals

- CP3 catalog filters, full quote/transaction history and detailed refresh screens owned by TASK-047/048.
- Charts owned by TASK-058, client-side frameworks, new trading rules, funding flows, valuation formulas or ranking algorithms.
- Workflow-policy changes, full regression execution, commits, pushes, PR creation or merge during this develop stage.

## Risk

- Financial UI: authentication, owner scoping, server-side input validation and idempotent retries must preserve existing atomic trading guarantees. UI quotes are informational; execution uses the domain's authoritative price.
- Missing/stale/provider-unavailable data must remain explicit and must not become invented values.
- Deterministic classification of the actual diff remains authoritative.

## Decisions

- Settled: server-driven UI, existing shared shell/components and domain contexts; no internal HTTP loopback from LiveView to REST controllers.
- Approved by human feedback: extend the API and card with the recorded statistics above; existing ingestion and TTL refresh own updates. Live transport remains TASK-080. Metrics may be revised in a later task.
- Trade forms retain their request key through retries; a separate explicit New trade action starts a fresh request after confirmation or before changing previously submitted terms. Execution always uses the authoritative domain quote.

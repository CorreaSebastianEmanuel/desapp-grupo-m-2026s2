# Outcome specification: Trading and portfolio UI

**Feature Branch**: `048-trading-and-portfolio-ui`

**Task**: `TASK-048`

## Outcome

Deliver authenticated buy and sell flows with clear results, an investor holdings view with profitability, and a paginated operation history. The UI delegates financial decisions to existing market domain operations. `TASK-058` owns the chart-focused portfolio view; this task does not duplicate it.

## Acceptance

- [ ] An authenticated investor can buy at the current performance quote or sell an owned quantity from a player's page, after seeing the estimated buy total and relevant balance or position.
- [ ] A successful trade displays its side, quantity, unit price, total, completion time, and operation/quote references; a rejected or unavailable trade shows an actionable error and does not claim success.
- [ ] The investor portfolio lists each operation-derived holding with quantity, average unit cost, current quote/value, and realized and unrealized profit/loss. Missing quotes are shown as unavailable, not as zero.
- [ ] Initial issuer inventory is identified separately from investor holdings and is not counted as an investor position.
- [ ] The operation history lists the authenticated user's purchases and sales with player, quantity, unit price, total, quote reference, and completion time; pagination preserves the selected page size.
- [ ] Focused LiveView tests demonstrate buy and sell feedback, a rejected trade, portfolio values, operation history, and authenticated-user isolation.

## Scope

- Player-page buy/sell interaction and operation result feedback using existing `Market` commands.
- Authenticated portfolio holdings/profitability and paginated transaction history screens using existing market read operations.
- Focused tests for the observable behavior above.

## Non-goals

- Portfolio charts and historical analytics delivered by `TASK-058`.
- Conditional-order creation or tracking, catalog/ranking behavior, API changes, and domain or persistence changes.
- Changes to financial rules, quote calculation, or the existing atomic/idempotent trading implementation.

## Risk

- Medium: authenticated financial information and trade actions are presented in the web layer; existing domain authorization and atomic trading remain authoritative. ThinFlow classifies the actual diff and selects required checks.

## Decisions

- Reuse the existing player detail, portfolio, and transaction routes; keep initial issuer inventory separate from operation-derived investor holdings, consistent with the established market model and `TASK-083` behavior.
- Render missing quote-derived values as unavailable. Do not substitute zero for missing financial data.

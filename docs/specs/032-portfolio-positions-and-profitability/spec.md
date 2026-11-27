# Portfolio positions and profitability

## Outcome

Authenticated users can inspect their player-token positions and see quantity,
average cost, current market value, and realized and unrealized profit or loss.

## Acceptance

- [x] A user's portfolio is derived from completed purchases and sales and shows one
  position per player the user currently owns.
- [x] Each position reports its owned quantity, average unit cost, current unit
  quote, current value, realized profit or loss, and unrealized profit or loss.
- [x] Portfolio values are scoped to the authenticated user and use exact decimal
  money arithmetic.
- [x] A position's average cost and realized profit or loss follow the cost-basis
  rule recorded in Decisions.
- [x] Tests demonstrate purchases, partial and complete sales, multiple purchase
  prices, current valuation, and isolation between users.

## Scope

- Add a domain read operation and persistence query for the authenticated user's
  current portfolio positions and profitability.
- Add focused tests for the read operation, calculations, and user scoping.
- Expose the result through the existing authenticated portfolio surface.

## Non-goals

- Historical portfolio valuation charts or portfolio history APIs.
- Changes to trade execution, quote calculation, credit balances, token supply,
  or transaction history.
- Unrelated interface or architecture refactors.

## Risk

- Financial calculations are high risk: preserve immutable transaction history,
  exact decimal arithmetic, and authenticated owner scoping.

## Decisions

- Human product decision (2026-10-28): the inventory cost-basis rule for realized
  profit or loss is weighted-average cost. Selling tokens realizes the sale price
  minus the position's current weighted-average unit cost; the remaining position
  keeps that same weighted-average cost. FIFO lateral accounting is not used.
- Human product decision (2026-10-28): money calculations run in a dedicated
  wide Decimal context and never inherit the caller's context. The
  weighted-average unit cost is rounded half-up to 18 decimal places only when
  the exact quotient does not terminate; cent-exact totals divided by integer
  quantities divide exactly at 18 decimal places or fewer. Reported realized
  and unrealized profit or loss derive from that recorded average cost.

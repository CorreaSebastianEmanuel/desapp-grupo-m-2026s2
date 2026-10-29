# Portfolio analytics and historical valuation API

**Feature Branch**: `057-portfolio-analytics-and-historical-valuation-api`
**Task**: `TASK-057`

## Outcome

Expose authenticated investor portfolio allocation and daily historical value/profit from immutable local trades and quotes for TASK-058 charts.

## Acceptance

- [x] GET /api/portfolio/allocation returns current positive positions, quote identity/time, decimal values and fractional weights.
- [x] GET /api/portfolio/history returns ascending daily UTC points, default last 30 days including today, with explicit from/to dates and at most 366 inclusive days. Today is partial with an actual cutoff. Reject future, reversed, malformed, duplicate and structured dates.
- [x] Replay historical quantities and weighted average cost; retain realized profit after complete sales. Include cumulative purchase expenditure, sale proceeds, net invested amount, remaining basis, realized/unrealized/total profit.
- [x] Carry eligible quotes forward using TASK-027 sequence/effective/inserted/ID ordering. Missing positive-position quotes yield null dependent values and missing player IDs; empty portfolios yield genuine zeros.
- [x] Ownership comes only from the authenticated actor; JWT and API keys work, authentication precedes validation. Reads are private/non-cacheable and have no financial/provider/job side effects.
- [x] Read trades and quotes in one read-only repeatable-read snapshot using batched queries; preserve TASK-032 behavior and demonstrate concurrency, decimal precision and actual HTTP execution.

## Scope

Analytics domain, pure shared ledger, local persistence, REST/OpenAPI, documentation and behavioral tests/inventories. Manual implementation without workflow orchestration; canonical ownership and independent evaluation preserve delivery compatibility.

## Non-goals

Charts/UI, issuer inventory, cash balance, percentage returns, trading/quote mutation, new provider calls, caching, new dependencies, migrations, and unrelated backlog repairs.

## Risk

High: owner-scoped financial reporting, historical accounting and shared reducer. Require complete profiles, strict static checks and independent testing/review before PR; exact-head hosted CI and human merge remain required.

## Decisions

- User selected daily UTC, 30-day default/366-day maximum, partial today, and separate purchase/sale flows plus realized/unrealized profit.
- Only to means preceding 30 days; only from ends today. Bounds are inclusive, valid four-digit ISO dates, no future days. Date error precedence: from, to, range. Unknown keys are ignored and cannot select an owner.
- Per-point flows/profits are cumulative since first trade, including pre-window history. TASK-032 investor trades define positions; initial issuer inventory and account cash are excluded.
- Retain TASK-032's local 200-digit Decimal context and half-up 18-place average cost. Derived amounts are unrounded decimal strings; quote prices have two places; weights round half-up to 18 places and need not sum exactly to one.
- A missing quote nulls affected position value, total value, unrealized/total profit and every allocation weight; known flows/basis/realized profit remain available. No holdings means zero value and no gaps.
- Historical data uses currently retained facts effective at each cutoff, not a past database-knowledge snapshot. Quotes effective after a point never participate. Snapshot time bounds current reads and today's partial point.
- The actual risk registry omitted test/e2e paths; classify only the new analytics E2E file under the existing high-risk application rule, retaining every required command. No workflow run is claimed. Retain workflow thinflow-v1 and active_run none; use canonical spec/evaluation, direct checks, review status and normal human-merge finalizer.

## Research

Reuse ADR-0017, TASK-027 quote reads, TASK-032 weighted-average rules, and the existing Ranking.Reader read-only repeatable-read pattern. PostgreSQL repeatable read preserves one snapshot across queries: https://www.postgresql.org/docs/16/transaction-iso.html . Decimal 3.1.1 context is process-local and can round arithmetic: https://decimal.hexdocs.pm/3.1.1/Decimal.Context.html . No new infrastructure is needed.

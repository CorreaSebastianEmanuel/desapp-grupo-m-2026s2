# Independent evaluation — TASK-032

Candidate: `032-portfolio-positions-and-profitability`; local material digest
`c755d0e91338b2b83c18778773028fc9ff9a801f3d978a4b16bb91782d903885`.
Reviewed the compact spec, task, current human feedback, REVIEW.md, repository
principles, complete candidate diff, implementation, tests and named ThinFlow
check evidence. No implementation edits, delegation or full-suite rerun.

## Acceptance and evidence

| Acceptance item | Evidence | Assessment |
| --- | --- | --- |
| Current positions derived from completed purchases and sales | Owner-filtered immutable purchase/sale queries; positions integration case covers partial/full liquidation | Blocked: separate queries can combine incompatible committed states (B1). |
| Quantity, average cost, current quote/value, realized/unrealized P/L | Domain result maps and authenticated LiveView table; quote integration case verifies current valuation | Present, but exact values fail B2. |
| Authenticated owner scoping and exact decimal money | Actor boundary, owner predicates, existing browser session authorization, outsider/unauthenticated assertions | Scoping passes; exact arithmetic blocked by B2. |
| Human-selected weighted-average cost basis | Calculation tests and purchase/sale reducer preserve average after partial sales | Ordinary examples pass; implicit context rounding corrupts basis for supported amounts (B2). |
| Tests for purchases, partial/full sales, multiple prices, current valuation and isolation | Two calculation unit cases plus four focused integration cases | Required scenarios are represented; concurrency and precision regressions need adding. |

## Deterministic evidence and boundaries

Recomputed selection and validated the receipt with
`scripts.thinflow.readiness(Path.cwd(), "TASK-032", require_evaluation=False)`:
passed. Tier **high** is appropriate for financial application changes and
inventory/profile updates; no unmapped paths. All five selected checks have
exit code zero, current material identity, and matching evidence hashes:
`ci-contracts`, `harness-tests`, `format`, `compile`, `unit-profile`.
Evidence records 25 CI contract tests, 353 harness tests and 636/636 executed,
passed unit cases. Format/compile produce silent successful output. These are
check artifacts, not agent summaries or workflow logs.

Web presentation delegates to the domain; Ecto queries stay in the persistence
module. No external adapter calls, trade writes, schema changes, credential
exposure or weakening of existing checks was introduced. Quote ordering matches
the authoritative quote reader. Inventory/profile changes register new files
and cases without removing existing coverage.

## Targeted checks executed

- The required local selection runs the unit profile, so the new persistence
  and LiveView behavior lacked execution evidence in that receipt. Ran
  `MIX_ENV=test mix test test/football_market/market/portfolio/positions_test.exs test/football_market/market/portfolio/quote_test.exs test/football_market_web/live/portfolio_live_test.exs`:
  **4 passed**.
- To validate the separate-query risk, ran a temporary in-memory ExUnit probe
  through `MIX_ENV=test mix run -e`, using existing committed private-schema
  fixtures and a Repo query telemetry callback to commit real trades between
  the two SELECTs. **1 passed**, confirming the anomaly described in B1;
  emitted `QA_RACE_CONFIRMED interleaved_quantity=0 actual_quantity=1`.
- To validate exactness, ran `MIX_ENV=test mix run --no-start -e` against
  `Portfolio.calculate/1` and its valuation expressions with a supported
  34-digit cent-exact unit quote. Confirmed B2, including
  `Settlement.exact_positive?(unit) == true`. Preliminary larger inputs that
  failed parsing/eligibility were discarded and are not evidence for B2.

## Blocking findings by root-cause class

### B1 — Inconsistent financial read snapshot

**Location:** `lib/football_market/market/portfolio_store.ex:8` (purchase SELECT
at line 21, independent sale SELECT at line 35).

The read uses separate statements without a shared database snapshot. Starting
with one purchased token, pause after the purchase SELECT returns; commit a
second purchase of one token and a sale of one token; resume the sale SELECT.
The reducer sees only the first purchase but also the new sale and returns an
empty portfolio. The user actually owns one token before and after those
interleaved operations; a subsequent read returns quantity one. The targeted
probe reproduced this using real `Market.purchase/2` and `Market.sale/2`
operations, without changing implementation or stored history.

**Required repair:** Read the relevant completed trades from one consistent
snapshot (for example, one combined SELECT or a suitable read transaction).
Add a deterministic interleaving regression. An ordinary READ COMMITTED
transaction with the same independent statements is insufficient.

### B2 — Implicit Decimal precision rounds financial facts

**Location:** `lib/football_market/market/portfolio.ex:54` (basis and average),
also lines 18 and 25 (current value and unrealized P/L), and line 71 (sale cost).

Arithmetic inherits the caller's Decimal context, whose observed precision is
34 significant digits. Reproduction: one completed purchase of quantity **3**,
unit quote **92345678901234567890123456789012.91**, exact persisted total
**277037036703703703670370370367038.73**. The quote passes the existing
settlement eligibility check, PostgreSQL numeric fields have no such precision
cap, and trade settlement computes the total exactly in PostgreSQL.

`Portfolio.calculate/1` reports average
**92345678901234567890123456789012.9** instead of the purchase unit price.
At that unchanged quote, the valuation expressions report current value
**277037036703703703670370370367038.7** and unrealized profit **0.03** rather
than the exact total and zero. This requires no periodic division or sale:
even a single valid purchase creates fictitious profit.

**Required repair:** Make financial calculations independent of implicit
context precision, preserving exact finite values and a deterministic
weighted-average basis. Define handling of nonterminating averages without
feeding accidental rounding back into accounting. Add regressions for the
supported large-value example, ordinary fractional averages and sale basis;
do not silently narrow supported trading amounts in this read-only task.

## Advisory findings

None.

## Residual risks

Hosted `ThinFlow required` on the exact PR head and human merge remain pending.
No browser E2E or complete integration profile was rerun; only the focused
integration cases and concrete discrepancy probes above were executed.
Required local checks are valid, but do not cover the two reproduced defects.

Verdict: FAIL

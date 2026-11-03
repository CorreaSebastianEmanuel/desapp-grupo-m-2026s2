## Outcome

TASK-086 delivers authenticated market administration and a readable investor frontend on `086-administrator-issuer-and-readable-investor-frontend`, stacked on PR #91. The primary inventory account administers selection of existing valuation versions; investors can understand portfolio and quote data and correct rejected trades in the same session.

## Acceptance

- [ ] Only the single valid existing account designated by `initial_issuance_recipients` (`MARKET_PRIMARY_ACCOUNT_ID`) may inspect administration or activate versions. Missing, invalid or ambiguous designation grants nobody access; signup and submitted identity fields grant no authority. HTTP, connected mounts and callbacks enforce fresh session and administrator authority, including the development-only operations page.
- [ ] Administration lists existing immutable configurations and their rules, identifies the active version and activates through the existing compare-and-set boundary using the selection the administrator saw. A stale selection reports conflict and reloads. Selection never edits versions, historical quotes or schedules immediate recalculation.
- [ ] Portfolio totals use readable responsive metric cards with exact values and existing empty, closed and incomplete semantics. Daily charts and history identify the calendar day in UTC; partial-day cutoffs remain clear. Storage and API cutoffs remain unchanged.
- [ ] Ranking links show catalog player names for real and demo players and the correct player destination. Strategy name/formula version remain visible; configuration and quote UUIDs are absent from investor-facing text.
- [ ] Player quote provenance, quote references and valuation freshness explain price, UTC dates, strategy/version and initial-issuance or performance source without dumping internal identifiers. Internal navigation, storage, API and reproducibility records remain intact.
- [ ] Conditional orders use a native date/time picker explicitly labeled UTC; browser wall-clock values are interpreted as UTC and validated by existing expiry rules. Invalid/past input is rejected without creating an order.
- [ ] After definitive invalid-quantity, funds, inventory or holdings rejection, a corrected buy/sale succeeds without logout or manual reset. Successful/uncertain submissions retain their idempotency protection; duplicate events cannot add another operation.
- [ ] Focused automated regressions cover permissions, activation/conflict, readable values/names/dates, expiry conversion and trade corrections. Real-browser journeys cover mobile summary layout, date/time entry and session continuity.

## Scope

Existing domain boundaries, browser authorization, administration controls, investor LiveView/components/CSS and directly affected test fixtures, browser journeys and maintained inventories. The development stage leaves a reviewable workspace; ThinFlow owns subsequent checks and independent evaluation.

## Non-goals

Configuration creation/editor, new formula defaults, changed strategy engines, immediate quote recalculation, financial/domain/API semantic changes, unrelated refactors, pushing the base branch or merging.

## Risk

High: administrator authorization and financial retry safety. Designation fails closed; every private callback revalidates authority. Only known definitive rejections release a trade intent; storage uncertainty and key conflicts retain it. Existing atomic financial and compare-and-set operations remain authoritative.

## Decisions

- User confirmed that the explicitly designated initial-inventory account is also administrator, and only existing configuration versions are selectable.
- `/administration` is authenticated in every environment; `/__local/ops` remains development-only and additionally requires the same administrator authority.
- Native `datetime-local` input is labeled UTC and converted at the web boundary, independently of the browser's timezone. Daily values display their UTC calendar day; partial days disclose their actual cutoff.
- Human-readable provenance is a presentation projection; immutable internal evidence and API identifiers are preserved.

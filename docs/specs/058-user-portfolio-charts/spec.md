# User portfolio charts

## Outcome

Authenticated users can understand their portfolio’s current allocation and daily historical value and profit/loss from persisted portfolio analytics. Charts identify their units and UTC as-of time, preserve unknown valuations as gaps, and expose accessible empty and unavailable states.

## Acceptance

- [x] The authenticated `/portfolio` page presents a current allocation chart and daily history charts for market value, realized profit/loss, and unrealized profit/loss, using the owner-scoped TASK-057 analytics context.
- The allocation chart shows each held player’s share of total market value in percent and is marked unknown when any held position lacks a current quote; it never assigns a fabricated share.
- Historical charts use the API’s default trailing 30 calendar days, daily UTC points, and each point’s `cutoff_at`. They show market value, realized profit/loss, and unrealized profit/loss in credits, with the effective cutoff date/time available to users.
- Missing or incomplete historical valuation is rendered as a visible gap for market value and unrealized profit/loss. Realized profit/loss remains displayable when quote data is missing. No unknown value is drawn or presented as zero.
- A user with no current holdings receives an accessible allocation empty state. A user without historical trades receives an accessible history empty state. Analytics read failures are announced as temporarily unavailable and do not masquerade as empty or zero-valued data.
- Charts have accessible names and summaries, and their underlying values are available in semantic text/table form. Existing portfolio positions and authentication behavior remain available.

## Scope

- Load owner-scoped current allocation and daily history in the authenticated portfolio LiveView.
- Render responsive, labeled charts and accessible data summaries using existing analytics responses; keep chart formatting and geometry in the web/presentation layer.
- Add focused UI coverage for populated values, missing quote gaps, empty states, analytics unavailability, and authenticated access.

## Non-goals

- Changes to analytics calculations, persistence, API contracts, trade behavior, or quote selection.
- User-selected date ranges, timezone controls, intraday charts, portfolio performance benchmarks, or currency conversion.
- Conditional-order behavior, unrelated workspace redesign, or new charting dependencies.

## Risk

- Read-only authenticated presentation change. Financial values and owner isolation remain enforced by the existing analytics domain/API; the UI must preserve decimal values and unknown states. Deterministic path classification remains authoritative.

## Decisions

- Reuse the existing TASK-057 allocation and history results. History is daily in UTC and defaults to the trailing 30 calendar days, as already defined by the API; use each returned `cutoff_at` for timestamp labels.
- Keep realized profit/loss distinct from unrealized profit/loss and from market value. Do not describe purchases or sales as investment return.
- Render unavailable quote-dependent values as gaps. Retain any valid realized profit/loss value for the same date.
- Use native web markup/SVG with accessible textual data so chart interpretation does not depend on color or pointer interaction.

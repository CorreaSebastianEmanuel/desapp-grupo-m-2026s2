---
id: TASK-086
title: Administrator issuer and readable investor frontend
type: task
checkpoint: CP2
priority: high
workflow: thinflow-v1
status: done
depends_on: TASK-085
active_run: none
---

## Outcome

Deliver the user-requested administrator/issuer and frontend improvements on a feature branch stacked on PR #91 (085-assign-initial-player-inventory-to-the-primary-account), without pushing changes to that base branch or merging it.

Product decisions already confirmed by the user:
- The single explicitly configured primary initial-inventory recipient is also the market administrator. Reuse MARKET_PRIMARY_ACCOUNT_ID / initial_issuance_recipients; never choose the first registered user or accept a client-supplied identity as authority. Public signup must not grant administration. Missing/ambiguous/invalid designation grants nobody administration.
- Add authenticated administration and a frontend control to inspect and activate existing valuation configuration versions through the existing domain boundaries and compare-and-set activation rules. Protect server-side mutation handlers and relevant entry points, including connected sessions; ordinary investors cannot activate strategies. Reuse the existing local operator page where appropriate, but distinguish its current development-only availability from actual authentication/authorization. Preserve the existing strategy engines, financial invariants and immutable history. Changing active configuration must not rewrite prices or invent immediate recalculation.
- Keep this delivery to selecting existing configuration versions, without inventing new formula defaults or building an arbitrary configuration editor.

User-specified frontend acceptance:
1. Portfolio summary metrics such as market value and cost basis must have a coherent, readable responsive layout instead of an unstyled left-aligned vertical list; preserve exact financial values and empty/closed/incomplete states.
2. Daily chart/history values should identify the calendar day rather than raw end-of-day timestamps such as 23:59:59.999999Z. Keep underlying cutoffs/UTC semantics and API data accurate; format necessary timestamps for people.
3. Hide internal configuration UUIDs from the investor ranking; retain a useful strategy name/version.
4. Ranking entries must display the actual player name rather than Jugador followed by its UUID, including real and demo players; links must still identify the correct player.
5. Quote references must not present unexplained internal UUIDs as user-facing information.
6. Player detail and quote provenance must show useful human-readable price/date/strategy/source information instead of technical identifiers. Preserve internal identifiers in storage/API/navigation and audit/reproducibility semantics.
7. Conditional orders need a proper date/time picker instead of typing a raw ISO timestamp. State its timezone clearly and preserve existing expiry validation and semantics.
8. After a definitive rejected buy or sale (invalid quantity, insufficient inventory/funds/holdings), correcting to a valid quantity must work in the same logged-in session. Do not require a new login or manual reset just to correct rejected input. Preserve atomic idempotency: duplicate clicks/reconnects and uncertain outcomes must not create another financial operation.

Add behavioral regression tests for authorization, strategy activation, user-facing names/date formatting, readable summaries, expiry entry and rejected-then-corrected purchases/sales. Use meaningful real-browser coverage for the affected journeys, including mobile layout and session continuity. Follow repository test inventories and risk-selected checks. Keep one compact spec.md and one fresh independent evaluation.md. The original PR remains unchanged and the new delivery must remain separate and reviewable.

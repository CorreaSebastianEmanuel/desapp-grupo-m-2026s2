# Outcome

The authenticated designated initial recipient can see, in a dedicated workspace section, the player tokens still held from initial issuance. This inventory is separate from the trade-based investor portfolio and does not change portfolio values, transaction history, or charts.

# Acceptance

- Every authenticated workspace page shows the signed-in user's available credit balance once in the shared navigation with exact two-decimal formatting; the badge fits the navigation on desktop and mobile.
- A user without a persisted balance sees 0.00 credits; a storage read failure is shown as unavailable, never as zero.
- The player detail presents the current per-token quote, the user's token quantity and estimated holding value, an integer quantity input, an estimated trade total, and distinct Comprar/Vender actions. The available balance is shown once in the shared navigation.
- Missing player statistics are explained once; fields without data are omitted rather than repeated as "No disponible" or "Unknown".
- Player positions and quote values use Spanish labels, readable timestamp formatting, and explicit credits-per-token units.
- A catalog search remains in the URL when opening a player detail; returning to the catalog restores its query and results. The detail view does not repeat the catalog search form below the trade controls.
- Search accepts the alphanumeric names shown in its examples, including local league codes such as "Demo BL1".
- Portfolio positions and their estimated market value appear before charts; the initial issuer inventory remains a separate, quantity-only section.
- Conditional orders identify the selected player by name, show the current quote and units, and do not expose player UUIDs in the interface.
- Empty ranking and catalog states explain the next useful action instead of showing technical identifiers or unexplained errors.
- Browser journeys use the Spanish labels and states visible in the app and cover sign-in, search, trading, order execution, and logout.
- The designated initial recipient sees a clearly labeled initial issuer inventory section listing each issued player they still hold and the remaining whole-token quantity.
- The view uses the immutable issuance recipient and the recipient's current persisted holding; it omits players with no remaining holding.
- An authenticated non-recipient does not see another user's initial issuer inventory.
- A user with no initial issuer inventory sees an accessible empty state.
- Initial issuer inventory does not appear as purchase-based portfolio positions and does not alter portfolio values, history, or charts.
- Read failures are reported as unavailable inventory, not as a successful empty state.

# Scope

- Add an authenticated credit-balance read and display it in the shared workspace header; a missing balance row means a zero balance.
- Improve shared balance, player detail, portfolio, catalog navigation, conditional order, ranking, and statistics presentation without changing trade rules.
- Add an authenticated domain read and persistence query for the actor's remaining holdings from their original issuance records.
- Show player name and remaining quantity in a separate section of the authenticated portfolio workspace.
- Add focused domain and LiveView tests for recipient visibility, remaining quantity, empty state, and separation from the trade portfolio.
- Add focused LiveView coverage for clear trade estimates, preserved search context, order player names, and Spanish workspace states.

# Non-goals

- Changing credit funding, issuance, purchases, sales, quote calculation, portfolio accounting, history, or charts.
- Showing inventory value, issuing or transferring tokens, or adding a new public API.
- Exposing another user's holdings or adding role-management behavior.

# Risk

- Medium: authenticated financial inventory read and LiveView presentation; no writes or financial calculations.

# Decisions

- The balance is the persisted spendable credit projection, not a grant or estimate; use exact cents and show a balance read error without a numeric fallback.
- The section is quantity-only and derives rows from the issuance recipient joined to that recipient's current holdings. This preserves the fixed-supply accounting boundary and avoids defining a new valuation metric.

# Require a performance quote before purchase

## Outcome

The fixed one-credit initial issuance value seeds quote history but does not enable a purchase. A direct purchase or conditional-order execution is allowed only when the latest positive quote is linked to a successful performance calculation. If the calculation returns no quote, the player remains unavailable for purchase until a later positive performance quote is published.

## Acceptance

- Given a player has only its initial issuance quote, when an investor attempts a direct purchase, then the request returns `quote_unavailable` and leaves balances, holdings, supply, idempotency keys, and financial history unchanged.
- Given a player has only its initial issuance quote, when an eligible conditional order is evaluated, then it does not execute or create purchase evidence.
- Given a positive performance-derived quote is published, when a direct purchase or conditional order executes, then it uses that performance quote under existing atomicity and idempotency rules.
- Given a player has only its initial issuance quote, when an investor opens its detail page, then the page explains that a performance quote is pending and disables the direct buy action; selling existing holdings remains governed by the existing sale rules.
- Given the active strategy produces a nonpositive score, when its calculation completes with `no_quote`, then the initial issuance value remains visible as historical context but purchases stay unavailable.

## Scope

Gate purchase eligibility on retained performance-quote evidence, retain existing quote history and close timing, and update the player detail explanation and focused behavioral tests. Do not change valuation formulas, initial supply/price, sale semantics, conditional-order submission, or quote scheduling.

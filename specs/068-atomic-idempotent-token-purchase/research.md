# Feature-specific decisions

## Shared quote/purchase ordering

Decision: reuse the player row lock, then read Quotes.latest/1 after all purchase locks and retain the exact selected quote.
Rationale: local inspection of lib/football_market/quotes.ex latest/1 and confirmation paths, lib/football_market/quotes/store.ex lock_player!/1 and priv/repo/migrations/20261014000000_create_initial_player_issuance.exs shows both application confirmation and ordinary quote/holding inserts coordinate on the player. Current quote order is descending COALESCE(performance_sequence,0), then effective_at; initial issuance is sequence zero. No new freshness/TTL/fallback rule is introduced.
Alternatives considered: pre-lock quote reads race; a separate price cache or global market lock is unnecessary. Two explicit barrier tests will prove the actual ordering. See ADR-0032.

## Existing financial and actor structures

Decision: add balances and purchase evidence in Market; reuse existing holdings, issuance, recipient, quote and AuthenticatedActor.account_id.
Rationale: lib/football_market/market.ex currently owns issuance only; lib/football_market/accounts/user.ex has no spendable balance. AuthenticateAPI already supplies a trusted actor for JWT and API-key requests. Human feedback permits test provisioning but excludes a funding product.
Alternatives considered: embedding finance in Accounts or controller couples authentication to trading; introducing deposits or a second quote store violates scope. See ADR-0024/0029/0032. Technologies and providers are settled by docs/ARCHITECTURE.md; no dependency research is required.

## Browser prerequisite diagnosis (feedback 2)

Decision: preserve the existing inline Chromium preflight and extend only its safe diagnostic producer/forwarder/consumer; see ADR-0033 and contracts/profile-diagnostics.md.
Rationale: scripts/test_profile_runner.py currently catches launch failure without a cause, filters child output to openapi-browser stages, and labels the preflight browser-prerequisite; scripts/agentflow_check.py exposes only profile stages/counts/locations. This local gap explains why a failed launch cannot be diagnosed from safe evidence. The human reproduction establishes that launch can succeed in the pinned environment, not a proven historical failure cause. No external research can identify that cause from available evidence.
Alternatives considered: raw exception output can expose paths, environment or secrets; automatic installs, browser replacement and weakened preflight exceed authorization. A separate new runner adds unnecessary machinery. Keep the cause unknown (launch-failed) when private error classification is inconclusive.

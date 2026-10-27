# Feature-specific decisions

## Shared quote/purchase ordering

Decision: reuse the player row lock, then read Quotes.latest/1 after all purchase locks and retain the exact selected quote.
Rationale: local inspection of lib/football_market/quotes.ex latest/1 and confirmation paths, lib/football_market/quotes/store.ex lock_player!/1 and priv/repo/migrations/20261014000000_create_initial_player_issuance.exs shows both application confirmation and ordinary quote/holding inserts coordinate on the player. Current quote order is descending COALESCE(performance_sequence,0), then effective_at; initial issuance is sequence zero. No new freshness/TTL/fallback rule is introduced.
Alternatives considered: pre-lock quote reads race; a separate price cache or global market lock is unnecessary. Two explicit barrier tests will prove the actual ordering. See ADR-0032.

## Existing financial and actor structures

Decision: add balances and purchase evidence in Market; reuse existing holdings, issuance, recipient, quote and AuthenticatedActor.account_id.
Rationale: At the original design baseline, lib/football_market/market.ex owned issuance only and lib/football_market/accounts/user.ex had no spendable balance. AuthenticateAPI already supplies a trusted actor for JWT and API-key requests. Human feedback permits test provisioning but excludes a funding product.
Alternatives considered: embedding finance in Accounts or controller couples authentication to trading; introducing deposits or a second quote store violates scope. See ADR-0024/0029/0032. Technologies and providers are settled by docs/ARCHITECTURE.md; no dependency research is required.

## Browser prerequisite diagnosis (feedback 2)

Decision: preserve the existing inline Chromium preflight and extend only its safe diagnostic producer/forwarder/consumer; see ADR-0033 and contracts/profile-diagnostics.md.
Rationale: At the original feedback-2 baseline, scripts/test_profile_runner.py caught launch failure without a cause, filters child output to openapi-browser stages, and labels the preflight browser-prerequisite; scripts/agentflow_check.py exposes only profile stages/counts/locations. This local gap explains why a failed launch cannot be diagnosed from safe evidence. The human reproduction establishes that launch can succeed in the pinned environment, not a proven historical failure cause. No external research can identify that cause from available evidence.
Alternatives considered: raw exception output can expose paths, environment or secrets; automatic installs, browser replacement and weakened preflight exceed authorization. A separate new runner adds unnecessary machinery. Keep the cause unknown (launch-failed) when private error classification is inconclusive.

## Effective sandbox forwarding (feedback 7)

Decision: resolve the launcher-selected policy once, explicitly forward it to Codex and bind the closed result to integration/E2E retry identity (ADR-0035).
Rationale: current local inspection of scripts/agentflow_codex.py shows only conditional network-access injection, no effective sandbox field or child environment binding. scripts/agentflow_verification.py already hashes declared retry_env values; reuse that mechanism. test/scripts/agentflow_models_test.py already owns fake-provider launch tests, so no live model call or research agent is needed. Human feedback supplies the concrete Chromium/sandbox observation; it does not establish the historical mode.
Alternatives considered: browser error inference cannot establish policy; hashing CHROMIUM_PATH alone misses the permission boundary; automatically escalating sandbox or clearing failures would violate authorization and retry guarantees. Passing a validated mode explicitly avoids later global-default drift. No technology selection is reopened.

# Internal initialization contract — TASK-028

This is a trusted Elixir domain interface. No HTTP endpoint, public command, worker or ingestion hook is introduced. Existing authentication/REST contracts are unaffected. In-process callers are trusted operator code; no claim of authorization between arbitrary BEAM code is made.

## Calls

`FootballMarket.Market.initialize_player(player_id)` uses the trusted `:football_market, :initial_issuance_recipients` setting. Exactly one valid UUID referring to an existing account is required. Empty/absent, multiple entries (even duplicate UUIDs), malformed or nonexistent identities fail. Capture the setting once per invocation; Store receives the captured validated identity, locks and rechecks durable consistency.

`initialize_player(player_id, assertions)` optionally accepts a map containing only `:recipient_id`, `:quantity`, `:unit_price`. Omitted assertions use canonical values; supplied values are assertions, not setters. recipient_id must equal designation, quantity must be integer 100, price must be an exact non-floating integer 1 or finite Decimal equal to 1. Reject unknown keys, malformed map/ID and float prices/quantities. No effective date, invocation ID, per-player designation or arbitrary callback is accepted.

`FootballMarket.Market.get_initial_issuance(player_id)` returns original evidence for verification only, not current inventory, a quote-query API or portfolio. An existing unissued player yields `{:error, %Market.Error{kind: :not_initialized}}`; missing player yields `:player_not_found`. Use a coherent read of immutable linked facts; no mutation. Initialization retries still validate current designation and holdings before success.

## Outcomes

Success: `{:ok, %{outcome: :issued | :already_completed, issuance: evidence}}`.
Evidence contains issuance ID, stable player ID, original recipient ID, integer quantity 100, exact Decimal initial_unit_price 1, initial_quote_id, exact Decimal initial_inventory_value 100, effective_at, rule_id `initial_issuance`, rule_version `1`, completed_at. It never includes password/API-key/JWT data or current balance. First and duplicate outcomes refer to the same evidence.

Failure: `{:error, %FootballMarket.Market.Error{kind: kind, reason: safe_reason}}`. Kinds: `:invalid_input`, `:player_not_found`, `:invalid_designation`, `:recipient_conflict`, `:inconsistent_state`, `:not_initialized` (read only), `:storage_failure`. Safe reasons distinguish wrong recipient/quantity/price, missing/ambiguous/nonexistent designation, market-wide conflict, orphan holdings/quotes, invalid holding or original evidence. Multiple applicable failures may return any applicable one. Every failed invocation leaves no new financial effects; no accounts or repairs. Storage disconnect/deadlock/constraint failures rollback and never become `already_completed` automatically. A subsequent explicit retry can succeed.

## Coordination contract

1. Issuance starts READ COMMITTED; market initialization singleton row lock precedes player row lock and user existence/key-share validation.
2. Read all financial facts after locks; validate every prerequisite and consistency condition before returning either success.
3. Existing recipient singleton and all retained issuances agree with captured designation. Insert recipient only in the transaction of first successful issuance.
4. No player issuance: holdings/quotes must both be absent. Insert exactly one original quote, one holding of 100 and one issuance; all deferred constraints pass at commit.
5. Existing issuance: compare original quote/recipient/canonical facts and sum valid holdings to 100. Return original evidence without writes, including when original owner now holds zero.
6. Every quote/holding writer, including direct ordinary SQL, locks the same existing player via DB guards before mutation. Future multi-player writers take ascending UUID locks. They do not acquire initialization's global lock after player locks. A transfer of 20 is one transaction, not two commits. Performance-quote persistence reuses market_quotes.
7. Unsupported isolation fails explicitly. Initialization rejects an existing caller transaction with invalid_input/transaction_in_progress before acquiring locks or writing, so every successful initialization response follows its own durable commit. Evidence retrieval can participate in read transactions. Future trading/quote transactions follow the player-lock contract without nesting initialization.

A pre-commit interrupted attempt rolls back all newly inserted rows, including recipient fixation. Lost response after commit preserves immutable state; retry validates and returns already_completed. No compensating deletion or reset.

## Integration prerequisites

Use existing user and player UUIDs. Initialize fresh catalog players before performance quotation. Players already quoted without issuance fail inconsistent_state. Statistics, strategy selection and provider health are irrelevant. Test fixtures may add later coordinated quotes/redistributions; production trading, quote calculation and automated catalog initialization remain downstream work.

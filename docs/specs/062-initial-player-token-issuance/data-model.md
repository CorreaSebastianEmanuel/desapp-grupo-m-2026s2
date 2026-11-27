# Data model — Initial Player Token Issuance

All new IDs except singleton keys are UUIDs. Existing player/user identities are authoritative; restrictive foreign keys prevent deletion/reassignment of referenced originals. Every migration object/function reference uses its migration prefix. Named constraint failures translate to safe domain errors in Store; raw database values/credentials are not returned.

| Entity / table | Fields | Constraints and relationships |
|---|---|---|
| InitializationLock / market_initialization_locks | id integer=1 | Seed one row in migration; prevent UPDATE/DELETE/TRUNCATE. Row lock coordinates issuance transactions. Contains no account/price preset. |
| InitialRecipient / market_initial_recipients | id integer=1, user_id UUID, fixed_at UTC usec | Insert only on first successful issuance; singleton PK, existing user FK RESTRICT. Immutable all DML mutation/truncate guards. Cross-table recipient checks require all issuances to use this user. |
| Holding / market_holdings | id, player_id, user_id, quantity integer | Unique (player_id,user_id), restrictive player/user FKs, quantity >=0. Integer DB type rejects fractions. Every INSERT/UPDATE/DELETE locks affected player(s); initialized aggregate must equal 100 at deferred commit. Prevent TRUNCATE. Owner/player identities cannot be updated in place. Zero rows permitted; absent owner means zero. |
| Quote / market_quotes | id, player_id, unit_price NUMERIC, effective_at UTC usec, rule_id string, rule_version string, inserted_at UTC usec | Existing player FK; positive finite exact price, nonblank rule fields, required dates. Partial unique initial rule per player. Initial rule requires price=1, version=1. Immutable UPDATE/DELETE/TRUNCATE guards. This is the shared quote-history store, not an initial-only parallel history. |
| Issuance / market_issuances | id, player_id, recipient_id, quantity integer=100, initial_unit_price NUMERIC=1, initial_quote_id UUID, completed_at UTC usec | Unique player and unique quote association, restrictive player/user/quote FKs. Composite quote FK (initial_quote_id,player_id) and deferred consistency checks for rule/value/effective date and recipient singleton. Immutable UPDATE/DELETE/TRUNCATE guards. Required facts never null. |

## Logical invariants and named enforcement

Use stable named constraints (`market_issuance_player_unique`, `market_holding_owner_unique`, `market_holding_nonnegative`, `market_quote_initial_unique`, `market_issuance_canonical`, `market_issuance_quote_player_fkey`, `market_recipient_consistent`, `market_supply_conserved`, `market_history_immutable`, `market_write_isolation`) or equivalently explicit names documented in the implementation. Tests assert names/categories so storage rejection cannot masquerade as a domain success.

No separate supply table: completed issuance establishes 100 and aggregate holdings conserves it. The deferred issuance INSERT guard requires exactly one initial holding of 100 for the original recipient and no positive other-owner holdings at first commit. A conserved total held by the wrong user is insufficient. Later transfer commits only enforce valid holdings and aggregate conservation. Deferred checks on issuance and holding writes verify final totals, allowing atomic 80/20 and 0/100 transfers in fixtures. Checks cover OLD and NEW player keys on deletions/changes. First orphan holdings/quotes remain readable and cause initialization rejection; no constraint creates an issuance for them. Direct inserts of completed issuance must obey canonical initial quote, market recipient and conserved supply. Acquire initialization lock before player for issuance insertion; quote/holding guards take player locks. Immutable guards also reject statement-level TRUNCATE; no cascade-delete financial history.

Every writable transaction must be READ COMMITTED. Under the lock, fresh post-lock statements see the latest committed player state. No write guard accepts a stale REPEATABLE READ snapshot. Financial DML guards use the same player lock, keeping holdings aggregate/quote history coherent while retries validate. Future multi-player writers acquire ascending UUID player locks and may not later acquire the initialization singleton. Constraints/guards supplement trusted Store orchestration, not substitute for input/prerequisite checks.

## Exact values and dates

One credit is Decimal.new("1")/NUMERIC 1; quantities are integers. Derived original inventory value is exact Decimal.new("100"), never a persisted current portfolio value. No floating input accepted, even 1.0. Initialization captures DB UTC time after prerequisite locks once, using it for initial effective_at and completed_at; fixed_at records first recipient fixation. Persisted time denotes completed initialization transaction's sampled instant, not the exact commit clock. No caller historical date. Quote rule/version and original recipient never depend on later active configuration.

## State transitions

`unissued + valid + no holdings/quotes → issued` atomically creates recipient if needed, quote, holding and issuance. Failed pre-commit execution remains unissued with no new records. `issued + valid designation + consistent retained state → already_completed` is read-only apart from locks. Post-commit acknowledgement loss remains issued. `unissued/issued + invalid prerequisites/conflict/inconsistency → failure` changes nothing. Later fixture transfers/quotes do not change issuance; ordinary initialized holdings must stay conserved.

## Consistency projection

Store builds a post-lock snapshot of designation user, fixed market recipient, existing issuance recipients, player issuance, its original quote and all player holdings/history. Pure Consistency validates IDs, nonnegative integral holdings, player membership, quantity=100, value=1, original quote existence/player/rule/version/date/value agreement, valid completion/effective times and market recipient agreement. Initial quote effective_at equals completed_at by construction. A missing original recipient holding after redistribution is valid. Unknown identities, null or contradictory facts and offsetting invalid holdings fail even if their total is 100.

## Fixtures and future extensions

No user balances, purchase/sale records, roles or funding schema is introduced. Snapshot real existing accounts/credentials/API keys and test-only exact balance sentinels to verify absence of financial/account writes. Legacy corruption fixtures run only in dedicated guarded test namespaces or pure maps; production guards are never disabled. TASK-026 extends this quote store with performance retention; TASK-029/030 add coordinated trading/financial audit without changing original issuance.

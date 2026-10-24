# Purchase persistence design

Reuse users, players, market_initial_recipients, market_issuances, market_quotes and market_holdings. Preserve their existing foreign keys, immutable facts and deferred supply checks. New tables use UUID identities and restrictive foreign keys. Implement in priv/repo/migrations/20261023000000_create_market_purchases.exs, with schema-prefix-safe functions/triggers and migrations on fresh and previously migrated stores.

| Structure | Fields and constraints | Mutability |
| --- | --- | --- |
| market_credit_balances | user_id PK/FK users, amount NUMERIC NOT NULL, updated_at UTC microseconds; finite amount >=0 and amount=round(amount,2) | Projection, row-locked; existing credits only |
| market_purchases | id UUID PK; buyer_id, recipient_id FK users, player_id FK players, quote_id; request_key text nonblank <=128 characters; quantity int 1..2147483647; unit_price NUMERIC positive finite cents; total NUMERIC positive finite cents = quantity*unit_price; quote_effective_at, rule_id, rule_version; nullable configuration_version_id/mapping_id and performance_sequence matching referenced quote; completed_at UTC microseconds | Append-only; unique(buyer_id,request_key), buyer<>recipient |
| market_credit_entries | id UUID PK; purchase_id FK, user_id FK, side debit/credit, amount NUMERIC positive finite cents; inserted_at UTC microseconds | Append-only; unique(purchase_id,side); deferred exactly one debit buyer and one credit recipient, both equal purchase.total |
| market_token_transfers | id UUID PK; purchase_id unique FK; player_id, from_user_id, to_user_id, quantity, inserted_at | Append-only; deferred exactly one, equal purchase player/participants/quantity |

Use existing composite quote/player identity FK; deferred consistency verifies copied price/effective/version facts against the immutable quote. Do not synthesize a performance version for an initial issuance quote. Financial evidence cannot be updated, deleted or truncated through ordinary DML. Reject missing or extra child entries, wrong participant, wrong quote, unbalanced amounts and incomplete operation at transaction commit. Keep DB-side supply conservation and holding uniqueness/nonnegativity intact. No orphan issuance or automatic repair is allowed.

Balances are projections, not funding operations. No backfill creates credits. Missing buyer projection reads as zero. A missing recipient projection is inserted as zero only inside a successful purchase; failed attempts roll that insertion back. Test fixtures provision balances before attempting purchases and must not expose a production funding function. No account balance upper bound is invented: unconstrained PostgreSQL NUMERIC plus explicit finite/cents validation avoids integer-money overflow.

Request state has only absent -> committed purchase. Pending state exists only inside a transaction and is never independently visible. Failure -> absent; retry can use a later current quote. Committed -> replay with the same player/quantity, or conflict for different material details. Keys compare exact bytes after rejecting whitespace-only strings; do not trim a meaningful key. UUIDs are canonicalized before material comparison. Projection locks and completed-key locks follow ADR-0032.

Market.Purchases.get_for_buyer/2 retrieves immutable operation plus transfer/ledger evidence for trusted internal callers. No public history/list endpoint is added. Tests read original evidence after later quote changes, another purchase and a fresh BEAM process.

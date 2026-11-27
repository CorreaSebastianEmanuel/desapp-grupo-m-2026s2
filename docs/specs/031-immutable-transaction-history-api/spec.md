# Outcome specification: Immutable transaction history API

## Outcome

Authenticated users can inspect their immutable market operations as one auditable, stably ordered, paginated history.

## Acceptance

- [x] `GET /api/transactions` requires API authentication and returns only operations where the authenticated user is the purchase buyer or sale seller.
- [x] Each row exposes operation `type`, immutable operation `id`, `player_id`, `quantity`, exact decimal-string `unit_price` and `total`, `quote_id`, and `completed_at`. A test executes a conditional buy order and verifies its purchase appears exactly once with all these fields.
- [x] Results are ordered by `completed_at` descending, then operation type and operation ID ascending. Tests traverse equal-time purchases and sales across page boundaries, including same-type ID ties, and prove there are no omissions or duplicates; a newer appended operation does not shift an existing continuation page.
- [x] `page_size` defaults to 25 and accepts integers from 1 through 100, including both boundaries. Responses contain `data` and `pagination` (`page_size`, `returned_count`, `has_more`, `next_cursor`). Blank, malformed, repeated, structured, or out-of-range pagination parameters return 400 without querying another user’s history.
- [x] Empty histories return an empty page. Unauthenticated requests return the standard generic 401. Reads do not mutate transaction or ledger records.
- [x] Focused tests assert complete conditional-order purchase evidence, purchase and sale visibility, actor isolation, deterministic tie ordering and cursor traversal across pages, structured/repeated/blank and boundary pagination inputs, authentication, exact decimal serialization, empty history, and unchanged ledger records after reads.

## Scope

- Add the market-domain read operation, persistence query, authenticated HTTP endpoint and JSON/OpenAPI contract for user transaction history.
- Add focused tests for the acceptance behaviors.

## Non-goals

- New financial operations, transaction mutation or deletion, filters, date ranges, aggregate balances, or exposing another user’s operations.

## Risk

- Medium: financial history is user-scoped and append-only; reads must not leak records or alter evidence.

## Decisions

- Reuse the existing authenticated `/api` boundary and opaque cursor list convention. Purchase ownership is `buyer_id`; sale ownership is `seller_id`. Each user sees a purchase or sale once, even when they are also the opposite-side market recipient.
- Merge the two immutable ledgers by `completed_at DESC, type ASC, id ASC`; cursor continuation binds that complete order anchor. Money is serialized as exact decimal strings.

# Direct sale contract

## Domain

`FootballMarket.Market.sell(actor, %{player_id: uuid, quantity: integer, request_key: string})` returns `{:ok, sale_evidence}` only after commit or `{:error, %FootballMarket.Market.Error{}}`. Identity comes from the authenticated actor. Matching completed retries return the original evidence; conflicting details return `key_conflict`; failed attempts do not consume the key.

## HTTP

`POST /api/sales` is protected by the existing JWT/API-key policy. The JSON body contains exactly `player_id`, `quantity`, and `request_key`.

Success is 200 with `data` containing `id`, `seller_id`, `recipient_id`, `player_id`, `quote_id`, `quantity`, `unit_price`, `total`, `request_key`, quote version evidence, and `completed_at`. Money is serialized as two-decimal strings.

Errors use `{\"error\":{\"code\":\"<category>\"}}`:

| Status | Categories |
| --- | --- |
| 401 | `unauthenticated` |
| 400 | `invalid_request` |
| 404 | `player_not_found` |
| 409 | `not_initialized`, `quote_unavailable`, `insufficient_tokens`, `insufficient_market_funds`, `key_conflict`, `self_sale`, `inconsistent_state` |
| 503 | `temporarily_unavailable` |

The endpoint accepts no seller/recipient/quote/price/total overrides and exposes no history route.

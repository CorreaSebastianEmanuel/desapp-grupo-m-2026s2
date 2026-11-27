# Ranking read contract

## Domain

`FootballMarket.Ranking.read/0` returns `{:ok, result}` as defined in data-model.md, `{:error, :no_active_configuration}`, or `{:error, :storage_unavailable}`. No caller-selectable configuration, filters, pagination or recalculation. Web adapter authenticates; internal contexts do not introduce another credential scheme. Reject execution inside an existing Repo transaction as storage_unavailable; preserve the owned snapshot guarantee. Known connection/database errors are sanitized; do not blanket-rescue programmer failures.

Snapshot linearization is the first data SELECT inside a REPEATABLE READ, READ ONLY transaction. Activation committed before that SELECT is visible; after it the complete old configuration/history is allowed. All quotes and reported configuration share one snapshot.

## HTTP

GET /api/ranking

Use existing protected API authentication and metadata `authentication_policy: :api_protected`. No new role or permission. No request body or query controls; incidental query parameters have no effect, matching a fixed read rather than silently implementing filters. JSON only.

Success: HTTP 200, JSON content-type, `cache-control: no-store` to prevent reuse across activations. Exact shape:

```json
{
  "configuration": {
    "configuration_version_id": "00000000-0000-4000-8000-000000000001",
    "strategy_id": "balanced",
    "formula_version": "1"
  },
  "data": [
    {
      "position": 1,
      "player_id": "00000000-0000-4000-8000-000000000002",
      "quote_id": "00000000-0000-4000-8000-000000000003",
      "unit_price": "12.50",
      "effective_at": "2026-10-26T12:00:00.000000Z"
    }
  ]
}
```

Active configuration with no eligible quotes returns the same configuration object and `data: []`. No active configuration: HTTP 409, `{"error":{"code":"no_active_configuration"}}`. Infrastructure/anchor/read error: HTTP 503, `{"error":{"code":"storage_unavailable"}}`. Both carry no-store and JSON headers. Unauthenticated/invalid/revoked/expired credentials retain existing AuthenticateAPI HTTP 401 error body/header behavior; no ranking query runs. Never include credentials, SQL, stack traces, configuration rules or provider payloads in responses.

Prices are positive fixed two-place decimal strings; UUIDs canonical lowercase; positions unique consecutive integers. Exact active saved-version identity plus strategy/formula is mandatory. No issuance quotes, inactive fallback or fabricated zero prices. Known success confirmation is specified in research.md. Response order is part of the contract.

## Executable evidence

Controller tests assert all outcomes, credential refusal and JSON precision. `scripts/verify_ranking_runtime.exs` must start a real listener on an allocated local port, await bounded readiness and fail if unavailable. Use real authenticated requests; assert status, JSON/no-store headers, complete configuration, selected quote IDs/prices/order/positions, empty success, 409 absent activation, 503 storage fault, and existing 401 credential refusal. Isolate fault injection to the test-owned reader/store; never expose a production fault-control endpoint. Stop listeners in cleanup and never print credentials. This script is explicitly executed by the runtime manifest command after service preflight, separate from full-profile discovery.

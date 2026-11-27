# Contract: REST API Authentication

## Route policies

Every application-owned `FootballMarketWeb.Router` route at `/api` or `/api/*` passes through exactly one policy:

- `api_public`: does not inspect or validate credentials and never assigns an actor.
- `api_protected`: authenticates before controller or application behavior.

Public `{method, path}` pairs are explicitly allowlisted by the route-policy audit. Browser, LiveView, framework/dev-only, unmatched, and non-`/api` routes are outside this contract.

## Accepted protected credentials

Exactly one of:

```http
Authorization: Bearer <opaque-jwt>
```

```http
X-API-Key: <opaque-api-key>
```

Header names and the Bearer scheme are case-insensitive. Credential values remain exact. Repeated fields, both forms together, blank values, unsupported schemes, extra Bearer parts, and validator rejection all fail closed. A coalesced field is not split.

## Successful protected request

The next Plug/handler receives:

```elixir
%FootballMarket.Accounts.AuthenticatedActor{
  account_id: account_uuid,
  authentication_method: :jwt | :api_key,
  credential_id: token_or_key_uuid
}
```

under `conn.assigns.authenticated_actor`. No response shape is defined by authentication; the protected operation owns its response.

## Unauthenticated response

All failures after the request reaches the authentication Plug return exactly:

```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json; charset=utf-8
WWW-Authenticate: Bearer realm="api"

{"error":{"code":"unauthenticated"}}
```

The connection is halted, no actor is assigned, and protected behavior does not run. Invalid HTTP rejected by the server before Plug execution is outside this contract.

## Authentication telemetry

Protected decisions emit `[:football_market, :api, :authentication]` with:

- measurement: monotonic `duration`;
- metadata: `route_policy: :protected`, generic `outcome`, and selected `authentication_method` only after unambiguous selection.

Headers, credential content, causes, claims, hashes, account IDs, and credential IDs are forbidden in authentication telemetry and logs.

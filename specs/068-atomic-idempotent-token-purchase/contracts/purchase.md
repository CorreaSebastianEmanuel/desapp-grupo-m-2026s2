# Direct purchase contract

## Domain

FootballMarket.Market.purchase(actor, %{player_id: uuid, quantity: integer, request_key: string}) returns {:ok, purchase_evidence} only after its own commit, or {:error, %FootballMarket.Market.Error{kind: category, reason: safe_reason}}. actor is the existing authenticated actor; trusted workers must supply the same explicit account identity through the domain boundary, never an untrusted payload buyer_id. Nested transactions fail safely. Matching completed retries return exactly the original persisted evidence. Internal get_for_buyer(buyer_id,purchase_id) returns evidence only for that buyer. No public history interface.

## HTTP

POST /api/purchases uses the existing api_protected pipeline and metadata authentication_policy: :api_protected. Accept one supported credential according to TASK-010; JWT/API-key semantics remain unchanged. Content-Type and Accept are application/json. Body has exactly player_id (36-character hyphenated UUID string), quantity (JSON integer 1..2147483647), request_key (nonblank string <=128 Unicode characters with no NUL byte). Reject unknown fields including buyer_id, recipient_id, price, unit_price, total and quote_id. Reject noncanonical UUID text (including 16-byte strings that an underlying UUID library might accept as raw bytes), floats, numeric strings, malformed JSON and keys with NUL bytes using invalid_request before persistence. Domain validation also runs for non-HTTP callers.

Success is 200 application/json for both initial commit and matching replay (same immutable body, no new operation). Body: {"data":{"id":"<purchase UUID>","buyer_id":"<UUID>","recipient_id":"<UUID>","player_id":"<UUID>","quantity":2,"quote_id":"<UUID>","unit_price":"1.25","total":"2.50","request_key":"client-key","quote_effective_at":"<UTC ISO8601>","rule_id":"<rule>","rule_version":"<version>","configuration_version_id":null,"mapping_id":null,"performance_sequence":null,"completed_at":"<UTC ISO8601>"}}. Nullable version fields reflect the selected quote; serialize money as decimal strings with exactly two places, never JSON floats. No Location header implying an unimplemented history route.

Errors use {"error":{"code":"<category>"}} with no SQL, credentials or internal stack details:

| Status | Category |
| --- | --- |
| 401 | unauthenticated (existing WWW-Authenticate: Bearer realm="api") |
| 400 | invalid_request (shape, key, quantity, malformed UUID/JSON) |
| 404 | player_not_found |
| 409 | not_initialized, quote_unavailable, insufficient_funds, insufficient_inventory, key_conflict, self_purchase, inconsistent_state |
| 503 | temporarily_unavailable (connection/lock/deadlock/storage interruption; no success claimed) |

A valid completed retry bypasses changed quote, funds and inventory eligibility. Conflicting completed details always report key_conflict before these business checks. Malformed payload or authentication errors can precede lookup. Other simultaneous rejections may report any applicable category. Failure does not consume the key. Unknown/inconsistent state is never repaired by purchase. Source is only the immutable designated recipient's current inventory.

Publish the path and response/error schemas in priv/static/openapi.json, reusing existing security schemes. Do not add quote, funding, sales, listing, conditional-order or history routes. Assertion-based runtime checks must start a real endpoint, assert readiness and exercise success, replay, conflict, business refusal and authentication; ConnTest alone is insufficient runtime evidence.

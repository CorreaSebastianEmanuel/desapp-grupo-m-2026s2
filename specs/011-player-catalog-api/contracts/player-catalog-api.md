# Contract: Player Catalog API

All routes require exactly one credential accepted by the shared protected API policy. Authentication failure occurs before query/path validation or catalog access and returns the TASK-010 response (`401`, `WWW-Authenticate: Bearer realm="api"`, `{"error":{"code":"unauthenticated"}}`). JSON responses use `application/json`.

## Player representation

```json
{
  "id": "0d96a6f6-a624-4dbf-8112-172e743d52ac",
  "display_name": "Ada Striker",
  "catalog_identity": "2026-ada-striker",
  "position": {"id": "2ae8581c-5192-4cd8-a2c1-67c1053b557d", "code": "FWD", "name": "Forward"},
  "team": {"id": "64935c84-ad37-4160-8478-f244d7bb52fc", "short_code": "ARS", "name": "Arsenal"},
  "season": {"id": "c3c1aa17-f40d-4bfb-9646-f89203bca17b", "start_year": 2026, "end_year": 2027},
  "league": {"id": "cbd85004-d225-47b8-a0f5-80960448ef37", "code": "PL", "name": "Premier League"}
}
```

Every `id` is a canonical UUID JSON string; years are integers; every other leaf is a non-empty JSON string. No field is nullable. Objects contain exactly the shown fields. `catalog_identity` is a local season-scoped catalog identity, not a provider identifier.

## `GET /api/players`

Query parameters:

- `page_size` optional: one base-10 integer from 1 through 100; default 25. Signs, decimals, whitespace, blanks, arrays/maps, and repeated occurrences are invalid.
- `cursor` optional: one non-empty opaque cursor issued by this operation. Blank, malformed, tampered, wrong-version/scope, arrays/maps, and repeated occurrences are invalid. A cursor can be replayed across requests, used with another valid page size, and used by any successfully authenticated actor.
- Unknown query parameters are ignored and never alter the result. Only `page_size` and `cursor` participate in this endpoint; filters and search remain outside scope.

Success (`200`) has exactly:

```json
{
  "data": [],
  "pagination": {
    "page_size": 25,
    "returned_count": 0,
    "has_more": false,
    "next_cursor": null
  }
}
```

`data` is ordered by `lower(btrim(display_name))`, then UUID identity. `next_cursor` is a non-empty string iff `has_more` is true. A cursor after the final item succeeds with an empty page.

Errors:

- invalid `page_size`: `400 {"error":{"code":"invalid_page_size"}}`
- invalid `cursor`: `400 {"error":{"code":"invalid_cursor"}}`

Errors contain exactly the shown structure and no catalog or decoder detail. If both supported parameters are invalid, validate `page_size` first, then `cursor`.

The cursor is stateless, encrypted, integrity-protected, endpoint/version scoped, and page-size independent. It is not a historical snapshot. With unchanged ordering data, replay and traversal are deterministic. Inserts strictly after an anchor may appear; inserts before do not. Ordering-key updates and deletions during traversal can cause gaps or duplicates. Deleting the anchor itself does not invalidate continuation.

## `GET /api/players/{player_id}`

`player_id` is the player's canonical UUID identity. A success is `200` with exactly:

```json
{"data": {"id": "0d96a6f6-a624-4dbf-8112-172e743d52ac", "display_name": "Ada Striker", "catalog_identity": "2026-ada-striker", "position": {"id": "2ae8581c-5192-4cd8-a2c1-67c1053b557d", "code": "FWD", "name": "Forward"}, "team": {"id": "64935c84-ad37-4160-8478-f244d7bb52fc", "short_code": "ARS", "name": "Arsenal"}, "season": {"id": "c3c1aa17-f40d-4bfb-9646-f89203bca17b", "start_year": 2026, "end_year": 2027}, "league": {"id": "cbd85004-d225-47b8-a0f5-80960448ef37", "code": "PL", "name": "Premier League"}}}
```

A malformed or absent identity returns the identical `404 {"error":{"code":"player_not_found"}}`. No provider fallback or import occurs.

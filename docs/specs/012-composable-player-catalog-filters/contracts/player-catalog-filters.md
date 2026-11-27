# Contract: Player Catalog Filters

This extends the existing [TASK-011 player catalog contract](../../011-player-catalog-api/contracts/player-catalog-api.md) for protected `GET /api/players` only. Authentication, JSON player and page shapes, page size, ordering, detail behavior, and all unmodified errors retain that contract.

## Query parameters

| Key | Accepted value | Membership rule | Invalid response |
|---|---|---|---|
| `league_id` | One UUID | Player's team season belongs to this league | `400 {"error":{"code":"invalid_league_id"}}` |
| `team_id` | One UUID | Player's exact season-specific team record has this ID | `400 {"error":{"code":"invalid_team_id"}}` |
| `position_id` | One UUID | Player's position has this ID | `400 {"error":{"code":"invalid_position_id"}}` |

All three are optional and combine with logical AND. Each accepted UUID has the 8-4-4-4-12 hexadecimal shape, with either letter case and no whitespace. Percent decoding happens before validation. Blank, malformed, bracket-structured, and repeated values are invalid, including repetitions of the same value. Query key order has no effect. Unsupported keys remain ignored and have no effect on membership or ordering.

Clients can obtain these IDs from the nested `league.id`, `team.id`, and `position.id` values in existing player list responses. A client with no known IDs must first obtain players through that existing list; this operation does not enumerate all possible filter values.

A valid but unknown ID, or a valid combination that no player satisfies, returns `200` with exactly the existing empty-page form:

```json
{"data":[],"pagination":{"page_size":25,"returned_count":0,"has_more":false,"next_cursor":null}}
```

No response states whether an ID or relationship exists. Filtering happens before ordering, keyset seek, and page limit, so nonmatches do not consume page capacity. A nonempty page contains only matching players and retains the TASK-011 representation with no new fields. The exact final page has `has_more: false` and `next_cursor: null`; a cursor positioned after all current matches produces the empty page above with its requested page size.

## Cursor continuation

Use a filtered `next_cursor` only with the same set of filter keys and UUID identities. Query key order and valid UUID letter case do not matter. Changing, adding, or removing any filter returns `400 {"error":{"code":"invalid_cursor"}}` with no player data. Changing only `page_size` is allowed. Previously issued unfiltered TASK-011 cursors still work without filters and return `invalid_cursor` if filters are supplied; filtered cursors return `invalid_cursor` without their filters. Tokens are opaque and must not be parsed by clients. They remain stateless, encrypted, non-snapshot keyset markers with the TASK-011 lifetime and mutation behavior.

For an authenticated request with several invalid supported values, validate and respond in this order: `page_size`, `league_id`, `team_id`, `position_id`, `cursor`. Authentication failure occurs before all validation and catalog reads, with the unchanged TASK-010 challenge and response. Neither an invalid response nor a success adds credentials, actor information, provider details, or cursor plaintext.

## Examples

```text
GET /api/players?league_id=<uuid>&position_id=<uuid>&page_size=100
GET /api/players?team_id=<uuid>&position_id=<uuid>&league_id=<uuid>&cursor=<opaque>
```

The detail route, season filtering, text search, discovery endpoints, UI, and OpenAPI publication are outside this extension.

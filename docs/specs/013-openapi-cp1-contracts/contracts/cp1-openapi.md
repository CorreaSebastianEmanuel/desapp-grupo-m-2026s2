# CP1 OpenAPI contract design

The implementation publishes the single OpenAPI 3.0.x JSON document at `/openapi.json`; this file is its design checklist, not a second served contract. `servers` is relative (`/`). Paths contain exactly these two operations:

| Operation | Parameters | Responses |
| --- | --- | --- |
| `GET /api/players` | Optional query `page_size` (integer 1–100, default 25), `cursor` (non-empty opaque string), `league_id`, `team_id`, `position_id` (UUID strings) | 200 `PlayerPage`; 400 `Error` with one of five codes; 401 `Error` plus `WWW-Authenticate` |
| `GET /api/players/{player_id}` | Required path `player_id` (UUID string) | 200 `PlayerDetail`; 401 `Error` plus `WWW-Authenticate`; 404 `Error` |

Both operations have `security: [{BearerAuth: []}, {ApiKeyAuth: []}]`. `BearerAuth` is HTTP `bearer` in `Authorization`; `ApiKeyAuth` is `apiKey` in header `X-API-Key`. The two entries are alternatives. The UI must send one selected method at a time. Header names and the Bearer scheme are case-insensitive; credential values are exact. Missing, invalid, expired, repeated, or mixed credentials receive 401 with exact JSON `{"error":{"code":"unauthenticated"}}` and `WWW-Authenticate: Bearer realm="api"`. Authentication precedes all parameter validation and catalog access.

## List semantics to place in parameter/operation descriptions

- Explicit `page_size` uses one unsigned base-10 integer in 1–100; absent means 25. Supported values reject blank, malformed, bracket-structured, or repeated occurrences.
- Each filter is one UUID without surrounding whitespace, matched against its nested player ID. Omitted filters impose no restriction; supplied filters intersect. Unknown query keys are ignored and query-key order is irrelevant. Valid but unknown or conflicting IDs yield an empty 200 page.
- Rows are locally stored players, ordered by case-insensitive display name and stable player ID tie-breaker; no live provider fetch occurs.
- `cursor` is opaque and non-empty. A filtered cursor binds to the normalized effective filter set; UUID letter case and query-key order do not alter it. Adding/removing/changing a filter yields `invalid_cursor`; changing only `page_size` is allowed. Traversal is not a snapshot. Clients must not decode or manufacture cursors.
- An authenticated request with several invalid supported values returns the first error in this priority: `page_size`, `league_id`, `team_id`, `position_id`, `cursor`.

## Response schemas and examples

Follow [data-model.md](../data-model.md): every public object uses all required fields and `additionalProperties: false`; UUID leaves use `format: uuid`; non-empty strings use `minLength: 1`; years are integers. `Pagination.next_cursor` is required, `type: string`, `minLength: 1`, `nullable: true` in OAS 3.0. The document must explain cross-field constraints that OAS cannot express.

The list 400 response has one exact `Error` body with a code enum and five named examples: `invalid_page_size`, `invalid_league_id`, `invalid_team_id`, `invalid_position_id`, `invalid_cursor`. The 401 and 404 response schemas constrain `code` to their respective single values; the 401 response also declares the `WWW-Authenticate` header with its exact example value. Include at least one nonempty list 200 example with a non-empty continuation cursor, one empty page example with all pagination fields, one detail 200 example sharing the same player shape, the generic 401 example, and a 404 example exactly `{"error":{"code":"player_not_found"}}`. Use fictional UUIDs and opaque cursor placeholders. Do not include any usable token or API key in examples or page configuration.

The 200 list body's top-level keys are exactly `data` and `pagination`; detail has exactly `data`. The `Player` and nested object keys are defined in [data-model.md](../data-model.md). The 400/401/404 bodies contain only the `error.code` envelope. All response bodies use `application/json`.

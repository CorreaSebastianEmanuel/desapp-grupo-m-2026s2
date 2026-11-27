# Documentation Data Model: TASK-013

No database entity or migration is added. These are public contract schemas for existing persisted catalog records. The JSON contract will be the machine-readable source; [the contract checklist](contracts/cp1-openapi.md) specifies operations and examples.

| Schema | Fields and validation | Relationship |
| --- | --- | --- |
| `Player` | Exactly required `id` (UUID), `display_name` and `catalog_identity` (non-empty strings), `position`, `team`, `season`, `league`; no nulls or extra fields | One public projection of a locally stored player and its current hierarchy |
| `Position` | Exactly required `id` (UUID), `code`, `name` (non-empty strings) | `Player.position` |
| `Team` | Exactly required `id` (UUID), `short_code`, `name` (non-empty strings) | `Player.team`; its persisted season determines `Player.season` and `Player.league` |
| `Season` | Exactly required `id` (UUID), `start_year`, `end_year` (integers) | `Player.season` |
| `League` | Exactly required `id` (UUID), `code`, `name` (non-empty strings) | `Player.league` |
| `Pagination` | Exactly required `page_size` (integer 1–100), `returned_count` (integer 0–100), `has_more` (boolean), `next_cursor` (nullable string, non-empty when present); no extras | `returned_count = length(data)`; `next_cursor` exists exactly when `has_more`, otherwise null |
| `PlayerPage` | Exactly required `data` (array of `Player`), `pagination` (`Pagination`); no extras | `length(data) ≤ page_size`; empty pages still include full pagination |
| `PlayerDetail` | Exactly required `data` (`Player`); no extras | Same `Player` schema as the list |
| `Error` | Exactly required `error` object with exactly required `code` string; no extras | Allowed code depends on operation/status; each response has one code |

`AuthenticationChoice` is a protocol constraint, not a stored entity: a request sends one Bearer token or one API key. Documentation credentials exist only in the active page's memory. A filtered cursor is an opaque value already produced by the catalog API; this task introduces no cursor state or transition.

## State and cross-field rules

- `has_more = true` requires non-empty `next_cursor`; `false` requires null. A schema can express required/nullable fields, while contract checks and descriptions enforce this conditional rule.
- An empty result has `data: []`, `returned_count: 0`, `has_more: false`, and `next_cursor: null`; `page_size` remains the applied value.
- Each list filter refers to the corresponding nested player identity. Effective filters intersect; valid unknown/conflicting IDs yield an empty page. Cursor validity depends on the normalized effective filter set, not page size.
- No credential, actor, provider payload, persistence column, or internal metadata enters these schemas.

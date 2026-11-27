# TASK-013 task-generation handoff

## Resolution

The P1 browser story needs the machine-readable contract to exist first. The plan now makes the single complete JSON file part of US1, with US2 tightening failure/security evidence and US3 adding parser and drift gates. This keeps the spec's story priority order without creating a second contract. No human feedback or unresolved product choice was present in the current TASK-013 backlog record.

## Remaining risks and sequencing guidance

- Phoenix router metadata uses `:player_id`, while OpenAPI uses `{player_id}`. Normalize only that syntax when comparing catalog routes; retain exact HTTP method and protection metadata.
- A valid OpenAPI 3.0 `nullable: true` field may be handled differently by generic JSON Schema validators. Use the pinned OpenAPI-aware parser for validity, then assert the required nullable field and cross-field cursor behavior separately.
- The UI distribution may change generated request panels or load additional assets across versions. During browser acceptance, inspect actual network requests and visible panels after credential switching. If any asset tries to load off-origin, correct the local bundle/configuration before accepting the page.

No other handoff or workflow log was consulted.

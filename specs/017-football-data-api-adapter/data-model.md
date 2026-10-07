# Feature-specific in-memory model

No migration, persistent identity, raw-response storage or new domain DTO. Existing provider entities/validation remain owned by `specs/016-external-football-provider-contract/data-model.md` and `lib/football_market/providers/types.ex`.

| Internal value | Fields and relationships | Rules |
| --- | --- | --- |
| Trusted adapter state | enabled, token, position_mapping, transport tuple; synthetic fixture_id only in fixture state | Token is secret; never derive from request. Validation precedence is in contracts/football-data.md. No secret-bearing Inspect output. |
| Discovery evidence | competition id/code; seasons id/startDate/endDate; currentSeason id/startDate/endDate | Positive integer source IDs; valid dates; match both years, distinct season identities, coherent current-season membership; compare first/final signatures. |
| Team membership list | explicit teams array of team identities; optional observed count and scope metadata | Validate all identities before dictionaries; explicit empty is allowed; any supplied count/scope must agree. |
| Team portion | id/name/tla/runningCompetitions/squad | Exactly one per listed team. All player rows retained. Staff/coach sections never enter players. Missing/null squad is invalid. |
| Person evidence | id/currentTeam.id, optional currentTeam.runningCompetitions | Exactly one per player, matching enclosing squad team; null/missing/conflicting currentTeam invalidates the request. Extra personal details discarded. |
| Collection state | validated request/context, initial evidence, ordered portions, pending IDs, opaque reference table | Ephemeral within one worker. Preserve duplicate rows until detection. No publication of unfinished state. |
| Source exchange | fixed route kind and normalized scalar IDs/year, status, private headers/body; received_us/received_utc for complete failure headers | Receipt pair captured before close/parsing; relative and date delays use the same anchor. Transport only; no transport fields in candidate/error. Fixed origin and trusted test exception only. |
| Private retry window | integer not_before_us; unique worker-local per-call reference | Record only valid supplied future waits; remove on every work terminal path. No header, callback or clock value in public error. ADR-0015 owns readiness conversion. |
| Internal runtime outcome | normalized outcome plus optional integer retry expiry | Opaque to unchanged Runtime; Runner unwraps and refines rate_limited at ready_us after deadline precedence. Unregistered other adapters preserve exact outputs. |

## Translation to existing candidates

- League: canonical `Request.leagues()[code]` name, after source competition identity/code verification. Vendor display-name aliases are not passed into the canonical league name.
- Season: exact matched date years, league reference. League/season source bindings use discovery competition/season IDs.
- Team: source `name` and `tla` become name/code; season reference. Blank or absent values fail; no `shortName`/name-derived fallback.
- Player: source squad `name` becomes display_name; team reference corroborated by person evidence; position reference from explicit role mapping. No first/last-name reconstruction.
- Position: canonical configured code/name (`GK` Goalkeeper, `DEF` Defender, `MID` Midfielder, `FWD` Forward). Only used roles need appear; empty catalogs may carry no positions. Positions have no vendor source binding under the existing contract.
- References: allocate opaque result-local refs for league/season/team/player, unrelated to source IDs; positions use their canonical code as required by the existing validator. Source IDs become decimal strings only after positive-integer validation and token-containment checks. Distinct same-name players stay distinct; any duplicate source identity fails.
- Provenance: label `football-data-org`, boundary-generated retrieval time and qualified bindings; synthetic fixture_id in fixture runs only. The adapter returns the existing candidate envelope, never a final DTO bypassing `Validator`.

## Lifecycle

Unvalidated input → normalized request → selected source/configuration validation → capability check → initial discovery → complete team list → every team and person portion → final discovery → candidate → existing whole-result validation/error normalization → private expiry capture → strict readiness/deadline selection → public outcome with remaining delay refreshed only when registered (ADR-0015). Any failure terminates with one safe category; deadline/caller exit closes source resources and prevents late publication. No persistent state transition occurs.

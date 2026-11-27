# Provider value model

This is an in-memory contract, not an Ecto model or migration. Types live in `lib/football_market/providers/types.ex` under `FootballMarket.Providers`. Struct names below define the public normalized values; adapters may submit equivalent plain candidate maps for validation. No persisted IDs, money, scores, rating or transport fields exist here.

## Request and configuration

| Value | Fields | Rules |
| --- | --- | --- |
| Request | operation, scope, timeout_ms | operation is `:catalog` or `:performances`; default timeout 5000; positive integer only |
| Scope | league_code, start_year, end_year; performances additionally from, to | trim/uppercase league to PL/BL1/PD/SA/FL1; years are integers, not booleans, end = start or start+1; independently optional inclusive bounds |
| Context (private) | deadline_us, runtime, positions, provider_label | one monotonic deadline, immutable configured vocabulary, controlled stable label; never football facts |
| Internal options | provider, positions, runtime | provider = module plus private state; runtime = module plus state; production defaults come from internal application configuration; no caller request key selects provider |

Accepted input key formats and safe error behavior: contracts/provider.md. Scope years impose no inferred date window or new numeric range. Instants use the already accepted ADR-0011 boundary: explicit UTC/offset DateTime or ISO-8601 instant with at most six fractional digits, normalized losslessly to UTC microseconds. Bounds do not require the source to publish a match in that year.

## Football facts

| Entity | Fields | Relationships / validation |
| --- | --- | --- |
| League | ref, code, name | canonical supported code/name pair inherited from Catalog; nonblank result-local ref |
| Season | ref, league_ref, start_year, end_year | resolves returned league and equals request years |
| Team | ref, season_ref, name, code | resolves returned season; trimmed nonblank labels; name and code each unique case/trim-insensitively within season |
| Position | ref, code, name | ref equals configured canonical code; name/code pair from injected vocabulary; case/trim-insensitive name and code uniqueness; no source binding required |
| Player | ref, season_ref, display_name, team_ref, position_ref | returned season/current team/current position; trimmed nonblank display name; names may repeat |
| Match | ref, season_ref, status, kickoff_at, home_team_ref, away_team_ref | completed only in returned facts; valid actual instant in requested interval; distinct participating teams in same season |
| Performance | ref, match_ref, player_ref, team_ref, position_ref, minutes_played, counts | one player-match pair; event-time team must participate; player/team/match share season; historical position need not equal current position |

Every ref is opaque, nonblank, safe text and unique within its entity kind for this result. No cross-result stability, database UUID or name-based identity is promised. Relationships use explicit ref fields, not source identifiers. All entity collections are unordered lists; uniqueness is validated before indexing. Identical and conflicting duplicates both fail. Performance refs require no source binding; league/season/team/player/match refs do.

`counts` has exactly these canonical keys, materialized as integer or nil: goals, assists, shots_on_target, tackles, interceptions, saves, goals_conceded, yellow_cards, red_cards. Omitted optional keys and explicit nil normalize to nil. Values are non-negative integers (never boolean/string/float); unknown keys fail. `minutes_played` is required non-negative integer, with no 90/120 ceiling. Positive counts with zero minutes remain valid. The semantic meanings in spec FR-007 align with TASK-020; no aggregate or provider rating can replace a player count.

Catalog facts contain league, season, teams, positions and players. Performance facts additionally contain matches and performances; teams/players/positions form a reference directory, not a complete catalog. Its closure contains historical match participants, performance players/event-time positions and each returned player's current team/position, even if the current team did not play that match. Exclude unused directory records/bindings after eligibility selection. Retained directory members satisfy the same business and relationship rules as catalog members. Candidate match maps carry an extra scope discriminator for eligibility (contracts/provider.md); final Match values do not. This private candidate field establishes no persistent identity.

## Envelope and provenance

| Value | Fields | Rules |
| --- | --- | --- |
| Result | operation, scope, facts, provenance | one complete `{:ok, Result}`; no success alongside error |
| Provenance | provider, retrieved_at, bindings, fixture_id | configured stable safe provider label; UTC retrieval instant separate from kickoff; fixture ID required for fixture-backed results, otherwise nil |
| Binding | provider, kind, league_code, start_year, end_year, ref, source_id | kind is league/season/team/player/match; qualified source key unique; exactly one binding per required entity; no dangling/extra binding |
| Error | category, operation, scope, explanation, retryable, retry_after_ms, field, reference | fixed category/template; optional scope only when valid; optional allowlisted field/safe local ref; never facts/provenance/partial records |

Source IDs are opaque, case-sensitive public-safe strings, nonblank; preserve their bytes instead of lowercasing/trimming a nonblank ID. Same ID may occur in different providers/kinds/scopes; two distinct refs cannot share one qualified source key. Safety validation is separate from identity equality (ADR-0013). Fixture identifiers are stable controlled IDs from contracts/fixtures.md. Retrieval time is sampled after source retrieval and included only after successful validation; no provenance is returned on error.

Error categories/retry semantics are specified in contracts/provider.md. Rate-limit delay is optional positive integer milliseconds; malformed supplied delay fails as invalid-response rather than being guessed or dropped. Retry guidance causes no retries.

## State transitions

`input -> rejected invalid-request` (zero adapter calls), or `validated -> running one deadline -> complete validated success / typed error / timeout`. Running includes all portions plus normalization; no intermediate outcome exists. Deadline has precedence over any outcome not fully ready before it. Terminal state is immutable; cleanup cannot publish a second outcome. Worker crashes become unavailable while still within budget. A later request has independent correlation/state, not a fresh page budget for the old one.

No state transition writes the Catalog/Statistics repositories. TASK-018/TASK-021 establish persistent reconciliation; TASK-020 owns statistical persistence. Current affiliation, historical immutability, token supply, precision and append-only quote/audit rules are unchanged.

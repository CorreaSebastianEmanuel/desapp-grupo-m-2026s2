# Football-Data internal adapter and transport contract

Consumer API and result/error shapes remain exactly those of `specs/016-external-football-provider-contract/contracts/provider.md`. No public application route or permission change. Source requests below are outbound HTTP interfaces and require actual transport runtime evidence.

## Adapter

`FootballMarket.Providers.FootballData` implements the existing `Adapter` callbacks: `provider_label/0` returns `football-data-org`; `read(request, context, state)` returns one existing candidate or typed failure. Capability declaration is catalog/current-season subject to complete evidence; performances and existing historical squads are unsupported. No new consumer request fields/options.

Context retains the absolute deadline/runtime/positions map and gains the private record_retry_not_before function described in ADR-0015; public Adapter signatures and returned map keys do not change. The fixture ID, if present in trusted fixture state, is copied into candidate provenance metadata only. Production state never labels live responses as fixtures.

## Trusted configuration

`config/config.exs` sets `FootballMarket.Providers` provider nil by default and sets FootballData enabled false; all checked-in environments inherit disabled access. Runtime reads `FOOTBALL_DATA_ENABLED` (only exact `true` enables) and `FOOTBALL_DATA_TOKEN`. Unknown enablement strings retain a selected invalid configuration state that returns invalid-request on use; they never enable work or raise at startup. Absence/`false` leaves provider nil. Explicit enablement selects `{FootballData, state}` even if token is missing so valid requests can report authentication-failed. Do not print tokens or entire environment/configuration.

Provide trusted immutable canonical vocabulary `%{"GK" => "Goalkeeper", "DEF" => "Defender", "MID" => "Midfielder", "FWD" => "Forward"}` and initial mapping `%{"Goalkeeper" => "GK", "Defence" => "DEF", "Midfield" => "MID", "Offence" => "FWD"}`. These reproduce existing canonical names without importing seed/Repo modules. Operator extensions are application configuration `position_mapping`, not untrusted environment JSON or request fields. Normalize keys with trim/case-fold once; duplicate normalized keys, unknown targets, blank keys/values, malformed settings or omitted required broad mappings invalidate configuration. Targets must exist with canonical names in context.positions. There is no implicit repair or persistence lookup. Additional documented mappings require explicit configuration and tests; person-specific fine-grained labels do not override supplied squad roles.

State is a dedicated redacted-inspection configuration value containing enabled/token/mapping/transport and safe invalid-state classification, not a raw exception. Transport defaults to `{MintTransport, :live}`. No live base URL, proxy, port, CA-disable, headers or redirect setting is accepted. A test-only `{MintTransport, test_state}` is accepted only under `MIX_ENV=test`/the corresponding compiled test capability: fixed loopback address, ephemeral port, fixture hostname and fixture CA; all other addresses rejected. Recording transport injection is trusted fixture state, never consumer data or live environment configuration.

Precedence: facade consumer validation → no selected source unsupported → facade canonical vocabulary validation → selected adapter enabled check → token missing/blank authentication-failed → remaining non-secret configuration/mapping validation → capability check → source work. Invalid enablement itself returns invalid-request at the enabled check: it is not an enabled source or a silently disabled selection. Other runtime parse errors return invalid-request after token presence for enabled state; facade validation continues winning even when source is disabled/misconfigured. Enabled invalid destination/mapping makes zero outbound attempts. A source-selected disabled adapter returns unsupported-capability. Valid enabled performance requests make zero outbound attempts. No secret is needed for startup/local reads.

## Source retrieval sequence

All requests use encrypted origin `https://api.football-data.org:443` and header `X-Auth-Token` privately. Methods/paths are generated from validated league-code allowlist, integer season year and positive integer resource IDs:

1. `GET /v4/competitions/{league_code}` — discovery.
2. `GET /v4/competitions/{league_code}/teams?season={start_year}` — complete team membership.
3. `GET /v4/teams/{team_id}` — each listed team's current-season squad, sequentially.
4. `GET /v4/persons/{person_id}` — each supplied player, sequentially after that team's squad validation.
5. `GET /v4/competitions/{league_code}` — final discovery, after all portions.

Do not fetch matches/scorers, follow payload URLs or construct paths from arbitrary strings. Reject noninteger, boolean, zero/negative, URL-shaped, path-shaped or secret-containing IDs before their use/binding. Numeric source taxonomy is adapter-specific; generic providers retain opaque source identity rules. No redirect is followed, including same-origin redirects. URL query has only generated season; token never enters a URL.

Discovery requires positive competition/current-season/season IDs, matching competition code and valid start/end dates for every season entry used as scope evidence. Match both years, including calendar-year input. Requested absent season in a valid accessible full discovery is not-found. Requested existing non-current season is unsupported-capability before teams/persons. Current-season identity must resolve to a coherent available-season entry. Malformed/duplicate contradictory discovery, mismatched returned code or malformed current supported scope is invalid-response. Final discovery must match initial competition ID/code, requested-season ID/dates and current-season ID/dates; unrelated matchday/lastUpdated changes do not invalidate it. A rollover fails, without restarting.

The team list must contain an explicit array. Validate all IDs and duplicate evidence; any supplied count, filters.season, competition or season metadata must be well-formed and consistent with discovery/request. Do not invent or require undocumented squad-level season fields. Full team-list semantics plus verified source discovery and running competition identity establish the season under ADR-0014's conservative interpretation. Team detail ID must match list ID; names/tla must be nonblank and agree when provided in both portions. runningCompetitions must contain the verified competition ID/code; wrong/absent membership fails. Team detail squad must be an explicit array, including valid empty. Null, omission or withheld data cannot become empty.

For each squad row, require ID/name/mapped nonblank position. Separate coach/staff fields are ignored, never converted to players. Explicit non-player discriminators in a purported squad row invalidate it; unknown/unmapped roles never become guessed players. Person ID must match squad ID; currentTeam.id must equal the squad team ID. If person running competition evidence is supplied, validate consistency; no fine-position or contract-date inference. Missing/null or different currentTeam fails invalid-response, including a one-sided stale transfer. Person access/missing-resource failures retain their observed error category. Duplicate players within/across teams fail before map construction, even identical rows; no transfer reconciliation.

No pagination is documented for the chosen team collection. Accept only a complete collection; observed truncation/limit/continuation evidence inconsistent with that documented shape is invalid-response, never partial success or a followed arbitrary next URL. If a future documented continuation is required, it needs an explicit contract/fixture update within one unchanged deadline. Every listed team and supplied person must complete before final discovery/candidate validation.

## Private transport port

`FootballData.Transport` exposes `request(route, credential, context, trusted_transport_state)` returning `{:ok, %{status: integer, headers: list, body: binary}}` with private `received_us`/`received_utc` receipt fields for complete failure headers, or a fixed safe transport failure. route is one of the fixed discovery/teams/team/person tagged values above, not a URL. The adapter never returns the transport envelope. Production Mint HTTP/1 runs entirely in the existing worker, with peer verification, hostname verification/SNI and `:public_key.cacerts_get()` trust roots; no verification bypass. Test TLS uses its private fixture CA and verifies fixture hostname.

Once a non-200 status is observed, collect available complete headers for delay handling, close the connection and return that observed status with an empty ignored body; do not wait for/read a failing body. A protocol/body failure after an observed failure status cannot erase its category; unusable headers simply mean no known delay. Before any status, connection failure is unavailable. Truncated/malformed 200 response framing/body is invalid-response rather than being converted to an empty catalog. The transport may report a fixed `invalid_response` failure without exposing protocol details. Deadline exhaustion still wins over all observed statuses if normalized readiness is late.

Connect/write/wait budgets are remaining absolute time, sliced at VM-safe limits for huge budgets; no operation starts after deadline. Close sockets in ordinary terminal paths. The outer worker bound remains authoritative during DNS/connect/handshake and kills owned work on timeout/caller exit. Independent peer-close assertions cover blocked headers/body, failed handshake, early errors, success and caller death. No task/pool/process ownership transfer, automatic retries, quota sleep or background fetch. Test harness readiness is asserted before calls; unavailable harness/listener is a failing check, not skipped evidence.

## Error/status translation

Before reading/parsing error bodies, classify observed status. Preserve category even for unreadable/hostile body. Only successful 200 JSON object exchanges proceed to source validation. Other 2xx statuses/bodyless success are invalid-response for these resources.

| Observation | Category |
| --- | --- |
| 401 or 403 | authentication_failed |
| 404 or 410 | not_found |
| 429 | rate_limited |
| 300–399, including absent/malformed Location | unavailable, no second request |
| 500–599; unexpected connection/DNS/TLS/transport exception | unavailable |
| 400/other 4xx rejecting an already validated translated request; unrecognized status | invalid_response |
| malformed/incomplete/inconsistent 200 body or JSON | invalid_response |
| insufficient normalized readiness budget | timeout, taking TASK-016 precedence |

401/410 and otherwise unspecified statuses are conservative adapter mappings; source-documented 400/403/404/429 semantics are linked in research.md. Source message text never selects a category. Candidate failures contain only category and optional retry_after_ms; consumer operation/scope/templates/retryable are added by the existing boundary. No partial facts/provenance, raw statuses, headers, exceptions or source messages escape.

For 429 only: prefer a single valid `Retry-After` (RFC 9110 integer delta seconds or HTTP-date); otherwise consider a single valid `X-RequestCounter-Reset` integer seconds. Header names are case-insensitive. Ambiguous repeated values in either delay family make delay unknown. Malformed/zero/negative delta is unknown; no float/sign/coercion. Capture received_us and received_utc when complete failure headers become available, before connection close, parsing or normalization; retain the original pair through transport failures after the status. RecordingTransport models the same event. Absent/incoherent receipt fields yield unknown delay, never a fresh parser-time anchor. Translate positive seconds into expiry_us = received_us + seconds * 1000000. For HTTP-date, expiry_us = received_us + DateTime.diff(header_instant, received_utc, :microsecond). A documented date need not be paired with or adjusted by a vendor Date header. Record only valid expiry via the private context function, then emit the unchanged candidate map. Runner carries only this integer privately through normalization and recomputes public retry_after_ms at the complete ready_us using div(max(expiry_us - ready_us, 0), 1000); non-positive/sub-ms becomes nil, category stays rate_limited. Parsing and subsequent normalization must both count. No stored duration may renew the wait. Deadline precedence applies before refinement. Unregistered legacy adapters retain their original durations and behavior; malformed failure keys remain invalid-response. A malformed preferred header may fall back only to an independently valid unambiguous reset header. `X-RequestsAvailable` is never a delay. No header/counter enters the error, no guessed zero/default wait and no retry is executed. Tests control UTC and elapsed time independently.

## Private readiness seam and guard boundary

ADR-0015 owns the sole authorized Runner deviation. record_retry_not_before is worker-local, scoped by a fresh reference and cleaned with try/after even for synchronous fixture execution. It accepts an integer only; adapters not using it behave exactly as before. Internal outcome wrapping does not change Runtime or expose expiry; Runner applies it only to validated rate_limited outcomes after strict readiness acceptance. Public consumer fields, Error.failure allowlist and Adapter return shape remain unchanged.

Guard changes are confined to runner.ex AST deltas in run/4 and the private with_retry_window/1 and refine_retry_delay/3 helpers plus its exact statistics allowance; independent semantic guards preserve deadline/cancel/close and other adapters. All other protected bytes and fixture fingerprints stay asserted.

## Diagnostics

No logging of requests/responses/state/exceptions; never enable Mint/TLS tracing. Parse failure paths catch raw exception terms inside the worker before crash reports can emit secret data. Dedicated state Inspect redacts token and transport-sensitive fields. Fixtures capture all application diagnostics under adversarial responses, exceptions, redirects and IDs. Numeric-ID validation plus explicit known-token exclusion protects provenance; names/codes also reject known token containment rather than manufacture replacements. No global Logger suppression or weakened assertions is allowed.

# Internal provider contract

This document declares Elixir operations and an adapter port, not HTTP routes. No endpoint or permission changes are in scope. Fields/entities are owned by [data-model.md](../data-model.md).

## Consumer operations

`FootballMarket.Providers.catalog(request, options \\ [])`

`FootballMarket.Providers.performances(request, options \\ [])`

Both return `{:ok, %FootballMarket.Providers.Result{}}` or `{:error, %FootballMarket.Providers.Error{}}`. They never return partial facts, raw payloads or vendor exceptions. Provider selection is a trusted internal option/configuration rather than a request fact. No source-specific branch is needed by consumers.

Request is a map with all atom keys or all equivalent string keys. Mixed key styles, non-map input and unsupported fields fail safely without atom creation. Catalog allowlist: `league_code`, `start_year`, `end_year`, `timeout_ms`. Performances allowlist adds `from`, `to`. First three are required. Omitted timeout becomes 5000; explicit nil/boolean/zero/negative/fraction/string is invalid. Bounds omitted or nil are unbounded independently. Scope normalization: trim and uppercase league code; integer season years with end=start or end=start+1; explicit instants and inclusive ordered bounds using ADR-0011. Catalog bounds are unknown fields, even when nil. There is no implicit season-date restriction.

Example normalized scope: `%{league_code: "PL", start_year: 2025, end_year: 2026}`. Performance scope includes `from: nil, to: nil` unless normalized bounds are present. Timeout/configuration are outside football scope.

Result has operation, normalized scope, facts and provenance. Facts have league/season plus teams/positions/players and, for performances, matches/performances. Positions reference configured codes. Current and event-time affiliations use different explicit fields. Empty success still includes requested league/season and their bindings; a nonempty position vocabulary does not require unused positions to appear. Data-model.md defines every field, including all nine unknown-or-integer count keys.

## Adapter port and candidate

`FootballMarket.Providers.Adapter` declares `provider_label/0` and `read(request, context, adapter_state)` callbacks. Labels are stable internal safe identifiers, not raw vendor diagnostic strings. Invoke both callbacks inside the deadline worker; even a blocking label callback cannot extend the budget. An unsafe returned label yields invalid-response without reflecting it. Trusted options select `{adapter_module, adapter_state}`, immutable configured `%{position_code => canonical_name}` vocabulary, and `{runtime_module, runtime_state}`. Missing source/capability returns unsupported-capability. Invalid internal vocabulary is detected before adapter work and returns invalid-request with the safe field `:positions`; it is not silently repaired or fetched from Repo.

`read/3` returns one of:

- `{:ok, %{operation: operation, scope: scope, facts: candidate_facts, bindings: bindings, fixture_id: optional_fixture_id}}`.
- `{:error, %{category: allowed_category, retry_after_ms: optional_delay}}`.

Candidate dictionaries are lists, preserving duplicate evidence. Scope/operation must match the validated request. Candidate facts use the field names in data-model.md; each candidate match additionally carries a required `scope` discriminator map (league_code/start_year/end_year), removed from the final Match DTO. This allows exclusion of raw bulk-source matches without requiring their unused relationships to resolve. Status may also be scheduled/live/postponed/abandoned for eligibility filtering. Bindings identify kind/ref/source_id; the boundary adds the controlled provider/request qualification. No raw exception, message, header, status code, URL or other diagnostic slot is accepted. Unexpected envelope keys or retained fact keys are invalid-response. Source-specific unrelated fields may be ignored by the adapter before candidate creation; unsupported metrics in retained performances are never silently ignored. Unused facts of provably excluded records follow the filtering rules below.

Concrete source field mapping/HTTP configuration is TASK-017. Test adapters here translate only synthetic fixture shapes. Pagination is internal; an adapter aggregates every required portion under `context.deadline_us` and never yields a success page. No retries, backoff, fallback, reconciliation, persistence, callback publication or detached work. The adapter must respect cancellation and own any source resource cleanup within the call. The boundary also bounds blocking adapters with a worker, rather than trusting cooperation alone.

## Eligibility sequence

1. Validate top-level operation/requested scope/league/season. A mismatched requested envelope is invalid-response.
2. Inspect every match's nonblank result ref and league/season/status discriminators without rewriting malformed values; refs are needed to route performances and detect a conflicting declaration of a retained ref. Scope uses the same valid league/year rules as requests. Invalid or missing discriminator is invalid-response. A demonstrably different supported league/season is irrelevant and excluded.
3. A recognized non-completed status is excluded, without requiring unused kickoff/metrics/participation. For in-scope completed matches require an unambiguous kickoff, then exclude outside inclusive bounds. Unknown status or undecidable required kickoff fails. Endpoints differing by one microsecond and offset-equivalent instants have exact oracles.
4. Select supplied performances for eligible match refs. A performance referring to no declared match cannot be proven irrelevant and fails. Do not invent performances for selected matches. Excluded matches' performances are excluded without validating unused counts.
5. Compute transitive reference closure from retained matches/performances, including players' current affiliations. Preserve all duplicate declarations for retained refs, and validate all retained fields/edges/bindings. Discard bindings of declared excluded entities; a binding with no declared target fails. Final bindings cover exactly the retained league/season/team/player/match directory. Reject retained cross-season links, unresolved refs, duplicate entity/source/business keys, repeated player-match pairs and invalid participating team/position/metric facts. Do not filter invalid retained records.

Catalog has no eligibility filtering: validate the entire candidate. Performance directory entries used only by excluded matches are omitted; their unused fact fields do not poison a narrow result. Unresolvable references needed to decide closure fail. A duplicate match declaration for an eligible ref is invalid even if one duplicate says scheduled; no selective winning record.

## Error contract

| Category (Elixir atom) | Safe explanation template | retryable |
| --- | --- | --- |
| invalid_request | Request input is invalid. | false |
| unsupported_capability | Provider does not support this operation or scope. | false |
| not_found | Requested league season was not found. | false |
| authentication_failed | Provider access must be corrected. | false |
| rate_limited | Provider rate limit prevents completion. | true |
| unavailable | Provider is temporarily unavailable. | true |
| timeout | Provider request deadline expired. | true |
| invalid_response | Provider facts violate the contract. | false |

Atoms correspond to spec's hyphenated names. Envelope fields: category, controlled operation, valid normalized scope or nil, template explanation, retryable, retry_after_ms or nil, known field or nil, locally safe reference or nil. Unknown input names report field `:request`; invalid league/season/bounds/timeout use known fields without their raw values. Invalid timeout errors retain the independently validated normalized scope, including valid performance bounds; malformed scope is omitted. No error has facts or provenance. Only rate-limited may carry a positive integer delay; omitted/nil stays nil. Unknown categories, extra diagnostic fields or malformed delays are invalid-response. Unexpected exception/exit before deadline becomes unavailable without reflection; invalid candidate validation becomes invalid-response. Deadline exhaustion wins if the final normalized error is not ready in time.

The safe-field vocabulary is request, league_code, start_year, end_year, from, to, interval, timeout_ms, positions, operation, scope, league, season, teams, players, matches, performances, provenance, bindings, minutes_played and the nine count names. Diagnostics never expose raw input values or source refs. Optional reference can be omitted consistently.

Public-safe source/ref text excludes invalid UTF-8, control characters, recognizable URL/authorization/credential expressions and blank strings. Source IDs remain case-sensitive/opaque otherwise; there is no guessed numeric taxonomy. Do not rewrite unsafe IDs into a successful identity. Sentinel tests include URL userinfo and token query strings, Bearer/Basic/Authorization content, exceptions, hostile unknown keys and source identifiers. Concrete adapters remain responsible for classifying identifiers as public-safe: generic validation cannot discover every arbitrary secret.

## Time and runtime port

Runtime's internal interface is `now_us(state)`, `utc_now(state)`, `launch(fun, deadline_us, state)`, `await(handle, deadline_us, state)`, `cancel(handle, state)` and `close(handle, state)`. Await reports a correlated ready event (outcome/readiness_us), timeout or safe worker-failure signal. Runner owns semantic deadline calculation, readiness comparison and terminal choice; a fake runtime must not replace those policy decisions. Production launch uses a short-lived coordinator to monitor caller death and cancel the retrieval worker even when it cannot process messages. Production waiting is bounded by the absolute deadline. Positive integer timeout overrides have no ceiling: both caller and coordinator use VM-safe receive slices, recalculating remaining time against that unchanged deadline after each slice. Fixed wall time makes offline provenance reproducible; elapsed time controls deadlines independently.

Start budget immediately before provider work. All source portions plus validation consume it. Readiness denotes a complete normalized outcome, not raw transport completion. Compare readiness strictly `< deadline`; equality times out. On deadline select one timeout, cancel/disconnect replies without waiting for further provider work, and prevent late data from reaching this or later calls. Cleanup is required on every terminal path and caller exit. Exact deterministic tests cover completion/validation/error events around deadline; short real tests prove blocked work cannot hold the caller and is cancelled. OS scheduling is not a hard realtime guarantee; it does not authorize extra provider work after deadline.

## Reuse by later adapters

`FootballMarket.ProviderContractCase.assert_contract!(adapter, fixture_id)` executes this contract against explicit source example/expected outcome metadata. Later adapters supply deterministic source stubs for the same examples, with capability expectations declared rather than faked. Consumption checks stay source-independent. See fixtures.md; no fixture correspondence or source mapping enters persistent reconciliation.

The supplied fixture adapters expose the test-only `source_key/0` (`:a` or `:b`) and `example_ids/0` for inventory/correspondence selection. These are not production Adapter callbacks. To reuse `ProviderContractCase` with another deterministic source stub, declare its example keys, correspondence and independent expected bindings in the inventory; do not add source interpretation to consumer assertions. The facade has no production fixture or position-vocabulary default: configure `provider` and immutable `positions` internally or pass those trusted options explicitly.

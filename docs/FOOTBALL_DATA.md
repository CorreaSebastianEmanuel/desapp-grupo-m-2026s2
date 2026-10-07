# Football-Data.org internal source

Ordinary development, tests and production disable this source. Startup and local catalog/statistics reads require no provider credential and start no retrieval. This adapter only supplies complete current-season catalogs through `FootballMarket.Providers.catalog/2`; it never imports or writes them. Historical squads and all `performances/2` requests return unsupported-capability. They cannot provide CP2 statistics-to-quote ingestion.

An operator explicitly selects the source with `FOOTBALL_DATA_ENABLED=true` and injects `FOOTBALL_DATA_TOKEN=<operator-injected-secret>` through the deployment's secret environment. Keep the token outside tracked files, command arguments, URLs and logs. Unset/`false` keeps the provider unselected. Other enablement strings produce invalid-request on use, without startup exceptions. Enabled access with absent/blank credentials produces authentication-failed; local reads remain available.

Trusted non-secret configuration contains immutable positions `GK` Goalkeeper, `DEF` Defender, `MID` Midfielder and `FWD` Forward. The application `position_mapping` setting maps Goalkeeper → GK, Defence → DEF, Midfield → MID and Offence → FWD, trimming labels and matching without case sensitivity. All four mappings are required; extensions must be explicit and tested against canonical vocabulary. No vocabulary is fetched from persistence. No environment JSON or consumer field changes these settings.

The live service is fixed to verified HTTPS `api.football-data.org:443`. The token travels only in `X-Auth-Token`. There is no live URL, proxy, custom port, insecure TLS, redirect, retry, backoff or fallback option. Loopback transport injection exists only in compiled test capability. No public endpoint or scheduled ingestion invokes the adapter.

Use the ordinary internal request, for example `%{league_code: "PL", start_year: 2026, end_year: 2027}`. Supported leagues are PL, BL1, PD, SA and FL1 when source access and facts provide complete evidence. Both years must match discovery. Existing historical seasons cannot use current squads. Person current-team evidence corroborates every squad affiliation; discovery brackets collection to detect rollover. These checks do not guarantee an atomic or fresh roster snapshot.

A complete request costs `3 + T + P` source calls: discovery, teams, each team, each person, final discovery. A 20-team/500-player example requires 523 calls. Free-tier quota may fail long before completion; this adapter neither waits nor upgrades subscriptions. The shared default deadline is 5,000 milliseconds. Internal callers may supply any positive whole-number `timeout_ms`, including very large values. All portions and validation share that deadline, and readiness must be strictly before it. No successful fixture promises live completion within the budget or subscription coverage.

Safe errors contain operation/scope, category and retry guidance, with no source body, status, message, credential or partial facts:

| Category | Operator action |
| --- | --- |
| invalid-request | Correct consumer input or trusted configuration. |
| authentication-failed | Correct credentials/subscription access before retrying. |
| invalid-response | Correct source facts or adapter translation; do not ingest partial records. |
| not-found | Confirm requested scope/resource exists; unchanged scope does not merit retry. |
| unsupported-capability | Choose a later specified source/capability; unchanged requests cannot succeed. |
| rate-limited | A later caller may retry; respect a known positive `retry_after_ms`, otherwise delay is unknown. |
| unavailable | A later caller may retry connectivity/service failures; redirects remain refused. |
| timeout | A later caller may retry with an appropriate whole-request budget. |

A known rate-limit wait stays anchored to the original source-header receipt. `retry_after_ms` reports the whole milliseconds still remaining when the complete normalized outcome is ready; parsing and normalization consume that wait. An expired or sub-millisecond remainder becomes unknown, preserving rate-limited. Later wall-clock changes cannot renew it.

Only rate-limited, unavailable and timeout are retry eligible. Retry eligibility never performs work within this call. No source message interpretation is needed.

Offline acceptance and independent QA commands are in [the feature quickstart](../specs/017-football-data-api-adapter/quickstart.md). The synthetic fixture suites require no account, external services or live network; actual transport checks run a private ready-checked loopback TLS listener. Application regression/isolation checks use the existing local PostgreSQL/Redis only.

An optional live smoke is operator-only: explicitly enable and inject the token, then invoke the existing internal Providers API for a verified accessible current season. Do not print configured state, token, transport exchanges or raw exceptions. Disable afterward. A live smoke is neither an acceptance prerequisite nor a startup action; access, quota, latency or ambiguous affiliations can still refuse the request.

# Offline acceptance inventory

Implement synthetic v4-shaped exchanges in `test/fixtures/football_data/exchanges.exs`, explicit independent expected outcomes/bindings in `expected.exs`, and stable metadata in `cases.exs`. Cases declare request/configuration, exchange sequence, clock events, source-to-result correspondence, expected outbound count and capabilities. No expected value is computed by adapter/validator/translator. Small readable bases/overrides are permitted; expanded cases remain inspectable and independent of expectations.

Exercise actual `FootballData` through `Providers`, not a fake adapter. RecordingTransport replaces only the transport port and asserts method, route, fixed destination and token placement before responding. Reuse provider-neutral `FactOracle.assert_facts!` and explicit correspondence/binding expectations; new ContractCase asserts common envelopes/retry semantics without vendor conditionals. Leave TASK-016's four files, 217 cases, fingerprints, bootstrap and consumer helper unchanged. Runner alone has the ADR-0015 constrained AST-delta exception; Error/Runtime/facade and every other protected byte guard remain unchanged. Its complete offline suite remains a required check.

Every stable prefix below must expand into nonempty cases with explicit outcomes. Tests assert inventory completeness, metadata-to-test coverage, deterministic provenance and two equal executions; merely mentioning a requirement is insufficient.

| Stable prefix | Required examples | Spec numbered scenarios |
| --- | --- | --- |
| FD-C01 | Five separate PL/BL1/PD/SA/FL1 valid current seasons, complete facts/bindings; extra unrelated fields discarded | US1.1, US1.2; US4.2 |
| FD-C02 | Explicit empty teams; nonempty teams with empty squads; missing/null/denied/malformed collection distinctions | US1.3 |
| FD-C03 | Multiple team/person portions succeed; later failure gives one error and no partial data | US1.4 |
| FD-C04 | Distinct same-name players; duplicate IDs within/across portions; missing names/tla/positions; unmapped labels; trimmed/case-folded four-role mapping; unknown extensions; non-player sections/rows | US1.5 |
| FD-C05 | One-sided stale transfer (person names another team); cross-team duplicates; null/absent currentTeam; changed discovery; conflicting running competition/team/list/person IDs; malformed dates and calendar-year discovery match/no match | US1.1, US1.5; US3.2 |
| FD-S01 | All default environment configs disable selection; startup without provider credential; local catalog/statistics reads; no selected provider; selected disabled state | US2.1 |
| FD-S02 | Enabled missing/blank token, catalog and performance; zero outbound attempts | US2.2 |
| FD-S03 | Token only in approved destination header; outputs/log capture/Inspect/provenance clean; synthetic placeholders only | US2.3; US4.3 |
| FD-S04 | Invalid config/vocabulary/mapping, unsafe origin/port/scheme/proxy/test override; same/cross-origin redirects and hostile IDs/URLs/exceptions; no forwarding or secret diagnostics | US2.4; US4.3 |
| FD-S05 | Invalid consumer maps/key styles/fields/scopes/bounds/timeouts under every selected/disabled/invalid state; precedence, zero work and invalid-timeout scope retained | US2.5 |
| FD-E01 | Proven absent accessible season versus denied discovery; exact both-year matching; source resource 404; no latest substitution | US3.1 |
| FD-E02 | Existing historical season refused before roster calls; source current-season match required | US3.2; US4.2 |
| FD-E03 | Enabled/configured valid performance request unsupported with zero source work; no fabricated empty/minutes/scorers | US3.3; US4.2 |
| FD-E04 | Each status in contract, no-body/hostile error bodies, every safe retry boolean; transport/DNS/TLS exceptions; malformed 200 | US3.4 |
| FD-E05 | Positive/missing/malformed/zero/negative/expired/delayed Retry-After/reset; HTTP-date, mixed header case, duplicate/conflicting headers, fallback, quota counters excluded; full normalized readiness matrix below | US3.4 |
| FD-E06 | 20 teams/500 players synthetic complete exchange (523 calls), quota exhaustion at call 11 after earlier validated portions; no sleep/retry/partial publication; fail-fast remaining calls | US1.4; US3.4 |
| FD-D01 | Default/custom/4294968000/10000000000000 ms, readiness one microsecond before/at/after deadline for success/error; translation/whole validation consumes budget | US3.5 |
| FD-D02 | Discovery/late team/person/final discovery share budget; subsequent portion never starts after expiry; caller exit; blocked real TLS body/header/handshake; independent peer closure and no late mailbox/outcome | US3.5 |
| FD-I01 | Exact Catalog/Statistics tables and read results unchanged after actual adapter success, every error category and cancellation; zero provider calls during local reads | US3.6; US2.1 |
| FD-O01 | Inventory executed twice without external services/live requests/credentials, identical facts/errors/provenance, strict nonempty selectors; original contract preserved | US4.1, US4.2 |

The spec has no named AC identifiers; USx.y labels reference its numbered scenarios without altering spec.md. verification.json covers all canonical FR/SC identifiers exactly and points to suites asserting these stable prefixes.

## B1 complete-boundary expiry matrix

`retry_expiry_test.exs` adds source-independent oracles through Providers; never calculate expectations with Errors/Runner helpers. Extend existing FD-E05 coverage without rewriting TASK-016 fixtures. Every delta-seconds, HTTP-date and reset format covers no processing delay, parsing-only time, post-parsing normalization-only time and both phases. Fix receipt UTC independently of monotonic time; add nonzero receipt origin and wall-clock-change cases to prove no re-anchoring. For a two-second source wait, total readiness offsets 0/1/2/3 seconds yield 2000/1000/nil/nil; include a positive-but-overstated result and less than one whole ms remaining. All finish inside an appropriate request deadline; add before/at/after-deadline precedence separately.

Preserve original /tmp QA probes unchanged and port their assertions into tracked tests/bootstrap selectors; clean CI must not rely on temporary files. Test repeated/synchronous requests, record-then-success/non-rate/invalid failure/exception, missing or incoherent receipt data, unknown/malformed/expired header data and unregistered legacy rate limits. Assert exact public field allowlist, no expiry/header leakage, no cross-call metadata and unchanged 217 fixture fingerprints. Pauses are test-only controlled clocks; production never waits for retry.

Real HTTPS tests repeat delta/date/reset positive and expired outcomes with time consumed during parsing and after it. Preserve the QA Retry-After:1 plus 1200-ms normalization-pause assertion and independently observed closure. Since readiness needs bounded scheduling tolerance on real time, fix exact expected values in deterministic tests and assert positive upper/lower bounds anchored to observed receipt/readiness for real waits; expired must be exactly nil. Do not weaken the original QA assertions.

## Real transport evidence

`transport_runtime_test.exs` drives the actual MintTransport and adapter/facade against a ready ephemeral TLS loopback listener with a synthetic CA, hostname and token. Assert HTTP methods/paths, secret header present exactly at the authorized listener, status and header handling, parsed complete expected result or category, and redirect target receiving zero requests. Exercise each outbound route kind, failed identity verification, duplicate/unsafe config, malformed/hostile bodies and early status rejection. Observe socket closure directly on success/failure/timeout/caller death; fixture worker termination alone is insufficient. Bound waits and fail unavailable listeners. Tests never open a live destination; external service absence cannot be silently skipped.

Pure fixture selectors cover catalog, configuration, errors, deadline, fixtures and safety without startup. TLS runtime requires only local sockets/dependencies, not PostgreSQL/Redis. Isolation/profile regressions separately require existing local services and service preflight. Module tags remain exactly one of unit/integration; bootstrap files alone enter ignore filters.

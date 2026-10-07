# TASK-017 validation guide

Run from repository root with `.tool-versions` tools. Behavioral commands below are implementation-owner acceptance instructions. Existing implementation is retained; B1 correction and fresh acceptance remain pending after authoritative feedback 1. Internal formats and scenarios are owned by contracts/football-data.md, contracts/fixtures.md and data-model.md.

## Prerequisites

1. Elixir 1.20.3 / OTP 29.0.6; dependency tree installed with `mix deps.get --locked` after implementation updates mix.lock for Mint.
2. Compile without starting the application: `MIX_ENV=test mix compile --warnings-as-errors`.
3. Fixture-only checks need no account, internet, PostgreSQL or Redis. Real transport checks need only loopback TLS sockets and synthetic certificates from the test harness.
4. Application/profile checks require existing PostgreSQL/Redis (`sh scripts/local_services.sh start`), Node 24, installed `tools/openapi` packages and the existing Playwright browser prerequisites described in specs/014-cp1-test-coverage-profiles/quickstart.md. No new service is introduced.

## Offline acceptance

Use the executable manifest via `python3 scripts/agentflow_check.py CHECK_ID` for canonical receipts. Individual debugging commands:

```sh
elixir test/provider_contract_offline.exs all
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs catalog
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs configuration
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs errors
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs retry-expiry
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs deadline
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs safety
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs fixtures
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs all
MIX_ENV=test mix run --no-start --no-compile test/football_data_offline.exs transport-runtime
```

Expected: nonzero test counts and zero failures; suite selector mistakes fail. The fixtures selector executes every case twice with controlled UTC/elapsed time, equal outcomes/bindings and zero live requests. Original 217 provider cases/fingerprints remain unchanged. All five league fixtures preserve supplied players, scope and canonical roles. Historical/performance requests refuse honestly; partial, malformed, stale-transfer and rollover examples fail with no earlier facts. Pre-work rejection makes zero transport attempts; security captures contain no sentinel. Huge positive timeouts and invalid-timeout scope regressions persist.

transport-runtime starts its own bounded-ready local TLS listener, verifies server identity and asserts requests/status/headers/complete bodies through real Mint. It fails if readiness or peer-close evidence is missing. Same/cross-origin redirects receive no second request; TLS trust/hostname failures yield unavailable. No external service or public application HTTP request is needed.

## B1 reproduction and corrected acceptance

The new retry-expiry selector ports the independent controlled-time QA assertions into tracked tests. For Retry-After:2, complete readiness at 1/2/3 seconds must yield 1000/nil/nil. Its delta/date/reset matrix separately consumes time during parsing and after it, checks positive overstated and expired waits, unknown receipt evidence and legacy adapter equality. transport-runtime includes real HTTPS expiry and peer-close assertions. See ADR-0015 and contracts/fixtures.md; parser-only tests cannot prove FR-011.

Preserve both original QA scripts. After loading existing test support through Mix, rerun them unchanged when present:

```sh
MIX_ENV=test mix run --no-start --no-compile /tmp/task017-independent-qa/delay-acceptance.exs
MIX_ENV=test mix run --no-start --no-compile /tmp/task017-independent-qa/delay-http.exs
```

Expected after correction: zero failures, exact deterministic expected waits and nil for the real 1200-ms pause. These workspace probes supplement the portable manifest tests; their absence in a clean checkout cannot replace or skip tracked assertions. Their current prior failures are QA evidence, not fresh passing receipts.

## Local state and regression

```sh
MIX_ENV=test mix test.prepare
MIX_ENV=test mix infrastructure.verify
MIX_ENV=test mix test test/football_market/providers/football_data/isolation_test.exs --warnings-as-errors
MIX_ENV=test mix test test/football_market/providers/football_data/scope_test.exs test/football_market/providers/scope_test.exs test/football_market/statistics/scope_test.exs --warnings-as-errors
MIX_ENV=test mix test --include performance --warnings-as-errors
sh scripts/test_profile.sh unit
sh scripts/test_profile.sh integration
```

Expected: PostgreSQL migration probe and Redis PONG; exact catalog/statistics state and read equality after success/error/cancellation; no provider calls from startup/reads; unchanged layer/financial invariants and all regressions passing. Unavailable services fail rather than skip.

## Final owner evidence before QA

Finish source, operator documentation, task descriptions and develop handoff; stage new files for the existing coverage working-tree snapshot without committing/publishing. Receipt paths are ignored by this feature's .gitignore. Then run every verification.json check via agentflow_check.py, including toolchain, formatting, compile, preflight, all offline selectors, actual TLS runtime, isolation/scope, full regressions, both profiles and `coverage` (`sh scripts/coverage_report.sh`). Record successful task checkboxes only after execution. Any source/canonical change requires fresh affected receipts; readiness conservatively requires all receipts from the final source set.

Run `python3 scripts/workflow_artifact_probe.py develop --readiness` only after all non-gate tasks are complete. QA independently reruns all manifest checks and challenges the expectation mapping; final review consumes fresh evidence and covers residual risks. Their reports must end `Verdict: PASS`.

## Explicit operator use

The implementation adds docs/FOOTBALL_DATA.md. Runtime enablement requires `FOOTBALL_DATA_ENABLED=true` and secret injection for `FOOTBALL_DATA_TOKEN=<operator-injected-secret>` outside tracked files; never echo it or put it in a command argument/URL. Invoke only the existing internal Providers API. Keep unset/false for ordinary development/tests/application use. Initial role mapping and canonical vocabulary are trusted non-secret config.

No automated live smoke is an acceptance prerequisite. An optional operator-only call may use an accessible current league season after explicit enablement, but source access/quota/latency/affiliation evidence can still refuse it. Correct credentials/config/source facts for nonretryable failures; retryable is advice to a later caller, not work done by this adapter. Existing historical seasons and performance are unsupported. This evidence cannot certify CP2 statistics-to-quote ingestion.

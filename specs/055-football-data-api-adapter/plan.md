# Implementation Plan: Football Data API Adapter

**Branch**: `017-football-data-api-adapter` | **Date**: 2026-10-06 | **Spec**: [spec.md](spec.md)

**Input**: `specs/055-football-data-api-adapter/spec.md`; TASK-017, CP2, dependency TASK-016.

## Summary

Add a read-only Football-Data.org adapter behind the unchanged `Providers.catalog/2` and `Providers.performances/2` boundary. Trusted configuration selects it only after explicit enablement. Complete current-season catalogs require documented scope evidence and per-player current-team corroboration. Historical/performance limits remain explicit refusals. One worker owns sequential HTTPS collection, translation and whole-result validation under the existing absolute deadline. Deterministic vendor-shaped fixtures and real loopback TLS checks prove compatibility and credential containment without an account. Feedback 1 adds a private source-anchored retry expiry seam to prevent stale waits after complete normalization; settled product/source decisions remain unchanged.

## Technical Context

**Language/Version**: Elixir 1.20.3 / Erlang OTP 29.0.6, per `.tool-versions`.

**Primary Dependencies**: Existing provider boundary, Jason, ExUnit; add direct Mint `~> 1.11` and lock its dependency tree during implementation. Existing Phoenix/Ecto/PostgreSQL/Redis remain the established stack (`docs/ARCHITECTURE.md`). No new service/client pool.

**Storage**: None in adapter. PostgreSQL/Redis used only by application isolation/regression checks. No raw payload/provenance persistence.

**Testing**: ExUnit, provider-neutral FactOracle, independent expected data, controlled provider runtime, test-only recording transport and real Mint against an ephemeral loopback TLS server. Pure fixture bootstrap uses `mix run --no-start --no-compile` to load dependencies without starting the application, DB or Redis; existing `elixir test/provider_contract_offline.exs all` stays unchanged.

**Target Platform**: Existing Linux OTP application.

**Project Type**: Internal external-adapter module in the modular monolith; no new public HTTP interface.

**Performance Goals**: Existing default 5,000 ms deadline; any positive integer override accepted without a ceiling; only normalized readiness strictly before deadline succeeds. Complete request cost `3 + T + P`; no latency guarantee or subscription feasibility claim.

**Constraints**: Offline deterministic acceptance; fixed HTTPS destination and identity verification; no redirects, automatic retries, waiting, fallback, persistence, partial success or detached resources. Fixtures use real documented shapes and synthetic values only.

**Scale/Scope**: Five specified leagues; current-season catalogs conditionally supported; existing historical scopes and all performances explicitly unsupported. All supplied players retained or whole request fails.

## Constitution Check

| Principle/gate | Before research | After design |
| --- | --- | --- |
| I: spec before implementation | PASS: spec, challenge, product decision and authoritative TASK-017 feedback 1 loaded | PASS: B1 correction stays within FR-011/015; every FR/SC and numbered scenario linked to checks/tasks |
| II: domain integrity | PASS: read-only external boundary | PASS: local-read independence tested; no supply, money, trading, audit or quote changes; no invented valuation inputs |
| III: modular simplicity | PASS: reuse ADR-0013 and existing contexts | PASS: worker-owned transport only; bounded Mint addition and evidence interpretation recorded in ADR-0014; narrow internal readiness seam recorded in ADR-0015 |
| IV: evidence quality | PASS: tests required before each behavioral increment | PASS: synthetic independent oracles, actual transport TLS assertions, scope checks, service preflight, profiles and coverage planned |
| V: independent verification | PASS: approved product decisions authoritative | PASS: implementation receipts required before fresh QA; only QA/final review tasks deferred; both terminal PASS verdicts required |

These are architecture assessments, not claims that future code checks ran. No unresolved clarification or unjustified gate failure. TASK-016 feedback remains authoritative: preserve huge accepted timeouts, invalid-timeout scope, all 217 fixture cases/fingerprints and shallow-checkout portability.

## Project Structure

### Documentation (this feature)

```text
specs/055-football-data-api-adapter/
  spec.md, plan.md, research.md, data-model.md, quickstart.md, tasks.md
  contracts/football-data.md, contracts/fixtures.md
  verification.json, .gitignore
  handoffs/architecture.md, handoffs/tasks.md, handoffs/develop.md
  qa-report.md, handoffs/qa.md, review-report.md, handoffs/review.md
docs/adr/0014-football-data-evidence-and-owned-transport.md
docs/adr/0015-source-anchored-retry-expiry.md
docs/FOOTBALL_DATA.md
```

### Source Code (repository root)

```text
lib/football_market/providers/runner.ex # only ADR-0015 private expiry seam
lib/football_market/providers/football_data.ex
lib/football_market/providers/football_data/
  configuration.ex, scope.ex, translator.ex, errors.ex, transport.ex, mint_transport.ex
config/config.exs, config/runtime.exs
mix.exs, mix.lock
test/football_data_offline.exs
test/support/providers/football_data/
  fixture_data.ex, recording_transport.ex, contract_case.ex, tls_server.ex
test/fixtures/football_data/
  exchanges.exs, expected.exs, cases.exs
test/football_market/providers/football_data/
  configuration_test.exs, catalog_test.exs, scope_evidence_test.exs
  security_test.exs, errors_test.exs, retry_expiry_test.exs, deadline_test.exs
  fixtures_test.exs, isolation_test.exs, scope_test.exs, transport_runtime_test.exs
test/football_market/providers/scope_test.exs
test/football_market/statistics/scope_test.exs
```

**Structure Decision**: All production changes belong under Providers. Feedback 1 supersedes the previous prohibition on Runner changes only for the private expiry seam in ADR-0015. Runner.run/4 plus private with_retry_window/1 and refine_retry_delay/3 helpers may carry/refine expiry metadata; no public signature changes. Error, facade, DTOs, Adapter behaviour, Request, Runtime, Validator, domain contexts, controllers, application startup/supervision, seeds and migrations remain unchanged. Config defaults remain source-unselected; runtime opt-in supplies immutable canonical vocabulary, explicit broad-role mapping and adapter state. No Repo lookup. Exact test-only guard updates allow this feature's named paths/dependency/bootstrap changes while retaining all old assertions, pure boundary checks and fixture fingerprints. TASK-016 bootstrap/helper/fixtures remain untouched. Runner alone replaces its byte equality guard with a constrained AST-delta guard plus independent semantic tests; every other protected boundary file retains byte equality. The statistics guard adds only runner.ex to its TASK-017 production allowance. See ADR-0015 for exact constraints. New fixture/bootstrap paths alone enter Mix ignore filters; actual test files remain discoverable and each has exactly one existing unit/integration module tag.

## Phase 0: Focused Research

[research.md](research.md) resolves evidence, quota, concrete HTTP lifecycle and status/delay questions. Existing architecture/ADRs own all other choices. [ADR-0014](../../docs/adr/0014-football-data-evidence-and-owned-transport.md) records durable extensions and rejected alternatives. No live source call or research agent is needed.

## Phase 1: Design and Implementation Boundary

### Configuration and precedence

The facade continues validating consumer requests and canonical vocabulary exactly as TASK-016. Adapter validation then checks explicit enabled state, token presence, non-secret configuration and role mappings before capability/source work. Disabled runtime configuration leaves provider selection nil; an explicitly selected disabled adapter refuses as unsupported-capability. Missing/blank credentials with an enabled valid consumer request return authentication-failed, including performance requests; malformed non-secret config returns invalid-request after credential presence. Valid performance requests return unsupported-capability with zero transport calls. No operator misconfiguration raises during application startup. Exact settings/interfaces in contracts/football-data.md.

### Evidence and translation

Source collection follows ADR-0014 and data-model.md. Discovery matches both season years and rejects malformed/incoherent scope. Absent accessible scope is not-found; existing non-current scope is unsupported-capability before roster retrieval. Current collection verifies team IDs/competition membership and person current-team identities, then repeats discovery. Changed current-season evidence is invalid-response, never a new-season restart. All partial portions remain private; final candidate uses the unchanged validator. Explicit empty arrays for covered scope are accepted; missing/null/withheld arrays, duplicates, transfers or unmapped roles fail. Canonical names come from the existing vocabulary, not invented vendor names.

### Transport and time

The existing deadline worker owns every Mint socket, opens sequential per-exchange connections and closes them on ordinary termination. The live destination is fixed with peer/hostname verification; trusted test mode is loopback-only with local CA verification. No connection ownership transfer, pool, proxy, redirect following or generic URL setting. Numeric source IDs and fixed path builders prevent hostile path/URL composition. Before each connect/write/wait, recompute remaining time against `context.deadline_us`; VM-sized waits are slices, not new budgets. Outer Runtime independently bounds blocking DNS/TLS/translation. A killed worker's socket cleanup must be observed from the TLS peer after deadline and caller exit. Configured/public identifier values equal to or containing the token fail safely; never sanitize them into a new identity.

### Errors and diagnostics

contracts/football-data.md owns numeric statuses, retry delays and no-body classifications. Status failures are classified before attempting JSON; valid success requires complete parse/validation. No raw exceptions, bodies, source messages, URLs or authorization values are logged or returned, including debug/error paths. Transport state uses redacted inspection; tests capture diagnostics and compare sentinel absence. Only positive known future delays survive; no waiting occurs. Deadline precedence remains the existing boundary's final normalized readiness rule. The source-anchored expiry design below fixes QA B1; a parser-level check alone is insufficient.

### Source-anchored retry expiry — feedback 1

[ADR-0015](../../docs/adr/0015-source-anchored-retry-expiry.md) is the only durable deviation from the original implementation boundary. The private transport envelope records `received_us` and `received_utc` when complete failure headers are first available, before close/return/parsing. RecordingTransport supplies the same controlled pair. Absent/incoherent receipt evidence means unknown delay; never re-anchor at parser entry. Relative seconds anchor to received_us; HTTP-date is converted against received_utc into that same monotonic domain. Preserve existing precedence, duplicate handling and fallback semantics. Parsing/UTC sampling costs consume the shared budget.

Runner injects a private `record_retry_not_before` function into the worker's context. It accepts only an integer expiry, uses a unique per-call reference for worker-local storage, and is inaccessible to consumer input. FootballData.Errors records the fixed expiry and returns the unchanged failure map (category plus optional positive duration); it does not add keys to the Adapter candidate. Runner extracts/deletes this private value after Error.failure and existing normalization, wrapping the normalized outcome plus expiry only for opaque internal runtime delivery. with_retry_window/1 invokes existing work/4 through a callback-bearing context, packages its outcome plus recorded expiry, and cleans storage with try/after even on exceptions and synchronous fixture runtimes. Repeated registrations retain the earliest expiry rather than renewing a wait. work/4 and its existing normalization hook remain AST-unchanged. No resources, raw headers, callbacks or expiry appear in the public Error.

On accepted readiness strictly before the deadline, Runner unwraps the outcome. Only a valid rate_limited Error with recorded expiry is refreshed: `remaining_ms = div(max(expiry_us - ready_us, 0), 1000)`; positive remains, otherwise nil. Ready_us comes from the existing runtime's complete normalized outcome event; no wall-clock refresh or new utc_now call after readiness. Late readiness still selects timeout/cancellation first. Without recorded expiry, preserve the legacy error exactly. Success, malformed failure, exceptions and non-rate categories cannot inherit recorded metadata. Runtime, Error.failure allowlist and public Adapter/consumer contracts stay byte-unchanged.

Test first at the complete facade: Retry-After delta, HTTP-date and reset headers; time during parsing and separately during later normalization; still-positive overstated waits, sub-ms remainder and expiry before/at/after readiness. Pin the QA expectations for Retry-After:2 at 1/2/3 seconds to 1000/nil/nil. Preserve and rerun the two original /tmp QA probes unchanged; port their source-independent assertions into tracked tests so clean CI does not depend on /tmp. Real HTTPS Retry-After:1 with a 1200-ms normalization pause must yield nil and peer closure before the request deadline. Preserve other adapters' fixed-duration errors and hostile-envelope rejection; prove no cross-call leak under synchronous/repeated fixture calls, caller exit, deadline and huge overrides.

The narrowed Runner guard compares metadata-normalized AST with HEAD, allows changes only in run/4 and the private with_retry_window/1 and refine_retry_delay/3 helpers, and rejects other deletions/edits. Add independent invariant assertions for strict readiness, unchanged deadline/cancel/close paths, legacy-error equality, no vendor branch or forbidden dependencies/process creation. Do not simply remove Runner from protection or update a blanket fingerprint. Keep all other byte guards and the 217 independently pinned fixture cases intact.

### Acceptance and checkpoint coverage

contracts/fixtures.md maps each numbered scenario to stable synthetic cases; verification.json maps all 17 FR and six SC IDs to executable check IDs. It intentionally requires actual TLS runtime checks for outbound HTTP, with service readiness and status/header/body assertions; no public endpoint is introduced. Developer runs every manifest check via `scripts/agentflow_check.py`; QA reruns independently. Pure fixtures require no external services or internet; existing local services are required for application/regression evidence only.

| Checkpoint/invariant | Evidence and limitation |
| --- | --- |
| CP2 data/import boundary | Complete conditional catalogs, honest unsupported performance/historical outcomes, safe source configuration and deterministic data |
| CP2 persistence/profiles/coverage/documentation | Exact catalog/statistics state isolation; existing separate profiles/coverage; operator guide and internal contract |
| CP2 valuation/quotes/trading/history/ranking | Remain separate backlog outcomes; this adapter supplies no usable per-match performance path and cannot certify full CP2 |
| CP1 regression | Existing auth/catalog/OpenAPI and quality checks remain green; no schema/route changes |
| CP3 boundaries | Feature-scoped AST/scope tests preserve layers; no claim of full CP3 architecture/metrics delivery |
| Product invariants 1–5, 7 | No financial writes or supplied performance facts; protected through scope and full regressions |
| Product invariant 6 | Startup/local reads initiate zero provider calls even after provider success/failure/cancellation |

## Delivery and Validation

Test-first per story; first prove complete catalog translation, then operator safety, failure/deadline honesty and offline compatibility. US1 is the first independently testable increment, not permission to omit US2–US4 before QA. Preserve existing source-neutral assertions via FactOracle; new test support owns only adapter-specific exchange checks.

Stage all new canonical/source files and final develop handoff before coverage's existing snapshot check; no commit/publication is authorized here. Ignore only workspace-specific `handoffs/check-*.json` receipts. After final source stabilization execute all manifest checks, record task completion only from passing commands, then run develop readiness. Fresh QA and final review retain independent terminal `Verdict: PASS` requirements.

## Complexity Tracking

No constitution violation. Mint remains justified by ADR-0014. ADR-0015 permits only a private Runner expiry seam because final readiness occurs after adapter parsing; adapter-only subtraction cannot satisfy FR-011. No new infrastructure, public contract or product scope.

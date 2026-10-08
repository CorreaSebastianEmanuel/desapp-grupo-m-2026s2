# Implementation Plan: Football Scraping Adapter

**Branch**: `055-football-scraping-adapter` | **Date**: 2026-10-07 | **Spec**: [spec.md](spec.md)
**Resolved feature**: `specs/056-football-scraping-adapter` via `.specify/feature.json`; the spec's 055 branch label identifies TASK-055, not its directory.

## Summary

Implement an offline-verifiable FotMob-shaped adapter behind the merged `FootballMarket.Providers.Adapter`. Reuse `Providers.catalog/2`, `performances/2`, Request, Runner, Validator and Error without changing their public behavior. Decode source documents, establish scope and completeness, build candidates and let the existing validator accept or reject the entire result. No persistent writes or new endpoint. Actual FotMob access remains disabled: affirmative permission, complete rosters, season-wide performance completeness and required substitute positions have not been established.

Product-decision.md permits this delivery. ADR-0018 resolves the critic's four material findings without a source replacement or substitute-position decision. Synthetic successes prove translation/contract behavior only, never actual source availability. See research.md and contracts/source-mapping.md for the boundary between observed and assumed shapes.

## Technical Context

**Language/Version**: Elixir ~> 1.20.3, existing OTP toolchain (`scripts/check_toolchain.sh`).
**Primary Dependencies**: Existing Providers, standard-library crypto and Jason from mix.exs. No browser, HTTP client dependency, scheduler or additional service.
**Storage**: Read-only in-memory DTOs; safe synthetic files under test/fixtures/scraping. PostgreSQL/Redis only for existing integration regression and local-state assertions; no migration.
**Testing**: ExUnit, controlled FixtureRuntime, independent FactOracle, existing 217-case contract corpus and portable fixture fingerprints. Pure Elixir offline entrypoint for source decoding; Mix integration tests for database isolation.
**Target Platform**: Existing local modular Phoenix application; deterministic tests also run without Phoenix/database startup.
**Project Type**: Internal external-source adapter.
**Performance Goals**: Entire read/translation/validation ready strictly before existing default 5,000 ms or any valid caller override, including large integers. No added throughput promise.
**Constraints**: One deadline, sequential portions, no retries/fallback/detached work; zero external calls in tests. Live transport is deny-only in this delivery. Fixture use is explicit state, not a live configuration bypass.
**Scale/Scope**: Both existing operations; five canonical leagues; explicit 2024–2025 and 2025–2026 fixture scopes. No all-season live claim. No unresolved design clarification; external evidence gaps are activation blockers.

## Constitution Check

Pre-design and post-design: PASS for the design boundary (not implementation acceptance).

- I: spec and approved product decision govern behavior; each story/scenario maps to tasks and executable verification.
- II: Adapter cannot touch tokens, money, trades, audit, quotes, strategy inputs or persisted facts. No floating-point monetary data introduced. Local reads remain independent.
- III: Reuse modular provider boundary and ADR-0013. Adapter-only modules, no web/domain/persistence changes; ADR-0018 records the durable access/completeness extension.
- IV: Tests precede changes, independently authored expectations, no normalized DTO inputs pretending to test decoding; regression, formatting, compilation and regression safeguards in verification.json.
- V: Implementation owner executes every manifest check before separate QA and review. Only explicitly mapped downstream gates can remain incomplete; neither gate is claimed passed here.
- Safety: No source contact, credential acquisition, live activation, publishing or changes to downstream scope. TASK-021 position-frequency policy stays unresolved there.

## Project Structure

```text
specs/056-football-scraping-adapter/
  plan.md research.md data-model.md quickstart.md tasks.md verification.json
  source-assessment.md fixture-matrix.md
  contracts/adapter.md contracts/source-mapping.md
  handoffs/architecture.md handoffs/tasks.md
lib/football_market/providers/
  scraping.ex
  scraping/assessment.ex scraping/source.ex scraping/translator.ex
  scraping/transport.ex scraping/disabled_transport.ex
  scraping/fixture_transport.ex
  # existing Request/Runner/Validator/Runtime unchanged
 test/support/providers/scraping_fixture_data.ex
 test/fixtures/scraping/{inventory,cases,expected,documents}.exs
 test/scraping_adapter_offline.exs
 test/football_market/providers/scraping/
  assessment_test.exs catalog_test.exs performances_test.exs
  safety_test.exs deadline_test.exs matrix_test.exs equivalence_test.exs
  isolation_test.exs
```

**Structure Decision**: `Scraping` implements existing `Adapter.read/3`; its state chooses a source-document transport and immutable assessment reader. Fixture transport remains read-only and cannot access URLs. DisabledTransport never performs I/O. Do not change global Providers configuration to select the scraper by default. Add test bootstrap/fixtures to mix.exs test_ignore_filters only as needed to avoid executing data files as suites.

## Phase 0: Resolved decisions

research.md cites local canonical evidence and settled ADRs; no technology survey or research agents. The temporary exploratory report informed the observed paths, but no acceptance command relies on temporary files. No raw captured sample is retained without applicable permission.

## Phase 1: Design and implementation boundary

1. **Access**: Assessment is explicit, immutable, versioned and dated; trusted reader rechecks current revision/time before every portion and before publication. Mandatory permission conditions, destination allowlist, operation/season coverage, retention/attribution, cadence, volume/concurrency and revalidation must all be established. DisabledTransport rejects every actual live attempt regardless of switches. No live HTTP client ships here. Future live activation requires a reviewed concrete transport with atomic shared admission across callers/processes and proven cancellation; unknown limits or unimplemented coordination remain blockers. Fixture transport simulates admission/revocation and concurrency without contacting any source.
2. **Completeness**: Source.read accumulates lists without deduplication; checks identity/scope for discovery, terminal pagination, all required rosters or eligible match details and explicit collection-presence/terminal witnesses. A witness must have a documented evidence reference in the scope assessment, not a bare boolean in source content. Synthetic transport manifests can assert hypothetical terminal observations, clearly labelled. Actual FotMob currently has no accepted complete-roster or full-season witness; unsupported assessment blocks its live use. In an assessed-supported fixture, missing witness/data or repeated portion is invalid-response. A fully checked empty scope or a completed match with an explicit empty supplied-performance collection is valid, distinguished from missing detail. Published absent scope is not-found; declared unavailable season is unsupported-capability.
3. **Translation**: Use fixed-key parsing, never dynamic atoms. Preserve requested season independently from response, check external competition/season/match IDs at every relevant boundary. Source-specific position mapping is explicit assessment data into caller vocabulary; no usualPosition fallback for match facts. Known non-completed/out-of-bounds matches follow existing eligibility precedence before checking irrelevant player details. Unknown status/kickoff eligibility fails. Construct distinct result refs/bindings from kind and scoped opaque ID, preserving duplicate lists for rejection; names never identify players.
4. **Metrics**: Only assessed verified direct player counts are admitted. Invalid claimed verified values fail; unavailable/unverified optional mappings become nil with reasons in assessment. No event reconstruction algorithm in this delivery; own-goal/goalkeeper fixtures exercise direct metrics and unknown event-derived counts. A mere tackle label or team-total conceded value is unverified. Missing required minutes/position fails a supposedly supported response; known absent capability fails before source work.
5. **Timing and errors**: All parsing, portions, assessment checks and normalization use Runner's existing context.deadline_us and runtime. Check remaining budget before each portion; do not reset timeout or cap accepted large values. Synchronous fixture reads; no spawned transport work that survives Runner cancellation. Return only existing category and optional positive retry delay through Error.failure; exceptions/addresses/content stay out of output. Observed errors retain category, except deadline precedence.
6. **Evidence**: Inventory records stable ID, synthetic origin/date, raw byte fingerprint, source-shape evidence class, expected outcome and scenario mapping. Expected terms are authored independently of translator/validator. Both operations have explicit entity correspondence to FixtureSourceA. Run identical controlled corpus twice, compare full outcomes/provenance with fixed UTC clock, fail on attempted network/credentials. Do not alter original 217 cases or fingerprints.

## Validation and checkpoint coverage

verification.json maps all 18 FR and 7 SC identifiers; acceptance scenarios have stable `USn.m` aliases in fixture-matrix.md (no new behavioral requirements). Service preflight precedes Mix state-isolation/regression. Offline bootstrap must refuse unknown selectors and zero-test runs. No affected HTTP endpoints: runtime_required=false; executable in-process production-runtime cancellation and service/state assertions apply instead. Adding an endpoint would violate FR-015 and require a scope decision plus HTTP readiness/status/header/body checks.

CP2 contribution is truthful adapter/fixture evidence upstream of ingestion, not live-ready statistics or fulfillment of charts/conditional orders/E2E. Existing provider-contract and unit/integration regressions remain checks. Per current human feedback, the duplicate CP1 coverage report is excluded from TASK-055; its script and CI remain available. Later ingestion retains lineage and schedules retries; TASK-056 owns freshness. Product invariant verification includes exact catalog/statistics snapshots after both successful and failed adapter calls, zero source requests on local reads, no Repo/Ecto/web dependency in new production modules and unchanged financial code. QA independently challenges the mapping and blocker claims.

## Complexity Tracking

No constitution violation or infrastructure deviation. ADR-0018 is a durable provider-boundary extension, not permission to deploy recurring scraping.

## User-authorized workflow correction — 2026-10-07

The unit profile exposed an obsolete TASK-014-specific exclusion assertion in `test/ci/coverage_report_contract_test.exs`. Align that contract regression with the authorized general exclusion policy, and permit this exact test path in `test/football_market/statistics/scope_test.exs`. The executable snapshot regression in `tests/test_agentflow_delivery.py` continues to prove that source/spec/plan changes remain bound; do not weaken production snapshot checks.

The user paused the run after 72 minutes and authorized verification efficiency changes without reopening scraper product decisions. Include scripts/agentflow_check.py, scripts/agentflow_verification.py, scripts/coverage_report.sh, tests/test_agentflow_delivery.py, tests/test_agentflow.py, test/scripts/workflow_artifact_probe_test.py, docs/AGENT_VERIFICATION.md, docs/AGENT_CONTEXT_POLICY.md and the delivery workflow. Development explicitly requests same-stage current-receipt reuse; runtime/service checks stay fresh and QA executes independently. Normalize temporary test-root aliases on macOS without changing production path checks; permit only the named artifact-probe test in the existing scraper scope inventory. Two failed executions with unchanged inputs block a third attempt and report elapsed time/evidence. Coverage snapshots exclude generated handoffs and QA/review reports for every feature while binding code and design. Remove cp1-coverage from this manifest and retain unit/integration checks. Add workflow-controls for helper/snapshot regressions. Keep the run paused until explicitly resumed. Existing adapter behavior, permission blockers and independent verdict gates remain authoritative.

## Final-publication correction — current feedback

The bounded B1 fix extends the implementation boundary to existing Adapter and Runner: an optional read-only publication_guard/3 captures admission revision before source work, and Runner invokes its closure only after successful Validator completion. Scraping rechecks current assessment expiry, withdrawal and revision at this last publication boundary. Existing read/3 and consumer result shapes remain unchanged; adapters without a guard retain prior behavior. Runner's outer deadline and cancellation still govern every outcome. No transport, capability or source activation changes. Six assessment regressions and timeout precedence run under assessment; the unchanged human-named reproduction runs under publication-gate.

The statistics scope regression's active-feature inventory must permit exactly providers/adapter.ex and providers/runner.ex for this correction. Its original domain allowlist and dependency checks stay intact. Two unchanged unit-profile attempts failed solely on the obsolete path inventory (59.974 seconds total); the relevant inventory is corrected before further execution.

## CI service provisioning correction — current feedback

Feedback 3 authorizes only the existing Quality baseline job's missing Redis dependency: use compose.yaml's exact pinned Redis image, test configuration port 6379 and bounded redis-cli ping health readiness. Preserve PostgreSQL, least privilege, complete scripts/ci_unit_tests.sh discovery and all source-access/publication behavior. Extend QualityBaselineContractTest with exact image/port/health assertions, retaining all other prohibitions. Refresh the workflow byte oracle and permit exactly .github/workflows/quality-baseline.yml in the scraper scope inventory. Align README.md and quickstart.md prerequisites. Add ci-service-contract and ci-baseline checks to verification.json; keep existing profiles and independent gates. No additional service architecture or product behavior.

# Focused local findings — TASK-063

No unresolved technology choice remains. Reuse docs/ARCHITECTURE.md, ADR-0006 (API authority), ADR-0009 (coverage), ADR-0025 (durable synchronization) and ADR-0026-revocable-browser-session-boundary.md. No external research or agent session was needed.

## Independent inventory

Decision: committed per-case assignments, separate discovery and runtime event reconciliation; explicit update command only.
Rationale: `test/support/test_profile_audit.ex` currently globs modules and reads tags; `scripts/test_profile.sh` only validates a module count, sentinel and nonzero summary. A removed file can disappear from both expected/discovered scope, and a missing case can hide behind a passing module.
Alternatives considered: regenerate expected scope on every run (cannot detect omissions); module-only inventory or total counts (cannot detect substituted cases); move current HTTP/browser tests into E2E (violates preserved integration scope).

## CI and non-ExUnit tests

Decision: inventory includes ExUnit, existing Python/shell workflow/service tests and Node/custom validator cases. Native adapters preserve their checks and classify them once. Required baseline job runs unit/integration once; new required E2E job runs new complete journeys. See ADR-0028.
Rationale: `.github/workflows/quality-baseline.yml` executes default Mix via `scripts/ci_unit_tests.sh`, plus workflow tests and OpenAPI checks. `.github/workflows/sonarcloud.yml` independently generates workspace JS LCOV and evaluates native Sonar/CP1 gates. Named profile commands alone currently do not describe this total population.
Alternatives considered: optional/manual E2E (does not meet CP2 evidence); running legacy full Mix followed by both profiles (duplicates entire suites); ignoring non-ExUnit tests (contradicts FR-003).

## Runtime/worker isolation

Decision: separate test BEAM with owned schema, normal connections, real queue consumers and production Endpoint; bounded local polling.
Rationale: `config/test.exs` defaults to SQL Sandbox, server false and Oban manual. `test/support/synchronization/runtime_probe.ex` supplies owned-schema migration precedent but drains the queue manually; it is useful integration evidence, not the new E2E journey. `BrowserSessionCase` supplies a test clock precedent but its probe routes must not become production routes or authentication bypasses.
Alternatives considered: reuse a shared sandbox transaction (masks worker visibility); directly perform/drain worker (does not establish real background execution); sleeps without terminal-state assertion (can pass incomplete work); new public sync API (out of scope).

## Deadlines and secrets

Decision: 30-second startup and per-sync deadlines, 10-second browser action deadline, 180-second E2E process ceiling; fixed safe diagnostics and summary-only retained artifacts.
Rationale: synchronous setup failures, hung workers and child signals must fail rather than skip or hang. Existing private-capture runner offers a reusable starting point; `ci_unit_tests.sh` currently prints raw Mix output and needs the same safe policy.
Alternatives considered: raw error dumps/screenshots (credential risk), unbounded polling (FR-010 failure), changing product retries/expiry (outside plan boundary).

## Legacy service-script prerequisite discovered during task synthesis

Decision: integration service cases use a test-only Docker command wrapper and materialized Compose config with unique project, volume names and ports; test helpers honor those ports/private temporary files. Docker Engine/Compose is a supported integration prerequisite, not an optional skip.
Rationale: local_services.sh hardcodes football_market_local; compose.yaml explicitly names shared volumes; local_services_failure_test.sh binds 5432/6379. Executing these unchanged against the contributor's stack would stop shared services. Existing acceptance orchestration also invokes a child shell suite, so inventory must record the entry-point graph and avoid double-running its leaves.
Alternatives considered: run on the shared stack (unsafe interference); merely change project name (named volumes still shared); mocks in place of real service lifecycle checks (weakens coverage); change production local-services behavior (unnecessary scope). Keep the original production scripts under test and isolate their Docker target in test tooling. No new daemon/service is introduced.

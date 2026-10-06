# Implementation Plan: External Football Provider Contract

**Branch**: `016-external-football-provider-contract` | **Date**: 2026-10-06 | **Spec**: [spec.md](spec.md)

**Input**: TASK-016, CP2; prerequisite TASK-005. Current feedback: `backlog/feedback/TASK-016.md` (B1/B2 corrections retained; reversible fixture refactor with portable independent fingerprints captured before that refactor (baseline `7a0e115`, local QA only)). Production behavior and all 217 cases remain unchanged.

## Summary

Add a read-only, provider-neutral Elixir boundary for league-season catalogs and completed player-match performances. Pure request/result validation surrounds an injected adapter; one cancellable worker owns retrieval and normalization under one absolute deadline. Supply two synthetic adapters and a reusable, identity-aware offline contract suite. No vendor, HTTP interface, persistence, reconciliation, retries or new service is introduced.

## Technical Context

**Language/Version**: Elixir 1.20.3, Erlang/OTP 29.0.6, pinned in `.tool-versions`.

**Primary Dependencies**: Elixir/OTP and ExUnit only for the boundary. Existing Phoenix/Ecto/PostgreSQL support catalog isolation regression; no dependency additions. Settled stack: `docs/ARCHITECTURE.md`, `mix.exs`.

**Storage**: None in provider code. Existing PostgreSQL is required only by isolation/regression checks. Redis remains existing infrastructure, checked by preflight; no provider cache.

**Testing**: Pure ExUnit tests, deterministic elapsed-time runtime, real-process cancellation smoke tests, database-backed isolation, existing full suite and CP1 profile/coverage preservation. Every changed behavior receives tests first.

**Target Platform / Project Type**: Existing Linux modular monolith; internal Elixir interface.

**Performance Goals**: Default 5,000 ms and positive integer overrides; fully validated readiness strictly before the deadline, including all portions and normalization. No throughput target or invented record/page cap. One retrieval worker and one short-lived runtime coordinator per request; no pool. Memory holds one complete logical result.

**Constraints**: Offline fixtures need no Mix application, database, network or credentials. No raw-source data or arbitrary diagnostics escape. Collections are unordered; same-name players remain distinct. Configured position vocabulary is injected as immutable values, never fetched from a database by provider code.

**Scale/Scope**: Two operations, five leagues, at least two synthetic seasons, eight error categories and nine optional counts. Material unknowns resolved in [research.md](research.md); no external technology research needed.

## Constitution Check

Pre-research and post-design assessment:

| Principle | Design evidence | Assessment |
| --- | --- | --- |
| Specification first | FR-001–FR-014, 17 numbered acceptance scenarios, SC-001–SC-006 mapped to contracts, tasks and checks | Satisfied by design |
| Domain integrity | No financial values or writes; local catalog stays authoritative; current/event-time affiliation separated per ADR-0002 | Satisfied by design |
| Modular simplicity | DTOs/validators, orchestration and adapter behaviour separated; no web/Repo dependency or service | Satisfied by design |
| Evidence-based quality | Test-first tasks; offline, isolation, regression, format, compile, profile and coverage commands | Execution required in development |
| Independent verification | Only QA/review tasks deferred; independent reruns and terminal PASS reports | Downstream gates required |

No violation or outstanding clarification. [ADR-0013](../../docs/adr/0013-provider-contract-boundary.md) records the durable boundary extension. ADR-0002/0010/0011/0012 remain authoritative; no database/catalog model deviation is authorized.

## Project Structure

```text
specs/016-external-football-provider-contract/
  spec.md, plan.md, research.md, data-model.md, quickstart.md, tasks.md
  verification.json
  .gitignore (workspace-local check receipts only)
  contracts/provider.md, contracts/fixtures.md
  handoffs/architecture.md, handoffs/tasks.md
docs/adr/0013-provider-contract-boundary.md
mix.exs (five exact test data/bootstrap ignore filters only)
test/football_market/statistics/scope_test.exs (active TASK-016 path allowlist only)
lib/football_market/providers.ex
lib/football_market/providers/
  adapter.ex, types.ex, request.ex, instant.ex, error.ex
  validator.ex, catalog.ex, performances.ex, provenance.ex
  runner.ex, runtime.ex
test/provider_contract_offline.exs
test/support/provider_contract_case.ex
test/support/providers/
  fixture_data.ex, fixture_source_a.ex, fixture_source_b.ex, fixture_runtime.ex, fact_oracle.ex
test/fixtures/providers/
  cases.exs, source_a.exs, source_b.exs, expected.exs
test/football_market/providers/
  request_test.exs, catalog_contract_test.exs, performance_contract_test.exs
  deadline_test.exs, error_safety_test.exs, equivalence_test.exs
  fixture_matrix_test.exs, fixture_preservation_test.exs, catalog_isolation_test.exs, scope_test.exs
```

**Structure Decision**: Pure provider DTOs remain separate from Ecto Catalog/Statistics schemas and web modules. `Providers` resolves internal adapter/runtime/vocabulary options and delegates. `Adapter` is the replaceable source port; fixture implementations are test support only. No production Catalog, Statistics, router, supervision, migration, dependency or permission changes. Mix test discovery ignores only the four fixture data files and offline bootstrap; scope tests compare the remaining Mix AST to HEAD. The existing Statistics worktree guard retains its original paths and recognizes the exact TASK-016 files only when this feature is active; its statistics integrity/dependency assertions remain unchanged. These test-only adjustments resolve regression evidence from development. New ExUnit modules carry exactly one existing `:unit` or `:integration` module tag.

## Phase 0: Focused Resolution

Local inspection confirmed catalog league constants, mutable current affiliation, configurable positions, lossless UTC microsecond inputs and integer/unknown counts. Use ADR-0011's instant semantics without coupling Providers to Statistics. `research.md` resolves filtering, diagnostic safety, reference equivalence and deadlines. TASK-017/TASK-022 own real provider feasibility.

## Phase 1: Design and Implementation Boundary

### Requests and adapter port

[contracts/provider.md](contracts/provider.md) owns exact keys/return shapes; [data-model.md](data-model.md) owns entities. `Providers.catalog/2` and `Providers.performances/2` accept one request map and trusted internal options with the same meaning for every source. Reject unknown keys, mixed key styles, invalid scope/bounds/timeouts before adapter work. Match string keys against a fixed vocabulary without creating atoms. Provider selection is internal; absent operation/coverage produces unsupported-capability.

An adapter receives a validated Request and Context containing one absolute deadline, and returns one complete candidate or typed failure. Pagination/translation stay inside adapters, demonstrated by test sources. No portion is independently published. Distinguish unsupported coverage, recognized missing scope and recognized empty scope.

### Eligibility and validation

Catalog candidates are validated entirely. Performance candidates first validate the requested envelope and match league/season/status discriminators. Recognized other supported scopes and non-completed states are excluded; invalid/unknown discriminators fail. Completed matches in scope require a valid actual kickoff before inclusive comparison. An excluded non-completed match needs no kickoff to establish exclusion; an undecidable completed kickoff fails.

Select eligible matches, their supplied performances and transitive directory closure, including each player's current team/position alongside historical participants. Validate every retained fact, uniqueness rule, binding and relationship. Retained cross-season edges, bad metrics or duplicates fail the whole request. Excluded matches' unused facts cannot invalidate a narrow answer; catalog facts receive no filtering. Keep lists until duplicate validation, avoiding silent map overwrites. Detailed mixed-response oracles: contracts/fixtures.md.

### Deadline and terminal outcome

`Runner` validates inputs, takes monotonic start immediately before launch, and computes one deadline. `Runtime` owns monitored process creation, deadline-aware waiting and cancellation; test `FixtureRuntime` controls elapsed time and event delivery. Separate injectable wall time supplies retrieval provenance. Worker retrieval plus validation produces one correlated ready event. Only fully validated readiness strictly before deadline succeeds; equality/later readiness yields timeout, including errors. Raw-page arrival is never readiness.

VM receive waits are capped at 4,294,967,295 ms per slice and recompute remaining time against the same absolute deadline; accepted positive integer budgets have no new ceiling. The owner returns at deadline without joining blocked work. A request-scoped runtime coordinator monitors the caller while the retrieval worker is blocked; it cancels the worker on deadline/caller exit and disconnects replies. Deactivate the reply target and discard correlated late messages; request IDs isolate later calls. No outcome can escape after terminal timeout. Pre-deadline typed failures retain category; unexpected worker failure becomes safe unavailable. Catch raw exceptions at worker entry before process exit can emit default crash logs. Clean up both processes on every terminal path. Adapters cannot detach work, write or publish. Cancellation is not a sandbox for a malicious adapter. Test exact virtual boundaries plus short real blocking/caller-exit/cancellation tests using process monitors and bounded cleanup.

### Safe errors and provenance

`Error` generates explanations from fixed templates. Unknown input keys report `:request` rather than the hostile name. Affected fields are allowlisted; optional affected refs are omitted unless locally generated and safe. Operation/scope/provider label are controlled by the facade; invalid scope is omitted. An invalid timeout retains the independently normalized league-season and valid performance bounds; timeout validation never discards that scope. Typed failures carry only category and validated optional rate-limit delay; malformed categories/shapes become invalid-response. No raw exception/exit, stack trace, transport status or inspected payload is logged or returned.

Only provenance admits source IDs/fixture IDs. Adapters must select public-safe IDs; validation rejects recognizable URLs, credential/authorization expressions, controls and invalid text. Preserve other opaque case-sensitive content; never rewrite identity. Test sentinel leakage across complete outcomes, not just explanations. Arbitrary secrets cannot be inferred from opaque bytes: TASK-017 remains responsible for selecting safe identifiers. This enforces FR-012 without claiming universal secret detection.

### Shared offline support

`ProviderContractCase.assert_contract!/2` takes an adapter and stable fixture ID. Case metadata connects source examples, explicit expected outcome, scenario and FR/SC coverage. `FactOracle` uses declared per-kind entity correspondences and reference bijections, comparing unordered values/edges and provenance separately. Negative oracle tests swap same-name players' teams and performance edges. This support cannot become production reconciliation.

`test/provider_contract_offline.exs` bootstraps pure modules/support/tests in explicit dependency order without Mix/application startup. Suite selectors are `request`, `catalog`, `performances`, `deadline`, `safety`, `fixtures`, `fixture-preservation`, `all`; unknown/empty selections fail, and ExUnit failures return nonzero. Run fixture examples twice with fixed clocks and no provider network/credentials. Separate database-backed isolation tests assert unchanged rows/reads for every error and zero provider calls on local reads.

### Fixture refactor boundary (feedback 2)

Keep the four fixture entry files and independent catalog/performance bases in each file. `FixtureData` is test-only structural editing: explicit put/drop paths traverse maps, zero-based rows and source B cells while preserving packet wrappers/order. It stamps controlled case IDs, never translates source A into B or derives expectations from production validators. Short error outcomes remain explicit literals; every stable case and its mappings remain declared.

Load `fixture_data.ex` before synthetic adapters in the pure bootstrap; direct entry-file evaluation loads that same helper when needed. Mix retains its five exact data/bootstrap ignore filters. Extend the active Statistics test allowlist only for this helper and `fixture_preservation_test.exs`. No production/configuration/inventory changes.

The preservation test asserts fixed SHA-256 fingerprints independently captured from pre-refactor terms, serialized with `:erlang.term_to_binary(term, [:deterministic])`, plus 217 entries each. Expected hashes are literal and never derived from current fixtures. The same test runs in fixtures/all, unit/regression, and a dedicated manifest check that places a failing Git shim first on PATH. Pure preservation requires neither Git nor repository history; CI checkout/fetch remains unchanged. The protected backup branch remains intact. Independent QA separately compares original-commit terms locally and reviews override readability. Temporary saved terms and historical Git are supplemental local QA evidence, never fixture or persistent test prerequisites.

## Alignment, Invariants and Checkpoint Coverage

| Scope | Evidence / task phase |
| --- | --- |
| US1, FR-001–FR-005/FR-008 | Request/catalog suites; Phase 3 |
| US2, FR-006–FR-008 | Performance/eligibility suite; Phase 4 |
| US3, FR-009–FR-012 | Deadline/error safety/local isolation; Phase 5 |
| US4, FR-013, SC-001/SC-004/SC-005 | Shared matrix/oracle; Phase 6 |
| FR-014 | Scope/AST dependency and changed-path assertions; Phase 7 |
| All SCs | verification.json; fixture matrix covers numbered scenarios without inventing AC identifiers |
| Product invariants 1–5/7 | No token/money/trade/audit/quote mutation; no scoring substitutes in facts; full regression |
| Product invariant 6 | Per-error state snapshots and local-read provider spy |
| CP2 | Provider input boundary and deterministic data; existing persistence/profile/coverage checks. No complete CP2 or live-provider readiness claim |
| CP1 / CP3 | Preserve catalog/auth/OpenAPI via regression/profiles; scoped boundary tests do not replace future CP3 architecture tests |

## Validation and Delivery

See quickstart.md and verification.json. Development executes every check after final source stabilization and completes every non-gate task. QA independently reruns and challenges scenario coverage. HTTP runtime checks are inapplicable: FR-014 excludes endpoints and none are declared. Service preflight still verifies the existing test database/Redis. Existing coverage binds a staged working-tree snapshot; staging new files is necessary, committing/pushing is not authorized in development. The feature .gitignore excludes only workspace-local check receipts, whose actual contents/output hashes remain required by readiness. Stage the completed develop handoff before QA independently reruns coverage. No architecture-stage behavioral PASS or fabricated receipts.

## Complexity Tracking

No violation. A cancellable per-call process and test-only runtime are the smallest design that bounds blocking source work; no infrastructure addition.

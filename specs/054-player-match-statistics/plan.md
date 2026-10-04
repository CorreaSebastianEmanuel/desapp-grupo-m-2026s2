# Implementation Plan: Player Match Statistics Model

**Branch**: `020-player-match-statistics-model` | **Date**: 2026-10-03 | **Spec**: [spec.md](spec.md)
**Feature directory**: `specs/054-player-match-statistics` (setup script labels this directory as BRANCH; actual Git branch is the value above).

## Summary

Persist completed matches and strict provider-neutral performances in a new Statistics domain context, with exact integer counts, unknown optional metrics, append-only database protections and deterministic local history. Resolve product-challenge findings with ADR-0010 (catalog race/integrity protections) and ADR-0011 (lossless microsecond boundary). Reuse TASK-005 catalog and ADR-0002 transfers. Feedback 2 adds original-input malformed-text rejection (B2) and a bounded existing Catalog concurrency harness repair (B3), documented in ADR-0012. Preserve feedback 1 Unicode migration safeguards (B1). No implementation or publishing occurs in architecture.

## Technical Context

**Language/Version**: Elixir 1.20.3, Erlang/OTP 29.0.6 (existing toolchain).
**Primary Dependencies**: Existing Ecto SQL ~>3.13/Postgrex, Decimal via Ecto; application remains Phoenix ~>1.8.13. No dependency or service additions.
**Storage**: Existing PostgreSQL 17.6; Redis 8.2.1 remains application infrastructure, unused by Statistics reads.
**Testing**: ExUnit strict-value unit tests and PostgreSQL integration tests; existing unit/integration profiles, full regression and informational CP1 coverage job.
**Target Platform**: Existing modular monolith in local/CI environments.
**Project Type**: Internal domain/persistence feature within a web application; no exposed endpoint.
**Performance Goals**: No new latency or capacity SLO; indexed exact lookups and deterministic histories without arbitrary row/window limits.
**Constraints**: Preserve FR-013 exclusions, integer precision, atomic operations, event-time affiliation, immutable accepted facts and field-safe errors.
**Scale/Scope**: Two tables, one context, schema/query/input/error modules, custom exact Count type and catalog constraint mapping, plus the explicitly authorized Catalog test-harness extension in ADR-0012. Deterministic examples cover five leagues and two seasons. No new seed commands.

## Constitution Check

Pre-design: PASS. Specification and approved decision determine scope; no unresolved human decision. Behavioral tests precede implementation. Existing architecture/ADRs determine stack.

Post-design: PASS. Web/domain/persistence/adapters stay separated; no web or provider modification. Unique/composite restrictive keys, append-only triggers and Ecto.Multi provide integrity under concurrency. No money, quote, token, trading or audit changes. Independent QA and final review remain downstream tasks; architecture is not their verdict. ADRs document database enforcement and precision choices. No unjustified constitutional violation.

## Project Structure

```text
specs/054-player-match-statistics/
  plan.md, tasks.md, research.md, data-model.md, quickstart.md, verification.json
  contracts/statistics-context.md
  handoffs/architecture.md, handoffs/tasks.md
lib/football_market/statistics.ex
lib/football_market/statistics/{match,performance,count,input,error,query}.ex
priv/repo/migrations/20261003000000_create_match_statistics.exs
priv/repo/migrations/20261004000000_align_statistics_identity_whitespace.exs # feedback B1
lib/football_market/catalog/{team,season,position}.ex  # deletion constraint mappings only
test/support/statistics_case.ex
test/support/catalog_concurrency_case.ex # feedback B3: process-owned race connections only
test/football_market/catalog/constraints_test.exs # existing concurrent tests only
test/football_market/statistics/{input,count,storage,integrity,concurrency,history,scope}_test.exs
```

**Structure Decision**: Statistics owns normalized domain inputs, schema changesets and reads through Repo. Catalog owns current affiliation. Reuse DataCase/CatalogCase; add deterministic fixture helpers, not a runtime seed. Keep web, worker and external adapter trees outside the implementation boundary.

## Phase 0 — Feature Research

Complete in research.md. Only unresolved concrete risks were relational mutation races and lossless timestamp behavior. Inspected existing catalog constraints and installed Ecto adapter/type; consulted focused PostgreSQL documentation. Feedback-specific inspection finds that Input.identity/1 accepts NUL and scoped lookup sends it to SQL; existing Catalog workers execute inside a parent unboxed_run without establishing their own ownership. The reported owner exit must be causally reproduced in development before repair; this inspection is not a passing reproduction. ADR-0012 bounds that repair. No settled technology research was delegated. Metrics stay as FR-006 facts; unavailable provider coverage stays nil for later ingestion.

## Phase 1 — Design

Data-model.md defines tables, exact counts, private integrity witnesses and named constraints. Contracts/statistics-context.md defines trusted callable functions, errors, batch shape, lookup semantics and rejection interfaces. Quickstart.md and verification.json define executable acceptance, services and developer/QA responsibilities.

Writes and scoped identity reads validate original strings before any SQL or Ecto casting: require valid UTF-8, reject embedded U+0000 as invalid_identity on match_identity, and retain Unicode blank rejection as required. Batch errors retain the failing zero-based envelope index. Do not rescue arbitrary Postgrex errors into fabricated validation failures. Other encodable identity content stays accepted; no ASCII restriction. Then validate original types and keys before Ecto casting; normalize identities through the same database expression for insert and lookup. Kickoff and bounds become UTC microseconds without truncation. Database NOT NULL/check constraints reject invalid persisted values; unknown metrics have no defaults. Record APIs use Ecto.Multi and translate only recognized integrity errors. Batch failure cannot leave any partial fact.

Use restrictive composite keys in ADR-0010 to enforce seasons during concurrent catalog writes. Copy season witness values from the actual catalog row inside the insertion transaction; stale values must fail rather than silently reinterpret season meaning. Match participants are immutable; the performance insertion trigger validates event-time participation. UPDATE/DELETE triggers reject even no-op changes. Catalog deletion changesets map new references to established errors; display changes and valid current affiliation changes remain allowed.

History uses exact player identity, inner joins to immutable matches, optional inclusive predicates on UTC kickoff and stable normalized identity ordering. Do not join current team/position as historical values or invent missing rows. Do not infer kickoff boundaries from season years. Internal IDs, pair reads and season-scoped identity reads distinguish invalid, unknown and absent as the contract requires.

## Acceptance and Test Strategy

Write failing tests before each behavioral implementation. Input/count unit matrices cover every metric independently: positive, zero, nil/omitted optional, missing minutes, negative, fraction, float 1.0, strings, booleans and unknown keys. Integration fixtures cover five leagues and two seasons, empty match, zero-minute participation with positive counts, 90/123+ minutes, all retained values and offset/fraction precision.

Integrity tests use direct repository/SQL writes as well as context APIs: all normalized duplicate forms, cross-season references, nonparticipants, same home/away team, unknown position/player, immutable UPDATE/DELETE and protected catalog key mutation/deletion. Raw failure assertions use savepoints or separate transactions so a poisoned PostgreSQL transaction cannot masquerade as later successful evidence.

Concurrency tests use separate connections and committed fixtures with isolated fixture ownership, deterministic barriers and bounded timeouts; never shared Sandbox ownership as proof. Verify exactly one duplicate winner and unchanged existing rows for both matches and performances, plus catalog-key mutation versus insertion in both interleavings. Run actual race cases only with MIX_TEST_PARTITION=statistics_concurrency, using Sandbox unboxed connections. When invoked by the default full suite/profile, this file defines a driver test that launches the same file in a child Mix process with that partition and asserts successful nonempty race results. Clear inherited CP1_PROFILE, CP1_PROFILE_COVERAGE, CP1_PROFILE_RECEIPT and CP1_PROFILE_SENTINEL_PATH in the child environment so the child cannot overwrite parent profile/coverage evidence. In the dedicated partition, define the actual race tests instead of the driver (prevent recursion). Reuse existing league/position rows and create uniquely scoped season/team/player fixtures for each run; retain append-only fixture facts in this dedicated guarded test partition, with assertions scoped to generated IDs. Do not disable triggers, reset the database or delete accepted fixture facts. Register connection/task cleanup before spawning.

Feedback B3 extends only `test/football_market/catalog/constraints_test.exs`, new `test/support/catalog_concurrency_case.ex`, and Statistics scope assertions to permit those exact paths. Do not modify Catalog production behavior, shared DataCase ownership defaults, connection-pool settings, exclusion tags or suite selection. Reproduce both existing Catalog races, including full-regression ordering, and record the owner lifecycle causing failure. Every concurrent worker establishes and releases its own unboxed connection inside its lifetime; a parent connection or shared Sandbox allowance is insufficient. Assert distinct PostgreSQL backend PIDs, synchronize both workers at a bounded readiness barrier and await results before cleanup. Retain exactly-one-success/one-changeset-conflict assertions for league, season, team, position and player, plus original-row preservation. Scope count and cleanup to fixture IDs; never globally delete tables or reset databases. Run the Catalog module's two real races in a guarded catalog_concurrency partition; default suite/profile execution uses an asserting child driver clearing the same CP1 receipt/coverage environment variables as Statistics. The driver must execute both cases, assert nonempty success, propagate any worker/child error, and avoid recursion. Register cleanup before launch. Only remove fixture-owned unreferenced Catalog rows in FK order; never disable immutable protections or delete historical statistics. Repeated focused execution and the required complete regression must pass after repair. The implementation handoff records causal evidence rather than declaring the defect unrelated because its file was unchanged.

B2 tests must be ordinary maintained unit/integration regressions, adapted from the independent QA malformed_identity_test.exs reproducer, not a new dependency on QA artifacts. Cover NUL at start/middle/end, invalid UTF-8, valid Unicode identities, field-safe record_match/get_match errors and a late failing batch after valid match/performance envelopes; assert zero partial changes and unchanged accepted facts. Preserve all 25 Unicode White_Space normalization cases and corrective-migration safeguards.

History tests prove every US3 scenario plus fractional facts +/-1 microsecond around bounds, equivalent offsets, two same-day matches, tie ordering, inverted/invalid bounds and separate season identities. After current affiliation changes, old fields remain identical and a new valid team-B performance succeeds. Tests run with no configured provider and no adapter path in Statistics; scope checks inspect module dependencies and verify excluded web/valuation/trading files remain untouched.

| Specification scenarios | Executable test artifact | Manifest checks |
| --- | --- | --- |
| US1.1–4; SC-001, SC-005 | storage_test.exs, input_test.exs, count_test.exs | storage, input |
| US2.1–7; SC-002, SC-004 | integrity_test.exs, concurrency_test.exs | integrity, concurrency, catalog_concurrency |
| US3.1–5; SC-003–005 | history_test.exs | history |
| FR-012 complete matrices / FR-013 scope | all above, scope_test.exs | feature_scope, profiles, regression |

Spec contains 13 FR and five SC identifiers; numbered story scenarios have no AC identifiers. Map them without editing spec or inventing identifiers. Developer executes every manifest check through agentflow_check.py after all source changes; QA reruns independently. Only QA/review tasks may remain deferred. No affected HTTP interface exists, so runtime_required is false; adding one violates FR-013 and would require a new product specification and runtime assertions.

## Product Invariants and Checkpoint Coverage

CP2 contribution is persisted/tested normalized valuation inputs and documented internal interfaces, with existing green build/test profiles/coverage checks preserved. It does not complete CP2 valuation, quotes, trading, operation history or ranking. CP1 auth/OpenAPI/catalog remain regression protected. CP3 advanced metrics and architecture obligations are not introduced here.

Token supply, integer money, atomic/idempotent trades, immutable financial audit and inserted quote history stay owned by existing/future contexts. Stats deliberately reject duplicates; import retry idempotency is TASK-021. Local reads have no provider dependency. Reproducibility requires TASK-022 and later quote work to capture exact selected input membership or equivalent immutable evidence and test late-arriving facts; immutability of these rows alone is insufficient. This is a durable dependency, not extra current implementation.

## Complexity Tracking

No constitutional exceptions. ADR-0012 records the approved test-only boundary extension; it changes no product scope. Private relational witness columns and two focused database triggers replace wider catalog freezes or new historical/provenance entities. Count's custom exact type avoids coercion and duration ceilings using an existing dependency.

## Delivery amendment — pinned PostgreSQL parity (2026-10-04)

TASK-020's remote Quality baseline fails on the corrective generated-column migration: its existing service uses PostgreSQL 16, while this plan and `compose.yaml` require PostgreSQL 17.6. The migration's `SET EXPRESSION` requires the planned PostgreSQL 17 environment. Align the existing CI service to the exact local image `postgres:17.6-alpine@sha256:ef257d85f76e48da1c64832459b59fcaba1a4dac97bf5d7450c77753542eee94`. This restores the settled infrastructure boundary; it does not introduce a service, change product behavior or authorize a migration rewrite.

The additional implementation boundary is `.github/workflows/quality-baseline.yml` (only the PostgreSQL image), `test/ci/quality_baseline_contract_test.exs` (replace the obsolete PostgreSQL 16 assertion with a focused parsed-service assertion of the exact pinned image and equality with the PostgreSQL service image in `compose.yaml`), `test/ci/fixtures/quality-baseline.sha256` (refresh the workflow fingerprint after independently confirming that only the image changed), and `test/football_market/statistics/scope_test.exs` (permit those two exact CI test/fixture paths, without permitting the entire CI tree). Keep the existing fingerprint enforcement and every other quality/security assertion. `compose.yaml` stays authoritative and unchanged. A focused failing contract before the image change protects against recurrence without adding a new test framework or broadening suite selection.

Developer evidence must include the failing then passing image contract, passing existing SonarCloud/fingerprint contracts, formatting and compilation, migration preparation/storage/integrity checks on PostgreSQL 17.6, feature scope, and the complete regression after final stabilization. Update `verification.json` only to add the focused CI contract check; retain every existing required check and execute the complete manifest for fresh gates. No skips, success masking, credential or permission changes, dependency updates, pool changes or product repairs are included.

Append-only tasks T030–T034 below govern this delivery correction. Earlier completed tasks and QA/review PASS evidence describe the earlier revision only; they do not verify this amendment. Fresh independent QA and final review must inspect the final revision and end in `Verdict: PASS` before publishing the correction. Delivery then additionally requires green remote CI for the published PR revision; human merge authority remains unchanged. Architecture performs no implementation, publication or gate declaration.

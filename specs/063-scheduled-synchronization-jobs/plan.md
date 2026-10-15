# Implementation Plan: Scheduled Synchronization Jobs

**Branch**: `019-scheduled-synchronization-jobs` | **Date**: 2026-10-15 | **Spec**: [spec.md](spec.md)
**Task**: TASK-019 · CP2. Git branch is 019; the setup helper reports the 063 feature binding. `.specify/feature.json` authoritatively binds this 063 directory.

## Summary

Add a trusted `FootballMarket.Synchronization` context and local Oban runtime. PostgreSQL atomically admits runs and queue work, coordinates normalized league seasons, stores attempts, immutable input identities and due occurrences, and retains history without pruning. Workers call the existing `Catalog.Ingestion.import_catalog/2`; no second provider boundary exists. ADR-0025 resolves all four product-challenge findings. No product clarification remains.

## Technical Context

**Language/Version**: Elixir 1.20.3 / OTP 29.0.6 from `.tool-versions`.
**Primary Dependencies**: existing Phoenix 1.8, Ecto SQL 3.13, Postgrex, Jason; introduce open-source Oban `~> 2.24.2` and lock its resolved dependency graph. Oban is mandated infrastructure, not a stack selection. Use its PostgreSQL engine, transactional insertion, one-shot catalog delivery jobs and a supervised reconciliation tick. No Pro dependency, new broker or network transport.
**Storage**: existing PostgreSQL; Oban tables plus synchronization ledgers and ingestion receipts. Redis is irrelevant to execution correctness.
**Testing**: ExUnit, existing unit/integration discovery, deterministic provider fixtures and clock, real independent PostgreSQL connections, actual process/node restart probes, loopback HTTP assertions.
**Target Platform**: one local application instance with PostgreSQL and optional Redis for this feature; preflight existing regression dependencies separately.
**Project Type**: modular Phoenix monolith with internal operator API; no new route/UI.
**Performance Goals**: asynchronous acceptance without retrieval; ten competing callers converge; bounded execution defaults to one catalog attempt. No new latency SLA.
**Constraints**: disabled schedule; UTC daily default; three total attempts with waits >=60/300 seconds; preserve provider minimum delay, access gates and TASK-018 semantics. Every begun interrupted attempt consumes budget. No credentials or raw payload in jobs/history.
**Scale/Scope**: five supported leagues and explicit seasons; independent budgets/scopes. Downstream statistics/TTL/orders/valuation/trading/UI remain separate tasks.

## Constitution Check

| Principle | Before research | After design |
|---|---|---|
| Specification first | PASS: complete spec and product decision loaded | PASS: numbered scenarios mapped in tasks and quickstart; no behavioral expansion |
| Domain integrity | PASS: PRODUCT invariants authoritative | PASS: ingestion transaction retained; receipt is metadata, no monetary/quote/statistics writes |
| Modular simplicity | PASS: existing monolith/Oban decision | PASS: internal facade, pure policies, persistence store, worker and existing adapter separated |
| Evidence quality | PASS: deterministic acceptance required | PASS: verification manifest, RED-first tasks, DB recovery and real HTTP assertions planned |
| Independent verification | PASS: challenge read; human_check_required false | PASS: only final QA/review deferred; neither claimed executed |

No unjustified constitutional violation. ADR-0025 documents the narrow ingestion receipt extension and explicit job-ledger ownership; this does not relax reconciliation, limits or access rules.

## Project Structure

Documentation: `plan.md`, `research.md`, `data-model.md`, `contracts/internal.md`, `quickstart.md`, `verification.json`, `tasks.md`, `handoffs/architecture.md`, `handoffs/tasks.md`; durable decision `docs/adr/0025-durable-catalog-synchronization.md`.

### Exact implementation inventory

New files (brace lists below enumerate exact paths, not open-ended allowances):

- `lib/football_market/synchronization.ex`
- `lib/football_market/synchronization/{input,policy,clock,run,attempt,trigger,schedule,occurrence,store,execution_guard,scheduler,recovery,dispatcher}.ex`
- `lib/football_market/workers/catalog_sync.ex`
- `lib/football_market/catalog/ingestion/delivery_receipt.ex`
- `config/synchronization.exs`
- `priv/repo/migrations/20261015000000_add_oban.exs`
- `priv/repo/migrations/20261015000100_create_synchronization_ledgers.exs`
- `priv/repo/migrations/20261015000200_create_catalog_delivery_receipts.exs`
- `test/support/synchronization/{case,clock,fixtures,runtime_probe}.ex`
- `test/fixtures/synchronization/expected.exs`
- `test/football_market/synchronization/{input,policy,migration,request,inspection,scheduler,concurrency,retry,recovery,integrity,scope}_test.exs`
- `test/football_market/catalog/ingestion/delivery_receipt_test.exs`

Existing files permitted only for integration:

- `mix.exs`, `mix.lock`: dependency and lock only.
- `lib/football_market/application.ex`: supervised Oban/dispatcher only.
- `config/runtime.exs`, `config/test.exs`: load dedicated configuration and manual test runtime; preserve `config/config.exs` byte-for-byte (issuance's pinned safety contract).
- `lib/football_market/catalog/ingestion.ex`, `lib/football_market/catalog/ingestion/publisher.ex`: optional validated delivery context and receipt validation/write in existing publication/replay transaction; no changed reconciliation rule.
- `test/football_market/providers/scope_test.exs`, `test/football_market/statistics/scope_test.exs`, `test/football_market/market/scope_test.exs`: exact active-feature inventory allowances and negative tests only, retaining unknown-feature rejection, legacy inventories and issuance configuration hash.

No web, provider implementation, market/statistics/valuation production, CI or coverage-inventory edits. Expand inventory only for concrete evidence and document the reason before implementation.

## Phase 0 — Resolved unknowns

See [research.md](research.md). Local inspection established: Oban is absent; ingestion accepts only provider/runtime/mappings/new_players and cannot correlate a lost acceptance reply; existing scope tests reject new unrelated feature paths; config/config.exs is hash-pinned. These are addressed explicitly rather than weakening regression tests. No technology survey or research agent was needed.

## Phase 1 — Design and transaction boundaries

### Admission and accepted inputs (US1, US3)

Normalize through Providers.Request and validate instructions against TASK-018. Resolve source references using a closed configuration registry, never dynamic atom/module evaluation. Persist versioned canonical non-secret material including provider, timeout, fixture artifact digest and sorted typed reconciliation instructions; compare full material after digest lookup. Trigger is excluded from equivalence. Preserve the original run's retry policy on coalescing; a new caller's policy never mutates accepted work. Reject invalid source/policy even when an active run exists.

Under a per-scope transaction advisory lock and partial unique active-scope index, return the equivalent run or safe scope-busy. A new run, trigger association, prepared delivery record and one-shot Oban job are committed together; acknowledge only after commit. Store failure rolls back and returns unavailable without a usable ID. Jobs contain only run/attempt IDs. No retrieval in admission. Terminal runs release active uniqueness; associations/history remain.

### Execution and receipts (US1, US3)

Catalog queue limit defaults to one. A worker acquires a PostgreSQL session advisory execution lock for its scope and one configured global execution slot using a dedicated connection owned by an execution guard monitoring that worker. Explicit unlock/connection termination on normal exit, worker death, timeout or runtime stop is mandatory; never leave session locks on pooled connections. Failure to acquire releases capacity and defers delivery without consuming a domain attempt. Reconciliation uses these same locks, so a live owner is not declared interrupted merely because it is slow.

Under row locks, claim the prepared delivery once, increment numbered attempt budget immediately before execution, and persist executing state/start. Resolve the pinned input artifact again, compare identity, and revalidate current access before retrieval; drift/missing config fails safely, never uses edited settings or cached authorization. Call ingestion outside a long database transaction; it captures a fresh revision per actual attempt.

The optional ingestion delivery context contains a UUID receipt/fence, not callbacks or raw data. Publisher validates its still-prepared state and scope under receipt row lock, then writes the confirmed safe Outcome in the SAME transaction as acceptance or exact replay. A revoked fence cannot publish; callers omitting context preserve existing behavior. Receipt metadata never changes delivery identity. No controller/provider/synchronization dependency is introduced into the ingestion publisher: DeliveryReceipt owns this neutral internal protocol.

Completion copies only confirmed safe receipt data into history. If completion fails, do not undo publication. Duplicate deliveries cannot claim the same attempt twice. Oban `max_attempts: 1` applies to each delivery, while the run ledger exclusively owns the finite domain budget. Persist retry outcome, deadline and next prepared delivery/job atomically; return safe handled completion to Oban after bookkeeping. Infrastructure exceptions must not leak exception text to job errors; sanitize worker boundaries. Oban completion cannot determine business success.

### Recovery and bounded retries (US3)

A boot/periodic dispatcher reconciles accepted pending work, expired waits and orphaned execution, even when scheduling is disabled. It never imports an empty scope implicitly. Acquire execution locks before recovering; revoke an orphan's prepared fence transactionally before allocating another attempt. Receipt confirmed => finish original run without provider work, including attempt three. No receipt => record interrupted/unconfirmed and consume the begun attempt. Below budget, persist the full retry wait from detection (conservative, never shortens a known deadline); at budget mark failed/exhausted-unconfirmed with deliberate manual recovery guidance. No fourth import or inference from current catalog content.

Use a bounded worker timeout greater than the configured provider deadline plus bounded bookkeeping allowance; validate it against policy. A guard connection loss can release locks before a suspended worker exits: recovery revokes the old receipt fence, and Publisher's row check prevents stale publication after revocation. Publication that acquired the receipt row first commits confirmed evidence before recovery decides. Normal execution is coordinated; exceptional redelivery still relies on TASK-018 reconciliation and fencing, not exactly-once claims.

Retry only provider retryable categories, transient persistence/concurrent_change and interrupted execution. Unclassified, drift, stale, invalid, denied and conflict outcomes terminate. Retry deadline is failure/detection UTC + max(local wait, ceiling(provider retry_after_ms/1000)); persist exact deadline. Retry-wait holds neither queue capacity nor execution locks. Dispatcher may repair missing/exhausted delivery jobs for a prepared attempt without inventing a begun domain attempt; claims and unique delivery IDs prevent duplicate starts. History is never automatically pruned; do not enable Oban pruning of feature work in CP2.

### Scheduling (US2)

Persist enabled intervals and per-scope UTC progress; operator configuration is applied transactionally, with a new generation on re-enable or changed recurrence/input definition. Default disabled, daily 00:00 UTC when enabled. Accept validated five-field UTC cron expressions using Oban's parser; reject impossible recurrence/no computable next instant. A pure recurrence function calculates latest due >= enabled_at; no backfill before enablement, including exact-boundary tests. Dispatcher ticks on boot and bounded polling (default 15 seconds) using injected UTC time; PostgreSQL history, not an in-memory timer or cron insertion, owns due identity.

Lock the schedule/generation row before scope admission, and make admission plus occurrence association atomic. Unique `(schedule_id,generation,scope,due_at)` includes terminal/coalesced runs. Persist a single latest unhandled candidate per scope plus compressed supersession ranges with recurrence identity; repeated busy ticks do not append unlimited duplicate rows. An incompatible active run leaves latest candidate pending. If newer due instants arrive, supersede older pending candidates and admit at most the latest. An equivalent active run handles that occurrence permanently, even if it later fails. Disabled generations admit nothing; accepted runs continue. Distinct schedule definitions targeting the same scope use ordinary scope coordination.

### Operator interface and boundaries

See [contracts/internal.md](contracts/internal.md) and [data-model.md](data-model.md). Inspection is by run ID and normalized scope with bounded deterministic pagination, safe categories and retained associations. No route/dashboard/permission model. Existing catalog HTTP reads are affected only as an availability invariant, so the runtime probe exercises authenticated local reads during queued and failed work with status/header/body and zero-provider-call assertions.

## Verification and checkpoint coverage

[quickstart.md](quickstart.md) maps all 18 numbered story scenarios and critic boundaries to independently authored tests. [verification.json](verification.json) maps all 16 FR and seven SC IDs (spec has no AC-prefixed IDs) to concrete checks. Unit and integration profiles run once each after edits; new tests join exactly one profile. Separate runtime probe is outside test discovery and adds actual HTTP/process boundaries. Required toolchain, service readiness, formatting, compilation and whitespace checks are included. No historical CP1 coverage report is required; CI/coverage infrastructure is preserved.

CP2 contribution is durable local infrastructure and offline evidence. It does not claim full browser E2E, charts, conditional orders, usable live source access or completion of CP2. QA independently reruns acceptance checks; final review assesses fresh QA evidence and targeted risks. Implementation owner completes every non-gate task before QA.

## Complexity Tracking

No constitutional deviation. The execution ledger, receipt fence and occurrence cursor address concrete crash/configuration risks; Oban uniqueness, catalog-content inference and in-memory timers cannot satisfy these requirements. ADR-0025 records the durable decisions and alternatives.

## Implementation decisions

The inventory above is unchanged. `Schedule.definition.previous_generations` retains each replaced enabled interval's canonical input, policy and recurrence so compressed supersession evidence remains interpretable after reconfiguration. The dispatcher recovers accepted work before applying schedule configuration; disabling the global scheduler persists disabled intervals without cancelling accepted runs.

`config/runtime.exs` loads the dedicated configuration with `Config.Reader` because runtime configuration disallows `import_config`; `config/config.exs` remains byte-identical. Source identity and advisory keys use deterministic external-term encoding. SQL admission locks use `Repo.query!` so dynamic-repo acceptance tests coordinate the same transaction they modify.

The runtime probe owns a disposable PostgreSQL schema, a real loopback listener, disposable BEAM children and a Redis container from the exact compose image. It drains real Oban delivery jobs, verifies application/schedule restart, aborts before publication and during third-attempt completion, and clears/reconnects only its own Redis. Test-only clock/failpoint seams are compiled out of production. No new production service is added.

Development's temporary targeted manifest checks are consolidated into the final unit/integration profiles; their helper receipts and RED output remain available locally. Final checks additionally include executable Node 24/Chromium preflight. No required behavior or regression is removed from the final profiles.

The retained provider Mix guard permits only the exact Oban dependency in the active feature's dependency AST. Negative regressions still reject another Oban version, duplicate insertion and unrelated dependency changes; test discovery remains unchanged. The redaction fixture returns a malformed provider result directly, preserving the existing contract distinction between invalid responses and retryable adapter exceptions.

Dispatcher configuration reconciliation disables persisted schedules whose keys were removed from the configured list before admitting due work. Accepted runs remain recoverable; re-adding a removed definition opens a new enabled interval. `scheduler_test.exs` covers this FR-006/007 regression.

Feedback B1: source resolution validates the effective runtime tuple and all six provider runtime callbacks without invoking them; an omitted runtime retains the provider default. Manual/initial and schedule configuration share this rejection before persistence. Due dispatch re-resolves and compares pinned effective inputs before admission, rolling back invalid or drifted configuration without handling the occurrence. Restoring the original configuration permits later admission. No provider implementation or access authorization changes. Maintained input/request/scheduler regressions cover malformed, unavailable and incomplete runtime modules, valid explicit/default runtime, zero executable work and scheduled recovery. Final unit/integration mappings continue to cover FR-002/006/007 and US1.3.

## CI repair verification boundary — 2026-10-15

Provider scope dependency approval must use this committed plan rather than ignored session metadata; preserve exact-version, duplicate and unrelated-dependency mutation assertions in `test/football_market/providers/scope_test.exs`. Local full verification additionally exposed the existing catalog query-plan test's 99,999-row fixture exceeding Ecto's default query timeout on pinned PostgreSQL 17.6. Permit only a 60-second timeout on that bulk fixture insert in `test/football_market/catalog/query_test.exs`; retain its full cardinality and all index-plan assertions. No production, financial, provider or synchronization behavior changes.

CI follow-up: the unfiltered CI suite passed all 525 tests but correctly failed warnings-as-errors because `test/fixtures/synchronization/expected.exs` lacked an exact `test_ignore_filters` entry. Permit that one fixture entry in `mix.exs` and the corresponding exact expected inventory in the provider scope test. The fixture remains loaded explicitly by synchronization tests; no test file is excluded. Add the actual `sh scripts/ci_unit_tests.sh` command to the verification manifest, alongside the separate profiles, because this concrete CI discovery failure is not exercised by their explicit file lists.

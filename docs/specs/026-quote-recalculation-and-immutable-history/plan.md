# Implementation Plan: Quote Recalculation and Immutable History

**Branch**: `026-quote-recalculation-and-immutable-history` | **Date**: 2026-10-17 | **Spec**: [spec.md](spec.md)

## Summary

Implement TASK-026 only: durable weekly calculation orchestration over accepted local facts, version-bound exact quote conversion, append-only evidence/history, and one recoverable TASK-060 evaluation request per confirmed quote. Reuse TASK-021 intents/dispatch, TASK-025 managed scoring/configurations and TASK-028 `market_quotes` and player locking. Approved feedback in `backlog/feedback/TASK-026.md` is authoritative. Critic findings are resolved in ADR-0029 and the error/delivery contracts below; no formula, provider, API, UI, trading or conditional evaluation implementation is authorized.

## Technical Context

**Language/Version**: Elixir 1.20.3 / OTP 29.0.6 (`.tool-versions`).
**Dependencies**: Existing Phoenix 1.8, Ecto SQL 3.13/Postgrex, Decimal, Oban 2.24.2, Jason. No dependency additions.
**Storage**: PostgreSQL authoritative; existing Oban database. Redis remains disposable infrastructure and is not used for calculation correctness.
**Testing**: ExUnit unit/integration profiles, real committed PostgreSQL races and fresh BEAM restart probes. Existing browser E2E stays in integration; no new browser surface.
**Platform/type**: Existing modular Phoenix application; trusted internal context and worker interfaces only.
**Performance**: No new throughput/SLA target. Select only affected player/season/UTC-week membership; index calculation identities and pending recovery. Perform scoring outside short final financial-lock transactions.
**Constraints**: Exact arithmetic, DB-protected evidence, deterministic fixtures, bounded retry, no provider calls. A UTC week is Monday 00:00 through the next Monday exclusive, per `Valuation.Week`.
**Scope**: One task, three P1 stories, CP2 retained dated quotes and the durable input boundary for TASK-060. CP2 charts/additional-feature presentation and CP3 cache/metrics remain separate.

## Constitution Check

Pre-design: I satisfied by approved spec/feedback and product decision (`human_check_required: false`); II requires append-only shared quote history, reproducible exact evidence, no financial mutation; III reuses monolith, ingestion, managed valuation and Oban; IV requires tests before behavior and manifest evidence; V reserves independent QA/review for downstream fresh sessions. No unresolved product decisions or constitution exceptions.

Post-design: same gates satisfied by the design, not claimed as implementation proof. DB guards extend the ADR-0010/0023/0024 boundary. ADR-0029 records the scoped interface extensions. All executable checks belong to implementation before independent QA; both reports must end `Verdict: PASS`. No publishing in this stage.

## Supporting artifact decisions

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve concrete gaps in import membership pinning, managed evaluation and shared quote storage using local implementation inspection."},
  "data_model": {"required": true, "reason": "Adds immutable membership, conversion mappings, calculation evidence/outcomes and durable quote follow-up; extends existing quotes."},
  "contracts": {"required": true, "reason": "Extends internal ingestion/valuation and introduces a stable TASK-060 delivery boundary; no HTTP interface."},
  "quickstart": {"required": true, "reason": "Feature requires explicit scale/configuration, initialized-player fixtures and crash/restart validation."}
}
```

## Project Structure and implementation boundary

Documentation: this directory's `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/calculation.md`, `quickstart.md`, `verification.json`, `tasks.md`, and concise `handoffs/architecture.md` / `handoffs/tasks.md`. New durable decision: `docs/adr/0029-pinned-quote-calculations-and-durable-followup.md`.

Production additions: `lib/football_market/quotes.ex`, `lib/football_market/quotes/{schemas,store,membership,conversion,mappings,evidence_codec,calculation,recovery}.ex`, `lib/football_market/workers/quote_calculation.ex`, and `priv/repo/migrations/20261018000000_create_quote_calculations.exs`. Forward-only migrations `20261018000300_reconcile_quote_import_snapshot_schema.exs`, `20261018000400_reconcile_quote_import_snapshot_facts.exs` and `20261018000500_reconcile_quote_mapping_schema.exs` repair databases where earlier migrations were recorded before their complete snapshot or mapping schemas were introduced.

Allowed existing changes: `lib/football_market/statistics/ingestion/publisher.ex` (atomic snapshot insertion only), `lib/football_market/valuation/{calculation_requests,managed,statistics_reader}.ex` plus `valuation.ex` (pinned managed entrypoint), `lib/football_market/workers/calculation_dispatch.ex` (receiving/enqueue recovery), `lib/football_market/market/quote.ex` (shared quote fields), `lib/football_market/application.ex`, `config/synchronization.exs` and `config/runtime.exs` (worker recovery and explicit mapping UUID). No broad ingestion or strategy redesign. Contexts own orchestration; persistence modules own SQL; workers call contexts; no web/provider changes.

Tests: `test/football_market/quotes/*_test.exs`, `test/support/quotes/{case,fixtures,runtime_probe}.ex`, `test/football_market/statistics/ingestion/calculation_test.exs`, and `test/football_market/valuation/configurations/managed_test.exs`. The shared quote-shape migration also requires exact compatibility updates to `test/support/market_case.ex` and `test/football_market/market/{retry,concurrency,rejection}_test.exs`, plus forward-only reconciliation migrations `priv/repo/migrations/20261018000600_reconcile_quote_calculation_requests.exs` and `priv/repo/migrations/20261018000700_reconcile_quote_calculation_attempts.exs` for already-migrated databases; these keep malformed direct quote writes rejected and preserve issuance invariants. Forward-only `20261018000800_reconcile_quote_request_requested_mapping.exs` retains the supplied unavailable mapping UUID; `20261018000900_reconcile_legacy_quote_admission.exs` protects that identity and permits only terminal unreproducible import requests without snapshots. Forward-only migrations `20261018001000_protect_quote_evaluation_deletion.exs` and `20261018001100_require_successful_quote_confirmation.exs` enforce the existing append-only event and deferred successful-result/quote/event invariants on already-migrated databases. Legacy request scope comes solely from original changed fact references; no full membership is inferred. The existing `test/support/valuation_configuration_case.ex` migration helper suppresses only expected module redefinition during repeated private-schema migration, restoring compiler options afterward. Register newly committed fixtures in `test/support/test_profile_audit.ex`; extend only exact feature allowances in `test/support/workflow_scope.ex` and existing `test/football_market/{statistics,providers,market,synchronization}/scope_test.exs` guards when required. Do not weaken global boundaries. Add `scripts/verify_quote_runtime.exs` as a development/QA assertion driver; implementation writes it, architecture only specifies it.

## Phase 0 — resolved unknowns

See `research.md` for bounded local evidence. Existing intents contain changed IDs, not complete weekly membership. Managed evaluation currently selects today's facts. Shared market quotes already support noninitial rules but lack calculation linkage and deterministic performance ordering. These concrete gaps require the extensions below. Technology, formulas, provider contracts and strategy lifecycle reuse ADR-0013/0020/0021/0022/0023/0024/0028; no external research needed.

## Phase 1 — design

### Admission and membership

While the existing import transaction holds its season advisory lock, after inserting all accepted facts, derive distinct affected player/season/weeks from newly accepted performance rows. Persist complete accepted membership for each such week, including earlier accepted rows, as immutable children of the existing calculation intent. Sort canonical membership by kickoff, match identity and performance UUID exactly as Preparation does; retain immutable references plus typed snapshots. Rollback of acceptance rolls back snapshots and intent. Unchanged/replayed imports add none. No second import runtime or provider boundary.

`CalculationRequests.accept/3` remains compatible and idempotent by intent ID/check ID/changed IDs. Receiving creates or locates one durable calculation request per snapshot and enqueues worker jobs transactionally. Intent delivery is distinct from calculation completion. Recovery scans both undispatched intents and unbound/pending/expired-lease requests; durable rows, not Oban uniqueness alone, determine processed state.

New explicit trusted admission first returns an existing matching request UUID or rejects conflicting reuse; for a new request it validates the scope and strategy selector, persists a fixed configuration and mapping UUID, then snapshots current accepted membership under the same season lock. Imported requests retain pinned membership at acceptance, but resolve the active strategy exactly once on their first calculation start, before loading valuation fact values. Persist that binding and mapping before evaluating; retries never resolve active again. Missing selection/mapping leaves a terminal safe admission outcome; no inferred scale. Explicit version selection never activates it. Legacy pending intents without snapshots must reconstruct original complete membership only from demonstrable retained acceptance evidence; otherwise record `unreproducible` and require a distinct explicit fresh request, never silently use latest membership.

### Identity and scoring

Unbound delivery requests have durable request IDs, not invented incomplete logical identities. Once fixed, a calculation's unique canonical material is player/season/week bounds + ordered immutable membership + saved configuration UUID/formula version + mapping UUID/version. Store full canonical material with a digest; compare material on digest conflict, fail safely on mismatch. Multiple import/explicit request IDs may link to one calculation. Unique DB constraints and row locks resolve concurrent admission. Effective time is excluded from identity; an exact retry returns the original outcome even after active selection changes.

Add a managed pinned-membership evaluator that resolves the fixed saved version, verifies retained original facts using `StatisticsReader.originals`, and uses existing Request/Preparation/Scoring logic. It must not call the current-membership selector. Reuse the existing managed descriptor/replay binding and typed configuration codec conventions; no alternate scorer. Extend only the envelope codec for persisted descriptors and for error evidence where existing Preparation returns no descriptor. Retain valid supplied scope, frozen membership, original rules, mapping and safe outcome even when score is absent; unavailable bindings are explicitly absent in admission failures, never fabricated.

### Exact conversion and commit

Mappings are immutable trusted saved records with explicit positive finite Decimal scale, mapping name/version and fixed `two-half-away-v1` rule. Unique name/version identifies one unchanged mapping; no seeded production default or management API. Automatic requests use the explicitly configured mapping UUID fixed on first start; explicit requests name it directly. Missing/invalid mapping fails closed. Saving/inspection is internal; changing a scale requires a new version.

Multiply score and scale via integer coefficients/exponents (reuse DecimalMath conventions), round to integer cents with ties away from zero, and construct Decimal without ambient-context truncation. Score <= 0 or cents <= 0 produces `no_quote`, no price/floor. A negative rounded product cannot arise for positive score and positive scale: test negative raw scores and invalid negative scale separately rather than inventing a valid negative mapping.

After scoring, acquire the existing player lock before the calculation row in the final transaction. Revalidate initialized issuance, fixed evidence, lease fencing and logical uniqueness. Insert immutable result/evidence, append to shared `market_quotes`, and insert one evaluation request keyed by quote UUID in the same transaction. DB guards verify matching player/configuration/mapping/evidence, successful positive two-decimal result, and the one-to-one quote/follow-up relationship at deferred commit. Direct writes cannot insert a performance quote without both. Keep initial quote rule and issuance linkage intact. Quote insertion obtains an increasing per-player performance sequence while holding the player lock; latest local selection uses sequence (initial record treated as sequence zero), not timestamp ties. Effective time is DB UTC sampled under that lock, retained unchanged on retry. No new public quote API or mutable current-price pointer.

Distinct membership/configuration/mapping appends a quote and event even at the same price. A failed/no-quote result emits neither. Pre-commit failure rolls back all confirmation effects; post-commit lost acknowledgement returns the existing immutable result. No holds/balances/trades or statistics/strategy rows are modified.

### Outcomes, attempts and recovery

Exact classification is in `contracts/calculation.md`. Pending/running and retry schedules are mutable fenced projections; identity/bindings, each attempt and terminal evidence/result are protected. Three attempts maximum, retry delays 60 then 300 seconds for temporary persistence/worker failure only. Persist attempt reservation before work, use a five-minute lease and monotonically increasing fence; recovery records interrupted attempts before rescheduling, including exhausted on the third interruption. Expired workers cannot confirm or overwrite a newer outcome. All code locks player before calculation for confirmation; claiming only locks calculation briefly and releases before acquiring a player lock. Reject caller-owned transaction nesting for APIs claiming durable confirmation. Recovery is scheduled through existing application/Oban patterns, not an external service.

Safe reason enums only; no raw provider data, exception text, executable modules, arbitrary atom decoding or credential-bearing logs. After storage outage prevents recording, the previously durable pending/leased request remains recoverable; never claim a recorded temporary error if its write failed.

### TASK-060 handoff

One immutable evaluation request per committed quote, stable idempotency key `quote-evaluation:<quote_uuid>`. Expose pending inspection and safe delivery-attempt/acknowledgement functions, with separate delivery state and recoverable leases. TASK-026 does not execute conditional orders or acknowledge unconsumed work. TASK-060 must atomically deduplicate effective evaluation by quote UUID in its own transaction, acknowledge only after durable consumption, and handle redelivery. Pending requests survive indefinitely until a consumer exists. This is at-least-once delivery with exactly one durable request, not a claim of exactly-once external execution.

## Validation and checkpoint alignment

`verification.json` maps every FR/SC in spec (there are no AC identifiers) to executable checks. Unit conversion/codec tests and integration acceptance/concurrency/immutability tests run within each existing full profile exactly once per stage; feature runtime is a separate targeted fresh-BEAM assertion driver, not a duplicate full profile. A focused `quote-regressions` manifest check exercises admission, import, recovery, follow-up, immutability, outcome and original replay assertions before full profiles. Include formatting, warnings-as-errors compilation, existing profile audits/static scope checks and infrastructure preflight. Preserve historical coverage infrastructure/CI, but do not add `test.cp1_coverage` or `coverage_report.sh` as an extra CP2 gate.

No HTTP endpoint is introduced or modified and `contracts/calculation.md` is an internal contract, so no HTTP assertion check is applicable. Runtime checks still fail on unavailable PostgreSQL/Redis and assert durable quote/evidence/follow-up after fresh application restart, recovery after import commit, and unchanged financial state. If implementation changes an HTTP interface, first align spec/plan/contracts/manifest and add readiness plus status/header/body assertions before QA.

Traceability: US1 covers FR-001/002/003/006 and SC-001/006; US2 covers FR-004/005/010/011/012 and SC-002/003/007; US3 covers FR-007/008/009/013 and SC-004/005. Cross-cutting FR-014/015 enforce scope and the complete matrix. Every numbered scenario is assigned to tasks/tests. Product invariants: supply 100 and holdings unchanged; exact money; atomic/idempotent quote confirmation; protected audit/history; original replay; offline local reads. Trading idempotency is preserved, not implemented here.

## Complexity Tracking

No constitution violations. Membership snapshot children and a durable quote outbox extend existing tables/interfaces because changed IDs alone lose original weekly membership and in-memory notifications lose committed work. No second quote store, second scheduler, new service or formula is warranted.

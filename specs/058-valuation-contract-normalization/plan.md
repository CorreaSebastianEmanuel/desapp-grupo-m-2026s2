# Implementation Plan: Valuation Engine Contract and Normalization

**Delivery branch**: `022-valuation-engine-contract-and-normalization` | **Date**: 2026-10-13 | **Spec**: [spec.md](spec.md)
**Binding**: `.specify/feature.json` selects `specs/058-valuation-contract-normalization`; setup reports logical feature branch `058-valuation-contract-normalization`. Preserve the delivery branch.
**Backlog**: TASK-022, CP2, depends on TASK-020. [Feedback 1](../../backlog/feedback/TASK-022.md) is authoritative.

## Summary

Add internal `FootballMarket.Valuation` preparation/scoring/replay over immutable local Statistics facts. Select one explicit half-open UTC week, sum counting metrics, normalize against explicit positive references, group historical positions and invoke an explicitly supplied trusted scorer. Return canonical evidence; replay exact original membership against authoritative facts. No production strategies or result persistence. Resolve all three [critic findings](handoffs/product-challenge.md) through [ADR-0020](../../docs/adr/0020-valuation-evidence-and-scorer-trust-boundary.md) and [the contract](contracts/valuation-context.md).

## Technical Context

- **Language/version**: Elixir 1.20.3, OTP 29.0.6, existing Phoenix modular monolith.
- **Dependencies**: existing Ecto/PostgreSQL, locked Decimal 3.1.1. No dependency/toolchain changes; Phoenix hosts the application but is not a valuation dependency.
- **Storage**: read-only Catalog/Statistics contexts. In-memory DTOs/descriptors, no tables/migrations. Redis is existing infrastructure, unused by valuation.
- **Testing**: ExUnit unit tests and Sandbox integration tests, deterministic fixtures and illustrative reviewed scorers. Every module has exactly one explicit unit/integration profile tag. Existing integration profile retains actual browser E2E; no new browser feature.
- **Platform/type**: local BEAM application, internal domain API.
- **Performance goals**: no SLA. One bounded history read for fresh selection; replay resolves original rows only. No arbitrary count ceiling.
- **Constraints**: UTC microseconds, exact consecutive Monday bounds, no floats, deterministic ordering, six-place decimal output, no writes/providers/defaults/fallback scores.
- **Scale/scope**: nine counting metrics, overall plus four historical groups, one exact season-specific subject per request. Five leagues/two seasons are acceptance coverage. No unresolved material unknown remains; see [research.md](research.md).

## Constitution Check

| Principle | Before research | After design |
|---|---|---|
| I Specification first | PASS: reconciled spec and authoritative feedback read | PASS: scenarios/FR/SC traced in contract and acceptance map |
| II Domain integrity | PASS: immutable replay and exact money-related arithmetic required | PASS: original fact validation, exact arithmetic, no financial/history writes |
| III Modular simplicity | PASS: reuse monolith and ADR-0002/0010/0011 | PASS: Valuation consumes domain contexts; pure preparation/scorer view; no new services |
| IV Evidence quality | PASS: every behavior requires tests | PASS: test-first tasks, executable map, scope tests and two existing profiles |
| V Independent verification | PASS: challenge/disposition read; no human check outstanding | PASS: developer checks before fresh QA/review; both terminal PASS verdicts required |

These are design conformance conclusions, not implementation/test PASS claims. No constitution exception. Product invariants 1 and 3–6 are protected by no token/trade/audit/quote writes and no provider access; invariant 2 by exact arithmetic, invariant 7 by original-membership replay. Durable contract refinements and bounded test boundary additions are in ADR-0020.

## Project Structure

Feature artifacts: plan.md, research.md, data-model.md, quickstart.md, contracts/valuation-context.md, contracts/acceptance-map.md, verification.json, tasks.md, handoffs/architecture.md and handoffs/tasks.md.

Exact allowed implementation inventory:

```text
lib/football_market/valuation.ex
lib/football_market/valuation/types.ex
lib/football_market/valuation/error.ex
lib/football_market/valuation/request.ex
lib/football_market/valuation/week.ex
lib/football_market/valuation/statistics_reader.ex
lib/football_market/valuation/preparation.ex
lib/football_market/valuation/position_groups.ex
lib/football_market/valuation/decimal_math.ex
lib/football_market/valuation/scorer.ex
lib/football_market/valuation/scoring.ex
lib/football_market/valuation/evidence.ex
lib/football_market/valuation/replay.ex
test/support/valuation_case.ex
test/support/valuation_scorers.ex
test/football_market/valuation/contract_test.exs
test/football_market/valuation/week_test.exs
test/football_market/valuation/normalization_test.exs
test/football_market/valuation/history_test.exs
test/football_market/valuation/missing_data_test.exs
test/football_market/valuation/outcomes_test.exs
test/football_market/valuation/position_groups_test.exs
test/football_market/valuation/scoring_test.exs
test/football_market/valuation/replay_test.exs
test/football_market/valuation/canonical_test.exs
test/football_market/valuation/matrix_test.exs
test/football_market/valuation/scope_test.exs
test/football_market/statistics/scope_test.exs
test/football_market/providers/scope_test.exs
```

Documentation edits stay in this feature and ADR-0020. No production Statistics/Catalog/Providers, web, config, CI, schema, job, cache, mix.exs or lockfile changes. Legacy scope tests may add only this inventory, conditional on this active feature; retain original assertions/module inventories and unrelated-path rejection. Any necessary material deviation requires an ADR and aligned tasks first.

## Phase 0: Focused Research

Local inspection resolved exclusive selection over inclusive history, immutable replay lookup, Decimal context precision and legacy worktree path guards. Reuse settled decisions from docs/ARCHITECTURE.md and ADR-0002/0010/0011. No external survey or research agents are needed.

## Phase 1: Design

1. Validate all structural input and numeric config before reads/scoring. Reuse Statistics instant validation at ADR-0011 precision; Week enforces consecutive UTC Monday midnights.
2. Resolve exact player/season through Catalog. Read Statistics inclusive history, filter closing boundary, validate isolation, snapshot immutable facts and canonicalize by UTC kickoff/stable match identity bytes/performance ID bytes. No classification by current affiliation.
3. Map every selected historical position, partition rows, retain raw metrics/minutes, validate required metrics only in applicable scopes, sum counts and cap/round ratios. Missing required values stop preparation; no applicable required scope is insufficient-data. Absent groups remain absent even when declared.
4. A trusted module owns strategy ID/version, configuration validation and derived requirements. Require exact match with prepared requirements before callback. Only rounded features reach scoring. Expected failures return no score; finite Decimal output is rounded once without clamp.
5. Canonical evidence captures original facts, resolved groups, effective rules and derived values. Replay resolves exact original facts via Statistics, compares snapshots, recomputes from original membership/rules and rejects every disagreement. Supplied original definition must match; no active defaults or fresh selection.

No exported entrypoint trusts caller-mutated Prepared data: score authenticates/reprepares its retained facts/rules against the original reader before invoking a scorer. Pure preparation workers are internal; unit tests can exercise unordered accepted DTOs without opening a caller-supplied fact trust boundary.

[data-model.md](data-model.md) specifies entities/errors; the contract specifies callback signatures, canonical/numeric representation and trust limits. TASK-025 owns config/version lifecycle. TASK-026 owns durable descriptors and retention/integrity. Original trusted descriptors are not authenticated remote documents in this scope.

## Verification and CP2 Coverage

[acceptance-map.md](contracts/acceptance-map.md) assigns all 28 story scenarios and edge obligations to executable assertion files. verification.json covers exactly FR-001–016 and SC-001–005; the spec has no AC identifiers. Developer executes every manifest check through scripts/agentflow_check.py after final edits; QA reruns independently. Only downstream QA/review tasks may defer.

Checks include exact toolchain, formatting, warnings-as-errors compile, guarded database preparation and actual PostgreSQL/Redis preflight, focused feature tests, architecture checks and complete unit/integration profiles once each. Do not add default-suite or historical CP1 coverage executions atop both profiles. Preserve coverage infrastructure/CI. Service/browser prerequisite failures block completion rather than justify omitted tests.

FR-016 excludes endpoints: no affected HTTP interface, so runtime_required is false and no HTTP check applies. Service preflight remains mandatory. Existing actual browser E2E contributes CP2 regression evidence, but this task does not deliver charts, orders, ranking, trading or immutable quotes. It supplies their deterministic valuation foundation.

## Complexity Tracking

No constitution violations. Replay requires original immutable rows and reviewed scorer/rules to remain available; unavailable originals fail explicitly. Trusted module determinism is a reviewed conformance obligation, not a runtime proof/sandbox. Narrow input and architecture/behavioral tests enforce the contract within this boundary.

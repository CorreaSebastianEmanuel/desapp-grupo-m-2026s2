# Implementation Plan: Balanced Valuation Strategy

**Branch**: `023-balanced-valuation-strategy` | **Date**: 2026-10-13 | **Spec**: [spec.md](spec.md)

**Input**: TASK-023, CP2; `.specify/feature.json` selects `specs/059-balanced-valuation-strategy`. Setup reports directory alias `059-balanced-valuation-strategy`; the actual delivery branch/spec use `023-balanced-valuation-strategy`.

## Summary

Add reviewed production `FootballMarket.Valuation.Balanced`, identity `{"balanced", "1"}`, to TASK-022's explicit Definition/Scorer interface. A nonempty flat weights map determines the exact overall required metrics. The existing engine selects accepted local weekly facts, validates references/mapping/completeness, authenticates prepared evidence, and owns final six-place rounding and authoritative replay. Balanced consumes already rounded overall features and returns their exact signed weighted sum as a finite Decimal. No registration, defaults or configuration persistence is needed.

Refine the shared exact weighted helper to discard zero factors before exponent expansion and combine equivalent coefficient/exponent contributions before common scaling, preserving existing semantics. See [ADR-0021](../../docs/adr/0021-balanced-strategy-explicit-rules-and-exact-contributions.md) and [research.md](research.md). The critic's findings are addressed by downstream calibration ownership, adversarial exact arithmetic, and durable malformed-shape public-workflow tests.

## Technical Context

**Language/Version**: Elixir 1.20.3, Erlang/OTP 29.0.6, pinned by `.tool-versions` / `scripts/check_toolchain.sh`.

**Primary Dependencies**: Existing Phoenix 1.8, Ecto SQL 3.13, Postgrex and Decimal transitively supplied by Ecto. No dependency/lockfile change. Reuse `Valuation.Scorer`, `Scoring`, `DecimalMath`, `Evidence`, `Request` and Statistics reads under ADR-0020.

**Storage**: Existing PostgreSQL accepted Catalog/Statistics facts, read-only. Definition/Prepared/ScoreResult remain in memory. No schema/migrations/new evidence store. Redis is only an existing service-preflight dependency, never part of scoring.

**Testing**: ExUnit pure unit config checks and DataCase integration checks using deterministic local facts and the production module. Existing audited unit/integration profiles remain. The integration profile includes existing browser preflight/checks; this internal formula adds no browser journey.

**Target Platform / Project Type**: Existing local Linux modular Phoenix monolith; internal domain strategy, no new transport.

**Performance Goals**: No new latency/throughput promise. At most nine contributions; exact finite values within available machine resources, without a business numeric ceiling. Avoid scaling zeros; do not turn resource/infrastructure failure into football absence.

**Constraints**: Explicit UTC Monday half-open week and historical mapping; signed exact weights/positive exact references; completeness includes zero-weight entries; no floating-point, ambient precision, current-time/randomness/external access; read-only and original-only replay.

**Scale/Scope**: One formula/version, four stories, nine existing counting metrics. TASK-024 owns position-aware production scoring, TASK-025 configuration lifecycle, TASK-026 quote conversion/orchestration/evidence retention. No new endpoints, permissions, providers, ingestion, jobs, events, caches, trading, charts or ranking.

## Constitution Check

| Principle | Before research | After design |
|---|---|---|
| I — specification first | FR-001–012 / SC-001–005, product decision and inherited Feedback 1 govern | Formula/config/error/replay contract and scenario map trace all behavior; no clarification outstanding |
| II — domain integrity | Exact numbers, immutable facts and original evidence required | Integer contributions, existing final rounding, no financial/history writes; token supply/trading untouched |
| III — modular simplicity | Reuse one scorer boundary | One scorer plus bounded shared-helper refinement; exact file inventories; no infrastructure |
| IV — evidence | FR-011 / AGENTS require behavioral tests | Test-first tasks and executable manifest cover every identifier, service preflight, scoped regressions and both profiles |
| V — independent verification | Product challenge/decision read; no pending human decision | Developer executes all checks before independent QA/review; only downstream gates may stay unchecked |

Pre/post-design gates pass with no constitution violation. This is a design assessment; implementation/runtime acceptance checks have not run.

## Design and Implementation Boundary

### Explicit configuration and requirements — US1/US2

Definition config is exactly `%{weights: %{metric_atom => integer_or_finite_decimal}}`: plain maps, only `:weights`, nonempty. Reject structs as containers, nested role maps, list containers/tails, string keys, unsupported options, floats, strings, booleans, nonfinite/corrupted Decimal fields, missing/empty weights. Validate shape before traversal. Use fixed `Request.metrics/0`, never intern caller strings. The existing engine's `Evidence.normalize_config/1` canonicalizes equivalent Decimal representations; integer/Decimal config leaves retain the inherited typed distinction.

Derive `%{overall: configured_metrics_in_Request_order}` from every entry, including zero. Existing engine validates exact prepared requirements and reference coverage before callback. Balanced also fails safely on absent configured features; it never skips a row or substitutes zero. No per-role policy, preset, sign/sum restriction. `evaluate/2` validates definition before fact selection, including empty history.

### Exact arithmetic — US1/US3

Enumerate configured metrics in fixed order, read only overall rounded features and call `DecimalMath.weighted/1`. Represent feature/weight as signed integer coefficient and base-10 exponent (integer exponent zero). Multiply coefficients and add exponents without Decimal context operations. Drop zero factors before any power expansion; strip trailing coefficient zeros, combine equal-exponent contributions, discard cancellations, then align survivors at the minimum exponent and sum exactly. Return canonical positive zero at exponent zero if none survive, otherwise a finite unrounded Decimal. Common engine alone performs final half-away rounding and six-place rendering. No product rounding, weight-sum division, intercept, clamp or quote conversion.

Change only `weighted/1` and private helpers; preserve ratio/normalization/public rounding. Shared-helper regressions must prove illustrative scorers still agree. Sparse accumulation avoids unnecessary work but imposes no exponent/count ceiling or constant-resource guarantee. Independently expected adversarial fixtures are in [acceptance-map.md](contracts/acceptance-map.md).

### Evidence and replay — US4

Reuse ScoreResult/Descriptor and canonical config encoding; serialize no executable module. Original explicit Definition is required for replay. Balanced does not own selection, snapshots, authoritative fact authentication or derived-evidence comparison. Late arrivals affect fresh evaluation, not original replay. Substitution of weights/references/mapping/facts/features/score fails under inherited taxonomy. No engine/replay rewrite is planned: diagnose any inherited defect against its contract rather than relax acceptance or add a parallel engine.

### Architecture checks and allowed files

All implementation edits are confined to these exact paths:

```text
lib/football_market/valuation/balanced.ex
lib/football_market/valuation/decimal_math.ex
test/football_market/valuation/balanced/config_test.exs
test/football_market/valuation/balanced/formula_test.exs
test/football_market/valuation/balanced/outcomes_test.exs
test/football_market/valuation/balanced/arithmetic_test.exs
test/football_market/valuation/balanced/replay_test.exs
test/football_market/valuation/balanced/scope_test.exs
test/football_market/valuation/scope_test.exs
test/football_market/statistics/scope_test.exs
test/football_market/providers/scope_test.exs
```

New config tests use `:unit`; remaining new tests use `:integration`. Use existing `test/support/valuation_case.ex` unchanged; small definitions/oracles stay in their test files. No request/preparation/scoring/evidence/replay edits, profile/coverage/CI changes, web/Catalog/Statistics/provider production, mix files or schema changes are planned.

Extend Valuation's top-level production inventory by `balanced.ex`, retaining AST/purity checks and historical TASK-022 allowance coverage. Anchor the historical allowance assertion to the original TASK-022 production inventory, separately from the extended current inventory: do not require its preserved allowance branch to authorize balanced.ex. Add an exact active `specs/059-balanced-valuation-strategy` branch to each legacy `valuation_paths/1` listing only these eleven paths; preserve TASK-022 branches. New scope tests compare both active-feature allowances with the exact planned edit inventory, unknown features return empty and unrelated/unplanned paths are rejected. Balanced purity excludes even Catalog/Statistics reads: only feature/config inputs enter it.

Assert no SQL mutations around success/failure evaluate/score/replay via calling-process Repo query telemetry (INSERT/UPDATE/DELETE/DDL), no follow-up events and unchanged fact snapshots. Fixture writes happen before tracing; cleanup handlers. Combine actual workflow assertions with AST provider/write/job restrictions, including local calls such as send/spawn, not just dotted calls; unavailable external providers must not affect local success. For read-failure evidence use a separate DataCase module with async:true in balanced/scope_test.exs, which gives an unshared sandbox owner; invoke public evaluate in a monitored raw process without ownership/caller propagation. Assert the ownership/read failure remains visible rather than empty/insufficient history. Do not change the pool's global mode or stop shared services.

## Project Structure

```text
specs/059-balanced-valuation-strategy/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── verification.json
├── contracts/
│   ├── balanced-scorer.md
│   └── acceptance-map.md
├── tasks.md
└── handoffs/
    ├── architecture.md
    └── tasks.md
docs/adr/0021-balanced-strategy-explicit-rules-and-exact-contributions.md
```

**Structure Decision**: Existing Valuation namespace, feature-specific nested tests. Existing contracts/ADR-0020 own shared DTOs/replay/errors; supporting artifacts document only new rules/assertions.

## Verification and Checkpoint Coverage

`verification.json` is executable acceptance mapping; contracts/acceptance-map.md supplies scenario-level assertions. Every FR/SC identifier is covered; spec uses numbered scenarios rather than AC identifiers, all mapped there. Developer executes every check after source/design edits through `agentflow_check.py` with explicit development reuse; service/environment checks run fresh. QA reruns independently without reuse. All new tests have exactly one profile tag and are discovered by the existing audit.

Required: toolchain, formatting, warnings-as-errors compilation, PostgreSQL/Redis preflight, targeted strategy/config/arithmetic/replay/architecture checks, inherited malformed-input regressions and both full profiles. Each full profile appears once. Do not add `test.cp1_coverage`/`coverage_report.sh` as an extra CP2 gate; preserve infrastructure/CI. No HTTP route is affected: `runtime_required` is false, local-domain assertions run in DataCase. Any later HTTP scope change requires service readiness and status/header/body assertions plus manifest updates.

This supplies one CP2 configurable strategy, not the second strategy, active rules, immutable quotes, ranking, trading, charts or conditional orders. TASK-025/026 must obtain intentional operator weights/references, retain effective rules, and demonstrate integration; fixtures are not calibration. Actual frontend browser E2E remains a checkpoint obligation for frontend tasks. CP3 cache/observability stay outside this task.

## Complexity Tracking

No constitution violations or baseline deviations. ADR-0021 records explicit production config and a bounded refinement of ADR-0020 arithmetic; no new service.

## Current development sequencing

Feedback 1 records recovered PostgreSQL/Redis host transport. Preserve prior service attempt history; proceed T003 onward, deferring T002 guarded preparation to the final fresh T024 services execution after genuine implementation changes. T002 remains unchecked until that succeeds. No service configuration or requirement changes.

The read-failure test uses a private unnamed Sandbox pool with `ownership_mode: :manual` because the application pool defaults to automatic checkout. The monitored raw process selects that pool via process-local dynamic Repo and receives no owner/caller propagation. This exercises public evaluate's real ownership failure without changing global sandbox mode, production code or shared services; the private test pool is cleaned up.

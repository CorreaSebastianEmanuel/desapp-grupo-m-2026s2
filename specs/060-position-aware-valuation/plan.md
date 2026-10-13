# Implementation Plan: Position-aware Valuation Strategy

**Git branch**: `024-position-aware-valuation-strategy` | **Date**: 2026-10-13 | **Spec**: [spec.md](spec.md)
**Feature directory**: `specs/060-position-aware-valuation` (resolved by `.specify/feature.json`; setup-plan reports this logical feature name, not a new Git branch).
**Input**: TASK-024; completed dependency TASK-022; authoritative [Feedback 1](../../backlog/feedback/TASK-024.md).

## Summary

Add a second production performance scorer to the existing internal valuation context. Each historical group has explicit metric weights; independently normalized six-place features are multiplied exactly and summed across populated groups before one final rounding. Approved role partitioning scores 2.000000 concentrated versus 4.000000 split; a zero-contribution group never dilutes the score. Configuration, evidence, replay and errors use the common contract. No market prices, storage lifecycle or HTTP interface are added.

## Technical Context

**Language/Version**: Elixir 1.20.3 / OTP 29.0.6, pinned by `.tool-versions`.
**Primary Dependencies**: Existing Phoenix 1.8, Ecto/Postgrex and transitive Decimal; no dependency changes. Scorer depends only on valuation types/Request/DecimalMath.
**Storage**: Read-only accepted PostgreSQL Catalog/Statistics facts through the existing context; no schema, migration or write. In-memory descriptors remain owned by the common engine.
**Testing**: ExUnit unit and database-backed integration modules, existing profile audit, actual Chromium integration/browser prerequisites, independent integer-rational arithmetic generator; deterministic local fixtures.
**Target Platform**: Existing local Linux Phoenix application with PostgreSQL and Redis service preflight. Redis is not a scoring dependency.
**Project Type**: Domain strategy inside the existing modular monolith; internal Elixir interface.
**Performance Goals**: No new latency/throughput target. Exact accumulation over configured entries in populated groups; preserve accepted arbitrary-size counts and finite weights without artificial ceilings.
**Constraints**: Six-place nearest/ties-away output, no ambient Decimal precision, floats, per-product/group rounding, defaults, provider access, time/randomness or writes. Fixed four groups and nine metrics; complete explicit configuration even for absent groups.
**Scale/Scope**: One scorer, one test-support module, eight strategy test files and bounded changes to three existing architecture tests. TASK-023 is not a prerequisite; its existing helper is reused, its strategy remains unchanged.
**Unknowns**: None unresolved. Feature-specific local inspection is recorded in [research.md](research.md); settled stack choices refer to existing architecture and ADRs.

## Constitution Check

| Principle / gate | Before research | After design |
|---|---|---|
| Specification first | PASS: reconciled spec, challenge/decision and Feedback 1 agree | PASS: all 30 scenarios mapped; no product change |
| Domain integrity | PASS: scores are not token prices | PASS: read-only facts; exact money/quote boundary; no token, transaction, audit or history mutation |
| Modular simplicity | PASS: existing Scorer/evidence/replay contract | PASS: one pure module; no new service, store or provider boundary |
| Evidence-based quality | PASS: FR-012 requires automated behavior tests | PASS: test-first tasks, executable manifest, targeted checks plus one run per full profile |
| Independent verification | PASS: no pending material human decision | PASS: developer runs all checks; independent QA reruns; final review requires fresh PASS evidence |
| Delivery safety | PASS: planning only | PASS: no implementation, publication, merge or fabricated receipts |

These are design assessments, not production test results. No constitution exception or baseline deviation is needed. [ADR-0022](../../docs/adr/0022-position-aware-populated-group-sum.md) records the durable formula/configuration decision; ADR-0020/0021 remain authoritative for trust and arithmetic.

## Project Structure

### Documentation (this feature)

```text
specs/060-position-aware-valuation/
  spec.md
  plan.md
  research.md
  data-model.md
  contracts/position-aware-scorer.md
  contracts/acceptance-map.md
  quickstart.md
  verification.json
  tasks.md
  handoffs/architecture.md
  handoffs/tasks.md
```

### Exact implementation inventory (13 files)

```text
lib/football_market/valuation/position_aware.ex                    # new
test/support/position_aware_case.ex                              # new
test/football_market/valuation/position_aware/config_test.exs     # new
test/football_market/valuation/position_aware/formula_test.exs    # new
test/football_market/valuation/position_aware/mixed_test.exs      # new
test/football_market/valuation/position_aware/outcomes_test.exs   # new
test/football_market/valuation/position_aware/arithmetic_test.exs # new
test/football_market/valuation/position_aware/replay_test.exs     # new
test/football_market/valuation/position_aware/selection_test.exs  # new
test/football_market/valuation/position_aware/scope_test.exs      # new
test/football_market/valuation/scope_test.exs                    # bounded inventory addition
test/football_market/statistics/scope_test.exs                   # exact active-feature allowance
test/football_market/providers/scope_test.exs                    # exact active-feature allowance
```

All paths are repository-relative. Production inventory gains only `position_aware.ex`. Preserve the old 058/059 feature allowances; add this exact 13-file inventory only for active feature 060, with explicit negative tests for unplanned paths and unknown features. No wildcard feature allowance. `scope_test.exs` checks must continue rejecting cross-layer effects and inventory leaks.

**Structure Decision**: Reuse `FootballMarket.Valuation` facade, Scorer/Definition/FeatureView/ScoreResult/Descriptor structs, Request, Preparation, DecimalMath, Evidence and Replay unchanged. The test helper owns deterministic fixture setup and independently calculated expected values only. It must not call production normalization/weighted/round functions to calculate expectations.

## Phase 0: Research and challenge disposition

Local inspection resolved the only technical questions: `DecimalMath.weighted/1` already accumulates signed coefficients/exponents without rounding; Request validates duplicate requirements/mappings and exact reference unions; Scoring validates definitions before selection and derives requirements; score/replay authenticate authoritative facts. No web research or research agent is needed.

The current independent challenge has no remaining material finding. Feedback supersedes the former averaging dispute. Record the accepted sum in ADR-0022; retain downstream calibration and descriptor-origin ownership under ADR-0020. Do not reopen them or add scope.

## Phase 1: Design and contracts

1. **Definition/configuration**: `PositionAware.identity/0` returns `{"position_aware", "1"}`. `validate_config/1` admits exactly a plain atom-key map with `:weights`, whose keys are exactly the four groups and whose nonempty metric maps contain only supported metrics and finite integer/Decimal values. Reject missing/extra keys, overall scope, structs, list/pair collections, nested improper tails and malformed numeric fields ordinarily. Do not call Map.new on unvalidated collections. The map-only choice follows the common production boundary; duplicate supplied collections fail rather than being collapsed.
2. **Requirements**: Derive every group's canonical metric list in Request.metrics order, including zero-weight entries, with no overall requirement. The existing engine enforces equality against explicit preparation requirements and a strictly positive exact reference for exactly the configured union, including absent groups. Definition/request validation precedes empty-history outcomes.
3. **Score callback**: Inspect populated declared group features only; absent groups introduce no term. Reject malformed/direct feature views and missing required features rather than supplying zeros. Complete known-zero entries remain present. Flatten all `{rounded_feature_Decimal, exact_weight}` terms and call `DecimalMath.weighted/1` once; return the unrounded Decimal. Scoring performs the sole final round. No group average, subtotal round, shared overall cap, minutes multiplier, clamp or implicit sign.
4. **Evidence/replay**: Return the existing ScoreResult/Descriptor. Keep all four configured weight/requirement sets and shared references even for absent groups, while measured scopes remain absent. Canonicalization is delegated to Evidence. score authenticates caller-held preparation; replay resolves original immutable facts/rules, never fresh late-arrival selection. Equivalent Decimal representations normalize; integer/Decimal type tags remain distinct. Configuration changes affecting an absent group still bind different evidence.
5. **Errors and effects**: Reuse common validation/not_found/no_recorded_performances/insufficient_data/unsupported_strategy/strategy_failure/unavailable_replay/inconsistent_replay outcomes. Expected malformed input never relies on callback-exception rescue. Infrastructure errors stay visible. Pure scorer has no Catalog/Statistics/Repo/provider calls; facade reads are existing authoritative reads only.

Detailed interface and acceptance traceability: [contract](contracts/position-aware-scorer.md), [acceptance map](contracts/acceptance-map.md). Entity relationships: [data model](data-model.md). Runnable validation: [quickstart](quickstart.md).

## Validation and checkpoint coverage

Write new behavioral assertions before changing source, observe the expected missing-scorer red result, then correct actual source before rerunning. Inherited behavior may already pass; do not introduce artificial failures. Config tests use `:unit`; persisted evaluation/authentication/replay/arithmetic/selection/effect tests use `:integration`. No test skip or fixture exclusion changes.

FR-012 requires every acceptance scenario and edge case, all 36 metric/group combinations, concentrated/split 2/4, no dilution, missing/zero/absent distinctions, duplicate/malformed input, exact signed ties and within/cross-group cancellation, at least 20 deterministic permutations, original replay versus fresh arrivals/rules and effect isolation. Independent expected values use integer numerator/denominator arithmetic and quotient/remainder rounding; generate vectors in memory with count/checksum summaries. No expanded dataset is committed.

The [manifest](verification.json) maps every canonical FR/SC identifier to concrete targeted test commands, and includes toolchain, formatting, warnings-as-errors compilation, actual service preflight, architecture/regression checks, unit and integration profiles. There are no AC identifiers in this spec; its 30 numbered scenarios are mapped separately. No affected HTTP endpoint: runtime_required=false is deliberate, not a missing runtime test. Existing browser tests still run in the integration profile.

Implementation runs each manifest check through `scripts/agentflow_check.py` after final edits, records its receipts, and completes every developer task before QA. Use explicit `--reuse` only for eligible unchanged development receipts; services always run fresh. QA runs independently without reuse; final review uses fresh QA evidence and targeted uncovered-risk checks. Never add a CP1 coverage report by default or rerun unchanged full profiles merely to repeat evidence. Preserve coverage/CI infrastructure. Two unchanged failed executions require diagnosis, not a third identical attempt; actual corrective source work is authorized.

CP2 contribution: second configurable strategy formula and exact reproduction through the existing contract. TASK-025/026 still own durable configuration/active selection and quote conversion/retention; charts, conditional orders, trading, ranking and browser delivery are separate tasks. No claim that this strategy completes CP2. Product invariants remain intact: no supply mutation, floating-point money, financial transaction, audit rewrite, quote overwrite or provider-dependent local read.

## Complexity Tracking

No constitution violations. One new domain module; existing exact helper and replay are reused. Any required common-engine production change outside the inventory must first be justified by a concrete failing obligation and reflected in the plan/tasks/ADR; do not expand silently.

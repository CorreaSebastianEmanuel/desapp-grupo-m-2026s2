# ADR-0022: Position-aware Rules and Exact Populated-group Sum

**Status**: Accepted for TASK-024 architecture under approved Feedback 1
**Date**: 2026-10-13

## Context

[Feedback 1](../../backlog/feedback/TASK-024.md) settles the former mixed-position finding: independent group caps and exact summation intentionally make four goals score 2.000000 in one role and 4.000000 when split across two roles with reference 2 and weight 2. Comparability means consistent explicit rules, not invariance under role partitioning. [ADR-0020](0020-valuation-evidence-and-scorer-trust-boundary.md) establishes authoritative facts/replay; [ADR-0021](0021-balanced-strategy-explicit-rules-and-exact-contributions.md) establishes the existing exact contribution helper.

## Decision

Add `FootballMarket.Valuation.PositionAware`, identity `position_aware`, formula version `1`, implementing the existing Scorer behavior. Configuration is exactly `%{weights: %{goalkeeper: metric_map, defender: metric_map, midfielder: metric_map, forward: metric_map}}`; each metric map is nonempty, atom-keyed and contains finite integer/Decimal weights. Reject collections and structs where maps are required, before conversion/traversal. This preserves the existing configuration boundary and cannot conceal duplicate supplied collection entries. Do not introduce list conversion, string interning, presets or an overall scope.

Derive all four required metric sets, including zero weights. Request and Scoring retain exact requirement/reference agreement. Preparation already supplies independently capped, rounded group features. Flatten every populated group's feature/weight pairs into **one** `DecimalMath.weighted/1` call; return its unrounded Decimal. Scoring alone rounds the final score. Never round group subtotals. Empty groups supply no term; populated known-zero groups remain measured evidence.

Retain all four groups' configuration in existing canonical descriptors even when absent from measured scopes. Existing authoritative score/replay reads and no-score taxonomy remain unchanged. No parallel evidence format/store, shared arithmetic change, new dependency or architecture-baseline deviation is required.

## Consequences and alternatives

Test independent saturation, zero-contribution non-dilution, signed cross-group ties/cancellation and changed rules for an absent group. Protect purity and the exact active-feature file inventory through bounded additions to existing architecture tests; preserve old feature inventories and exclusions.

Group averaging, shared overall caps and dominant-role selection contradict approved feedback. Per-group rounding loses exact residuals. Pair-list support would require additional schema handling without an accepted consumer need; malformed/duplicate pair collections instead fail ordinarily. Calibration and durable lifecycle/retention remain TASK-025/026. Bulk arithmetic vectors stay in memory or ignored temporary outputs.

# ADR-0021: Explicit Balanced Rules and Exact Contributions

**Status**: Accepted for TASK-023 architecture under approved specification and AGENTS rule 9
**Date**: 2026-10-13

## Context

TASK-023 adds a production scorer to [ADR-0020](0020-valuation-evidence-and-scorer-trust-boundary.md). The critic identifies calibration ownership, fractional exponent/cancellation evidence and malformed nested inputs. No approved numerical preset exists. The inherited helper is exact but expands rational denominators even for zero contributions and does not combine equivalent exponent contributions before scaling.

## Decision

Balanced has stable identity `balanced`, version `1`, and exactly a nonempty flat atom-key metric weights map. Every entry, including zero, declares an overall requirement. Existing Request/Scoring own agreement with requirements/references; Evidence owns canonical encoding; Replay owns authoritative comparison. No defaults, policies, registry or separate store. TASK-025/026 must obtain and retain intentional operator configuration before market demonstration; fixtures are not calibration.

Refine existing `DecimalMath.weighted/1`: multiply signed coefficients/add exponents, skip zero factors before scaling, strip trailing zeros, cancel equal-exponent terms, then align surviving coefficients once. Return an unrounded Decimal; engine alone rounds the score. This is a bounded refinement, not a numerical service or baseline deviation. Exact representation can consume growing resources; introduce no input ceiling or fixed precision.

Keep scorer purity and exact active-feature inventories. Persist adversarial assertions through common evaluate/score/replay. Reject malformed containers/tails/numeric fields structurally, without callback exception trapping as routine validation, string interning or broad infrastructure rescue.

## Consequences and alternatives

Sparse cancellation/zero elimination avoids unnecessary expansion; independently expected fractional residuals test signed ties under varied Decimal contexts. Shared-helper illustrative behavior must remain unchanged. Integer/Decimal type tags remain distinct; equivalent Decimal representations canonicalize as before.

Built-in presets add an unsupported calibration choice. Fixed precision, weight normalization or input ceilings violate approved behavior. A duplicate engine/store bypasses authoritative replay. TASK-024/025/026 retain ownership; no provider, financial, persistence or web scope is added.

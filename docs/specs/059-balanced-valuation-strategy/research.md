# Feature-specific design findings

Material questions were resolved by local inspection; no external research or agents were needed. Settled stack/replay decisions remain in docs/ARCHITECTURE.md, ADR-0020 and the inherited valuation-context.md. TASK-022 Feedback 1–3 remains authoritative; no TASK-023 feedback file exists at planning time.

## Explicit configuration and calibration

- **Decision**: Exactly `%{weights: %{metric_atom => exact_weight}}`, no preset. Every entry derives an overall requirement, including zero. TASK-025/026 must provide/retain intentional settings before CP2 market demonstration.
- **Rationale**: Scoring validates explicit definitions before reads, derives requirements through the module and checks them before scoring. Flat weights exclude role policies. Product decision rejects invented calibration.
- **Alternatives considered**: Illustrative nested scope/policy config admits out-of-scope semantics. Automatic references/fixture presets invent business rules. Explicit module contract needs no registry.

## Exact disparate-exponent arithmetic

- **Decision**: Refine DecimalMath.weighted/1 using grouped signed coefficients/exponents, early zero elimination/cancellation and one surviving scale, without intermediate rounding. Engine rounding stays unchanged; ADR-0021 records this refinement.
- **Rationale**: Current helper is exact, so the critic does not prove a correctness defect. Its rational expansion performs avoidable work even for zero. Independent adversarial fixtures test fractional residuals near both signed ties, equivalent representations, disparate exponents and varied contexts.
- **Alternatives considered**: Private strategy arithmetic duplicates a settled boundary. Fixed precision/input ceilings contradict FR-003/007. New rational dependency is unnecessary for nine decimal contributions.

## Safe malformed-input regressions

- **Decision**: Check plain maps/finite numeric structure before iteration. Reject improper tails, role maps, corrupted Decimal fields and unknown string keys. Track public-workflow assertions and keep inherited malformed regressions executable without /tmp dependencies.
- **Rationale**: Feedback 2/3 records specific public failures; existing Evidence proper-list/Request validation must not be bypassed. Callback containment is not ordinary input validation.
- **Alternatives considered**: Broad rescue hides infrastructure faults. List config/string interning expands input surface without value.

## Exact architecture inventories

- **Decision**: Add balanced.ex to production inventory and the eleven exact plan paths to active TASK-023 legacy allowances; preserve historical branches and all purity/unrelated-path checks.
- **Rationale**: Current scope tests count top-level files and allow TASK-022 only. Existing profile audit already discovers tagged nested tests.
- **Alternatives considered**: Skipping boundary checks/broad directory allowances weakens evidence. No CI/profile changes needed.

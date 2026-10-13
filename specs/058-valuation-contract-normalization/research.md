# Feature-specific research — TASK-022

No unresolved material unknown remains. Settled stack: docs/ARCHITECTURE.md. Identity/current affiliation: ADR-0002. Immutable facts and precision: ADR-0010/0011. Product arithmetic and scope: Feedback 1.

## Weekly selection

- **Decision**: Read Statistics with explicit inclusive bounds, filter the ending instant in Valuation, sort DTOs independently.
- **Rationale**: statistics/query.ex uses <= to and database normalized-identity ordering. Valuation needs < end and locale-independent ties without changing the existing contract.
- **Alternatives considered**: Changed Statistics semantics breaks consumers; unbounded history wastes work; a new persistence query adds needless scope.

## Replay authority

- **Decision**: Resolve original pairs with Statistics.get_performance/2 and get_match/1; verify retained performance ID and every immutable captured field. See ADR-0020.
- **Rationale**: Original immutable facts defeat coordinated raw-count/derived-value tampering; caller snapshots/digests cannot prove originality.
- **Alternatives considered**: Snapshots alone permit fabrication; a new store/signature scheme overlaps TASK-026. Trust descriptor origin to internal consumers; durable integrity is downstream.

## Scorer binding and absent groups

- **Decision**: Explicit reviewed module owns identity/version, validates config and derives requirements; compare with Prepared before callback, supplying only rounded features. Keep populated applicable features when another declared group is absent.
- **Rationale**: Resolves critic findings 2/3 without production formulas or arbitrary-code execution. Require-all illustrative scorer fails on absent contributions; explicitly populated-only policy may succeed.
- **Alternatives considered**: Independent requirements/weights can disagree; raw minutes permit forbidden participation scoring; zero-filling or globally failing absent groups contradicts spec. No callback sandbox needed.

## Exact decimal arithmetic

- **Decision**: Use finite Decimal coefficient/sign/exponent or integers to form exact integer ratios; cross-multiply saturation, scale to millionths, quotient/remainder half-away rounding. Round final finite Decimal by coefficient/exponent; canonical positive zero. Illustrative weights multiply/add exact coefficients without ambient context rounding.
- **Rationale**: Installed deps/decimal/lib/decimal/context.ex documents default precision 34 and exponent limits. Any arbitrary guard-digit choice can double-round a ratio extremely near a half or lose large accepted counts. Integer arithmetic gives an exact oracle with no new count ceiling.
- **Alternatives considered**: Default Decimal division, large fixed precision and floating point cannot meet all exactness obligations. Existing Decimal 3.1.1 suffices as value representation, so no dependency changes.

## Regression path guards

- **Decision**: Exact active-feature allowances in legacy Statistics/Providers scope tests, preserving every purity/module/unrelated-path assertion.
- **Rationale**: Those tests inspect worktree paths against earlier feature inventories; new Valuation files otherwise fail despite proper separation.
- **Alternatives considered**: Disabling guards, broad directory allowances or production dependency edits weaken or expand the contract. ADR-0020 records the bounded extension.

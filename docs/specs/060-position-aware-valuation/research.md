# Feature-specific research — TASK-024

Settled technology and boundaries are reused from docs/ARCHITECTURE.md, ADR-0020 and ADR-0021. No unresolved technical question warranted external research or delegation.

## Exact accumulation across historical groups

- **Decision**: Flatten all populated-group terms into one existing DecimalMath.weighted/1 call, with final rounding left to Scoring.
- **Rationale**: Local inspection of lib/football_market/valuation/decimal_math.ex shows integer coefficient/exponent multiplication, zero elimination, equal-exponent cancellation and exact alignment. It already avoids ambient context. The revised US4 cross-group ties would fail if each group's result were rounded first.
- **Alternatives considered**: Separate rounded group results, averaging and shared overall normalization contradict FR-006/008 and Feedback 1. A duplicate arithmetic helper is unnecessary.

## Configuration container and agreement

- **Decision**: Exactly one plain weights map containing four nonempty metric maps; finite integer/Decimal leaves. Derive all four group requirements, no overall scope. Reject supplied list collections as invalid, including duplicates, without converting them to maps.
- **Rationale**: Scoring.definition validates explicit definitions, Request already rejects duplicate metrics/mapping entries and checks exact reference unions. Existing production Balanced uses map-only configuration; Evidence.valid_config? deliberately excludes tuples. Pair-list support is not needed to satisfy any consumer. Lists are malformed configuration, never an alternative route around duplicate checks.
- **Alternatives considered**: Adding pair-list support would extend the shared schema; numerical presets would invent calibration. Neither is needed. See ADR-0022.

## Evidence, no-score behavior and isolation

- **Decision**: Reuse Prepared/ScoreResult/Descriptor and original-rule authoritative replay unchanged. Add conformance tests and exact active-feature inventories only.
- **Rationale**: lib/football_market/valuation.ex validates definitions before preparation; score authenticates retained facts; replay already compares original membership, values, rules and derived evidence. Required group absence is already retained without fabricated features. All-group config is independent of measured populated scopes.
- **Alternatives considered**: New evidence format/store, current-role lookup and fresh selection during replay bypass the common trust boundary. Durable origin/configuration lifecycle remain downstream under ADR-0020.

## Verification obligations

- **Decision**: Service preflight, targeted strategy/common regressions, pure boundary checks and one execution of each existing complete test profile. No additional historical CP1 report or HTTP probe.
- **Rationale**: docs/AGENT_VERIFICATION.md and current feedback prohibit redundant default CP1 coverage execution. This feature has an internal interface and no changed routes; integration already checks actual browser prerequisites. The implementation owner creates the planned test files and executes every manifest command; architecture only validates the design/manifest.
- **Alternatives considered**: Re-running the coverage report repeats both profiles without an affected obligation. Bare HTTP requests add no acceptance evidence. Bulk generated fixtures violate proportional evidence guidance; keep the independent generator and checksum summary instead.

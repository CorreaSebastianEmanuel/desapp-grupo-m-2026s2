# Feature Specification: Balanced Valuation Strategy

**Feature Branch**: `023-balanced-valuation-strategy`

**Created**: 2026-10-13

**Status**: Ready for independent product challenge

**Input**: User description: "TASK-023 — Implement and test the general weighted performance strategy. Checkpoint CP2; depends on TASK-022."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Calculate a General Weekly Performance Score (Priority: P1)

As a market maintainer, I need one configurable performance formula applied consistently across players and historical positions, so recorded football performance can be evaluated under a common set of rules.

**Why this priority**: This is the first production scoring strategy needed by the CP2 market. A performance score is the input to later quote calculation, not itself a token price.

**Independent Test**: Evaluate accepted local weekly performances with explicit references and signed metric weights; compare the result with the formula and examples below.

**Acceptance Scenarios**:

1. **Given** a player's selected weekly performances total 3 goals, 1 assist and 2 goals conceded, references are respectively 4, 2 and 4, and weights are respectively 2, 1 and -1, **When** the balanced strategy evaluates the week, **Then** normalized features are 0.750000, 0.500000 and 0.500000 and the score is 1.500000.
2. **Given** 2 goals in a defender performance and 2 goals in a forward performance, a goal reference of 2 and goal weight of 2, **When** the week is evaluated, **Then** the overall total of 4 is capped to feature 1.000000 and the score is 2.000000. Separately capped position-group features are not added to make 4.000000.
3. **Given** two valid histories with identical configured metric totals but different recorded minutes, historical roles or current affiliations, with valid historical mappings, **When** both use the same references and weights, **Then** their scores are identical, including when all minutes are zero. Their retained evidence may differ.
4. **Given** known zero totals for all configured metrics and at least one selected performance, **When** evaluation runs, **Then** the score is 0.000000. **Given** a red-card total of 1, reference 2 and weight -2 as the only configured contribution, **When** evaluation runs, **Then** the score is -1.000000 without a score floor.
5. **Given** any one of goals, assists, shots on target, tackles, interceptions, saves, goals conceded, yellow cards or red cards configured alone with a known total of 1, reference 2 and weight 2, **When** evaluation runs, **Then** the score is 1.000000 for each of the nine cases, with no implicit sign or role-dependent multiplier.

---

### User Story 2 - Use Explicit Rules and Detect Incomplete Data (Priority: P1)

As a market maintainer, I need the required statistics to follow the explicit configuration and invalid or incomplete requests to return clear failures, so missing football evidence never becomes a fabricated score.

**Why this priority**: Configuration and data completeness determine the meaning of the score and must agree before scoring.

**Independent Test**: Vary configured metric membership, weights, references and required data; check ordinary validation and distinct no-score outcomes through the common valuation workflow.

**Acceptance Scenarios**:

1. **Given** only goals have a configured weight, goals are known in every selected row and saves are unknown, **When** evaluation runs with only an overall goals requirement and goal reference, **Then** goals alone determine the score and unknown saves do not block it.
2. **Given** goals and saves have configured weights and one selected row has unknown saves, **When** evaluation runs, **Then** it returns “datos insuficientes” identifying overall scope, saves and the affected performance, with no score or row exclusion. This also applies if the saves weight is zero.
3. **Given** a nonempty configuration whose weights are all zero and complete required metrics, **When** evaluation runs, **Then** the score is 0.000000. Removing a metric entry instead of assigning zero removes that metric's requirement; keeping a zero entry still requires its reference and complete recorded values.
4. **Given** missing or empty weights, an unsupported metric such as minutes, a position-specific weight, an unsupported configuration option, or a missing, nonnumeric, nonfinite or binary floating-point weight, **When** evaluation runs, **Then** validation identifies the invalid configuration and returns no score. Positive, negative and zero exact weights are valid; weights need not add to one.
5. **Given** references do not exactly cover the configured metrics, any required reference is not finite and strictly positive, or prepared requirements contain a different metric set or a position-group scope, **When** evaluation or scoring is requested, **Then** validation fails before producing a score. No missing reference, weight or requirement is supplied automatically.
6. **Given** a valid request for a known player with no selected recorded performances, **When** evaluation runs, **Then** it returns the distinct “sin actuaciones registradas” outcome without a score. An unknown player returns not-found; a malformed week or invalid historical mapping returns validation failure. Invalid configuration is not hidden by an empty history.

---

### User Story 3 - Preserve Exact Decimal Contributions (Priority: P1)

As a valuation consumer, I need results that agree with the stated decimal rules, so repeating fractions, penalties and cancellation do not introduce financial rounding errors later.

**Why this priority**: Exact reproducible arithmetic is a domain invariant and a prerequisite for quote calculation.

**Independent Test**: Check rounded-feature consumption, positive and negative ties, cancellation and large exact weights against independently calculated results.

**Acceptance Scenarios**:

1. **Given** 1 goal, reference 6 and weight 3, **When** evaluation runs, **Then** the normalized feature is 0.166667 and the score is 0.500001, using the rounded feature rather than the unrounded fraction.
2. **Given** goals and assists each normalize to 0.500000 and each has weight 0.000001, **When** evaluation runs, **Then** exact contributions sum to 0.000001 before final rounding and the score is 0.000001, not 0.000002. With both weights -0.000001, the score is -0.000001.
3. **Given** a feature of 0.500000 with weight 0.000001 or -0.000001 as the sole contribution, **When** evaluation runs, **Then** scores are respectively 0.000001 and -0.000001. A feature of 1.000000 with weight -0.0000004 produces 0.000000 without negative zero.
4. **Given** goals and assists each normalize to 1.000000 with respective weights 1000000000000000000000000000001 and -1000000000000000000000000000000, **When** evaluation runs, **Then** the exact cancellation yields 1.000000. Calculation order or ambient decimal precision does not alter it.

---

### User Story 4 - Reproduce a Score Under Its Original Rules (Priority: P2)

As a quote-history consumer, I need the balanced strategy's exact identity, rules and football inputs retained with the result, so a later configuration change or late performance cannot silently rewrite an earlier calculation.

**Why this priority**: The strategy must be usable by the existing reproduction contract before immutable quotes and configuration lifecycle are implemented.

**Independent Test**: Retain a balanced score's reproduction descriptor, change fresh inputs or configuration, and replay it using its original definition and authoritative local facts.

**Acceptance Scenarios**:

1. **Given** a successful evaluation, **When** the result is inspected, **Then** it identifies strategy `balanced`, formula version `1`, all effective weights, overall requirements, references, original performances, week, historical mappings, normalized features, rounding rules and final score through the existing complete reproduction descriptor.
2. **Given** that result and a later performance accepted inside the same week, **When** original evidence is replayed with the original definition, **Then** the original score and membership are reproduced exactly. Fresh evaluation can include the late performance and yields new evidence.
3. **Given** a descriptor calculated with goal weight 2 and a feature of 0.500000, **When** fresh evaluation uses weight 4, **Then** the new score is 2.000000 and the old score remains 1.000000. Original replay requires weight 2; substituting the changed configuration fails explicitly. Changed references or mappings similarly cannot substitute for retained rules.
4. **Given** unavailable original facts or rules, an unsupported strategy identity/version, or altered retained facts, derived features or score, **When** scoring or replay runs, **Then** the existing distinguishable unsupported, unavailable or inconsistent outcomes apply without fallback. Valid current facts or another version do not repair original evidence silently.
5. **Given** identical facts and rules supplied in different performance and configuration-entry orders, with external providers unavailable, **When** evaluation repeats, **Then** features, score and canonical reproduction evidence are identical and no external access or write occurs.

### Edge Cases

- All nine counting metrics are available for explicit selection. An omitted metric differs from a metric with weight zero. Every configured metric, including zero-weight entries, is required in every selected performance because the strategy uses overall scope. Empty weights are invalid; nonempty all-zero weights are valid with complete data.
- Signed weights are used exactly as supplied. No implied penalty signs, absolute-value conversion, division by the sum of weights, requirement that weights sum to one, bias term, score clamp or minimum score applies. Positive and negative weights may cancel exactly.
- A known zero count is valid. Unknown required counts, even for zero-minute performances, block the whole score. Unknown unconfigured counts remain raw evidence. No coverage guarantee is inferred from available records.
- Each required total is normalized independently before weighting. Several saturated features may produce a score greater than one; penalties may produce a negative score. Large accepted counts introduce no new ceiling beyond per-feature saturation.
- Mixed historical roles use the overall total once. The existing explicit historical mapping remains mandatory even though role groups have no effect on this formula. Current labels and affiliations never provide a fallback.
- Only a single explicit UTC Monday-to-next-Monday week is accepted, opening inclusive and closing exclusive by stored kickoff. Player/season isolation, equivalent offsets and canonical selection follow the inherited contract.
- Malformed configuration, malformed numeric values, unexpected options and malformed nested collection structures return ordinary safe failures rather than uncaught exceptions or coerced defaults. Infrastructure failures remain visible; they are not reported as empty football history.
- Original replay never expands membership after late arrival or substitutes current configuration. Unavailable or inconsistent original evidence yields no score. Durable storage and authentication of retained descriptors remain downstream responsibilities.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST supply the production general weighted strategy identified as `balanced`, formula version `1`, through TASK-022's existing preparation, scoring, evaluation and replay behavior. Formula version identifies these semantics; configuration changes remain explicit effective rules, without a new version-management service in this task.
- **FR-002**: Each calculation MUST explicitly supply a nonempty set of metric weights and the common request's exact subject, season, UTC week, historical position mapping and metric references. The strategy MUST support any nonempty subset of goals, assists, shots on target, tackles, interceptions, saves, goals conceded, yellow cards and red cards. It MUST introduce no implicit metric selection, weight or reference preset.
- **FR-003**: Weights MUST be finite exact signed numbers, including integers, fractional decimals and zero. Empty or malformed configuration, missing/nonnumeric weights, booleans, binary floating-point values, nonfinite values, unsupported metrics/options and role-specific settings MUST yield ordinary validation failures without a score. There is no sign restriction or sum-to-one rule.
- **FR-004**: The strategy MUST derive its required metric set from every configured weight entry, including entries with zero weight, in overall scope only. Common request requirements MUST agree exactly and references MUST cover exactly that set with finite strictly positive exact values. An omitted metric is unrequired; a zero-weight metric remains required. A nonempty all-zero configuration MUST produce a valid zero score only when its required data is complete.
- **FR-005**: Selection and preparation MUST preserve TASK-022's accepted local facts, one-week kickoff selection, player/season isolation, explicit historical mapping, canonical evidence and distinct failure outcomes. Every selected performance contributes to each configured metric's overall total. No per-position scoring, row exclusion, imputation, per-match average, per-minute scaling, participation bonus or exposure threshold is permitted.
- **FR-006**: For configured metric m, with overall weekly total T_m, explicit positive reference R_m and signed weight W_m, the formula MUST be F_m = round6(min(T_m / R_m, 1)) and score = round6(sum(W_m * F_m)). Both round6 operations mean nearest with ties away from zero. The strategy MUST consume the common preparation's already rounded F_m; products and the sum MUST remain exact until the single final rounding. No extra intercept, normalization by weight sum, group combination or score-to-price conversion applies.
- **FR-007**: Arithmetic MUST avoid binary floating-point and dependence on ambient decimal precision, input ordering, current time, randomness or mutable affiliation. Required normalized features stay in [0,1]; the final signed score is not clamped. Features and scores MUST expose exactly six decimal places, no scientific notation and no negative zero. Accepted large counts and finite exact weights MUST not acquire an arbitrary numeric ceiling.
- **FR-008**: Known zeros and valid zero-minute records MUST score normally. Any unknown required metric MUST return the inherited insufficient-data outcome identifying metric, overall scope and performance, with no usable or partial score. Unknown unconfigured metrics MUST NOT block scoring. Empty recorded history MUST return no-recorded-performances, distinct from unknown-player and invalid-request failures; no fallback score or fabricated football record is allowed.
- **FR-009**: Success MUST return the common score result with complete reproduction evidence binding original accepted facts and membership, request rules, overall requirements, normalized features, all effective weights, strategy identity/version and score. It MUST be canonical regardless of input ordering and sufficient for the existing authoritative replay checks. No redundant strategy-specific evidence store is introduced.
- **FR-010**: Replay MUST reproduce original scores with the original explicit definition and rules. New facts, current affiliations, changed weights/references/mappings and active settings MUST NOT substitute for original evidence. Unsupported definitions and missing or inconsistent evidence MUST preserve the common distinguishable no-score outcomes. Score production MUST remain read-only, with no provider access, quote/history/financial writes or follow-up events.
- **FR-011**: Automated behavioral tests MUST cover every acceptance scenario and edge case through the common valuation workflow using deterministic local facts and the production balanced strategy. Coverage MUST include each of the nine metrics, positive/negative/fractional/zero weights, omitted versus zero-weight missing metrics, all-zero configurations, mixed-role overall saturation, invalid configuration and requirement/reference mismatches, weekly boundaries, zero minutes, exact rounding/cancellation, large values, permutation independence and original replay after changed configuration or late arrival. Error regressions MUST exercise ordinary failures, and read-only/provider-independent behavior MUST be checked.
- **FR-012**: Scope MUST remain this formula, explicit configuration validation, required-metric derivation and conformance to the existing scoring/replay contract. Position-aware rules belong to TASK-024; configuration persistence, active selection and immutable configuration lifecycle belong to TASK-025; quote conversion, orchestration, durable evidence retention and quote history belong to TASK-026. No catalog/provider/ingestion change, scheduler, job, cache, ranking, trading behavior, permission, endpoint, chart or user interface is added.

### Key Entities

- **Balanced Strategy Definition**: General overall-count formula with stable identity `balanced`, formula version `1` and explicit metric weights. The same effective definition applies regardless of player position or league.
- **Effective Calculation Rules**: Configured metric weights plus the request's matching overall requirements, positive references, exact week and historical mapping. They are retained together even though weights and preparation rules have different owners in the common contract.
- **Weekly Overall Features**: Six-place normalized configured metric totals from every selected accepted performance; historical roles and minutes remain evidence rather than scoring factors.
- **Balanced Score and Reproduction Evidence**: Signed six-place performance score and the existing complete descriptor linking its original facts, preparation rules and effective strategy definition. This is not a token quote or a new persistent entity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Consumers obtain the exact expected score in 100% of the specified arithmetic cases, including all nine individual metrics, mixed-role saturation, penalties, fractional/zero weights, both signed ties and large-value cancellation.
- **SC-002**: Consumers distinguish valid zero scores, no recorded performances, missing required data, invalid rules and unknown players in 100% of the specified cases, with zero fabricated or partial scores. Missing omitted metrics never block; missing configured zero-weight metrics always block.
- **SC-003**: At least 20 permutations of a multi-performance, multi-metric case produce identical scores and canonical evidence. Valid histories differing only in minutes, role assignments or current affiliation produce identical scores when configured overall totals and rules agree.
- **SC-004**: Original replay reproduces 100% of retained successful example scores after late arrivals or fresh rule changes when original facts and rules remain available. Every specified unavailable/inconsistent replay case fails explicitly without substitution.
- **SC-005**: Every successful acceptance example can be independently explained by the stated weighted-sum formula and retained inputs, without undocumented defaults. All acceptance calculations require zero provider access and cause zero quote, history or financial writes.

## Assumptions

- TASK-022 is the completed dependency. Its [approved behavioral specification](../058-valuation-contract-normalization/spec.md), including the human decisions recorded there, remains authoritative for common selection, normalization, error and replay rules; the relevant [contract](../058-valuation-contract-normalization/contracts/valuation-context.md) and [ADR-0020](../../docs/adr/0020-valuation-evidence-and-scorer-trust-boundary.md) constrain integration. This specification fully states the balanced formula and its metric/configuration decisions.
- Actors are trusted internal valuation consumers and market maintainers; this task introduces no public configuration interaction or permissions. General means one explicit rule set across positions, not empirically equal valuation for different roles.
- No approved numerical production preset exists in the supplied context. All reference and weight values are explicit operator choices; acceptance numbers are calculation fixtures, not recommended market calibration. This task provides the production formula and validation usable with such choices. A desired built-in preset would require a separately justified product decision rather than silently adopting test values.
- Metric-entry presence determines required data, including zero weights, following the common contract's explicit required-metric semantics. Removing an entry is the unambiguous way to disable its data requirement. This is a conservative rule against silently accepting incomplete configured inputs.
- Strategy identity and formula version are stable; changed effective configuration is captured in evidence now. Durable immutable configuration versions, activation and recovery of original definitions remain TASK-025; retained quote evidence remains TASK-026. The strategy does not claim to authenticate a wholesale replacement with another legitimate descriptor.
- The existing engine's mandatory historical mapping is retained even for this overall-only formula. Valid mapping changes that preserve overall totals do not alter the numeric balanced score but do change reproduction evidence.
- Mathematical correctness, transparent failures and reproducibility are the acceptance outcomes. No new latency or throughput promise, live-provider dependency or completeness guarantee for all real-world appearances is introduced.

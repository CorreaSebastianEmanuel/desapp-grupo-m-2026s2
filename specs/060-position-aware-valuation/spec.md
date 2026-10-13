# Feature Specification: Position-aware Valuation Strategy

**Feature Branch**: `024-position-aware-valuation-strategy`

**Created**: 2026-10-13

**Revised**: 2026-10-13

**Status**: Product decisions reconciled — ready for renewed independent product challenge and planning

**Input**: User description: "TASK-024 — Implement and test position-specific weighting for comparable player evaluation. Checkpoint CP2; depends on TASK-022. Incorporate approved Feedback 1."

## User Scenarios & Testing *(mandatory)*

Successful scenarios supply explicit valid rules for all four groups, references covering their configured metric union, historical mappings and a player/season with an explicit UTC week. Arithmetic examples describe all contributing terms; other groups are absent or have known-zero configured counts. Numerical examples are test inputs, not production presets. The mixed-position sum and its role-partition effect were approved in [Feedback 1](../../backlog/feedback/TASK-024.md); no product decision remains pending.

### User Story 1 - Evaluate Performance Under Historical Position Rules (Priority: P1)

As a market maintainer, I need the same recorded football metric to carry explicitly configured importance for each historical position, so players are evaluated according to their recorded roles rather than their current catalog position.

**Why this priority**: The second CP2 production strategy must give position-specific weighting a precise, reproducible meaning.

**Independent Test**: Evaluate single-position weekly histories for all four groups with explicit weights and references; compare their scores with independent calculations.

**Acceptance Scenarios**:

1. **Given** separate complete histories each containing 1 goal, goal reference 2, and goal weights 1 for goalkeeper, 2 for defender, 3 for midfielder and 4 for forward, **When** each history is evaluated, **Then** its normalized goal feature is 0.500000 and its score is respectively 0.500000, 1.000000, 1.500000 or 2.000000. Other absent groups contribute nothing and are not represented as recorded zeros.
2. **Given** goalkeeper rules weight saves by 2 and goals conceded by -1, weekly totals are respectively 3 and 2, and references are 4 for each, **When** a goalkeeper-only history is evaluated, **Then** features are 0.750000 and 0.500000 and the score is 1.000000. These illustrative weights do not establish a production preset.
3. **Given** historical center-back and fullback positions explicitly mapped to defender, **When** their selected performances total 3 tackles with reference 4 and defender tackle weight 2, **Then** they form one defender scope with feature 0.750000 and score 1.500000. Changing the player's current position or team leaves that result unchanged.
4. **Given** complete selected counts and fixed historical positions, **When** only valid recorded minutes change, including to zero or extra-time totals, **Then** features and score remain identical. No minutes, appearance or participation factor applies.
5. **Given** any of the nine supported counting metrics as the only configured metric of a populated group, with total 1, reference 2 and weight 2, **When** evaluation runs, **Then** that group's score is 1.000000. Each metric must be supported in each of the four groups without an implied sign or role restriction.

---

### User Story 2 - Evaluate Mixed Historical Positions Without Losing Facts (Priority: P1)

As a valuation consumer, I need every selected performance evaluated within its own historical position group, so a player who changes roles during the week is evaluated transparently.

**Why this priority**: A dominant-role shortcut would discard the role information required by the approved common valuation contract.

**Independent Test**: Partition a mixed defender/forward week and independently calculate the sum of its separately normalized weighted contributions, including saturation and addition of a populated group with known-zero counts.

**Acceptance Scenarios**:

1. **Given** 1 goal as defender and 1 goal as forward, shared goal reference 2, and respective goal weights 1 and 4, **When** evaluation runs, **Then** the two group features are each 0.500000, exact contributions are 0.500000 and 2.000000, and the final score is 2.500000.
2. **Given** 2 defender goals and 2 forward goals, goal reference 2 and both role weights 2, **When** evaluation runs, **Then** both independently capped features are 1.000000, both exact contributions are 2.000000, and the score is 4.000000. With the same four goals concentrated in either one role, the feature is capped at 1.000000 and the score is 2.000000. This role-partition effect is approved behavior; groups are neither averaged nor replaced by an overall normalization cap.
3. **Given** that mixed history with goalkeeper and midfielder rules also configured, **When** evaluation runs, **Then** the score remains 4.000000; absent groups remain absent and introduce no invented metric total, feature, penalty or missing-data error. Known zero in a populated group is still measured evidence.
4. **Given** a row whose historical position is neither center-back nor fullback, explicitly mapped to defender, with 1 tackle and 0 goals, and a forward row with 1 goal, tackle and goal references 2, defender rules requiring only tackles with weight 2 and forward rules requiring only goals with weight 4, **When** evaluation runs, **Then** the original score is 3.000000. Changing the explicit historical mapping to assign both rows to forward yields a fresh goal feature of 0.500000 and score 2.000000 with new evidence; replay of the original evidence still returns 3.000000. No catalog-position change alone can make this reassignment.
5. **Given** the 2.500000 history in scenario 1 and an additional midfielder row with known 0 goals, including valid zero minutes, with midfielder rules requiring only goals at weight 9 and the same reference 2, **When** the expanded week is evaluated, **Then** the midfielder feature is a measured 0.000000, the score remains 2.500000 and evidence records the added row/group. Adding a populated zero-contribution group cannot dilute other contributions.

---

### User Story 3 - Require Exactly the Statistics Configured for Each Position (Priority: P1)

As a market maintainer, I need missing data to be checked against the rules of the recorded position, so irrelevant unknown metrics do not block evaluation and required unknowns never become fabricated zeros.

**Why this priority**: Group-specific metric requirements are essential to a usable position-aware strategy and to honest valuation inputs.

**Independent Test**: Use four explicit group rule sets; vary metric presence, references, weight validity, empty history and historical mappings; inspect distinct no-score outcomes.

**Acceptance Scenarios**:

1. **Given** goalkeeper rules require only saves and defender rules only tackles, goalkeeper rows have known saves but unknown tackles, and defender rows have known tackles but unknown saves, **When** evaluation runs, **Then** preparation succeeds with complete required group features. No overall saves or tackles requirement is introduced.
2. **Given** a populated group with any unknown configured metric in one selected row, **When** evaluation runs, **Then** “datos insuficientes” identifies group, metric and performance and no partial or usable score is returned. This applies to zero-minute rows and to zero-weight metric entries.
3. **Given** a zero-weight metric entry, **When** the entry remains configured, **Then** its reference and known values are required in every selected row of that group. Removing the entry removes that group's requirement for the metric if another configured metric remains; requirements in other groups are unaffected.
4. **Given** nonempty metric rules for all four groups and all configured weights are zero, **When** required metrics in populated groups are complete, **Then** the score is 0.000000. A populated group's known-zero counts also score normally. Empty recorded history instead yields “sin actuaciones registradas” with no score; an unknown player yields not-found.
5. **Given** a missing group rule, an empty group metric set, overall weights, an unsupported group/metric/option, malformed nested collections or an invalid weight, **When** evaluation runs, **Then** ordinary validation identifies the invalid configuration with no score. Positive, negative, fractional and zero finite exact weights are valid; no sum-to-one requirement applies.
6. **Given** preparation requirements disagree with any configured group/metric pair, references do not exactly cover the union of all configured metrics, or a reference is missing, zero, negative or invalid, **When** evaluation or scoring runs, **Then** it fails validation without a default. One reference per metric is shared across groups, including currently absent groups' configured metrics.
7. **Given** invalid configuration and an otherwise empty week, **When** evaluation runs, **Then** the invalid configuration is rejected rather than concealed as no recorded performances. Invalid weeks or missing/conflicting historical mappings also preserve the common ordinary validation behavior.

---

### User Story 4 - Reproduce Exact Position-aware Contributions and Scores (Priority: P2)

As a quote-history consumer, I need the original historical grouping, effective rules and score retained together, so later facts or configuration changes cannot silently change an earlier calculation.

**Why this priority**: Reproducibility is a product invariant and the strategy must integrate with the existing score/replay contract before quote storage is delivered.

**Independent Test**: Independently calculate six-place features and exact contributions; retain successful results and replay original evidence after late arrival, configuration or affiliation changes.

**Acceptance Scenarios**:

1. **Given** 1 forward goal with reference 6 and forward weight 3 as its sole metric, **When** evaluation runs, **Then** feature 0.166667 produces score 0.500001. Scoring consumes the rounded feature, not the unrounded fraction. With reference 128 and weight 1, feature and score are both 0.007813, demonstrating feature half-rounding.
2. **Given** one populated group with goals and assists each normalized to 0.500000 and each weighted 0.000001, **When** evaluation runs, **Then** exact products sum before rounding and score is 0.000001, not 0.000002. With both weights negative the score is -0.000001. A sole 0.500000 feature weighted 0.000001 or -0.000001 yields respectively 0.000001 or -0.000001; a final -0.0000004 is exposed as 0.000000.
3. **Given** two features in one populated group both equal 1.000000 and respective weights 1000000000000000000000000000001 and -1000000000000000000000000000000, **When** evaluation runs, **Then** score is 1.000000 despite large cancellation. The same features/weights distributed across defender and forward yield exactly 1.000000 as well. Order and ambient decimal precision do not alter either result.
4. **Given** a successful evaluation, **When** its evidence is inspected, **Then** it binds strategy `position_aware`, formula version `1`, all four groups' configured weights, group requirements, shared references, original selected facts and resolved positions, week, normalized features, rounding and the final score through the existing complete reproduction descriptor.
5. **Given** an original forward goal score of 1.000000 from feature 0.500000 and weight 2, **When** fresh calculation uses weight 4 or includes a late accepted performance in the original week, **Then** it creates new evidence and may change the score. Replay with original facts and rules reproduces 1.000000; supplying changed weights, references or mappings cannot substitute for the original rules.
6. **Given** missing original facts/rules, altered facts, grouping, derived features or score, duplicated evidence or unsupported strategy identity/version, **When** scoring or replay runs, **Then** the common distinguishable validation, unsupported, unavailable or inconsistent no-score outcomes apply without fallback.
7. **Given** the same facts and effective rules in different performance, group-rule, metric or mapping-entry orders, with providers unavailable, **When** evaluation repeats, **Then** it produces identical score and canonical evidence with no external access or writes.
8. **Given** one defender and one forward goal, shared reference 2 and goal weight 0.000001 in each role, **When** evaluation runs, **Then** each feature is 0.500000, each exact group contribution is 0.0000005 and their sum yields score 0.000001. Rounding group subtotals would incorrectly produce 0.000002. With both weights -0.000001 the score is -0.000001, not -0.000002.
9. **Given** those same features with defender weight 0.000002 and forward weight -0.000001, **When** evaluation runs, **Then** the exact sum is 0.0000005 and the final score is 0.000001. Negating both weights yields exact sum -0.0000005 and score -0.000001. With weights 0.000001 and -0.000001 the contributions cancel to 0.000000.

---

### User Story 5 - Select Only the Explicit Historical Week (Priority: P2)

As a valuation consumer, I need the strategy to retain the common weekly selection and ordinary failure outcomes, so choosing a position-aware formula cannot change which local football facts are evaluated.

**Why this priority**: Scores are comparable only when their historical scope is explicit and reproducible.

**Independent Test**: Evaluate local records at week boundaries, with equivalent offsets and across a calendar-year boundary; verify membership, isolation and invalid requests.

**Acceptance Scenarios**:

1. **Given** the week 2026-10-05 00:00 UTC to 2026-10-12 00:00 UTC and subject performances immediately before, exactly at and inside both boundaries, **When** evaluation runs, **Then** only opening-inclusive/closing-exclusive records contribute, selected by stored kickoff rather than arrival or completion time. Equivalent explicit-offset bounds yield identical evidence and score.
2. **Given** the week 2026-12-28 00:00 UTC to 2027-01-04 00:00 UTC with records from the requested subject/season and other subjects/seasons, including distinct matches at the same instant, **When** evaluation runs, **Then** only the exact subject/season contributes, both distinct in-week matches remain distinct, and crossing the year imposes no extra season-date rule.
3. **Given** missing, ambiguous, equal, reversed, non-Monday, non-midnight or multiweek bounds, or a subject/season mismatch, **When** evaluation runs, **Then** ordinary validation returns no score without a current-week default. An unknown subject instead returns not-found.
4. **Given** separate populated histories with configured goal totals 0, 2 and a very large accepted integer, shared reference 2 and role weight 2, **When** evaluation runs, **Then** respective features are 0.000000, 1.000000 and 1.000000, and scores are 0.000000, 2.000000 and 2.000000. No arbitrary accepted-count ceiling or manufactured missing appearance is introduced.

### Edge Cases

- Empty recorded history differs from populated known-zero groups and from incomplete required metrics. No real-world appearance coverage is certified from available records.
- An absent group has no feature; it is never presented as known zero. Its explicit rules are still valid configuration retained for reproduction.
- Only metrics explicitly configured for a historical group are required in that group's rows. Unknown values in other groups remain raw evidence; no row is discarded or imputed.
- A metric with zero weight remains required. Nonempty all-zero group rules are valid; empty rules or missing groups are invalid. Numerically identical role weights are allowed even though position-specific weights can differ.
- Every selected historical position needs an unambiguous explicit mapping. Center-backs and fullbacks map to defender; mutable labels and current roles never supply a fallback. No dominant historical position is selected.
- Each populated group's total is independently capped before weighting. Several saturated groups can score higher than the same production concentrated in one group; this approved effect remains even with identical role weights. Adding a populated group with known-zero contributions changes evidence without diluting the score.
- Single-position and mixed-position scores can be negative or greater than one. Signed weights are applied as supplied without implied penalty signs, absolute values, group-level rounding, weight normalization, bias or score floor. Final scores remain performance scores, not token prices.
- Selection uses one explicit UTC Monday-midnight-to-next-Monday-midnight week, opening inclusive and closing exclusive by stored kickoff; equivalent offsets, year boundaries and player/season isolation follow TASK-022.
- Invalid finite-number representations, binary floating-point, nonfinite values, booleans, text weights and malformed collections yield ordinary failures, not arithmetic exceptions or silently coerced values. Infrastructure failures are not converted into football missing-data outcomes.
- Original replay uses only original membership and effective rules; fresh late-arrival selection cannot rewrite retained evidence. Durable evidence storage and authentication remain downstream responsibilities.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide the second production strategy identified as `position_aware`, formula version `1`, through TASK-022's existing preparation, scoring, evaluation and authoritative replay behavior. This task supplies a performance scoring formula, not a token price.
- **FR-002**: Each calculation MUST explicitly supply a nonempty metric-weight set for each of goalkeeper, defender, midfielder and forward, together with the common exact player/season, UTC week, historical mapping and metric references. Each group MUST support any nonempty subset of goals, assists, shots on target, tackles, interceptions, saves, goals conceded, yellow cards and red cards. No reference, metric set or weight preset is inferred.
- **FR-003**: Weights MUST be finite exact signed numbers, including integer, fractional and zero values. Missing/empty group rules, unsupported groups/metrics/options, overall-scope weights, malformed structures, duplicate group/metric entries where supplied as collections and missing/nonnumeric, text, boolean, binary floating-point or nonfinite weights MUST yield ordinary validation with no score. Duplicate required metrics and duplicate/conflicting historical mapping entries MUST also fail; canonicalization MUST NOT conceal them. Weights need not sum to one or differ across groups.
- **FR-004**: Required metrics MUST be derived exactly from configured entries in each historical group, including zero weights, with no overall requirements. Supplied preparation requirements MUST match all four derived group sets exactly. References MUST cover exactly their metric union with one strictly positive finite exact value per metric shared across groups. Absent groups' configured references remain required configuration; absent performances are not manufactured.
- **FR-005**: Every selected row MUST contribute to its mapped historical group's required weekly totals exactly once under TASK-022's selection and completeness rules. For group g and metric m, normalized feature MUST be F_gm = round6(min(T_gm / R_m, 1)) and exact weighted contribution MUST be W_gm * F_gm. The already-rounded common feature MUST be consumed; products and accumulation MUST remain exact until final score rounding. No overall contribution, per-minute scaling, match averaging, participation multiplier, minimum exposure or dominant-role classification applies.
- **FR-006**: The final score MUST be round6(sum over populated historical groups g and their configured metrics m of W_gm * F_gm). Absent groups contribute no term; populated groups with complete known-zero counts contribute exact zero without changing other groups' contribution or any denominator. Contributions MUST be summed exactly across metrics and groups before one final rounding. Group averaging and shared overall normalization MUST NOT replace this formula. Independent [0,1] caps per group intentionally allow the approved role-partition effect: four goals with shared reference 2 and weight 2 score 2.000000 in one role, versus 4.000000 when split two goals in each of two roles.
- **FR-007**: An absent group MUST NOT cause missing-data failure or be represented as measured zero. In any populated group, every configured metric MUST be known in every selected row; an unknown MUST return insufficient-data identifying group/metric/performance without a partial score. Unknown unconfigured metrics MUST NOT block. Known zeros and complete zero-minute rows MUST score normally. Invalid configuration is checked even when history is empty; valid empty history yields no-recorded-performances, distinct from not-found and validation failures.
- **FR-008**: Feature and final score rounding MUST be six decimal places, nearest with ties away from zero, with fixed six-place output and no scientific notation or negative zero. Arithmetic MUST avoid binary floating-point, ambient precision dependence and arbitrary ceilings on accepted counts or finite exact weights. No intermediate product or group score rounding is permitted. The cross-group sum MUST be rounded only once and remain a finite signed score without a clamp.
- **FR-009**: Success MUST return the common complete reproduction evidence binding original local facts/membership, resolved historical grouping, full mapping, week, every group's effective weights and requirements, shared references, normalized features, rounding, strategy identity/version and score. Canonical evidence MUST be independent of caller ordering, including entries for currently absent groups. No parallel evidence format/store is introduced.
- **FR-010**: Replay MUST authenticate original accepted facts and recompute with the original exact strategy definition and rules. Late facts, current affiliation and changed weights/references/mappings MUST NOT substitute for original evidence. Unsupported definitions, unavailable originals and inconsistent retained evidence MUST preserve the common distinguishable no-score outcomes. Configuration changes affecting only an absent group still change effective evidence and cannot replace the original replay definition.
- **FR-011**: Calculation MUST remain deterministic and read-only, using accepted local facts and explicit rules, without current-time/randomness dependence, provider access, writes or follow-up events. Invalid structures and expected scoring failures MUST return safe ordinary errors; infrastructure failures MUST remain visible. No failure may produce a usable score, quote or financial/historical write.
- **FR-012**: Automated behavioral tests MUST cover every acceptance scenario and edge case through the common production evaluation, authoritative fact verification before scoring and replay workflow. Coverage MUST include all four groups and nine metrics; mixed roles, independent group saturation and the approved concentrated-versus-split example; absent versus known-zero groups and no dilution from adding a populated zero-contribution group; group-specific unknowns and zero-weight requirements; invalid rules/reference/requirement/mapping cases including duplicates; UTC boundaries and season isolation; minutes independence; rounded-feature consumption, signed ties, exact cross-group accumulation without subtotal rounding, large cancellation within and across groups and at least 20 input permutations; changed-rule/late-arrival replay and inconsistent/unavailable evidence; ordinary malformed-input failures and zero provider/write effects.
- **FR-013**: Scope MUST remain this strategy's formula, explicit configuration validation, group metric derivation and conformance to the existing scoring/replay contract. TASK-025 owns durable configuration/version lifecycle and active selection; TASK-026 owns quote conversion, orchestration and immutable evidence/history retention. No change to the balanced strategy, statistics schema, provider/ingestion behavior, scheduler, job, cache, ranking, trading, permission, endpoint, chart or user interface is included.

### Key Entities

- **Position-aware Strategy Definition**: Strategy identity, formula version and explicit signed metric weights for each of the four supported historical groups.
- **Effective Group Rules**: Complete four-group weights and requirements plus shared per-metric references, week and historical-position mapping, retained together even when only one group is populated.
- **Historical Group Features**: Independently normalized weekly counts for the required metrics of each populated historical group. Raw affiliation and minutes remain evidence, not scoring factors.
- **Position-aware Result and Reproduction Evidence**: Finite six-place performance score and the common descriptor binding original facts and effective rules. This is neither a persisted quote nor a new financial entity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Consumers obtain the exact specified score in 100% of single-position and mixed-position arithmetic examples, including each of nine metrics in all four groups, independent saturation, the 2.000000 concentrated versus 4.000000 split outcome, no dilution from zero-contribution groups, signed ties and exact accumulation/cancellation within and across groups.
- **SC-002**: Consumers distinguish valid zero, absent roles, empty history, unknown required metrics, invalid rules and unknown players in 100% of specified cases, with zero fabricated rows or partial scores. Unknown unconfigured metrics never block complete applicable rules.
- **SC-003**: At least 20 permutations of a multi-performance, multi-group, multi-metric case yield identical scores and canonical reproduction evidence. Changing only valid minutes or current affiliation alters no score.
- **SC-004**: Replay reproduces 100% of retained successful example scores using original available facts/rules after late arrival or fresh configuration changes. Every specified unavailable/inconsistent replay case fails explicitly, including a rule change for an absent group.
- **SC-005**: A maintainer can explain every successful example from retained historical groups, references, weights and the approved formula, with no undocumented preset. All acceptance calculations require zero provider access and cause zero quote/history/financial writes.

## Assumptions

- TASK-022 is the completed dependency. Its [approved specification](../058-valuation-contract-normalization/spec.md), including human clarifications, governs common weekly selection, historical grouping, normalization, no-score taxonomy and reproduction. Its [valuation contract](../058-valuation-contract-normalization/contracts/valuation-context.md) and [ADR-0020](../../docs/adr/0020-valuation-evidence-and-scorer-trust-boundary.md) constrain integration. This specification owns only production position-aware decisions.
- Trusted internal valuation consumers and market maintainers are the actors. Comparable means the same explicit configuration and historical grouping rules are applied consistently; it does not promise statistically equal scores for different roles or real-world price accuracy.
- Complete rules for all four groups are a conservative configuration boundary: every valid historical performance has applicable rules without a fallback or silent omission. Absent groups remain absent in evidence. Group-specific metric selection allows role-relevant data requirements without prohibiting any supported metric for any role.
- No approved numerical production calibration is supplied. Reference/weight values remain explicit operator choices; acceptance numbers are deterministic fixtures, not a recommended market preset. Built-in calibration would require a separate justified product decision. This matches the sibling balanced strategy's explicit-configuration boundary without making TASK-023 a prerequisite.
- Stable identity/version describe the formula. Effective rule changes are captured in evidence; durable immutable versions, activation and original-definition recovery remain TASK-025. Durable descriptor retention/integrity remains TASK-026; no authentication claim for wholesale substitution with another legitimate descriptor is introduced.
- [Feedback 1](../../backlog/feedback/TASK-024.md) explicitly approves exact summation with independent per-group caps and shared per-metric references, accepting the role-partition effect. Comparability means consistent rules, not equal scores for equal production partitioned differently across roles. This settled decision requires no further human product check.
- No new latency, throughput, live-source or real-world completeness guarantee is introduced. Correctness, transparency and exact reproducibility are the acceptance outcomes.

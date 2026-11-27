# Feature Specification: Valuation Engine Contract and Normalization

**Feature Branch**: `022-valuation-engine-contract-and-normalization`

**Created**: 2026-10-12

**Revised**: 2026-10-13

**Status**: Product decisions reconciled — ready for independent product challenge and planning

**Input**: User description: "TASK-022 — Define deterministic scoring inputs, normalization windows, position groups, and decimal output. Checkpoint CP2; depends on TASK-020. Incorporate the approved human decisions in Feedback 1."

## Human Clarifications — 2026-10-12

The approved decisions in [Feedback 1](../../backlog/feedback/TASK-022.md) supersede the original draft proposals. The supplied 2026.2doSem.DocumentoDeVisión (1).pdf, section 3.2, pages 2–3, was reviewed during the human clarification: it requires configurable weighted strategies and proposes weekly/match aggregates and normalization to [0,1]. The requirements and scenarios below are the complete agreed behavior.

- Evaluate recorded performances by kickoff within one UTC week: Monday 00:00 inclusive to the following Monday 00:00 exclusive.
- Sum weekly counting metrics. Minutes provide historical evidence only; participation earns no bonus or penalty, and zero minutes do not invalidate a calculation.
- Normalize each required counting total to [0,1] by min(total / explicit positive configured metric reference, 1), then apply strategy weights. Production references and weights belong to TASK-023/024; TASK-022 uses explicit configuration and illustrative test values without production defaults.
- Missing required metrics yield insufficient data without a score; missing unrequired metrics do not block. Known zeros are valid. No imputation or silent exclusion is allowed.
- Empty recorded history yields the separate outcome “sin actuaciones registradas”, without asserting actual nonparticipation or deciding how quotes are retained/displayed.
- Use each performance's historical position, explicitly mapped to goalkeeper, defender, midfielder or forward, without current-position fallback.
- Normalized features and final scores have six decimal places, rounded to nearest with ties away from zero. Signed strategy weights may penalize unfavorable counting metrics; normalized features stay in [0,1].
- Routine reversible representation and validation choices are delegated under AGENTS rule 9. These settled decisions require no further human product check.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Prepare Comparable Weekly Local Inputs (Priority: P1)

As a valuation consumer, I need an explicit week's accepted local performances and consistently normalized counting totals, so strategies compare football performance using the same facts and rules.

**Why this priority**: Both planned strategies need a common input contract before their production weights can be defined.

**Independent Test**: Prepare an explicit week with known local histories and illustrative references; compare selected membership, totals and normalized features with hand-calculated results.

**Acceptance Scenarios**:

1. **Given** a requested week from 2026-10-05 00:00 UTC to 2026-10-12 00:00 UTC and performances immediately before, exactly at and inside these boundaries, **When** preparation runs, **Then** the opening-boundary performance is included, the closing-boundary performance is excluded, and only that exact season-specific player's recorded performances inside the week contribute. Equivalent time-zone offsets select identical membership.
2. **Given** two selected performances with 90 and 45 minutes and 1 and 2 goals, and an illustrative goal reference of 4, **When** goals are prepared, **Then** total goals are 3, retained total minutes are 135 and the normalized goal feature is 0.750000. Changing only valid recorded minutes leaves that feature and its weighted contribution unchanged.
3. **Given** totals of 0, 4 and 9 goals in separate valid histories and a goal reference of 4, **When** preparation runs, **Then** normalized goals are respectively 0.000000, 1.000000 and 1.000000.
4. **Given** selected performances for different historical teams in one season, **When** current team changes, **Then** weekly membership and contributions remain unchanged with original affiliations retained; facts from another player or season never contribute.
5. **Given** identical accepted facts in different caller orders and an unavailable provider, **When** preparation repeats, **Then** membership, totals, features and reproduction evidence are identical without provider access.
6. **Given** missing, equal, reversed, ambiguous or nonweekly bounds, or a missing, zero, negative, nonfinite or binary floating-point required reference, **When** preparation is requested, **Then** validation identifies the invalid request and returns no score or fabricated default.

---

### User Story 2 - Distinguish Missing Records, Insufficient Data and Zero (Priority: P1)

As a market maintainer, I need valid zeros, absent records and unknown required metrics distinguished, so calculations do not manufacture football evidence or a score.

**Why this priority**: Treating unknown performance as zero changes valuations and conceals coverage failures.

**Independent Test**: Compare known-zero, empty, zero-minute and incomplete weekly histories; inspect distinct outcomes and confirm failures return no usable score.

**Acceptance Scenarios**:

1. **Given** at least one selected performance and a required counting metric explicitly zero in every selected row of its scope, **When** preparation runs, **Then** its total is known zero and its normalized feature is 0.000000, including when every row has zero minutes.
2. **Given** a known player without recorded performances in the requested week, **When** evaluation runs, **Then** it returns “sin actuaciones registradas” without a score; this differs from unknown-player not-found and from “datos insuficientes”, and does not assert actual absence from matches.
3. **Given** one selected row with an unknown required metric, **When** preparation runs, **Then** “datos insuficientes” identifies the metric, scope and performance; no imputation, row exclusion or partial score occurs.
4. **Given** an unknown metric not required in that row's scope, **When** preparation runs, **Then** its unknown value remains in raw evidence without blocking required features.
5. **Given** a zero-minute performance with 2 goals and another with 1 goal, and a goal reference of 4, **When** preparation runs, **Then** both counts contribute and normalized goals are 0.750000, including when the second performance also has zero minutes.
6. **Given** a zero-minute performance with an unknown required metric, **When** preparation runs, **Then** insufficient data identifies the missing metric; minutes neither excuse missing data nor cause the failure.
7. **Given** matches without a recorded performance for the subject, **When** evaluation runs, **Then** those matches contribute no manufactured row or metric, and coverage of all real appearances is not certified.

---

### User Story 3 - Retain Historical Position Groups (Priority: P2)

As a position-aware strategy consumer, I need weekly features grouped by each performance's recorded position, so later catalog changes cannot reclassify historical contributions.

**Why this priority**: TASK-024 needs position-specific inputs while TASK-023 needs overall inputs from the same facts.

**Independent Test**: Prepare a mixed-role history with explicit mappings and metric requirements per scope; change current position and compare overall and group totals and features.

**Acceptance Scenarios**:

1. **Given** a defender performance with 2 tackles and a midfielder performance with 1 tackle, and a tackle reference of 4, **When** overall and both groups require tackles, **Then** overall tackles are 3 with feature 0.750000, defender tackles are 2 with feature 0.500000 and midfielder tackles are 1 with feature 0.250000. Minutes do not change these values.
2. **Given** those facts, **When** current position changes to forward, **Then** historical group membership, totals and features remain unchanged.
3. **Given** a selected historical position without an explicit mapping, assigned to multiple groups or assigned to an unsupported group, **When** preparation runs, **Then** validation identifies the position/mapping without guessing from labels or current position. Central defenders and fullbacks map to defender.
4. **Given** no selected goalkeeper performances, **When** grouped inputs are returned, **Then** goalkeeper is absent rather than a measured zero. All selected rows still belong to exactly one of the four supported groups.
5. **Given** a populated defender group with zero minutes and 2 tackles and a populated midfielder group with positive minutes and 1 tackle, **When** both groups require tackles with reference 4, **Then** both succeed with features 0.500000 and 0.250000; no exposure threshold applies.
6. **Given** goalkeeper rows with known saves but unknown tackles and defender rows with known tackles but unknown saves, **When** only goalkeeper saves and defender tackles are required, **Then** preparation succeeds. Adding overall saves makes the defender's unknown saves insufficient data; group-specific requirements never imply missing metrics are zero.
7. **Given** selected defender performances but requirements only for goalkeeper saves, **When** preparation runs, **Then** no goalkeeper group is manufactured and insufficient data identifies the absence of an applicable required scope, without a score.

---

### User Story 4 - Replay a Decimal Score Exactly (Priority: P2)

As a quote-history consumer, I need a score to identify its exact facts and effective scoring rules, so late statistics and configuration changes cannot change a historical calculation.

**Why this priority**: Product invariant 7 requires reproducibility; a week's bounds alone do not freeze original membership.

**Independent Test**: Evaluate a deterministic illustrative weighted scorer, retain its reproduction descriptor, add a late performance in the week and compare replay with fresh selection.

**Acceptance Scenarios**:

1. **Given** normalized overall goals of 0.750000 and goals conceded of 0.500000, an explicit illustrative strategy/version and weights of 2 and -1 respectively, **When** scoring runs, **Then** the score is 1.000000 with prepared inputs and a complete reproduction descriptor. Negative weights do not make normalized features negative.
2. **Given** normalized goals conceded of 0.500000 with weight -2 and no other required contribution, **When** scoring runs, **Then** the score is -1.000000; scores are finite signed decimals and are not clamped to the normalization interval.
3. **Given** a successful result and a late performance within its week, **When** the descriptor is replayed, **Then** original membership, features and score remain unchanged. Fresh selection may include the late row and creates different evidence.
4. **Given** 1 goal with reference 6 and an illustrative weight of 3, **When** preparation then scoring run, **Then** normalized goals are 0.166667 and the score is 0.500001, demonstrating that the scorer consumes rounded features. With reference 128, normalized goals are 0.007813.
5. **Given** scorer results 1.2345674, 1.2345675 and -1.2345675, **When** final output is produced, **Then** scores are 1.234567, 1.234568 and -1.234568 respectively. A result of -0.0000004 is exposed as 0.000000.
6. **Given** a changed strategy version, references, weights or position mapping, **When** a new calculation runs, **Then** its descriptor identifies the changed rules; replay uses the original rules or fails explicitly if they are unavailable.
7. **Given** duplicated rows, unavailable original facts/rules or disagreements between original facts, group assignments, totals, features or score in replay evidence, **When** replay runs, **Then** it fails without substituting current facts or returning a partial score.
8. **Given** an unsupported strategy/version, a scorer failure or a nonfinite/nondecimal scorer result, **When** scoring runs, **Then** the corresponding failure is distinguishable and returns no fallback score, quote or historical rewrite.

### Edge Cases

- Both week bounds are explicit unambiguous instants. After conversion to UTC they must be Monday 00:00 and the immediately following Monday 00:00. Missing, equal, reversed, non-Monday, non-midnight and multiweek intervals are invalid. No current-week, last-N, season-to-date or scheduler default is inferred.
- Selection follows stored kickoff, not import time, match completion time or current affiliation. Distinct matches at the same instant remain distinct.
- A week may cross a calendar-year boundary; subject and season isolation still apply without inventing season-date constraints.
- Raw minutes, including zero, extra time and stoppage time, remain unchanged and have no scoring contribution or arbitrary cap. Counting totals are never divided by minutes, appearances or match duration.
- Every selected row contributes to each required total in its applicable scope. Unknown required metrics prevent that scope's calculation and any score; unrequired unknown metrics remain evidence.
- Required metric references must be explicit, finite and strictly positive. Each metric uses the same supplied reference in overall and group scopes; there is no reference estimated from the week's population.
- A saturated normalized feature remains 1.000000 even for very large accepted counts. A group total is independently normalized; summing capped group features need not equal the capped overall feature. Mixed-group combination is chosen by the later strategy.
- Empty groups are absent. A present group with known zero counts differs from an absent group. If performances exist but no declared required scope is populated, the outcome is insufficient data without a score, not no recorded performances. No minimum-match or positive-minute threshold is inferred.
- Replay/input evidence with duplicate performance identities or duplicate player-match pairs is invalid, even if duplicate rows agree. Out-of-week, wrong-player and cross-season replay rows are rejected rather than silently filtered.
- Replay retains original historical mapping and resolved groups even if a new calculation uses changed rules. Caller order, locale and provider availability cannot affect arithmetic.
- Normalized features stay in [0,1]; signed weights can reduce the final score. A score is not a token price; denomination, score-to-price conversion and price positivity belong to later tasks.
- Unavailable or inconsistent reproduction evidence causes an explicit replay failure, never fresh selection or substitution of a different strategy version. Rounded zero has no negative sign.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST define a provider-neutral common preparation, scoring and replay contract using TASK-020's accepted local facts. It MUST support explicitly supplied deterministic scorers without implementing either production strategy in TASK-022.
- **FR-002**: Fresh preparation MUST identify one exact catalog player, its season, an explicit evaluation week, required metrics by scope, a historical position mapping and every required metric reference. Scoring MUST additionally identify a strategy, its version and all effective configuration including weights. No required value may be inferred from current time, display names, current affiliation, provider state or an active global default.
- **FR-003**: Selection MUST use only the subject's accepted recorded performances in the identified season whose stored kickoff satisfies start <= kickoff < end. Both bounds MUST form one UTC Monday-00:00-to-next-Monday-00:00 week at TASK-020's accepted precision. Equivalent offset representations MUST have identical behavior. Unknown subjects yield not-found; malformed requests, invalid weeks and player/season mismatches yield validation failure. Valid empty selection yields the distinct no-recorded-performances outcome “sin actuaciones registradas” with no score and no claim of actual nonparticipation.
- **FR-004**: For every required counting metric in each applicable scope, preparation MUST sum all selected performances in that scope and normalize the total as min(total / configured metric reference, 1). Overall scope includes every selected row; a historical group scope includes every row assigned to that group. References MUST be explicit finite strictly positive integer or exact decimal values, with one reference per required metric shared across scopes. Missing or invalid required references MUST yield validation failure; production defaults MUST NOT be invented. No match averaging, duration division, recency weighting, population-relative scaling or engine-inferred multiplier applies.
- **FR-005**: Supported counting metrics MUST be goals, assists, shots on target, tackles, interceptions, saves, goals conceded, yellow cards and red cards, retaining TASK-020's meanings and non-negative integer validity. Minutes MUST remain historical evidence and MUST NOT be a scoring feature, bonus, penalty or validity threshold. Required metrics MUST be explicitly declared for overall scope, particular historical groups, or both, allowing different required sets per group. Empty requirement declarations, empty declared metric sets and unsupported metrics/scopes MUST yield validation failure. Requirements for groups without selected rows do not manufacture zero-valued groups. If selected performances exist but none belongs to any declared required scope, preparation MUST return insufficient data with reason no applicable required scope, without a score.
- **FR-006**: An unknown required metric in any selected performance of its required scope MUST yield insufficient data, “datos insuficientes”, identifying the metric, scope and performance without a score. Missing unrequired metrics MUST NOT block preparation. Known zero is valid, including in zero-minute performances. No imputation, silent exclusion, partial score or default score is allowed. Zero total minutes alone MUST NOT invalidate otherwise complete inputs.
- **FR-007**: Every selected performance MUST be assigned using its historical stable position identity and an explicit unambiguous mapping to exactly one of goalkeeper, defender, midfielder or forward, including for overall-only requests. Central defenders and fullbacks MUST map to defender. Missing mappings, conflicting assignments and unsupported groups MUST yield validation failure. Unused mapping entries are allowed. Current positions and mutable labels MUST NOT supply fallback classifications. Groups partition original evidence without choosing a dominant role or default combination weights.
- **FR-008**: Prepared inputs MUST retain selected performance/match identities, kickoff instants, subject/season, historical team/position, raw minutes and known/unknown metrics. They MUST expose overall and populated-group membership, row counts, total recorded minutes, complete required counting totals, supplied references and normalized features. Unrequired metrics remain raw evidence; no complete total or normalized feature is promised for them. Absent groups MUST remain absent.
- **FR-009**: Each required normalized feature MUST be capped to [0,1] and then rounded once to six decimal places, to nearest with ties away from zero. Scorers MUST consume those rounded features; there is no per-row or other intermediate rounding. Strategy weights apply after normalization. The final score MUST be rounded once with the same rule, without an engine-imposed score clamp. Binary floating-point arithmetic is forbidden. The reference/total ratio MUST preserve sufficient exactness for repeating fractions and half-rounding: 1/6 produces 0.166667 and 1/128 produces 0.007813.
- **FR-010**: Scoring success MUST include one finite signed decimal score, prepared inputs and a complete reproduction descriptor. Exposed normalized values and scores MUST have exactly six decimal places without scientific notation or negative zero; counts/minutes remain integers. Numeric configuration MUST use finite exact integer/decimal values, never binary floating-point, NaN, infinity or booleans. A nondecimal scorer result MUST fail rather than be coerced to a score. Arithmetic MUST support TASK-020's accepted integer counts without a new arbitrary ceiling.
- **FR-011**: Reproduction evidence MUST capture exact original membership, immutable raw facts or references sufficient to recover them unchanged, subject/season, UTC week bounds, metric-scope requirements, historical mappings and resolved groups, references, normalization/rounding rules and, for scoring, exact strategy/version and every effective configuration value including weights. Labels and week bounds alone are insufficient. Evidence MUST be canonical regardless of caller order, ordering rows by kickoff instant, stable match identity and performance identity with locale-independent identity comparison; metric/group/configuration ordering MUST also be deterministic.
- **FR-012**: Replay MUST use only original membership and effective rules, validate fact identity/values, player/season, week membership and historical grouping, and reject duplicate or inconsistent evidence. Derived totals, normalized features and scores MUST be recomputed from the original immutable facts and rules; disagreements with supplied derived values MUST fail. Replay MUST NOT select fresh membership, use mutable affiliation or silently substitute configuration. Fresh selection after late arrival is a new calculation. TASK-022 defines and returns the necessary evidence; TASK-026 owns its durable retention with immutable quotes.
- **FR-013**: Validation, not-found, no-recorded-performances, insufficient-data, unsupported-strategy, strategy-failure and unavailable/inconsistent-replay outcomes MUST be distinguishable. Failures MUST identify relevant fields, metrics, scopes, performances or rules without provider payloads/persistence internals. Missing values MUST be reported deterministically. No unsuccessful outcome yields a usable score, partial success, quote or financial/historical write. Expected invalid requests MUST return ordinary failures rather than unhandled exceptions.
- **FR-014**: A scorer MUST evaluate only supplied prepared inputs and explicit effective configuration, using rounded normalized counting features for weighted contributions. Raw minutes/membership are evidence, not participation scoring inputs. Scorers MUST NOT fetch external data, inspect current affiliation, depend on randomness/current time or silently select another version. Explicit illustrative general and group-aware scorers MUST suffice to verify the contract without adopting TASK-023/024 production formulas or defaults. Mixed-group combination and production weight selection remain later strategy decisions.
- **FR-015**: Automated behavioral tests MUST cover every acceptance scenario and edge case with deterministic local facts and illustrative scorers. Required coverage includes all nine metrics' known-zero/unknown handling; UTC weekly opening/closing boundaries and invalid weeks; equivalent offsets; season/player isolation; all four groups and group-specific requirements; transfers/mixed roles; zero-minute/extra-time inputs; saturation/large counts; invalid references/configuration; replay duplicates, tampering and unavailable facts/rules; late arrival; changed mappings/references/weights/version; ordering independence; repeating fractions; both signs' half-rounding; distinct ordinary failure outcomes; and absence of provider access, fabricated facts or quote/history writes.
- **FR-016**: Scope MUST remain common preparation/scoring/replay contracts, weekly selection, counting normalization, historical grouping, decimal outputs and failure semantics. Production references, weights and score-to-price formulas belong to TASK-023/024; configuration storage/selection/version lifecycle belongs to TASK-025; quote orchestration, retention/display, persisted history and durable follow-up events belong to TASK-026 and later quote tasks. Adapters, ingestion/provenance/corrections, scheduling/jobs, ranking, trading, caching, endpoints, authentication, charts and user interfaces are excluded.

### Key Entities

- **Valuation Request**: Exact season-specific subject, explicit UTC week, required counting metrics by scope, positive per-metric references and historical position mapping; scoring adds strategy identity/version and complete effective configuration.
- **Prepared Inputs**: Canonical immutable performances, historical group partitions, raw totals and rounded normalized counting features; minutes and affiliation are retained evidence.
- **Position Group Mapping**: Explicit stable historical-position assignments to the four supported role groups, captured alongside original resolved assignments.
- **Strategy Definition**: Deterministic scoring rules with identity, version, explicit metric-scope requirements and effective configuration/weights; production formulas remain later tasks.
- **Result and Reproduction Descriptor**: Finite decimal performance score and sufficient evidence to reproduce original membership, facts and rules; distinct no-score outcomes describe missing records, missing required values and other failures.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Deterministic examples across five supported leagues, at least two seasons and all four groups yield 100% of expected weekly membership, counting totals and normalized features, including exact boundary and saturation cases.
- **SC-002**: Consumers distinguish valid zero, no recorded performances, unknown required metrics and unknown subjects in 100% of specified cases without fabricated scores. Complete zero-minute histories succeed, and changing only valid recorded minutes changes no normalized feature or weighted score.
- **SC-003**: Repeated calculations and at least 20 permutations of one multi-performance set yield identical features, reproduction descriptors and scores. Replay after late arrival, current-affiliation changes or new configuration reproduces 100% of original successful results when original evidence remains available.
- **SC-004**: Every decimal example, including repeating fractions, feature-before-score rounding, saturation, signed half-rounding and large counts, agrees exactly with the specified six-decimal rules, with zero floating-point-dependent results.
- **SC-005**: General and group-aware illustrative scorers consume the same underlying evidence without provider interpretation or changes to accepted facts; consumers can identify every specified failure and reproduce every successful score from its original evidence.

## Assumptions

- TASK-020's [specification](../054-player-match-statistics/spec.md) supplies immutable completed-match performances, precise kickoff instants, historical affiliation, integer minutes and optional counting metrics. TASK-005/ADR-0002 supply season-specific identities and mutable current affiliation. Their existing contracts remain authoritative.
- Actors are trusted internal valuation consumers; no public role, permission or route is introduced.
- Required metrics are scope-specific: a metric required for a group is checked in every selected row of that group; a metric required overall is checked in every selected row. Missing unrequired values in other groups never imply zero or block a complete required scope.
- The caller explicitly supplies the week and effective configuration. Illustrative reference/weight numbers in scenarios are test inputs only, never approved production defaults. Production reference/weight justification and mixed-role weighting remain TASK-023/024.
- Position taxonomy remains extensible catalog data. An explicit mapping is supplied rather than freezing provider codes or creating positions; TASK-025 resolves durable mapping/configuration ownership and version lifecycle.
- Prepared evidence describes available accepted recorded facts, not certified complete real-world coverage. Missing source coverage and correction remain ingestion concerns.
- TASK-026 must retain descriptors or equivalent immutable evidence with quotes. Snapshot storage, publication/availability cutoffs, scheduler timing and quote-effective-date/display policies are not selected here.
- No latency service guarantee is introduced; correctness, clear no-score outcomes and reproducibility are the outcomes of this foundational contract.

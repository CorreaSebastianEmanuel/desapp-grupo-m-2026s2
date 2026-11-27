# Feature Specification: Valuation Strategy Configuration and Versioning

**Feature Branch**: `025-valuation-strategy-configuration-and-versioning`

**Created**: 2026-10-13

**Status**: Ready for independent product challenge

**Input**: User description: "TASK-025 — Configure/select strategies and preserve immutable versions used by every calculation. CP2; depends on TASK-023 and TASK-024."

## User Scenarios & Testing *(mandatory)*

The actors are trusted market maintainers and internal calculation consumers. This feature provides durable rule management and version-bound performance evaluation; it introduces no public administration interface. Formula version and configuration version are different identities: `balanced`/`1` and `position_aware`/`1` identify the approved formulas; each saved complete rule set receives its own permanent configuration-version identity. Acceptance numbers are fixtures, never production presets.

### User Story 1 - Save and Inspect Complete Valuation Rules (Priority: P1)

As a market maintainer, I need to save complete explicit rules for either approved strategy and retrieve them later, so calculations can use intentional, inspectable settings rather than transient configuration.

**Why this priority**: Every calculation needs recoverable original rules before active selection or quote history can be reliable.

**Independent Test**: Save one valid rule set for each strategy, inspect their derived requirements and exact values, and retrieve both after application restart without a provider connection.

**Acceptance Scenarios**:

1. **Given** balanced formula `1`, goal weight 2, goal reference 2 and an explicit valid historical-position mapping, **When** the maintainer saves the rules, **Then** a new permanent version identifies the formula, exact weights, references, mapping, derived overall goals requirement and creation time; it is available for explicit use but is not automatically active.
2. **Given** position-aware formula `1`, nonempty metric weights for all four historical groups, references exactly covering their metric union and an explicit mapping, **When** rules are saved, **Then** all groups' settings are retained, including groups absent from current performances; references are shared by metric across groups and no overall requirement is added.
3. **Given** unsupported formula identity/version, missing or malformed weights, references, mapping, unexpected settings, conflicting or duplicate supplied entries, or a missing position-aware group, **When** saving is attempted, **Then** an ordinary validation or unsupported-strategy outcome identifies the problem, with no saved version or selection change.
4. **Given** a configured zero-weight metric or nonempty all-zero weights, **When** rules are saved, **Then** the configuration is valid with the same references and required metrics as nonzero entries. Omitting a metric removes its requirement; an empty balanced metric set or empty position-group metric set is invalid.
5. **Given** exact fractional, negative or very large weights and strictly positive exact references, **When** rules are saved and retrieved after restart, **Then** their exact values and canonical evidence semantics are preserved without rounding, truncation or binary floating-point conversion. Missing, zero, negative or nonfinite references are rejected.
6. **Given** saved versions for both strategies and no active selection, **When** the maintainer lists versions or requests one by identity, **Then** formula identities, full rules, requirements, creation times and current selection are inspectable; an unknown version yields not-found and an empty list is distinct from storage failure.

---

### User Story 2 - Select the Rules Used by New Market Calculations (Priority: P1)

As a market maintainer, I need to explicitly select a saved version for subsequent market calculations and restore an older version when needed, so rule changes are intentional and recoverable.

**Why this priority**: CP2 needs a single unambiguous active strategy, while historical rules must remain available.

**Independent Test**: Save two balanced versions and one position-aware version; activate, switch and restore them while inspecting selection history and stale-change failures.

**Acceptance Scenarios**:

1. **Given** saved versions and no active selection, **When** a maintainer activates a supported version while declaring that no selection is expected, **Then** exactly that version becomes the single market-wide active selection and a durable change records its identity and effective time.
2. **Given** active balanced version A and saved position-aware version B, **When** activation of B declares A as the expected current version, **Then** subsequent active calculations select B, A remains intact and usable by explicit identity, and the change records A, B and its effective time.
3. **Given** B is active, **When** the maintainer restores previously saved A with expected current version B, **Then** A becomes active through a new recorded change; neither A nor B is edited and no new configuration version is needed merely to restore A.
4. **Given** active A, **When** activation targets an unknown, malformed or currently unsupported version, or declares a stale expected selection, **Then** it fails distinctly without changing A or appending a successful selection change.
5. **Given** two requests to select different versions both expecting A, **When** they compete, **Then** at most one changes selection, the other receives a conflict, and a reader sees a complete old or new selection. Repeating activation of the already active version with a matching expected selection succeeds without a duplicate change record; a stale expectation still conflicts.
6. **Given** successful selection changes, **When** the application restarts or providers are unavailable, **Then** the active identity and ordered append-only change history remain recoverable. Saving an additional version alone does not change either.

---

### User Story 3 - Bind Each Calculation to One Immutable Version (Priority: P1)

As a calculation consumer, I need the exact rules used by every managed calculation recorded with its result, so changing the active strategy cannot change a calculation already in progress or conceal how a score was obtained.

**Why this priority**: Version provenance is the core task outcome and a prerequisite for reproducible quotes.

**Independent Test**: Evaluate fixed accepted local weekly facts through active and explicit-version selection, including a controlled activation during evaluation; inspect the version binding and existing reproduction evidence.

**Acceptance Scenarios**:

1. **Given** active balanced A with goal weight 2, reference 2 and a selected weekly total of 1 goal, **When** a managed active calculation begins, **Then** it fixes A before selecting football facts and produces score 1.000000 with A's permanent configuration identity, formula identity/version and the complete existing reproduction evidence.
2. **Given** that calculation has fixed A and B becomes active before it finishes, **When** it completes, **Then** it still uses A's full rules and identifies A. The next calculation begun after activation fixes B; no result mixes weights, references or mappings from both versions.
3. **Given** B is active and inactive saved A has goal weight 2 while B has goal weight 4, both with reference 2, **When** the same one-goal history is evaluated explicitly with A and then through active B, **Then** the scores are respectively 1.000000 and 2.000000, each bound to the corresponding saved version. Explicit evaluation does not activate A.
4. **Given** a saved position-aware version with goal weight 2 in each of defender and forward and shared reference 2, **When** a week with 2 goals in each group is evaluated, **Then** the score is 4.000000; concentrating the same 4 goals in one role scores 2.000000. Persisting/selecting rules does not replace the human-approved separate caps and sum.
5. **Given** no active selection, **When** an active calculation is requested, **Then** it returns a distinct no-active-configuration outcome without a score. Explicit use of a valid saved version still works. Unknown explicit identity, unavailable formula and unavailable rule storage fail without selecting a substitute.
6. **Given** a saved version, **When** a managed request attempts to override its weights, references, requirements or mapping, **Then** it fails validation without a score. Subject, season and explicit UTC week remain calculation-specific; an unmapped selected historical position, unknown player, empty recorded week or unknown required metric preserves the existing distinct failure outcome. Failed calculations do not create versions or activation changes.

---

### User Story 4 - Recover Original Rules and Reproduce Earlier Scores (Priority: P1)

As a historical-calculation consumer, I need the saved version used by an earlier result recoverable independently of current settings, so I can reproduce its score from original facts and rules.

**Why this priority**: Historical reproducibility is a domain invariant, including after late facts or rule changes.

**Independent Test**: Retain a successful version-bound result, save and activate changed rules, accept a late performance, restart, then replay original membership using the original saved version.

**Acceptance Scenarios**:

1. **Given** an earlier one-goal balanced result of 1.000000 bound to A, **When** new B with weight 4 is saved and activated and another performance arrives inside the original week, **Then** replay with A and original retained membership reproduces 1.000000; fresh evaluation may differ and cannot rewrite the earlier result.
2. **Given** saved A, **When** any attempt modifies its formula, weights, references, mapping, requirements, identity or creation metadata, or deletes A even if inactive and never used, **Then** it is rejected and A remains identical. A legitimate edit saves a distinct new version and leaves A intact.
3. **Given** two versions differing only in one absent position group's weight or an unused valid mapping entry, **When** their rules are inspected, **Then** they are distinct immutable versions with their full settings retained. Equal current scores do not permit substituting one version for the other's evidence.
4. **Given** a retained result's version identity disagrees with its evidence's formula or effective configuration, references, requirements or mapping, **When** managed replay is attempted, **Then** it returns inconsistent-replay without a score; another valid configuration or the active version cannot repair the mismatch.
5. **Given** original rules/facts are unavailable, an original formula is unsupported, or retained facts, features or score have been altered, **When** managed replay runs, **Then** the inherited unavailable, unsupported or inconsistent outcome is distinguishable and no fallback score is returned.
6. **Given** identical complete rules supplied in different valid entry orders, **When** they are saved as separate versions and used over the same facts, **Then** scores and effective rule evidence agree canonically while permanent version identities remain distinct. A new save is a new version even when values match an existing version; listing and lookup have stable identity-based ordering when creation times tie.

### Edge Cases

- An initially empty installation has no active preset. No production weight, reference, mapping or initial strategy is chosen from test fixtures; only explicit complete rules can be saved and selected.
- Validation checks reusable rule structure without needing a player's current statistics. Mapping must be nonempty and use existing stable position identities with supported historical groups; duplicate/conflicting keys and unknown identities fail. Unused valid entries are allowed. Every selected historical position must be covered at calculation time, with no current-label fallback.
- All position-aware groups and their reference union are required even when only one group is populated. Unknown configured metrics, including zero weights, block applicable populated rows; absent groups stay absent, and removing an entry changes the saved rule set.
- Version identities cannot be reused, overwritten or inferred from a mutable label, a creation timestamp, the active pointer or the formula version. Equal values or equal scores do not collapse separate saves. No draft/edit/delete lifecycle is added.
- Selecting a version takes effect when its change is durably confirmed. It does not retroactively select rules for the football week's date, schedule a future switch, cancel in-flight work, recalculate scores or rewrite historical records. Explicit replay always resolves the retained identity.
- Saving or changing selection either completes entirely or leaves no partial version/change. Storage outages remain visible infrastructure failures; they are never empty lists, no active selection, insufficient football data or successful activation.
- A deployment lacking a previously supported formula can still inspect its saved rules, but activation or evaluation fails unsupported. Implementations must retain original supported formula semantics for normal replay; a current formula must never be relabeled as an older one.
- Rule-management reads and calculations need no provider access. Only version creation and selection changes write their own records; calculating/replaying scores changes no saved rules, active selection, quote, financial operation or football fact.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide trusted internal creation, listing, lookup and active selection of durable configuration versions for `balanced` formula `1` and `position_aware` formula `1`. Unknown formula identities/versions MUST fail unsupported without dynamically accepting arbitrary executable strategies. Public administration, new user roles and public permission changes are outside this task.
- **FR-002**: Each saved version MUST bind a permanent unique identity, strategy identity, formula version, complete exact weights, exact metric references, full historical-position mapping, formula-derived metric requirements and immutable creation time. Player, season, week and selected performances MUST remain calculation-specific rather than configuration-version fields. Version lookup/listing MUST expose complete rules and current selection; lists MUST order by ascending creation time, breaking ties by stable identity.
- **FR-003**: Creation MUST apply the approved formulas' validation: balanced has a nonempty supported metric-weight set and overall requirements only; position-aware has a nonempty supported metric-weight set for each of goalkeeper, defender, midfielder and forward and group requirements only. Supported metrics are goals, assists, shots on target, tackles, interceptions, saves, goals conceded, yellow cards and red cards. Zero-weight entries remain required; all-zero nonempty configurations are valid. No metric, weight, reference, sign or calibration default is injected.
- **FR-004**: References MUST exactly cover the derived required metric union with strictly positive finite exact values, shared across position groups. Mapping MUST be explicit, nonempty and unambiguous, using existing stable position identities and supported historical groups. Unknown identities, duplicates/conflicts, malformed rules, unsupported options, empty mandatory structures and invalid numeric values MUST fail ordinarily before any version is saved. No requirements supplied by a caller may disagree with formula-derived requirements.
- **FR-005**: Finite exact signed integer and decimal weights, including fractions, zero and large values, MUST retain their accepted exact values and evidence semantics on durable round-trip. Binary floating-point, booleans, text numeric coercion, nonfinite values and malformed numeric representations MUST be rejected. Storage MUST introduce no numeric ceiling, rounding or representation change that violates the inherited canonical evidence contract.
- **FR-006**: A successful save MUST create one complete immutable version; each new save receives a distinct identity even for equivalent values. No later operation may update or delete a version, including unused/inactive versions or creation metadata. Rule edits MUST create a new version; saving MUST NOT activate it. Partial saves and reused identities are prohibited.
- **FR-007**: There MUST be zero active versions before explicit first activation and exactly one market-wide active version afterward. A successful activation MUST immediately select an existing currently supported version, with no per-player, per-user, per-league, scheduled or date-based selection policy. Original rules MUST remain independently addressable after switching.
- **FR-008**: Activation MUST require the expected current configuration identity, including an explicit expectation of no selection for first activation. A stale expectation MUST yield conflict without changing selection. Concurrent different targets expecting the same current identity MUST allow at most one successful change. Selecting the already active identity with a matching expectation MUST be a successful no-op; it MUST NOT append another change. Stale expectations still fail.
- **FR-009**: Each actual successful selection change MUST atomically retain an append-only record of previous identity (or none), new identity, durable effective time and stable change order. Maintainers MUST be able to inspect this history in change order, including when confirmation times tie. Active selection and history MUST survive restart. Invalid/failed/no-op selection requests MUST add no successful change. Selection history MUST NOT edit version records or claim retroactive football-week applicability.
- **FR-010**: Every production market calculation MUST use managed selection of either the active version or an explicit saved identity, then fix that version once before selecting football facts. Its weights, references, mapping, requirements and formula MUST all come from that one version; caller overrides MUST fail validation. An active change during calculation MUST NOT affect its rules, and explicit selection MUST NOT change market activation. Existing pure formula helpers remain compatible building blocks and MUST NOT provide an unversioned production market path.
- **FR-011**: Every successful managed calculation MUST return its permanent configuration-version identity alongside formula identity/version and the existing complete score/reproduction evidence. The retained rules MUST match the referenced saved version. Formula version MUST NOT be overloaded with configuration identity. This binding MUST be available to downstream quote storage without a parallel strategy-specific reproduction format.
- **FR-012**: Managed evaluation MUST preserve approved weekly selection, accepted local facts, grouping, normalized rounded features, exact signed contributions and six-place nearest/ties-away final rounding. Balanced weights apply to overall totals; position-aware contributions sum across populated groups with separate caps and no group averaging or subtotal rounding. Score-to-price conversion and calibrated weights/references MUST NOT be invented.
- **FR-013**: No active selection MUST yield a distinct no-active-configuration failure for active evaluation. Explicit valid inactive versions MUST remain usable. Unknown saved identities, invalid requests, unsupported formula, no recorded performances, insufficient required data and unavailable storage MUST remain distinguishable without a score, substitution, partial result or implicit preset. Configuration validation MUST precede football empty-history outcomes.
- **FR-014**: Original rules MUST be recoverable from the retained permanent identity without consulting current activation. Managed replay MUST verify that identity's formula and full effective rules against retained reproduction evidence, then use the inherited authoritative original-fact replay. Changed active rules, late arrivals, mutable affiliations, absent-group changes and unused mapping changes MUST NOT substitute for the originals. Unavailable originals, unsupported formulas and inconsistent evidence MUST yield the corresponding explicit no-score outcomes.
- **FR-015**: Rule reads, managed evaluation and replay MUST work from local stored rules and accepted facts without provider access and MUST NOT mutate versions, selection/history, football facts, quotes or financial records. Version creation and activation MAY write only their own complete version or selection records. Infrastructure failures MUST remain visible rather than being translated into business success or football missing-data errors.
- **FR-016**: Automated behavioral tests MUST cover all acceptance scenarios and edge cases, including both formulas, validation before writes, exact numeric round-trips after restart, nonempty all-zero rules, mapping validation, no active default, immutable inactive/unused versions, switching/restoring/no-op selection, stale expectations and competing activation, in-flight version fixation, explicit inactive evaluation, mismatch rejection, canonical ordering and original replay after configuration changes/late arrivals. Tests MUST exercise durable persistence and deterministic local fixtures; zero provider access and no unrelated writes MUST be checked.
- **FR-017**: Scope MUST remain durable configuration versions, one active selection with its history, original-definition recovery and managed score/replay integration. Existing explicit pure scoring contracts and approved formula semantics MUST remain compatible. TASK-026 owns quote conversion, orchestration/jobs, durable calculation-descriptor retention, quote effective dates, quote-history integrity and follow-up evaluation; TASK-027 owns quote exposure and TASK-033 owns ranking. No new provider/ingestion behavior, cache, scheduler, trading, chart, conditional-order rule, public endpoint or administration screen is included.

### Key Entities

- **Formula Identity**: Stable strategy name and formula version identifying approved deterministic scoring semantics independently of mutable selection and saved configurations.
- **Immutable Configuration Version**: Permanent identity plus complete reusable weights, references, historical mapping, derived requirements, formula identity and creation time. Never edited or deleted; many versions may refer to one formula.
- **Active Market Selection**: The single saved version used by new active calculations, or no selection before first activation. Changing it affects future selection only.
- **Selection Change**: Append-only previous/new configuration identities, effective confirmation time and stable ordering; preserves switching/restoration history independently of version contents.
- **Version-bound Calculation Result**: Existing score/reproduction evidence accompanied by the exact saved configuration identity used. Original subject/season/week/facts remain in the common evidence, whose durable quote retention is owned by TASK-026.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Maintainers can save, inspect and explicitly select at least one complete configuration for each of the two approved strategies, retrieve every saved rule exactly after restart, and explain each result from its saved rules without an undocumented preset.
- **SC-002**: In 100% of the invalid save, mutation, deletion and activation acceptance cases, no partial version, altered version or erroneous selection/change is retained. All competing different-target activation cases allow at most one change from the same expected selection.
- **SC-003**: 100% of successful managed evaluations identify exactly one permanent configuration version whose full rules match their reproduction evidence. All controlled in-flight activation cases retain the version fixed at calculation start.
- **SC-004**: 100% of successful retained acceptance results reproduce their original scores after rule switching, restart and late facts using original available evidence. All specified unavailable, unsupported or mismatched replay cases fail explicitly with zero fallback scores.
- **SC-005**: The balanced 1.000000 versus 2.000000 configuration-change example and the approved position-aware 2.000000 concentrated versus 4.000000 split example remain exact through saved-version evaluation. At least 20 permutations of multi-metric rule and mapping entries yield identical effective rules, scores and canonical reproduction evidence, apart from separate configuration identities and creation metadata.
- **SC-006**: All rule-management reads and calculation acceptance cases complete with providers unavailable; calculations produce zero version/selection, football, quote or financial mutations. Successful saves and selection changes survive restart with a complete inspectable history.

## Assumptions

- TASK-023 and TASK-024 are completed dependencies. Their [balanced specification](../059-balanced-valuation-strategy/spec.md) and [position-aware specification](../060-position-aware-valuation/spec.md), including [TASK-024 Feedback 1](../../backlog/feedback/TASK-024.md), settle the formulas. The [common valuation contract](../058-valuation-contract-normalization/contracts/valuation-context.md) and [ADR-0020](../../docs/adr/0020-valuation-evidence-and-scorer-trust-boundary.md) govern authoritative facts, exact evidence and trusted strategy execution. This specification owns lifecycle and version-binding behavior only.
- Market-wide immediate active selection is the smallest interpretation of the existing single active-strategy requirement. This task does not introduce a user or league policy. Expected-current selection prevents silent lost changes; it introduces no new account privilege or public interaction.
- The existing account model provides no approved administrative role. Trusted internal maintainers remain the management actors, consistent with the strategy dependencies. Exposing management externally requires a separately specified permission decision rather than treating any authenticated trader as a maintainer.
- A complete reusable version includes references and historical mapping as well as weights, so recovering original effective rules does not depend on mutable external configuration. The explicit player, season, week and original membership remain request/evidence data. Unused valid mapping entries are retained and version-bound, as in the inherited evidence contract.
- No approved numerical calibration or starting selection has been provided. This task is ready to implement explicit version creation/selection without choosing one. A live market must receive intentional operator rules before active calculations; test fixtures cannot satisfy production calibration.
- Configuration identities establish original-rule lookup and comparison; they do not authenticate wholesale replacement of a retained result with another legitimate result. TASK-026 must durably bind and protect quote evidence and its version identity. This task does not claim quote-history delivery or complete CP2 delivery.
- No new latency, throughput, historical source coverage or price-accuracy guarantee is added. Acceptance measures exactness, durable recoverability, conflict safety and transparent outcomes.

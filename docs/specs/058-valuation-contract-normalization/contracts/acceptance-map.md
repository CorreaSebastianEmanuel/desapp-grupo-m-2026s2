# Executable acceptance ownership

Test files below are implementation deliverables under test/football_market/valuation/. Each row names required assertion content, not a claim of execution. verification.json provides argv/check coverage. Spec has FR/SC identifiers but no AC identifiers; story numbers are preserved here without inventing new canonical IDs.

| Spec scenarios | Assertion file(s) | Required oracle |
|---|---|---|
| US1.1 | week_test.exs, history_test.exs | before/open/inside/closing/after microseconds; exclusive end; equivalent offsets; subject/season isolation |
| US1.2 | normalization_test.exs, history_test.exs | counts 1+2/ref4 -> 0.750000; minutes 135 retained, changes have no feature contribution |
| US1.3 | normalization_test.exs | 0/4/9 over ref4 -> 0/1/1 fixed six-place |
| US1.4 | history_test.exs | transfer/history teams survive; another subject/season never contributes |
| US1.5 | canonical_test.exs, scope_test.exs | arbitrary input ordering identical; no provider access |
| US1.6 | week_test.exs, contract_test.exs | malformed/missing/equal/reversed/ambiguous/nonweekly bounds; invalid required reference -> ordinary no-score validation |
| US2.1 | missing_data_test.exs | all nine known zeros valid, even all-zero minutes |
| US2.2 | outcomes_test.exs | known empty, unknown subject, insufficient-data distinct; no absence claim |
| US2.3 | missing_data_test.exs | each nil required metric lists exact scope/performance; no partial success/exclusion |
| US2.4 | missing_data_test.exs | unrequired nil retained raw, required complete features succeed |
| US2.5 | missing_data_test.exs | zero-minute 2+1/ref4 -> 0.750000 regardless of second minutes |
| US2.6 | missing_data_test.exs | zero minutes do not excuse nil required values |
| US2.7 | outcomes_test.exs | match without subject performance creates no row/evidence or completeness claim |
| US3.1 | position_groups_test.exs | overall 3/ref4 -> .750000, defender 2 -> .500000, midfielder 1 -> .250000 |
| US3.2 | position_groups_test.exs | current position change does not reclassify |
| US3.3 | position_groups_test.exs | missing/duplicate-conflicting/unsupported mapping errors; explicit CB/fullback -> defender |
| US3.4 | position_groups_test.exs | absent goalkeeper has no scope; every row has exactly one supported group |
| US3.5 | position_groups_test.exs | zero-minute defender 2 and positive-minute midfielder 1 both contribute |
| US3.6 | position_groups_test.exs | group-specific saves/tackles completeness; adding overall saves identifies defender nil |
| US3.7 | position_groups_test.exs | defender rows/goalkeeper-only requirements -> no_applicable_required_scope |
| US4.1 | scoring_test.exs | .750000*2 + .500000*(-1) -> 1.000000 and complete descriptor |
| US4.2 | scoring_test.exs | .500000*(-2) -> -1.000000, features still nonnegative |
| US4.3 | replay_test.exs | late row excluded on replay; fresh selection changes membership/evidence |
| US4.4 | normalization_test.exs, scoring_test.exs | 1/6 -> .166667 then *3 -> .500001; 1/128 -> .007813 |
| US4.5 | normalization_test.exs, scoring_test.exs | positive and negative half-away ties, .4 non-tie, negative zero normalized |
| US4.6 | replay_test.exs | new version/ref/weight/mapping changes fresh descriptor; old replay unchanged or explicit unavailable rules |
| US4.7 | replay_test.exs | duplicate IDs/pairs, unavailable facts/rules, altered facts/groups/totals/features/score rejected |
| US4.8 | scoring_test.exs, outcomes_test.exs | unsupported version, expected scorer error, callback exception, invalid nonfinite/nondecimal result distinct; no fallback |

## Additional edge and critic obligations

- contract_test/week_test: empty requirements/metric sets, unsupported metrics/scopes, minutes requirement rejection, missing full config/IDs, numeric strings/float/boolean/nonfinite/malformed Decimal, equivalent offsets, >6 fractional precision, non-midnight/non-Monday/multiweek/year-crossing weeks. Validate config even with empty history.
- normalization_test: exact quotient/remainder oracle, repeating fractions, decimal references, very large accepted counts, ratios just below/at/above rounding half beyond ambient precision, saturation before rounding, no arbitrary ceiling or caller Decimal-context dependence.
- position_groups_test: all four groups, unused mappings, populated-unrequired group raw evidence, independently saturated group vs overall features; mixed present defender and absent goalkeeper requirements preserve defender feature without fabricated goalkeeper/zero.
- scoring_test: mismatched config-derived requirements rejected before callback; undeclared weighted metric rejected; explicit populated-only policy succeeds on mixed scopes while require-all returns ordinary missing contribution. Features-only callback sees no raw minutes/affiliation. Exact signed large-coefficient weighted sum under changed Decimal context.
- replay_test: coordinated raw-count/total/feature/score tampering, historical position/group and kickoff/week tampering against original rows; modified caller-held Prepared rejected by score; out-of-week/wrong-player/cross-season replay rows rejected; no fresh membership substitution.
- canonical_test: at least 20 distinct permutations of the same multi-row/mixed-role set, tied kickoffs and byte-ordered identities; nested config and requirement/mapping input permutations; descriptors/features/scores identical; deterministic complete missing-detail order.
- matrix_test: all five supported leagues, two seasons, four groups; all nine metrics known/unknown, zero/extra-time/very large counts, weekly boundaries, general/group-aware illustrative scoring and replay. Assert expected membership, totals/features and exact scores, not merely success tags. This matrix supplements named scenario assertions.
- scope_test: AST/runtime dependency boundaries and production inventory; no provider/time/randomness/current affiliation reads in scorers, no writes through context/reader/pure workers, no financial/quote schema or event publication. Snapshot persisted fixture facts before/after prepare/evaluate/replay; verify unchanged. Assert trusted illustrative modules return failures safely. Exercise unavailable provider fixture without calling it. Preserve legacy guard rejection of unrelated paths.

## Requirement/check trace

verification.json maps 16 FR and 5 SC IDs to focused checks. FR-015 also maps both complete profiles; SC-001 maps matrix/history/grouping, SC-002 missing-data, SC-003 canonical/replay, SC-004 exact decimal/scoring, SC-005 scorer/replay/outcome checks. Profiles protect existing CP2 unit/actual browser E2E and repository regressions; no separate historical CP1 coverage gate. No affected HTTP interface.

Implemented assertion additions: canonical_test exercises 24 mixed-role permutations and typed nested configuration; replay_test includes deleted struct fields and malformed nested decimals in addition to coordinated tampering; normalization_test includes exact cancellation beyond ambient precision. matrix_test executes all ten league/season combinations with exact 27.000000 grouped and 9.000000 overall illustrative scores, replay, every metric's unknown outcome and 61-digit accepted counts. scope_test evaluates exact active legacy allowances directly from their AST, so it also runs independently in the integration profile without loading unit-only test modules.

Feedback 2/3 (FR-013/FR-015): contract_test.exs durably asserts ordinary public failures for improper requirement/mapping lists, nested configuration and replay facts, including all four cases in the original diagnostic probe. replay_test.exs adds proper-list/malformed nested memberships, descriptor facts, caller-held Prepared facts/scopes and strategy evidence, plus unchanged successful replay. The feedback-regression check executes these tracked assertion files, without requiring /tmp inputs in a clean checkout.

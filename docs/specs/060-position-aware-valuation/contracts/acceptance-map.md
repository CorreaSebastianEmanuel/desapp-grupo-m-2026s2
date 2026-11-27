# Acceptance map — TASK-024

The spec has 13 FR identifiers, 5 SC identifiers and 30 numbered acceptance scenarios; no AC identifiers are declared. verification.json maps the canonical identifiers to the executable check IDs below. These mappings specify required assertions, not passing evidence. Every successful persisted fixture must exercise prepare → evaluate → authenticated score → replay with the explicit original definition, unless the row describes a deliberate alternative fresh calculation. Expected numbers are independently calculated, never obtained from production arithmetic.

## Scenario-to-test assertions

Test paths below are relative to test/football_market/valuation/position_aware/ and use the _test.exs suffix. One assertion row may require several fixture variants.

| Scenario | Test file / check ID | Required concrete assertions |
|---|---|---|
| US1.1 | formula / position-formula | Each group's feature .500000; scores .500000/1/1.5/2; other groups absent from measured scopes |
| US1.2 | formula / position-formula | Saves .750000 and conceded .500000 at 2/-1 yield 1.000000 |
| US1.3 | formula / position-formula | Center-back/fullback stable IDs both map to defender; tackles total 3/ref4/weight2 → 1.500000; current affiliation changes no score |
| US1.4 | formula / position-formula | Separate complete accepted histories with minutes 0/ordinary/extra-time yield identical features/score, not identical raw facts |
| US1.5 | formula / position-formula | All 36 group/metric pairs at count1/ref2/weight2 → 1.000000, without implicit signs |
| US2.1 | mixed / position-formula | Defender/forward features .500000 with weights 1/4 → 2.500000 |
| US2.2 | mixed / position-formula | Same four goals concentrated → 2.000000; split 2+2 → 4.000000; two independent caps |
| US2.3 | mixed / position-formula | Absent configured goalkeeper/midfielder don't alter score or create measured scopes; retain rules |
| US2.4 | mixed / position-formula | Historical remap produces fresh 2.000000 versus original 3.000000; original replay remains 3.000000; no current-role fallback |
| US2.5 | mixed / position-formula | Add known-zero midfielder row at weight9 (including zero minutes); score stays 2.500000 and evidence adds measured membership |
| US3.1 | outcomes / position-outcomes | Saves required only goalkeeper, tackles only defender; other nil metric remains raw and doesn't block; no overall requirements |
| US3.2 | outcomes / position-outcomes | Unknown configured value in any populated-group row → insufficient_data with ordered group/metric/performance and no score, also zero minute/weight |
| US3.3 | outcomes / position-outcomes | Zero-weight metric still requires reference/value; removing it removes only that group's requirement; absent-group references still required |
| US3.4 | outcomes / position-outcomes | All-zero weights and complete known-zero counts → 0.000000; valid empty → no_recorded_performances; unknown player → not_found |
| US3.5 | config + outcomes / position-config + position-outcomes | Missing/empty/extra/overall groups, unsupported metric/option, structs, lists/duplicates/improper tails and invalid numeric fields → ordinary validation; finite signed integer/fraction/zero valid |
| US3.6 | outcomes / position-outcomes | Any requirement mismatch; missing/extra/nonpositive/nonfinite reference; duplicate required metrics → validation, no defaults |
| US3.7 | outcomes / position-outcomes | Invalid config outranks empty history; malformed week and missing/duplicate/conflicting mapping → common validation |
| US4.1 | arithmetic / position-arithmetic | 1/6 rounds .166667 ×3 → .500001; 1/128 tie → .007813 |
| US4.2 | arithmetic / position-arithmetic | Within-group tiny products sum before rounding; signed .0000005 ties → ±.000001; -.0000004 → unsigned .000000 |
| US4.3 | arithmetic / position-arithmetic | Huge weights differing by one cancel → 1.000000 within and across groups; independent exponent/fraction residuals under varied Decimal contexts |
| US4.4 | replay / position-replay | Inspect complete common descriptor: original facts/grouping/full rules/references/week/features/identity/rounding/score, including absent-group rules |
| US4.5 | replay / position-replay | Fresh weight/ref/mapping changes or late accepted row produce new evidence; original replay stays 1.000000; changed supplied definition/rules cannot substitute, including absent group changes |
| US4.6 | replay / position-replay | Missing facts/rules, coordinated raw/derived tampering, wrong grouping/features/score, duplicates, unsupported ID/version return exact distinct errors; authenticated score rejects tampered Prepared before callback |
| US4.7 | replay + scope / position-replay + architecture | At least 20 multi-row/group/metric/map/mapping permutations → identical score and canonical evidence; disabled providers, zero writes/events; same original facts/definition |
| US4.8 | arithmetic / position-arithmetic | Two group .500000 features ×±.000001 sum → ±.000001, never ±.000002 |
| US4.9 | arithmetic / position-arithmetic | Cross-group signed residuals → ±.000001 at tie and exact cancellation → unsigned .000000 |
| US5.1 | selection / position-selection | Before/open/inside/close/after membership by stored kickoff [open,close); offsets equivalent; arrival/completion not selectors |
| US5.2 | selection / position-selection | Year-crossing week, exact player/season isolation; same-instant different match IDs both retained, no season-date heuristic |
| US5.3 | selection / position-selection | Missing/ambiguous/equal/reversed/non-Monday/non-midnight/multiweek bounds, player-season mismatch → validation; unknown player → not_found |
| US5.4 | selection / position-selection | Count0/2/huge integer at ref2/weight2 → features 0/1/1, scores 0/2/2; no ceiling or fabricated row |

## Edge and invariant obligations

- config_test.exs directly tests validate_config/requirements and engine definition binding for malformed shapes, Decimal missing/extra/invalid fields, booleans/text/floats, unsupported atom/string keys and duplicate pair collections. Assert validation, never strategy_failure/callback_exception for expected bad config. All list containers are rejected before conversion; common mapping/required lists check duplicates and tails.
- arithmetic_test.exs uses an independent integer-rational generator in test/support/position_aware_case.ex. Include fractional exponents, positive/negative mixed weights, very large cancellation within/across groups, six-place fixed output, tiny residuals and ambient precision changes. Keep generated vectors in memory/ignored tmp and persist deterministic case-count/checksum summaries. Generator must not call DecimalMath.normalize/weighted/round or scorer code to derive expected values.
- replay_test.exs tests authoritative original row verification through public score/replay, including raw fact plus derived evidence tampering together, original member absence, unsupported definitions and missing rules. Keep at least 20 deterministic permutations of identical facts and equivalent representations, not extra accepted performances that change membership. Changing valid minutes changes raw evidence but not score; changing current affiliation changes neither original facts nor score.
- scope_test.exs asserts the exact 13-path current allowance, unchanged legacy 058/059 allowances, unknown-feature/unplanned-file rejection and pure AST dependencies. Exercise successful and unsuccessful facade paths with providers disabled, actual SQL capture (reads observed, writes rejected), no PubSub/provider/follow-up calls and unchanged original rows. Isolate a deliberate DB ownership failure and assert it escapes as infrastructure failure, not a missing-data result. Production tests cover effects; the independent QA reviewer must challenge omissions rather than trusting AST checks alone.
- No token supply, financial/audit/history/quote mutation is authorized. No new schema, endpoint, preset, registry, current-role lookup, cache/job/provider behavior, permission or UI. Architecture + valuation-regression checks preserve the boundary and existing balanced strategy. Full unit/integration profiles remain separate; integration retains actual browser testing. This is CP2 strategy evidence, not completion of remaining CP2 tasks.

## Check ownership

Developer executes all fourteen manifest checks after final edits; no developer check is deferred. Only T028 Independent QA and T029 Final review have gate tags/task_stages entries. QA reruns independently; review uses fresh QA evidence and adds targeted checks for uncovered risks. No HTTP runtime check is applicable to this internal scorer; fresh PostgreSQL/Redis service assertions remain mandatory. No extra default CP1 coverage report or expanded historical evidence dataset is added.

## Implemented assertion names

The exact ExUnit names below reconcile every numbered scenario with its assertions. Paths and check IDs are in the scenario table above; arithmetic covers 78 independent vectors under three contexts and replay covers 24 permutations. The common `overall` scope retains row metadata but has no configured totals/features; only populated historical group features are scored.

| Scenario | File | Exact test name(s) |
|---|---|---|
| US1.1 | formula | `US1.1 all four historical groups have explicitly different goal weights` |
| US1.2 | formula | `US1.2 goalkeeper saves and explicit signed conceded weights` |
| US1.3 | formula | `US1.3 center-back and fullback historical IDs ignore current affiliation` |
| US1.4 | formula | `US1.4 minutes zero, normal and extra-time leave the formula identical` |
| US1.5 | formula | `US1.5 all 36 group metric pairs have no implied restriction or sign` |
| US2.1 | mixed | `US2.1 US2.3 US2.5 mixed weights retain absent rules and known-zero group never dilutes` |
| US2.2 | mixed | `US2.2 separate caps approve concentrated two versus split four` |
| US2.3 | mixed | `US2.1 US2.3 US2.5 mixed weights retain absent rules and known-zero group never dilutes` |
| US2.4 | mixed | `US2.4 explicit historical remap changes fresh score but original replay survives` |
| US2.5 | mixed | `US2.1 US2.3 US2.5 mixed weights retain absent rules and known-zero group never dilutes` |
| US3.1 | outcomes | `US3.1 role-specific nil metrics have no overall completeness requirement` |
| US3.2 | outcomes | `US3.2 ordered group metric row details and no partial score including zero weights`; `omitted unknown metrics succeed, zero weights still require every selected row` |
| US3.3 | outcomes | `US3.3 removing zero-weight entry affects only its group; absent references remain required` |
| US3.4 | outcomes | `US3.4 known zero and nonempty all-zero rules differ from empty history`; `empty, unknown, malformed week and unmapped historical role remain distinct` |
| US3.5 | config + outcomes | `malformed shapes and numbers are ordinary failures before traversal`; `every malformed Decimal field, container and nested tail fails without callbacks throwing`; `invalid config fails through evaluate and authenticated score even in an empty week` |
| US3.6 | outcomes | `US3.6 every group requirement set and shared reference union must exactly match`; `requirements and references must exactly match the explicit definition` |
| US3.7 | outcomes | `invalid config fails through evaluate and authenticated score even in an empty week`; `empty, unknown, malformed week and unmapped historical role remain distinct` |
| US4.1 | arithmetic | `US4.1 US4.2 US4.3 US4.8 US4.9 independent rational vectors under three Decimal contexts` |
| US4.2 | arithmetic | `US4.1 US4.2 US4.3 US4.8 US4.9 independent rational vectors under three Decimal contexts` |
| US4.3 | arithmetic | `US4.1 US4.2 US4.3 US4.8 US4.9 independent rational vectors under three Decimal contexts` |
| US4.4 | replay | `US4.4 US4.5 descriptor binds full original rules and survives fresh changes and late arrivals` |
| US4.5 | replay | `US4.4 US4.5 descriptor binds full original rules and survives fresh changes and late arrivals` |
| US4.6 | replay | `US4.6 unsupported and unavailable originals are distinguishable from inconsistent evidence`; `US4.6 coordinated raw and derived tampering fails before the score callback` |
| US4.7 | replay | `US4.7 24 multi-group multi-metric fact rule and mapping permutations are canonical` |
| US4.8 | arithmetic | `US4.1 US4.2 US4.3 US4.8 US4.9 independent rational vectors under three Decimal contexts` |
| US4.9 | arithmetic | `US4.1 US4.2 US4.3 US4.8 US4.9 independent rational vectors under three Decimal contexts` |
| US5.1 | selection | `US5.1 stored kickoff selects half-open UTC week despite late arrival` |
| US5.2 | selection | `US5.2 year crossing isolates exact player and season while retaining same-instant matches` |
| US5.3 | selection | `US5.3 every invalid week class fails without a current week default` |
| US5.4 | selection | `US5.4 zero boundary and arbitrary-size accepted counts saturate without ceilings` |

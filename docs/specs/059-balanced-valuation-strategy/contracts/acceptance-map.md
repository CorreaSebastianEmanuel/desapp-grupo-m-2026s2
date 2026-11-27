# Assertion design and acceptance trace

Public-workflow assertions use production Balanced, deterministic accepted local facts and explicit rules. Files are planned under test/football_market/valuation/balanced/ and must precede corresponding behavior changes. Manifest checks execute exact files. Spec has numbered scenarios rather than AC identifiers; all are covered below.

| Scenarios / outcomes | Check | Required assertions |
|---|---|---|
| US1.1 | balanced-formula | Features .750000/.500000/.500000, score 1.500000; independently explain from retained totals/references/weights |
| US1.2 | balanced-formula | Mixed defender/forward goals total 4, overall cap 1, score 2; no group-cap addition |
| US1.3 | balanced-formula | Equal totals with varied valid historical mapping/minutes/current affiliation yield equal scores, including zero minutes; evidence may differ |
| US1.4 | balanced-formula | Complete known zeros → positive 0.000000; explicit red-card penalty → -1.000000, no floor |
| US1.5 | balanced-formula | All nine metrics individually, total 1/reference 2/weight 2 → 1.000000, no implicit sign/role |
| US2.1–3 | balanced-outcomes | Missing omitted saves succeeds; configured saves missing (including zero weight/zero minutes) fails with scope/metric/performance and no score; complete all-zero succeeds |
| US2.4 | balanced-config, balanced-outcomes | Missing/empty/malformed weights, unsupported keys/options/role config, invalid numeric types/fields fail ordinarily in callback validation and public evaluate/authenticated score |
| US2.5 | balanced-outcomes | Missing/extra/duplicate/group requirements or reference mismatch/nonpositive/nonfinite reference fail before score; no defaults |
| US2.6 | balanced-outcomes | Distinct empty-week/unknown-player/invalid-week/mapping outcomes; invalid config is not hidden by empty history |
| US3.1 | balanced-arithmetic | Rounded 1/6 feature .166667 times 3 → .500001, not .500000 |
| US3.2 | balanced-arithmetic | Two exact .0000005 products sum before rounding → .000001; negative mirror -.000001, not twice-rounded |
| US3.3 | balanced-arithmetic | Signed .0000005 ties round away; -.0000004 → positive 0.000000 |
| US3.4 | balanced-arithmetic | 10^30+1 and -10^30 weights on saturated features cancel → 1.000000 independent of context/order |
| US4.1 | balanced-replay | Descriptor binds balanced/1/full effective weights/request/facts/features/rounding/score; score(prepare(...)) equals evaluate |
| US4.2 | balanced-replay | Late accepted row changes fresh selection; replay reproduces original membership/score for every successful acceptance fixture |
| US4.3 | balanced-replay | Weight 2→4 yields old/new scores 1/2; original rules replay old; changed definition/references/mapping cannot substitute |
| US4.4 | balanced-replay | Unsupported identity/version; unavailable original definition/facts; altered counts/minutes/kickoff/position/features/score/config, duplicate facts/membership fail distinctly without score |
| US4.5 / SC-003 | balanced-replay | At least 20 deterministic multi-row/multi-metric fact/config insertion-order permutations yield identical scores/canonical evidence; external providers unavailable and no writes |

## Critic arithmetic probes

In arithmetic_test.exs, saturated features carry weights `%Decimal{sign: 1, coef: 1, exp: 1000}` and `%Decimal{sign: -1, coef: 10, exp: 999}`, which cancel. A third saturated metric carries residual .000000499999, .000000500000 or .000000500001: expected outputs 0.000000, 0.000001, 0.000001. Negative mirrors give 0.000000, -0.000001, -0.000001. Repeat with equivalent noncanonical Decimal representations, term permutations and low/high Decimal contexts with different rounding modes; restore context afterward. Expected values must not be calculated with the production helper or context-limited Decimal arithmetic.

Include tiny disparate negative exponents, signed cancellation, large accepted counts with unsaturated/saturated references, multiple saturated features yielding score above one, and zero contributions with finite weights at exponents ±10000. These exercise representation/zero handling without a new SLO or input ceiling. Direct helper assertions complement public evaluate/score checks and inherited normalization/scoring regressions.

## Critic malformed-shape probes

config_test.exs/outcomes_test.exs include weights `[{:goals, 1} | :invalid_tail]`, improper metric-value lists, extra nested option `[1 | :invalid_tail]`, unknown string keys, structs as containers, and Decimal with invalid sign/coef/exp, extra or missing fields. Assert ordinary no-score validation errors, not callback_exception. Include requirements `[:goals | :invalid_tail]`, mapping `[{position_uuid, :defender} | :invalid_tail]`, adjacent nested tails and deleted struct fields. replay_test.exs includes malformed supplied config, original facts `[valid_fact | :invalid_tail]`, malformed memberships and altered retained config. Assert common safe no-score taxonomy. feedback-regression reruns existing tracked TASK-022 contract/replay tests, never /tmp inputs.

## Isolation and side effects

outcomes_test.exs checks opening-inclusive/closing-exclusive kickoffs, equivalent offsets, player/season isolation, mandatory historical mapping and zero minutes. scope_test.exs checks exact inventories, scorer purity (including local send/spawn), no provider/web/job/cache/financial dependency, no SQL mutations/follow-up events and unchanged facts around successful/failed evaluate/score/replay. Trace only the calling process after fixture writes and detach handlers. A separate DataCase async:true module in the same file supplies an unshared owner for the read-failure probe: call public evaluate in a monitored raw process without SQL Sandbox ownership/caller propagation and assert visible ownership/read failure rather than empty/insufficient history. The default application pool auto-checks out unowned processes, so this probe selects a private unnamed manual Sandbox pool via process-local dynamic Repo. Do not alter global sandbox mode or disable shared services; clean up the private pool. No broad rescue may be added. Historical TASK-022 allowance assertions stay tied to the original inventory, while active TASK-023 assertions check its exact eleven edit paths.

verification.json maps all FR-001–012 / SC-001–005; no AC identifiers appear in spec. Existing application-owned PostgreSQL/Redis verification fails closed on missing services. No HTTP endpoint is affected.

## Feedback 3: Reproducible independent evidence

independent-oracle supplements FR-001/002/006/007/009/010/011 and SC-001/004/005 with all 511 nonempty metric subsets under varied Decimal contexts: exact Fraction expectations, original checksum, features, evaluate, authenticated score and original replay after late arrival. A missing-generator assertion proves failure before scoring. oracle-format validates the evidence probe. oracle-integrity supplements FR-011/012: regenerated cases equal the approved baseline, seed/count/checksum agree, no expanded dataset or evidence writes occur, and every production/application-test source hash and inventory matches b14ad23cab3b13ef0a8446afac79f3382b592c59. All three checks disable receipt reuse because evidence files are outside the common source fingerprint. This is evidence cleanup only; existing scenario checks and fresh QA/review gates remain required.

# Deterministic acceptance matrix

Implementation artifacts: `test/fixtures/providers/{cases,source_a,source_b,expected}.exs`; reusable assertions in `test/support/provider_contract_case.ex`, reference oracle in `test/support/providers/fact_oracle.ex`. The executable inventory contains 217 stable cases in `cases.exs`, with independent expected values in `expected.exs` and one source example per case in each source file. The matrix checks both sources twice (868 outcomes), all 17 scenario links and the absence of orphan/duplicate IDs. Direct process probes in `deadline_test.exs` supplement F-D05 source outcomes; persisted state is exercised only by `catalog_isolation_test.exs`.

Each stable case entry has `id`, operation, request, internal vocabulary, source example keys for A/B, explicit normalized expected facts/error, per-kind source-independent entity correspondence, controlled wall/elapsed events, numbered scenarios, and FR/SC identifiers. Expected outcomes must be hand-declared rather than computed through production validators. Parameter variants get stable suffixes. The manifest stores every generated ID, so runs can assert completeness and duplicates instead of silently skipping empty loops.

The source fixture collection itself is entirely pure. F-I01 reuses each error source example/expected error and declares an additional unchanged-state/read oracle plus the `catalog-isolation` check link. Offline repetition exercises those source outcomes and asserts the oracle/check metadata is present; actual persisted-state and production Catalog-read assertions run separately against local PostgreSQL. Offline conformance alone is not evidence for SC-006.

Source A uses nested named maps/string IDs and ordered pages. Source B uses packet/tuple/list fields with uppercase column names, distinct source IDs/result refs and reversed entity/page order. Its adapter restores logical portion order while aggregating the complete result. Both raw shapes include conflicting synthetic ratings, team totals and attempted-tackle extras that their adapters ignore. Both include ignorable synthetic source extras. Fixed retrieval time is `2026-10-06T12:00:00.000000Z`. No real athlete contact data, subscription, secret or external host is used; sentinel secrets are explicitly fake adversarial tokens.

## Catalog and requests

| Stable ID / variants | Expected oracle | Numbered scenarios / requirements |
| --- | --- | --- |
| F-C01-{league}-{season}-{source} (PL/BL1/PD/SA/FL1 × 2024-2025/2025-2026 × A/B) | Equivalent full facts under bijection, distinct safe provenance; trimmed labels, canonical configured positions; two same-name players remain distinct with different team refs | US1.1, US4.2; FR-001/004/005/012/013; SC-001/005 |
| F-C02-empty | Success with requested league/season/bindings, no invented entries | US1.2; FR-003; SC-002 |
| F-C03-{unknown-season,unsupported} | not-found vs unsupported-capability, never empty success | US1.2; FR-003/009 |
| F-R01-{case,whitespace,string-keys} | Canonical supported code; equivalent normalized request; no atom creation | US1.1; FR-002 |
| F-R02-{missing,unknown-field,mixed-keys,non-map,league,year-type,year-bool,year-gap,catalog-bound,timeout-type,timeout-zero,timeout-negative,timeout-bool} | invalid-request, safe field, zero adapter calls; invalid timeout preserves the valid normalized league-season | US1.3; FR-002/009/010; SC-002 |
| F-R03-{same-year,lower-only,upper-only,unbounded,offset-equal} | Valid same-year scope; independently optional inclusive bounds | US2.1; FR-002 |
| F-R04-{naive,bad-instant,overprecision,reversed} | invalid-request before work, no invented instant | US1.3, US2.1; FR-002 |
| F-C04-{missing-fact,blank-label,duplicate-ref,duplicate-source,duplicate-name,duplicate-code,duplicate-position-name,duplicate-position-code,cross-season,dangling,unmapped-position,extra-normalized-field} | Whole invalid-response for each retained catalog defect, including case/whitespace variants and identical/conflicting duplicates | US1.4; FR-004/005/008; SC-002 |
| F-C05-{same-id-other-kind,same-id-other-scope,same-id-other-provider} | Safe qualified IDs do not imply entity equality; no persistent catalog identity added | US1.1, US4.2; FR-005 |

## Performance and eligibility

| Stable ID / variants | Expected oracle | Numbered scenarios / requirements |
| --- | --- | --- |
| F-P01-{league}-{season}-{source} (same 20 combinations as F-C01) | Completed in-range matches, exact edges and nine distinguishable count values (protecting field transpositions); source examples include conflicting attempted-tackle/team-total/rating extras that cannot replace player counts; distinct kickoff/retrieval fields; directory closure only | US2.1, US4.2; FR-001/005/006/007/013; SC-001/005 |
| F-P02-{before,lower,equal-offset,upper,after} | Bounds inclusive; one-microsecond outside excluded; equivalent instants compare equally | US2.1; FR-002/006 |
| F-P03-{zero,nil,omitted,zero-minutes-positive-count,minutes-over-120,match-no-performance,empty} | Zero distinct from nil; all omitted optional keys become nil; no manufactured rows; valid minutes 0/121+ | US2.2; FR-003/007; SC-002/005 |
| F-P04-filter-mixed | In-range valid completed match retained; out-of-range completed match with bad unused metrics excluded; scheduled/live/postponed/abandoned matches excluded | US2.1; FR-006/008 |
| F-P05-{bad-scope,bad-status,bad-kickoff} | Undecidable eligibility fails whole request, even beside valid matches; non-completed known status can be excluded without kickoff | US2.1/5; FR-006/008 |
| F-P06-{eligible-bad-metric,eligible-duplicate,cross-season-edge,dangling-performance-match,duplicate-eligible-ref-with-scheduled-copy} | Entire invalid-response; no selective repair, overwrite or dedup | US2.5; FR-007/008 |
| F-P07-{excluded-only-directory,retained-player-current-team} | Unused directory facts omitted; retained closure includes team B/current position plus historical team A/event position | US2.1/3; FR-004/006/008 |
| F-P08-transfer | Player currently B, historical A participates in match, valid historical position differs; all edges resolved without persistence | US2.3; FR-006; SC-005 |
| F-P09-no-capability | unsupported-capability; no team totals/ratings/fabricated empty replacement | US2.4; FR-006/009 |
| F-P10-{negative,fraction,boolean,text,unsupported-count,missing-minutes,missing-kickoff,missing-position,unknown-league,missing-participant,same-home-away,nonparticipating-team,repeat-player-match,duplicate-identical,duplicate-conflicting,rating-substitute,team-total-substitute} | Whole invalid-response; run invalid count variants for all nine metrics plus minutes | US2.5; FR-006/007/008; SC-002 |

## Errors, budgets and isolation

| Stable ID / variants | Expected oracle | Numbered scenarios / requirements |
| --- | --- | --- |
| F-E01-{all-eight-categories} | Exact category/retryability, operation/valid scope/template; no records. Invalid-request occurs before work; others through supported fixture failure paths | US3.1; FR-009/011; SC-002 |
| F-E02-{known-delay,unknown-delay,bad-delay} | Positive integer rate-limit delay retained; nil unknown; invalid values become invalid-response | US3.1; FR-009 |
| F-E03-{exception,url,userinfo,token-query,header,unknown-key,source-ref,source-id,provider-label,fixture-id} | No fake secret/raw diagnostics anywhere in inspected complete outcome; recognized unsafe provenance/candidate input rejected, unknown key not reflected, unexpected exception unavailable | US3.1; FR-009/012; SC-002 |
| F-D01-default-{before,at,after,never} | Full readiness at 4,999,999 μs succeeds; 5,000,000/later/blocked time out; verify default timeout actually used | US3.2/3; FR-010; SC-003 |
| F-D02-custom-{before,at,after,validation-delay,error-at-boundary} | Direct production-runtime probes cover both operations with immediate success/error at 4,294,968,000 ms and 10,000,000,000,000 ms and caller-exit cancellation with the latter budget. With timeout 7 ms, readiness 6,999 μs succeeds, 7,000/7,001 fails; raw completion before bound but late validation times out; ready typed errors retain category only before deadline | US3.3; FR-009/010; SC-003 |
| F-D03-pages-complete | All required portions finish/validate within one original budget; one complete result | US3.4; FR-003/010 |
| F-D04-{later-page-error,later-page-timeout,cumulative-page-delay} | No earlier records exposed; later typed failure retained before deadline, otherwise timeout; no fresh page budget | US3.4; FR-003/009/010; SC-003 |
| F-D05-{late-result,next-call,caller-exit,crash} | Cancel/disconnect; no second outcome, late mailbox leakage or changed state; following request independent; early crash unavailable; bounded real worker cleanup | US3.2/3/4; FR-010/011 |
| F-I01-{every-failure-category} | Reuse F-E01 source outcomes with declared state oracle; separate integration check snapshots all local catalog tables/reads before/after, asserts unchanged rows/reads, zero provider work during reads and no retries/fallback | US3.5; FR-011/013; SC-002/006 |

## Repetition and oracle integrity

| Stable ID | Expected oracle | Numbered scenarios / requirements |
| --- | --- | --- |
| F-O01-repeat | Run every listed source variant twice with identical clock/fixture state; normalized outcomes identical; nonempty inventory links every numbered scenario and five leagues/two seasons; F-I01 persisted-state assertions are explicitly linked to catalog-isolation, not claimed by the pure run | US4.1/3; FR-013; SC-004 |
| F-O02-bijection-negative | Valid reordered/ref-renamed equivalent facts pass; missing/merged same-name player, swapped team and swapped performance edge fail the oracle | US4.2; FR-005/013; SC-001 |
| F-O03-traceability | Every ID resolves source examples, independent expected result/error and scenario references; no orphan examples/expectations, no duplicate IDs | US4.3; FR-013; SC-004/005 |

Required acceptance coverage totals: US1.1–4 (4), US2.1–5 (5), US3.1–5 (5), US4.1–3 (3) = 17. These are scenario labels, not added AC identifiers. `verification.json` maps the 20 actual FR/SC identifiers; each executable suite asserts its rows, and fixture-matrix checks assert no uncovered scenario. Scope tests additionally enforce FR-014 and library independence; catalog isolation is the only feature suite requiring persistence.

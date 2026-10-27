# Independent QA — TASK-033

2026-10-26. Reviewed active feature binding, full spec/plan/tasks, architecture/develop handoffs, human feedback 1–3, manifest, and implementation/inventory/contract diffs. No implementation edits, Agentflow invocation, receipt reuse, or delegation.

**Outcome:** required commands pass on the final stable-input attempt, and observed HTTP behavior passes. Acceptance remains incomplete because required regression and runtime assertion coverage is missing.

Evidence commands:

- **R:** `python3 scripts/agentflow_stage_checks.py --stage qa` (ordered runner, no reuse).
- **S:** `python3 scripts/agentflow_stage_checks.py --stage qa --summary` (bounded command evidence).
- **H:** `MIX_ENV=test mix run tmp/task033-qa-20261026/http_probe.exs` (exit 0; actual Bandit listener and TCP requests, additional QA assertions).

Local evidence: `tmp/task033-qa-20261026/{attempt1-summary.json,attempt2-summary.json,http_probe.exs,http-probe.log}`. These are ignored attempt artifacts; reports retain the bounded findings.

| Manifest check | Final R outcome | Seconds |
|---|---|---:|
| ci_parity | PASS; wrapper contract, no native profile run | 1.259 |
| preflight | PASS; required PostgreSQL/Redis readiness | 1.530 |
| format | PASS | 0.970 |
| compile | PASS; warnings-as-errors | 0.833 |
| credo | PASS; strict wrapper | 6.933 |
| openapi | PASS | 0.453 |
| runtime | PASS; actual HTTP outcomes | 7.209 |
| ci_profiles | PASS; single complete unit/integration wrapper and receipt validation | 927.021 |
| diff | PASS | 0.344 |

Final runner: nine passed, zero failed/blocked/unexecuted. Preserve the first attempt: seven passed, ci_profiles failed after 659.416 seconds, diff dependency-blocked. QA mistakenly prepared an unignored evidence script inside the feature during that attempt, changing its source fingerprint. The safe diagnostic exposed no registered failing case. QA moved its preparation outside bound sources and reran R with stable inputs; no third attempt or implementation repair occurred.

| Acceptance mapping | Independent evidence and result |
|---|---|
| US1.1/5/6; FR-001/003/006; SC-001 | R executes selection/controller cases: exact active UUID, same-formula inactive version excluded, initial/no_quote/no-history omitted, one selected quote per eligible player. PASS for these fixtures; failure-only coverage absent (B1). |
| US1.2/3; FR-005; SC-002/003 | R order tests plus H: prices `20.00,4.00,1.25,1.25`, positions `[1,2,3,4]`, ascending canonical UUID ties, identical repeated bodies. PASS. |
| US1.4; FR-004 | R equal-time sequence/pending-delivery case passes; selected price/time/quote retained. Cross-season selection and time-versus-sequence priority remain unproven by delivered regressions (B1). |
| US1.7/8; FR-007; SC-005 | R and H distinguish active-empty 200, no-active 409, storage-fault 503. PASS. |
| US1.9; FR-002 | R executes both committed-connection snapshot schedules with explicit barriers and enclosing-transaction refusal. H checks complete configuration identity. PASS. |
| FR-008/009; SC-004 | R verifies READ ONLY, protected snapshots and supply 100. H checks unchanged protected stores and zero provider calls around every HTTP request. Authentication/decimal/error contracts pass. |
| FR-010 | FAIL: required delivered regression coverage incomplete (B1). |
| FR-011 | Source/diff inspection confirms web/domain/persistence separation and bounded ranking-only application changes; no new migration, worker, provider, cache or permission tier. PASS. |

H recorded eleven responses. All are JSON. Market 200/409/503 responses carry `cache-control: no-store`; 401 retains `WWW-Authenticate: Bearer realm="api"`. Populated response configuration was `c71a29f4-dffd-48b9-b40d-8d885d88a0da`, strategy `balanced`, formula `1`; exact quote UUIDs and UTC microseconds are in H. Empty response has `data: []`; errors are exactly `no_active_configuration`, `storage_unavailable`, or `unauthenticated`. Valid API key succeeds; revoked key, expired/missing/invalid bearer credentials return 401. Incidental query parameters leave the complete ranking unchanged.

Blockers:

- **B1 — Required regression matrix incomplete.** `selection_test.exs:51` delegates to `RankingCase.add_performance_quote/2`, which fixes `season_id` to the original season (`test/support/ranking_case.ex:36`). No delivered ranking test selects history across seasons, opposes effective-time order to sequence order, or supplies a failure-only calculation/player. FR-010 and T003/T016 cannot be accepted from the checked boxes or green wrapper.
- **B2 — Runtime obligation overstated.** `scripts/verify_ranking_runtime.exs:199–229` asserts one entry and only the configuration UUID. It cannot prove multi-player numeric/UUID ordering and does not assert strategy/formula identity, despite T008 and the manifest expectation. H independently passes these behaviors; it does not repair the delivered mandatory runtime check.

Verdict: FAIL

## Independent direct-completion QA — 2026-10-27

Fresh acceptance against the existing specification and the user-authorized direct-completion plan, with origin/main through `62175ea` integrated. No Agentflow orchestration, extra feedback cycle, implementation edits or duplicate full-profile run. Earlier findings and failures above remain historical.

QA executed the twelve prerequisite/quality/runtime checks. A child approval/exec-handle interruption prevented reliable control of the following full-run command, so the parent executed the single CI wrapper, receipt verifier, E2E and whitespace check; QA independently inspected their actual evidence and validated every receipt against the current inventory. Evidence: `tmp/task033-finalqa-20261027/{cheap-results.json,full-results.json,independent-qa-audit.json}` and adjacent bounded logs/receipts.

| Checks | Fresh result |
| --- | --- |
| Exact toolchain, PostgreSQL/Redis, test preparation | PASS |
| Formatting, warnings-as-errors compilation, strict Credo | PASS |
| OpenAPI validation, test inventory, application source inventory | PASS; 1216 assigned cases, 553 source entries |
| Asset build and workspace JavaScript coverage | PASS; JavaScript 100% |
| Four-player real TCP ranking assertions | PASS |
| Single complete unit/integration CI wrapper | PASS; 961.190 seconds |
| Independent native-receipt validation | PASS; unit 618/618, integration 595/595 |
| End-to-end profile | PASS; 3/3, 51.680 seconds |
| Whitespace check and source stability | PASS; all 678 bound execution-input files unchanged |

Acceptance: all 27 ranking cases are assigned to and passed in integration. Selection tests now prove retained cross-season history, effective-time precedence over sequence and TASK-027's current-quote lookup, and a real failed calculation without an eligible quote, resolving **B1**. The actual TCP probe asserts the complete active configuration and four-player body, numeric price order, canonical UUID ties, consecutive positions and identical repeated reads, resolving **B2**.

Both committed snapshot schedules and enclosing-transaction refusal pass. Active-empty 200, absent-configuration 409, sanitized storage/configuration-integrity 503 and existing credential-refusal 401 contracts remain distinct. Exact decimal/timestamp serialization, no-store/JSON headers, read-only SQL, unchanged quote/selection/financial/audit/job snapshots and zero provider calls pass. Seven-operation OpenAPI/browser guards preserve the merged quote, freshness and purchase contracts. Source inspection confirms no ranking-owned migration, cache, worker, strategy formula, provider or trading behavior was added.

No local acceptance blocker remains. Hosted GitHub CI and SonarCloud were not executed because pushing/opening a PR was not authorized; their existing required gates remain in place. The feature is ready for human PR preparation and remains subject to those hosted checks and human merge authority.

Verdict: PASS

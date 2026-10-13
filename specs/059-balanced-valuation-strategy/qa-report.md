# Independent QA — TASK-023

Reviewed the active binding, complete specification/plan/tasks, architecture/development handoffs, current TASK-023 feedback, manifest, both production changes, all six new tests and every tracked diff. No implementation edits, Agentflow invocation, delegation, developer receipt reuse or historical report/log reads.

Evidence directory: `qa-evidence/independent-20261013/` (E below). `E/results.json` records exact executed argv, environment, exit status and elapsed time. All 13 manifest checks were executed directly; every final result is exit 0. Manifest executions totaled 122.286 seconds including the initial sandbox failure. Targeted tests total 45 passing tests; profile counts below are discovered files, not test counts.

| Required check | Independent evidence / result |
|---|---|
| toolchain, format, compile | Manifest commands `sh scripts/check_toolchain.sh`, `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`; corresponding E logs, exit 0. Compilation initially failed acquiring Mix's TCP lock (`:eperm`, 0.638s); second execution with local socket access passed (0.680s). No source change or warning suppression. |
| services | `MIX_ENV=test sh -c 'mix test.prepare && mix infrastructure.verify'`; E/services.log: migrations current; PostgreSQL and Redis OK. |
| balanced-config, balanced-formula, balanced-outcomes | Manifest `mix test --warnings-as-errors` invocations; corresponding E logs: 4, 3, 5 passed. |
| balanced-arithmetic, balanced-replay | Manifest invocations including inherited normalization/scoring tests; E logs: 9, 5 passed. |
| architecture, feedback-regression | Manifest invocations; E logs: 12, 7 passed. Real isolated ownership error remains visible; malformed-list regressions pass. |
| unit-profile, integration-profile | `MIX_ENV=test sh scripts/test_profile.sh unit` / `integration`; E logs: `audit_count=44` / `61`, `status=complete`. Inspected wrapper: requires sentinel completion, nonzero tests, zero skips, Chromium launch preflight and actual integration/browser tests. |

| Acceptance criteria | Verified evidence and relevant assertions |
|---|---|
| US1.1; FR-001/002/006; SC-001/005 | Formula test retains totals 3/1/2, features .750000/.500000/.500000 and score 1.500000; prepare+authenticated score+evaluate+replay agree. |
| US1.2–3; FR-005/007; SC-003 | Mixed defender/forward total is capped once: 2.000000. Zero-minute and different-minute/role histories yield equal scores; current affiliation change leaves original result identical. |
| US1.4–5; SC-001/002 | Known zero yields positive 0.000000; explicit red-card weight yields -1.000000. Each of nine metrics individually yields 1.000000; multiple saturated features yield 4.000000. |
| US2.1–3; FR-004/008; SC-002 | Omitted unknown saves succeeds; configured saves, including zero weight on zero-minute row, returns insufficient_data with overall/saves/performance ID and no score. Complete nonempty zero-weight configuration succeeds. |
| US2.4–5; FR-003/004/011 | Config/outcome tests reject unsupported options/roles/metrics, floats/booleans/nonfinite/corrupted Decimals, improper/nested tails and missing fields with ordinary validation. Requirements/reference mismatches, nonpositive references and group scopes fail without defaults. |
| US2.6; FR-005/008 | Distinct empty-history, not-found and malformed-week/mapping errors; invalid config precedes empty-history result. Opening/closing boundaries, equivalent offsets and player/season isolation verified. |
| US3.1–4; FR-006/007; SC-001 | Arithmetic tests: 1/6 feature produces .500001; contributions sum before rounding; signed ties produce ±.000001; negative zero eliminated; huge cancellation yields 1.000000. Residuals around both signed ties, ±10000 zero factors, 10^40 counts, contexts and permutations pass. |
| US4.1–3; FR-009/010; SC-004 | Descriptor assertions bind original rules/facts/features/identity/version/rounding/score. Late arrivals change fresh membership while retained examples replay exactly. Weight 2→4 changes fresh score 1→2; substituted weights/references/mapping fail replay. |
| US4.4–5; FR-009/010; SC-003/004/005 | Unsupported/unavailable/inconsistent outcomes reject altered facts/config/features/score and malformed/duplicate membership. All 24 permutations preserve canonical evidence. Provider-disabled workflows, SQL telemetry, call tracing and immutable snapshots verify no writes/provider access/events. |
| FR-011/012; independent coverage challenge | Exact eleven implementation paths respected; shared engine/replay unchanged. `python3 E/generate_oracle.py` uses Python Fraction to generate all 511 nonempty metric subsets. `MIX_ENV=test mix test --warnings-as-errors E/oracle_probe_test.exs` passed: 511 expected feature/score comparisons, 511 authenticated scores and 511 original replays after late arrival under varying low Decimal precision. |

The additional oracle initially completed all assertions but exited 1 for its QA filename not matching Mix's test filter (9.216s). Renaming only that QA artifact to `*_test.exs` removed the warning; fresh exit 0 in 8.059s (`E/oracle-probe-corrected.log`). No unchanged failing check ran more than twice. All 16 captured canonical/source hashes remain unchanged; `git diff --check` passed.

HTTP acceptance is inapplicable: inspected changes add only an internal scorer/helper and tests, with no routes/controllers/transport changes; manifest `runtime_required=false` agrees. No blocker or failed acceptance criterion remains.

Verdict: PASS

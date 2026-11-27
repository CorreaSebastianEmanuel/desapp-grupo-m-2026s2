# Independent QA — TASK-024

2026-10-13; active binding: `.specify/feature.json`. Read canonical project rules, constitution, spec, plan, tasks, architecture/develop handoffs, Feedback 1, manifest and all thirteen implementation paths/diffs. No implementation edits, delegated agents, Agentflow invocation, developer receipt reuse or historical workflow-log inspection.

Commands ran directly with the exact `verification.json` argv/env. Evidence directory **E** = `qa-evidence/independent-qa/`. [checks.json](qa-evidence/independent-qa/checks.json) records commands, exits, duration and output hashes; `E/<check-id>.log` contains fresh output. Toolchain and format were executed separately before the logged sequence. Every manifest check exited 0; twelve logged checks took 134.877 seconds.

| Check | Independent evidence | Requirements verified |
|---|---|---|
| toolchain | `sh scripts/check_toolchain.sh`: Elixir 1.20.3, OTP 29.0.6 | Pinned prerequisites |
| format | `mix format --check-formatted`: exit 0 | Formatting |
| compile | `MIX_ENV=test mix compile --warnings-as-errors`: exit 0 | Compilation |
| services | Migrated PostgreSQL marker SELECT; PostgreSQL/Redis `OK` | Actual service availability |
| position-config | 5 passed | FR-001–004; SC-002 |
| position-formula | 9 passed | FR-001–002,005–007,009; SC-001,003,005 |
| position-outcomes | 9 passed | FR-002–004,007,011; SC-002 |
| position-arithmetic | 2 passed; 78 vectors × 3 contexts | FR-005–006,008; SC-001 |
| position-replay | 4 passed; `POSITION_PERMUTATIONS count=24` | FR-001,009–011; SC-003–005 |
| position-selection | 4 passed | FR-005,008; explicit weekly selection |
| architecture | 12 passed; SQL reads/no writes, provider/event traces, ownership exception | FR-011,013; SC-005 |
| valuation-regression | 37 passed; common engine and Balanced | FR-010,013 |
| unit-profile | Audited 45 modules, `status=complete` | FR-012 |
| integration-profile | Audited 69 modules, `status=complete`; Chromium launch/browser tests | FR-012 |

Targeted checks total 82 overlapping test executions. Both complete profiles enforce no skips. Their fresh audit JSON and logs are in E. Manifest coverage mappings plus the following inspected assertions verify all thirty scenarios, rather than relying on developer receipts or test names alone.

| Acceptance criterion | Observed assertions | Check |
|---|---|---|
| US1.1 | Four role scores .5/1/1.5/2; feature .500000 | formula |
| US1.2 | Saves .75, conceded .5; score 1 | formula |
| US1.3 | CB/FB totals 3; score 1.5 survives affiliation changes | formula |
| US1.4 | Minutes 0/90/123 preserve features/score | formula |
| US1.5 | All 36 metric/group pairs score 1 | formula |
| US2.1 | Mixed .5 features produce 2.5 | formula |
| US2.2 | Concentrated 2 versus independently capped split 4 | formula |
| US2.3 | Absent groups introduce no measured scope | formula |
| US2.4 | Historical remap: fresh 2; original replay 3 | formula |
| US2.5 | Zero-minute, zero-count midfielder changes evidence, preserves 2.5 | formula |
| US3.1 | Role-specific nil metrics succeed; no overall requirement | outcomes |
| US3.2 | Ordered group/metric/row errors, including zero weights/minutes | outcomes |
| US3.3 | Removed zero-weight entry affects only its group | outcomes |
| US3.4 | Valid zero, empty history and unknown player remain distinct | outcomes |
| US3.5 | Malformed structures/numbers fail ordinarily; signed/fractional weights valid | config/outcomes |
| US3.6 | Exact reference union and all four requirement sets; duplicates rejected | outcomes |
| US3.7 | Invalid config precedes empty outcome; invalid weeks/mappings fail | outcomes |
| US4.1 | Rounded 1/6 ×3 = .500001; 1/128 = .007813 | arithmetic |
| US4.2 | Product sums, signed ties and unsigned zero | arithmetic |
| US4.3 | Huge within/across-role cancellation = 1; precision independence | arithmetic |
| US4.4 | Complete original facts/rules/week/features/rounding descriptor | replay |
| US4.5 | Original 1 survives changed rules/late arrival; substitutions rejected | replay |
| US4.6 | Missing/altered/duplicate evidence fails; forged facts rejected before callback | replay |
| US4.7 | 24 identical canonical results; providers disabled/no writes/events | replay/architecture |
| US4.8 | Cross-role tiny contributions round once to ±.000001 | arithmetic |
| US4.9 | Signed residual ties ±.000001; exact cancellation zero | arithmetic |
| US5.1 | Kickoff half-open boundaries, late arrival, equivalent offsets | selection |
| US5.2 | Year crossing; subject/season isolation; distinct simultaneous matches | selection |
| US5.3 | Every invalid week class fails without defaults | selection |
| US5.4 | Counts 0/2/10^40 yield scores 0/2/2 | selection |

Additionally, [fraction_probe.py](qa-evidence/independent-qa/fraction_probe.py) independently derives expectations with Python Fraction. Its temporary generated ExUnit probe verified 32 cases, four populated groups, 256 facts, signed weights, fractional references, all nine metrics, low Decimal precision, zero/extra-time minutes and large counts through prepare/evaluate/authenticated score/replay. `E/fraction-probe.json` records exit 0; checksum `970eb94bbbb2ead40187dd395e5baadb6dca56ed89103d1c65a44e93d3c9e4fc`. Initial probe exit 1 resulted solely from its filename violating Mix's test pattern despite passing assertions; corrected filename passed unchanged assertions with warnings-as-errors. Both attempts retained; no retry-limit bypass.

HTTP runtime: inapplicable; inspected diff changes no endpoints. All thirteen implementation hashes remained unchanged during the extra probe. Blockers: none. Durable configuration/evidence and price conversion remain downstream scope.

Verdict: PASS

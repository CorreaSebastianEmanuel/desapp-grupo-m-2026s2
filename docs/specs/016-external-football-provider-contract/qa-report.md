# Independent QA — TASK-016

2026-10-06; active feature resolved through `.specify/feature.json`, baseline `7a0e115`. Reviewed current spec, plan, tasks, architecture/develop handoffs, all human feedback, manifest and relevant file diffs. No implementation edits, agents, Agentflow invocation or historical QA/review evidence.

Evidence directory **E**: `/tmp/qa-task016-fresh-20261006`. `final-results.json` records exact manifest argv/environment, exit codes and log paths. Commands ran directly through `python3 E/run_checks.py`; `E/rerun_checks.py` reran only failed sandbox checks with local-socket access. All final exits are zero; initial sandbox failures remain recorded.

| Independent command/check | Fresh evidence |
| --- | --- |
| `sh scripts/check_toolchain.sh`; `mix format --check-formatted`; `MIX_ENV=test mix compile --warnings-as-errors` | Pinned toolchain; formatted; warning-free compilation. |
| `MIX_ENV=test sh -c 'mix test.prepare && mix infrastructure.verify'` | `service-preflight.rerun.log`: migrations current, `PostgreSQL: OK`, `Redis: OK`. |
| `elixir test/provider_contract_offline.exs SELECTOR` | request 6, catalog 5, performances 2, deadline 7, safety 4, fixtures 4, all 28 passed; corresponding `SELECTOR.log`. |
| Manifest fixture-preservation argv, including failing Git shim | `fixture-preservation.log`: 1 passed; fixed literal hashes, 217 entries/file. |
| Manifest catalog-isolation and scope Mix commands | Corresponding rerun logs: 1 and 5 passed. |
| `MIX_ENV=test mix test --include performance --warnings-as-errors` | `regression.rerun.log`: `Result: 248 passed`. |
| `MIX_ENV=test sh scripts/test_profile.sh unit/integration` | Profile logs: complete, audited module counts 30/38; scripts enforce nonempty execution and no skips. |
| `MIX_ENV=test sh scripts/coverage_report.sh` | `coverage.rerun.log`: complete. Fresh artifact `cover/cp1/7a0e1153ebd3c6db6598dd2ac979379705319f08-20261006T155046Z-20864/`: 90.3%, unchanged CP1 inventory, complete profile receipts. |

All matrix rows passed. Fixture families executed against both independent sources with explicit outcomes and bijective relationship assertions; metadata alone was not accepted.

| Acceptance criterion | Evidence and challenged behavior |
| --- | --- |
| US1.1 | catalog F-C01/F-C05: five leagues/two seasons, unordered facts, qualified provenance, same-name players distinct. |
| US1.2 | F-C02/F-C03: empty success retains context; missing and unsupported scopes have distinct errors. |
| US1.3 | request F-R01–04: malformed scope/keys/bounds/timeouts rejected before work; safe fields, no arbitrary atoms. |
| US1.4 | F-C04: missing/contradictory/duplicate facts and unresolved relationships fail wholly. |
| US2.1 | performances F-P01/02/04/05/07: inclusive microsecond bounds, offset equality, completed-only filtering, invalid discriminators rejected. |
| US2.2 | F-P03: zero versus unknown/omitted counts; zero/over-120 minutes; no manufactured appearances. |
| US2.3 | F-P08: historical team/position independent of current affiliation; closure and separate kickoff/retrieval times. |
| US2.4 | F-P09: unsupported-capability, no fabricated substitute. |
| US2.5 | F-P06/F-P10 and independent count mutations: invalid metrics/references/participation/duplicates/missing facts fail wholly. |
| US3.1 | safety F-E01–03: every category/retry rule, optional delays, hostile provenance/diagnostics and complete-outcome sentinel checks. |
| US3.2 | deadline F-D01/F-D05: default 5000 ms, late reply disconnection, real cancellation. |
| US3.3 | F-D02: strict before/equal/after readiness, validation/error precedence; production runtime and caller-exit regressions. |
| US3.4 | F-D03/F-D04: complete portions, later errors, cumulative delays; one shared budget, no partial success. |
| US3.5 | catalog-isolation and independent DB probe: both operations, eight errors, five-table/read equality, zero provider calls during reads. |
| US4.1 | fixtures: 217 cases × two sources × two runs = 868 identical deterministic outcomes; bootstrap verifies no application/service startup. |
| US4.2 | Negative equivalence tests detect merges, missing players, swapped teams/performance edges; valid reordered sources pass. |
| US4.3 | Matrix: exact inventories, independent expectations/bindings, all 17 scenario links; no orphan IDs. |

`elixir E/adversarial.exs`: 4 passed, including both operations with immediate success/errors at VM-boundary, huge and 2^80 budgets; invalid timeout scope/bounds preservation; cancellation/correlation; all nine metric mutations. `MIX_ENV=test mix run E/isolation.exs`: 1 passed with real timeout workers. `elixir E/oracle_challenge.exs`: same-size semantic mutations detected in every fixture file.

`elixir E/parity.exs` independently evaluates original Git terms and proves exact equality: cases 11,682→2,932; expected 3,549→575; A 15,685→2,101; B 20,604→2,568. Total 51,520→8,176 (84.1% reduction). Feedback fingerprints match recomputed baseline hashes; backup intact. Readable independent bases/overrides contain no encoded data or production-derived expectations; existing assertions and production/CI code unchanged.

FR-001–014 and SC-001–006 are covered by these rows and scope checks. FR-014 excludes HTTP endpoints; changed-path inspection confirms none affected, so HTTP runtime acceptance is inapplicable. Artifact completeness probe and both diff whitespace checks pass. Receipt-readiness was not rerun because it reads prohibited workflow logs; fresh direct checks provide acceptance evidence. No blockers; live-provider feasibility remains outside this feature.

Verdict: PASS

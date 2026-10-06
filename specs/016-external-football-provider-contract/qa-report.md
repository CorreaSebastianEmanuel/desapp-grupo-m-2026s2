# Independent QA — TASK-016

Fresh QA on 2026-10-06 against working-tree changes over `ec04b232c47285cf2fbe3ece5bfe6790abdcd471`. Read active spec/plan/tasks, architecture/develop handoffs, verification manifest and current B1/B2 human feedback; inspected production/test diffs and fixture data/oracles. No implementation edits or Agentflow invocation.

Command evidence is retained in `/tmp/qa-task016-fresh/`: `final-results.json` (17 exit-zero checks, commands/output hashes), initial/retry results and individual logs. Initial sandbox TCP restrictions blocked Mix/browser checks; exact commands were rerun with local access. No service/check was skipped.

| Check commands (direct execution) | Fresh result |
| --- | --- |
| `sh scripts/check_toolchain.sh`; `mix format --check-formatted`; `MIX_ENV=test mix compile --warnings-as-errors` | All exit 0; warning-free compile |
| `MIX_ENV=test sh -c 'mix test.prepare && mix infrastructure.verify'` | Exit 0; `PostgreSQL: OK`, `Redis: OK`, migrations current |
| `elixir test/provider_contract_offline.exs SELECTOR` | request 6, catalog 5, performances 2, deadline 7, safety 4, fixtures 3, all 27 passed; zero failures |
| `MIX_ENV=test mix test test/football_market/providers/catalog_isolation_test.exs --warnings-as-errors` | `Result: 1 passed` |
| `MIX_ENV=test mix test test/football_market/providers/scope_test.exs test/football_market/statistics/scope_test.exs --warnings-as-errors` | `Result: 5 passed` |
| `MIX_ENV=test mix test --include performance --warnings-as-errors` | `Result: 247 passed` |
| `MIX_ENV=test sh scripts/test_profile.sh unit` / `integration` | Both exit 0: `status=complete`, unit audit_count=29, integration audit_count=38 |
| `MIX_ENV=test sh scripts/coverage_report.sh` | Exit 0; `CP1_COVERAGE_REPORT status=complete`, working-tree snapshot |

All 17 manifest commands executed independently. Below, suite names denote the selector command above; fixture IDs identify inspected explicit expectations. Every row passed.

| Acceptance criterion | Evidence and challenged behavior |
| --- | --- |
| US1.1 | catalog/fixtures F-C01/F-C05: five leagues, two seasons, two source shapes; unordered facts/edges match, same-name players stay distinct; provenance separate |
| US1.2 | catalog F-C02/F-C03: scoped empty success, not-found and unsupported-capability distinct |
| US1.3 | request F-R02/F-R04: invalid league/year/keys/bounds/timeout rejected before callbacks, known safe fields, no atom creation |
| US1.4 | catalog F-C04: incomplete/contradictory/duplicate records and bindings reject whole response; adversarial duplicate source/ref/business keys also rejected |
| US2.1 | performances F-P01/P02/P04/P05/P07; additional.exs: exact inclusive microseconds/offset equivalence, four excluded statuses, retained closure and malformed discriminator failures |
| US2.2 | performances F-P03; adversarial/additional: zero distinct from nil/omission, minutes 121 allowed, no invented rows/counts |
| US2.3 | performances F-P08; additional: current C/GK versus historical A/FW retained independently; current team included in directory |
| US2.4 | performances F-P09: unsupported-capability, no total/rating/empty substitute |
| US2.5 | performances F-P06/P10; adversarial: all nine metrics reject negative/fraction/boolean/text/noncount values; dangling edges/duplicates/missing facts fail completely |
| US3.1 | safety F-E01/E02/E03: eight categories/retry rules, optional positive delay; hostile labels/IDs/diagnostics/exceptions never reflected |
| US3.2 | deadline F-D01/D05; additional: default readiness 4,999,999 succeeds, 5,000,000/later times out; blocked workers terminate, no late replies |
| US3.3 | deadline F-D02; additional: 6,999/7,000/7,001 µs, validation/error precedence; both real operations accept VM-limit-adjacent and huge budgets |
| US3.4 | deadline F-D03/D04: complete portions only, later failure preserved before deadline, cumulative delays share budget, no partial success |
| US3.5 | catalog-isolation F-I01: eight failures preserve exact five-table snapshots and catalog reads, zero calls during reads, no retries |
| US4.1 | fixtures: 217 IDs × two sources × two repetitions = 868 identical expected outcomes; offline bootstrap verifies no application/service startup |
| US4.2 | equivalence/fixtures: reference bijections reject merged/missing same-name entities and swapped affiliation/performance edges |
| US4.3 | fixture inventory: all 217 source/expected IDs linked; all 17 scenarios present; independent AST audit confirms four files are literal data |

FR-001–008 trace to US1/US2; FR-009–012 to request/safety/deadline/isolation; FR-013 to fixture matrix/isolation. FR-014 passed scope/AST and changed-path checks: no persistence/transport/web coupling or endpoint changes. HTTP exercise is inapplicable to this internal boundary. SC-001–006 are evidenced respectively by equivalence, invalidity/isolation, deadlines, repetition, complete result/error oracles, and exact catalog state/read equality.

Independent scripts `/tmp/qa-task016-20261006/adversarial.exs` and `repro.exs`, plus `/tmp/qa-task016-fresh/additional.exs` and `inventory.exs`, each ran separately with `elixir SCRIPT` and exited 0: 6 + 4 adversarial tests passed. B1/B2 resolved: huge immediate success/error and cancellation/correlation hold; invalid timeout retains normalized scope, malformed scope stays unreflected.

Blockers: none. Synthetic compatibility does not establish live-provider capabilities or complete CP2 readiness.

Verdict: PASS

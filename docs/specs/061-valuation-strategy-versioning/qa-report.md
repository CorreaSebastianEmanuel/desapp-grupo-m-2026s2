# Independent QA — TASK-025

Feature resolved from `.specify/feature.json`: `061-valuation-strategy-versioning`; branch `025-valuation-strategy-configuration-and-versioning`. Read specification, plan, tasks, architecture/development handoffs, current TASK-025 feedback, constitution/context policy and relevant implementation/test diff. No implementation or application tests modified; no developer receipts reused.

Evidence directory **E**: [fresh-feedback-20261013b](qa-evidence/fresh-feedback-20261013b/). Commands:

- `python3 E/run_manifest.py`: executes every current `verification.json` argv/environment directly, serially. [results.json](qa-evidence/fresh-feedback-20261013b/results.json) records commands, exit codes, durations and log hashes. **14/14 PASS**, successful executions **260.863 seconds**.
- `python3 E/run_oracle.py`: executes `MIX_ENV=test mix test --warnings-as-errors E/oracle_test.exs` with temporary generated vectors. [oracle-result.json](qa-evidence/fresh-feedback-20261013b/oracle-result.json): **PASS**, **5.190 seconds**. Python `Fraction` independently implements capped feature rounding, exact signed summation and final six-place ties-away rounding; no production arithmetic generates expectations.

Toolchain, formatting, warning-free compilation and PostgreSQL/Redis readiness passed. Targeted totals: rules-codec 5, versions 5, selection 5, managed 4, replay 5, durability 3, architecture 11, legacy-metadata 18 passed. Full audited profiles passed: **47 unit modules**, **79 integration modules**. Reviewed profile audit/no-skip safeguards and browser test: integration includes actual Chromium launch and interactive HTTP/browser assertions.

All matrix rows are **PASS**, established by fresh named-check execution and inspection of concrete assertions. Check IDs identify `E/<id>.log` and exact manifest commands.

| Scenario | Requirements/outcomes | Evidence and relevant assertion |
|---|---|---|
| US1.1 | FR-001/002/006, SC-001 | versions: UUID, formula, exact complete rules/time; save leaves selection empty. |
| US1.2 | FR-002/003/004 | versions, rules-codec: four groups/reference union retained, no overall requirement. |
| US1.3 | FR-001/004/013, SC-002 | rules-codec, versions: malformed/unsupported/duplicate inputs rejected; zero partial rows. |
| US1.4 | FR-003 | rules-codec: zero/all-zero valid, omission changes requirements, empty sets invalid. |
| US1.5 | FR-005, SC-001 | rules-codec, durability: fractions, huge integers/exponents, numeric tags and fresh-runtime exactness; invalid references rejected. |
| US1.6 | FR-002/013 | versions, durability: complete lookup/list, UUID tie order, empty/unknown/outage distinguished. |
| US2.1 | FR-007/009 | selection: explicit nil expectation, single selection and durable change. |
| US2.2 | FR-007/010 | selection, managed: cross-formula switch records predecessor; inactive A usable. |
| US2.3 | FR-006/007/009 | selection: restore existing A, append change without creating/editing version. |
| US2.4 | FR-008/013, SC-002 | selection: unknown/malformed/unsupported/stale requests leave state unchanged. |
| US2.5 | FR-008/009, SC-002 | selection: distinct committed backends, one winner/conflict; old/new reader visibility; stale-before-no-op. |
| US2.6 | FR-009/015, SC-006 | durability, architecture: fresh BEAM recovers ordered history; provider unavailable; save does not activate. |
| US3.1 | FR-010/011/012, SC-003 | managed: fixed A yields `1.000000`, UUID/formula/full evidence agree. |
| US3.2 | FR-010, SC-003 | managed: football-read lock plus return trace; activation during calculation preserves A; next uses B. |
| US3.3 | FR-010/013, SC-005 | managed: inactive A `1.000000`, active B `2.000000`, selection unchanged by explicit use. |
| US3.4 | FR-012, SC-005 | managed: split `4.000000`, concentrated `2.000000`; supplemental oracle verifies all four populated roles. |
| US3.5 | FR-013 | managed, architecture: no-active/not-found/unsupported/storage failure, no fallback. |
| US3.6 | FR-004/010/013/015, SC-006 | managed, architecture: overrides rejected before facts; unmapped/player/empty/unknown-zero-metric outcomes; zero mutations. |
| US4.1 | FR-014, SC-004 | replay, durability: original A/membership survives switching, late facts, affiliations and fresh applications. |
| US4.2 | FR-006/016, SC-002 | versions: direct SQL/Repo identity/rules/time/update/delete/truncate guards protect unused versions/history/anchor. |
| US4.3 | FR-002/011/014, SC-003 | replay: absent-group and unused-mapping changes remain distinct; equal-score substitution rejected. |
| US4.4 | FR-011/014, SC-004 | replay: UUID/formula/config/reference/requirements/mapping mismatch yields inconsistent-replay. |
| US4.5 | FR-013/014, SC-004 | replay: unavailable/unsupported originals, altered facts/features/score and malformed evidence fail without score. |
| US4.6 | FR-002/005/016, SC-005 | replay, versions: 24 permutations per formula, canonical agreement/distinct UUIDs, stable creation-time ties. |

FR-015/016/017 additionally pass architecture and both complete profiles: local reads, SQL/effect traces, exact 33-path scope and inherited formula compatibility. Direct insertion races/isolation guards and the documented A→B→A identity limitation are exercised by selection/versions.

Current feedback: `oracle.log` records `QA_SETUP_PASS fixtures=1 seasons=1 positions=4 facts=4`, `QA_ORACLE_PASS vectors=90 ... active_and_explicit=180 original_replays=180`, and `QA_FOUR_ROLE_PASS split=10.000000 concentrated=4.000000 late_fact_replay=10.000000 writes=0`. All nine metrics, negative/zero/large weights and rounding ties covered; bulk vectors generated only in temporary storage. Row snapshots verify replay leaves versions/history/facts unchanged.

Preserved diagnostics: first compile failed on sandbox TCP lock (`:eperm`, 0.806s); authorized local-socket retry passed. Supplemental attempt 1 failed solely in QA's Decimal text parser before application calls (2.100s); explicit unbounded parsing of trusted generated inputs fixed the harness. Same vector hash passed; no unchanged third attempt or weakened assertion. Implementation/application-test hashes remain unchanged.

No HTTP endpoint changed: runtime HTTP gate inapplicable, consistent with spec/plan/manifest and diff. Services were actually verified. No blockers. Final review remains a separate gate.

Verdict: PASS

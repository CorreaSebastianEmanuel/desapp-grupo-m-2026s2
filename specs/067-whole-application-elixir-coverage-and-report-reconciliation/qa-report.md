# Independent QA — TASK-067

Active feature resolved through `.specify/feature.json`. Reviewed the required context, complete spec/plan/tasks, architecture/development handoffs, feedback 1–11 and scoped implementation diffs. No implementation edits, delegation, Agentflow invocation or developer-receipt reuse.

Evidence: `cover/application/qa-evidence/qa-bc1a3752-8609-485f-87af-c3f6439c2839/` (E below). Commands ran directly from repository root. BEAM/service commands used `MIX_OS_CONCURRENCY_LOCK=0 MIX_ENV=test ERL_FLAGS='+S 4:4' POSTGRES_PORT=15432`, with authorized per-command service access. `E/manifest-results.json` records exact manifest argv and logs.

| Manifest check | Independently executed command | Result / evidence |
| --- | --- | --- |
| preflight | `python3 scripts/application_coverage.py preflight` | Exit 0; `preflight.log`: `status=ready`; configured services, toolchains, Chromium, assets, preparation and inventory checked. |
| format | `mix format --check-formatted` | Exit 0; `format.log`. |
| compile | `mix compile --warnings-as-errors` | Exit 0; `compile.log`. |
| credo | `bash scripts/credo_ci.sh` | Exit 0; `credo.log`: maintained/effective 419, excluded 25. |
| openapi | `node tools/openapi/validate.mjs priv/static/openapi.json` | Exit 0; `openapi.log`. |
| application-report | `python3 scripts/application_coverage.py run` | Exit 0; `application-report.log`: unit 489/489, integration 449/449, complete publication. Exactly one audited pair. |
| e2e | `sh -c 'mix test.prepare && mix test.e2e'` | Exit 0; `e2e.log`: 2/2 real browser/HTTP/worker journeys. |

Fresh complete run: `bc1a3752-8609-485f-87af-c3f6439c2839`; snapshot `03516ee4f50092e82dd33ffcd6b0517043c795e8854ca7f7543ab92c178b49a7`. Its immutable `cover/application/runs/RUN_ID/` contains report JSON, HTML, measurements, receipts, sidecars and native evidence. Current status binds report SHA-256 `81fbdc8723f37c16863e23af7dfc842bce64189d7a7e4af9e56c0ba2f2d41a47`.

| Acceptance obligations | Independent evidence and outcome |
| --- | --- |
| US1.1–3; FR-001–004; SC-001,005 | Independent Python assertions compared Git's tracked Elixir paths, both inventories, every report inclusion/exclusion and all per-file line sets. 444 unique files: 151 maintained application files included, 293 excluded with reasons; tests/support contribute no lines. `E/independent-accounting.json`. Inventory/role/duplicate and snapshot-mutation regressions passed within unit. |
| US2.1; FR-005,006; SC-002 | Recomputed executable and covered sets directly from native-normalized partition records, without the aggregation helper. Unique union: 4356 executable, 3860 covered, 496 uncovered, **88.61%**. All per-file counts agree. Twelve partitions: unit main (65 files), integration regular (104), ten committed single-file invocations. Real owner-audit scheduling was reconstructed by validation controls; schedule/ownership mutations were rejected. |
| US2.2–3; FR-007,009; SC-003 | `python3 /tmp/task067-qa-current/adversarial.py`: 23 isolated invalid cases rejected; genuine full native controls passed before/after (163.985s/164.023s). Covers coherent count/schema, receipt audit/component, selection, partition, export/run, UUID/date/directory, duplicate JSON, normalized calls, render and symlink faults. `E/adversarial-results.json`; 498.295s total. Registered numeric/structural regression matrix also passed. |
| Native completeness, B1–B4 | `python3 /tmp/task067-qa-current/native_probe.py`: real nonempty native fixture accepted before/after; lost executed counter, truncated export and duplicate export rejected without normalized output. Removed `pick/1` clause-1 counter had two calls; another counter retained line 4. `E/native-input.json`, `native-results.json`, control logs. Initial fixture setup/selection mistakes were corrected only in QA probes; implementation remained untouched. |
| US3.3; FR-008; SC-004 | `python3 /tmp/task067-qa-current/failure_probe.py`: separately injected actual child exit 7 for unit and integration. Both collector attempts failed, current validation rejected them, historical bytes remained unchanged; no historical fallback. `E/failure-results.json`. These are controlled fault injections, distinct from the successful real profile pair. |
| US3.1–2; FR-010; SC-006 | Documented procedure produced this fresh report; generated measurements/HTML passed reread validation. Deliberately altered HTML rejected. Contributor docs explain scope/exclusions, reproduction, limitations and no minimum threshold. |
| FR-011,012; SC-007,008 | Diff inspection found no production/endpoint or hosted-CI changes. Independent comparison preserved all 909 prior test assignments; 31 additions. Default/opt-in/conflict, CP1, JS and profile compatibility regressions passed in audited profiles; E2E passed. No affected HTTP endpoint requires an additional runtime endpoint matrix. |

Blockers: none. Coverage remains informational and excludes nested BEAM, E2E and JavaScript execution; their separate safeguards remain available. Official/historical evidence was preserved. All acceptance obligations above passed independently; final review remains a separate gate.

Verdict: PASS

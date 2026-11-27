# Local command and CI evidence contract

All commands run at repository root, MIX_ENV=test; no app startup is required for static analysis.

| Interface | Result |
|---|---|
| `mix credo --format flycheck` | Existing standard default-priority CLI, unchanged rules and scope; nonzero fails. |
| `mix run --no-start scripts/credo_inventory.exs --write-inventory` | Explicitly regenerate maintained tracked membership, retaining reviewed exact exclusions; unknown outside paths fail. |
| `mix run --no-start scripts/credo_inventory.exs` | Run Credo's actual pipeline, reconcile inventory/Git/valid effective sources, emit oracle evidence; nonzero on every mismatch, incomplete analysis or finding. |
| `sh scripts/credo_ci.sh` | Clear old evidence, run standard CLI and observation pass, bind same snapshots, retain both statuses/full lists; nonzero if either fails or snapshots change. |

No arbitrary analyzer arguments, rule overrides, strict mode or finding suppression. Failure diagnostics distinguish CLI failure, inventory mismatch, unclassified exclusion, incomplete oracle, source mutation and output failure. No shell success masks. JSON shapes: ../data-model.md.

CI adds a nonoptional step inside existing required Quality baseline job; no Sonar dependency. Always upload tmp/credo-ci/ with missing-files error, 14-day retention and revision/run-attempt-specific artifact identity. A reviewer downloads it from the Actions run's Artifacts section and compares trigger_revision with that run's triggering SHA; revision may be the PR synthetic merge HEAD and must remain separately reported. Completeness requires all list entries, not a count or truncated summary. No hosted settings are changed.

## Executable test matrix

`test/ci/credo_inventory_test.exs` (:unit) uses isolated Git fixtures: every maintained root plus root dotfiles; automatic discovery of added file; rename/delete and stale inventory; missing inventory row; effective omission/extra; exact justified archived exclusion; unknown path/category/empty reason; maintained-root exclusion rejection; duplicate/unsafe paths; invalid syntax/incomplete execution; CLI/API finding and success parity. This covers US1 scenarios 1–3 and inventory edge cases.

`test/ci/credo_ci_contract_test.exs` (:unit) exercises wrapper subprocesses with deterministic executables and real oracle fixtures: success; CLI nonzero; inventory nonzero; both fail; incomplete output; stale output cleared; changed snapshot; full-list JSON round-trip and limitations/revision. Parse workflow YAML with the existing Ruby helper and assert mandatory step order, unchanged jobs/triggers/Sonar separation, always-upload retention/missing-file policy, no bypass. Verify fixture artifacts can be decoded/read in full. This covers US2 scenarios 1–3, Sonar pass/fail/unavailable independence and US3 interpretation.

Extend existing quality/remediation/profile contracts without weakening their assertions. README contract checks runnable command strings, staged-source refresh, artifact retrieval, scope/reasons/default-priority and both disclaimers (US3 scenarios 1–2). Existing profile unit execution owns all new tests. QA additionally inspects retained Actions evidence when a later authorized CI run exists; hosted publication is outside this architecture stage.

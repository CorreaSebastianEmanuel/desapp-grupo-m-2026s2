# QA Report — TASK-005 Football Catalog Domain Model

Scope: independent acceptance of the active working diff against `spec.md`, `plan.md`, `tasks.md`, architecture/development handoffs, and all current human feedback. No implementation was changed. HTTP runtime testing is not applicable: FR-019 and the plan explicitly exclude endpoints, and the diff adds no router/controller surface.

| Acceptance area | Direct evidence | Result |
|---|---|---|
| AC US1.1–1.3; FR-001–009 | `MIX_ENV=test mix test test/football_market/catalog` → 14 passed. `CatalogTest` accepts all five exact league pairs, valid season/team hierarchy, trimming, required fields, and valid player/position relationships. Migration contract confirms five UUID tables, named checks/FKs, and lookup/uniqueness indexes. | PASS |
| AC US1.4; US2.2–2.4; edge constraints; FR-010–013, FR-017 | Focused suite exercises exact/case/whitespace duplicates for every declared scope, concurrent conflicts, invalid season span, unsupported/mismatched leagues, missing parents/position, composite team-season rejection, cross-season transfer rejection, same-season identity-preserving transfer, and restrictive league/season/team/position deletion. Count assertions prove originals and rejected-delete state remain unchanged. No multi-record production command exists, so FR-013 adds no further command case. | PASS |
| AC US2.1; FR-016; SC-005 | Query/context tests verify player preloads resolve position → team → season → league. Rollback-only probe `MIX_ENV=test mix run /private/tmp/task005_qa_probe.exs` reported `integrity=2_players_0_broken`; its LEFT JOIN audit found zero missing/contradictory relations. | PASS |
| AC US3.1–3.4; FR-014–015; SC-003 | Focused query tests cover normalized business identities, not-found behavior, UUID ordering, unknown filters, empty/individual/AND-composed filters, and a representative fixture of 5 leagues, 10 seasons, 20 teams, and 3 positions. The rollback-only probe reported `stable_uuid_lookups=5/5`, and accepted same team/player identities across different seasons. | PASS |
| SC-001–004 | The focused 14-test acceptance suite and adversarial probe cover valid examples, invalid relationships/ranges/blanks, every uniqueness boundary, representative filters, parent protection, and failed-write integrity. | PASS |
| SC-006 and scope | Diff inspection shows catalog context/schemas/query, one migration, tests/support, ADR, and the explicitly approved delivery-probe exception only; no HTTP, auth, provider, seed, cache, statistics, valuation, token, trade, or UI behavior. Canonical artifacts define all entities, ownership, identities, and lookups. | PASS |
| SC-007 | `MIX_ENV=test mix test test/football_market/catalog/query_test.exs --only query_plan --trace` → 1 passed, 3 excluded; generated/analyzed 100,000 players and required Index/Bitmap plans for league, season, team, position, and combined lookups. Percentile latency remains assigned to TASK-043. | PASS |
| FR-020 | `python3 -m unittest test/scripts/workflow_artifact_probe_test.py` → 6 passed, covering matching, unmatched, and repository-escaping globs. `python3 scripts/workflow_artifact_probe.py develop` → `valid: true` for the active feature. | PASS |
| Quality/regression | `mix format --check-formatted` → exit 0; `MIX_ENV=test mix compile --warnings-as-errors` → exit 0; `MIX_ENV=test mix test` → 39 passed; `git diff --check` → exit 0. | PASS |

Residual risk: query-plan evidence establishes planner index capability at representative cardinality, not production latency; this is the documented TASK-043 boundary. Current-affiliation mutation intentionally does not preserve roster history, per ADR-0002.

Verdict: PASS

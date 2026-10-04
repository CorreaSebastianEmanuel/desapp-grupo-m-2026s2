# Final independent review — TASK-020 amended CI PostgreSQL parity

Ready for human review. No blocking findings. This fresh T034 verdict supersedes the earlier review and verifies the delivery amendment; publication and green remote CI remain subsequent delivery obligations.

Read required repository policies, constitution, product/architecture/checkpoint documents, full spec/plan/tasks, all three human feedback entries, canonical developer and fresh independent QA handoffs/evidence, amendment diffs, maintained contracts, and Statistics context/input/query/schema/count/error/migration implementation. Review changed only this report and handoffs/review.md. No delegation, Agentflow invocation, workflow-run inspection, implementation modification, publication or merge occurred.

## Amendment and unchanged boundary

The workflow diff contains exactly one changed service-image line: PostgreSQL 16 becomes the exact planned PostgreSQL 17.6 Alpine tag/digest from unchanged compose.yaml. This resolves the corrective migration's PostgreSQL 17 SET EXPRESSION requirement without rewriting accepted migrations. CI commands, permissions, other services and dependencies are unchanged.

The focused regression parses both YAML documents, requires the exact planned image and equality with compose's PostgreSQL image. Other quality/security assertions remain intact. The refreshed fixture matches actual workflow SHA-256 036dceae96623134105d6a61b100d144ad55a469f54b1a43c6283d997abf863f; unchanged SonarCloud byte-oracle enforcement still hashes workflow bytes. Scope admits the two additional CI paths by exact membership, without a CI-tree prefix. Manifest inspection confirms all original 18 checks retained plus ci_database_contract and explicit T033/T034 gate deferrals.

Statistics retains separated domain validation, Ecto persistence and local reads without web/provider/cache/financial dependencies. Composite restrictive keys protect season meaning; unique indexes arbitrate duplicates; participation and immutable triggers preserve historical facts. Event-time relationships survive current transfers. Exact integer counts distinguish unknown from zero; UTC microsecond queries preserve inclusive boundaries and deterministic ordering. Ecto.Multi provides atomic batches and indexed field-safe errors. Original identity validation rejects NUL/invalid UTF-8 before SQL. Unicode normalization and generated-key migration safeguards preserve feedback B1/B2; independent connection ownership, bounded barriers and asserting nonrecursive drivers retain B3 concurrency integrity.

## Fresh evidence and independent execution

Independently executed a Python evidence-integrity validation: all 195 current source SHA-256 values equal QA's before/after hashes; the real Git index matches its unchanged QA hash; verification.json matches QA's manifest hash; all 19 current manifest IDs/argv/environments match successful QA entries with available logs. Current workflow diff equals the fresh QA-inspected workflow.diff. Evidence: qa-evidence/ci-parity/qa/source-hashes.json and results.json. Empty logs for silent successful checks were accepted only with recorded zero exit status.

Independently ran `env PATH=/private/tmp/task020-elixir-1.20.3/bin:/private/tmp/node-v24.0.0-darwin-x64/bin:$PATH MIX_ENV=test mix test test/ci/quality_baseline_contract_test.exs test/ci/sonarcloud_contract_test.exs test/football_market/statistics/scope_test.exs --warnings-as-errors`: **15 passed**. Initial sandbox socket denial was resolved through approved escalation; it was not counted as passing evidence. Also ran `git diff --check`: passed.

Inspected fresh QA logs and adversarial assertions: full regression **216 passed**, CI contracts **13 passed**, supplemental acceptance **4 passed**, repeated Catalog focused suite **6 passed**, informational integration coverage **93.17%**. Runtime image evidence matches the exact pin; SQL reports PostgreSQL **17.6** with both Statistics migrations applied. Supplemental generated-column challenges cover transactional legacy collision/blank rejection and successful recomputation while immutable guards remain active. Fresh profiles, compilation, formatting, preparation, storage/integrity/history/concurrency and coverage checks all passed in QA. No unresolved discrepancy justified repeating its full suite.

This contributes CP2 persisted local valuation inputs while preserving CP1 checks; it does not complete the remaining CP2 strategies/quotes/trading/ranking work.

Backlog impact: **TASK-022** must specify retained selected input IDs or equivalent immutable membership and a late-arrival regression before quotes depend on interval selection. Immutable Statistics rows alone do not freeze historical input membership. This existing plan/ADR-0010 obligation remains downstream; no backlog edits made.

Blockers: none. Both amended local gates now support authorized publication to PR #26. Require green remote CI for that published head before declaring delivery complete. Human merge authority remains unchanged.

Verdict: PASS

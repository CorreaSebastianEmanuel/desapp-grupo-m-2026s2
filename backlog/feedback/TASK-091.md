# Feedback — TASK-091

## Feedback 1

- Time: 2026-11-11T00:59:19+00:00
- Author: shebi
- Restart from: develop
- Impact: implementation, verification
- Required regressions: cited discrepancy plus required manifest checks

Automated exact-head hosted CI regression findings, validated locally by the coordinating agent; this is implementation/verification repair, not a new product decision. PR #101 head 44de9882c34c0daecc4c7641d8bdb4108029ee92: https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/actions/runs/42932389652/job/130234086811 . Audited integration regular partition failed four cases; E2E, SonarCloud, Credo, Sobelow and Dialyzer passed. Local reproduction command `MIX_ENV=test mix test test/football_market/ranking/selection_test.exs test/football_market/valuation/configurations/scope_test.exs test/football_market/valuation/scope_test.exs test/football_market_web/live/portfolio_live_test.exs` completed 23/27 passed, the same four failures.

Repair the complete root-cause groups in this single repair round:
1. Behavioral regression: Ranking.SelectionTest line 120 (`a failed calculation under the active configuration never creates a ranking entry`) receives {:error, :temporarily_unavailable}; the inherited contract expects an {:ok, calculation} with status unreproducible, nil price and no ranking entry. StatisticsReader.enrichment_identity/1 pattern-matches {:ok,row} from Statistics.get_performance for an intentionally missing original and raises. Preserve safe unavailable-original handling, immutable failure evidence, no quote/ranking creation, deterministic identities and original/enriched replay. Do not weaken this test or silently fabricate/skip required facts.
2. Configurations.ScopeTest line 19: current configuration namespace includes editor.ex and presets.ex, while its historical 33-path inventory describes TASK-025. Reconcile current exact namespace and purity checks with the two explicitly reviewed TASK-091 modules while preserving historical inventory/ownership and unrelated exclusions. Do not broadly whitelist unplanned modules.
3. Valuation.ScopeTest line 102: new deterministic SHA-256 in statistics_reader.ex is rejected by the old blanket :crypto regex. Preserve no random/time/writes/providers guarantees. Either keep the hash behind an appropriate reviewed boundary or allow only the exact deterministic hashing operation with meaningful negative controls; do not disable purity/security checks generally.
4. PortfolioLiveTest line 339: inherited assertion expects only known minutes/goals and hides nil assists. The approved UI now renders all counters with explicit Desconocido. Update exact per-metric known/unknown assertions for the approved presentation, preserving all quote/date/provenance/financial checks rather than weakening them to mere presence.

Keep the approved presets, editor, metric scope and all product decisions settled. Retain the individually reviewed source-bound Sobelow/Dialyzer triage; if affected source bytes move, re-run the native analyzer before refreshing only the exact reviewed findings. Reconcile every repair path in the explicit TASK-091 WorkflowScope (including backlog/feedback/TASK-091.md and docs/WORKFLOW_LESSONS.md), source roles, Credo and profile inventories. No plan/tasks/handoffs, broad exclusions, policy changes, history resets, merge or second PR.

After causal fixes run the four affected modules, the enrichment/preset/browser regressions and one complete integration profile (`sh scripts/test_profile.sh integration`) to close the demonstrated hosted integration gap; do not rerun the entire unit+integration+E2E suite during development. Repair all related instances together if that profile exposes the same root causes. Record concise current integration evidence under the task's ignored ThinFlow operational namespace and name it in the compact spec so the evaluator can inspect it. Leave authoritative risk-selected checks to ThinFlow once inputs stabilize, then require a fresh independent evaluation of the repair delta and affected surfaces. Update the existing PR #101 through the normal harness only. Prior PASS covers the earlier revision and does not validate this repair.

### Human decision — additional bounded verification round

- Time: 2026-11-11T02:24:00+00:00
- The user explicitly authorized: "Sí, continuar con esta ronda adicional (recomendado)" in response to diagnosing the timeout, completing integration and repeating evaluation of TASK-091 in the same PR #101. The first repair's evaluator found no additional blocking code defect; B1 is incomplete full-profile evidence (674 passed, no assertion failures, one unfinished case which passes alone).
- Continue with owned-run progress and wait diagnostics, without weakening the profile timeout, inventory or checks. Preserve the original failed evidence; obtain a native complete integration receipt, refresh material selected checks and launch a fresh independent evaluator with `agentflow verify`, then resume the existing verdict/publication gate. No manual state edits, new PR, merge or changes to approved valuation behavior.


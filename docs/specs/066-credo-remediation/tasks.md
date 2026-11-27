# Tasks: Existing Credo Findings Remediation

**Input**: spec.md, plan.md, verification.json, research.md and quickstart.md in specs/066-credo-remediation/.
**Tests**: Required compatibility regressions and test-first tooling contract. No behavior change is authorized. New characterization passes against existing behavior before refactoring; new tooling assertions fail before tooling implementation.
**Format**: `- [ ] Tnnn [P?] [USn?] Description with paths`. Only terminal QA/review tasks have gate labels.

## Phase 1: Setup

- [X] T001 Inspect current toolchain/service mappings using `.tool-versions`, `compose.yaml` and `config/test.exs`; prepare locked dependencies, Node24/Chromium and Docker access per `specs/066-credo-remediation/quickstart.md`; choose a task-owned safe test partition without resetting shared databases, record safe environment guidance in `specs/066-credo-remediation/handoffs/remediation.md`.
- [X] T002 Inspect the optional archived draft and manifest at `../task066-split/` against current source and `specs/066-credo-remediation/plan.md`; verify SHA256/base before reuse, record independent accepted/rejected hunk assessment in `specs/066-credo-remediation/handoffs/remediation.md`; if unavailable, document fresh remediation instead, with no historical check credit.

## Phase 2: Foundation

- [X] T003 Set the unique `backlog/TASK-065-*.md` dependency to TASK-066, preserving todo/blocked state; confirm no TASK-065 quality-integration work enters this task, and record the scope/dependency check in `specs/066-credo-remediation/handoffs/remediation.md`.
- [X] T004 Inspect existing assertions for each draft/current candidate path before any source refactor; record changed-path-to-regression commands and uncovered characterization needs in `specs/066-credo-remediation/handoffs/remediation.md`, using the selection table in `specs/066-credo-remediation/plan.md` and routing discovered product defects separately.

Foundation excludes actual source refactoring. The initial complete finding inventory follows the analyzer setup in US1; no archived application/test hunk may be applied before T009.

## Phase 3: US1 — Repeatable Credo standard (P1, MVP)

**Independent criterion**: exact nonruntime 1.7.19 dependency and supported effective source/rule configuration; documented standard invocation passes the tooling contract. Initial findings may still exist until US2.

- [X] T005 [US1] Write red tests in `test/ci/credo_remediation_contract_test.exs` for exact Credo declaration/lock, only dev/test and runtime false, documented standard command, supported named configuration, complete independently discovered first-party Elixir scope and unchanged stock rule/priority configuration; test rejection of missing maintained test/migration/root inputs, hidden exclusions, disabled/customized checks and suppression comments using deterministic temporary configurations. Inspect effective Credo configuration/input list rather than just matching config strings. Add the new cases to `config/test_profiles.json` through its explicit inventory-update workflow, preserving existing assignments; establish red evidence before T006.
- [X] T006 [US1] Add/reuse exactly `{:credo, "1.7.19", only: [:dev, :test], runtime: false}` in `mix.exs`, lock Credo and required transitive dependencies in `mix.lock`, and create supported default `.credo.exs` with all maintained source roots/root Elixir files per plan; preserve inherited default checks with no overrides/suppressions. Run T005 tests green; reconcile identical prerequisites with TASK-065 without delivering that integration.
- [X] T007 [US1] Document `MIX_ENV=test mix credo --format flycheck`, exact version, scope and unchanged default-priority policy in `README.md`; run the tooling contract tests and record exact effective analyzer inputs/version in `specs/066-credo-remediation/handoffs/remediation.md`.

## Phase 4: US2 — Remove every existing finding safely (P1)

**Independent criterion**: complete fresh findings reconciled, every finding remediated, zero final default-priority findings and existing regressions unchanged. Depends on US1.

- [X] T008 [US2] Capture the fresh complete default-priority inventory before source cleanup using `.credo.exs` and the standard command; retain private raw measurement with revision/diff/version/input hash, reconcile every maintained `.ex`/`.exs` file against effective inputs, and index every finding by check/path/line in `specs/066-credo-remediation/handoffs/remediation.md`; no finding may disappear through scope reduction.
- [X] T009 [US2] Before applying application refactors, run mapped existing assertions and add any missing characterization in affected `test/football_market/`, `test/football_market_web/` or `test/integration/` files for branch/error order, malformed inputs, exception boundaries, rollback/locking, ownership and replay. Assert current behavior first; register added cases in `config/test_profiles.json` without changing existing cases or assignments. Record exact causal commands in `specs/066-credo-remediation/handoffs/remediation.md`.
- [X] T010 [US2] Remediate assessed domain/adapter findings in `lib/football_market/accounts.ex`, `lib/football_market/accounts/`, `lib/football_market/catalog/`, `lib/football_market/market/`, `lib/football_market/providers/`, `lib/football_market/statistics.ex`, `lib/football_market/statistics/`, `lib/football_market/synchronization/` and `lib/football_market/valuation/` only where the fresh inventory requires; independently reviewed draft hunks may be reused. Keep evaluation/exception/query/transaction/lock boundaries and public errors unchanged; rerun each batch's causal regressions and update the ledger in `specs/066-credo-remediation/handoffs/remediation.md`.
- [X] T011 [US2] Remediate assessed remaining first-party findings in `lib/football_market_web/`, `lib/football_market/infrastructure/`, `lib/mix/tasks/`, `config/`, `priv/`, `scripts/` Elixir sources and root Elixir files only as required by inventory; preserve responses and infrastructure guard semantics, all existing CI/report behavior, migration semantics and database identities. Add current-behavior characterization before each uncovered branch, rerun causal tests and update `specs/066-credo-remediation/handoffs/remediation.md`.
- [X] T012 [US2] Reconcile initial and newly exposed findings against the combined current source in `specs/066-credo-remediation/handoffs/remediation.md`; review every accepted draft hunk, reject incompatible portions and remediate all remaining findings without scope exclusions. Run causal tests for corrections and a zero-finding measurement; final frozen-source manifest measurement still occurs at T018.

## Phase 5: US3 — Preserve critical test/domain safeguards (P1)

**Independent criterion**: unchanged subset-pattern meaning, owner/receipt refusal cases and financial/auth assertions; unit, integration and actual E2E pass after all cleanup. US3's preservation constraints already apply from T004; test/support changes await US2 characterization.

- [X] T013 [US3] Establish assertion-preservation before editing maintained tests/support: inspect `test/support/e2e/fixtures.ex`, `test/e2e/`, `test/ci/`, `test/support/test_profile_audit.ex` and affected support modules; run focused native profile receipt/source/ownership refusal regressions and existing browser/financial assertions; record baseline assertion meaning and exact commands in `specs/066-credo-remediation/handoffs/remediation.md`. Add characterization first wherever an affected safeguard lacks executable coverage, keeping `config/test_profiles.json` current.
- [X] T014 [US3] Remediate fresh findings in `test/` including all maintained fixtures/support/cases, preserving catalog nested subset matches in `test/support/e2e/fixtures.ex`, original assertions, owner/receipt provenance, child cleanup, secret-safe diagnostics and negative cases. Do not replace subset patterns with full equality or weaken a native safeguard; rerun each changed module's causal tests and record deltas in `specs/066-credo-remediation/handoffs/remediation.md`.
- [X] T015 [US3] Compare affected auth, market, valuation, provider and native-profile hunks against pre-change behavior and original assertions in `lib/`, `test/` and `config/test_profiles.json`; document the seven product invariants, transaction/evaluation ordering, subset strength and receipt ownership findings in `specs/066-credo-remediation/handoffs/remediation.md`. Correct within-scope discrepancies test-first; defer unrelated defects and never claim automatic semantic equivalence.

## Phase 6: Final developer verification and independent gates

- [X] T016 Reconcile docs and executable checks in `specs/066-credo-remediation/plan.md`, `specs/066-credo-remediation/verification.json`, `README.md` and `config/test_profiles.json` with actual changed-path tests; verify every FR/SC mapping and acceptance scenario, source scope and zero suppressions, and finish all source/design edits before final check receipts.
- [X] T017 Execute final `toolchain`, `services`, `format` and `compile` checks from `specs/066-credo-remediation/verification.json` using `scripts/agentflow_check.py`; missing services/browser/Docker or sandbox permissions block affected checks, never justify weakened gates. Capture safe evidence references in `specs/066-credo-remediation/handoffs/develop.md`.
- [X] T018 Execute final `credo`, `unit`, `integration`, `e2e` and `scope` manifest checks using `scripts/agentflow_check.py` after T016; all three profiles run once on final inputs, with existing HTTP/browser readiness and assertions. Do not add historical CP1 coverage or duplicate full-profile runs. Diagnose failures, apply only causal corrections, and observe the two-unchanged-failures rule; record current evidence in `specs/066-credo-remediation/handoffs/develop.md`.
- [X] T019 Complete all developer checkboxes T001–T018, record remaining scope/semantic-review risks and commands in `specs/066-credo-remediation/handoffs/develop.md`, then run `python3 scripts/workflow_artifact_probe.py develop --readiness`; QA may begin only when all implementation/test tasks and current receipts pass. TASK-065 stays blocked until TASK-066 completion after human merge.
- [ ] T020 [gate:qa] Independent QA reruns every manifest check without developer receipt reuse, challenges every FR/SC and numbered acceptance scenario plus hunk/assertion equivalence and source inventory, and writes `specs/066-credo-remediation/qa-report.md` and `specs/066-credo-remediation/handoffs/qa.md`; report ends exactly `Verdict: PASS` only with actual fresh proof.
- [ ] T021 [gate:review] Final review inspects fresh QA evidence, product/plan alignment and all risky financial/auth/native-profile changes, runs targeted uncovered checks, confirms TASK-065 remains blocked, and writes `specs/066-credo-remediation/review-report.md` and `specs/066-credo-remediation/handoffs/review.md`; report ends exactly `Verdict: PASS` only on acceptance. Human retains merge; no publication is authorized in this architecture session.

## Dependencies and execution order

T001 → T002 → T003 → T004 → US1 (T005 red → T006 green → T007) → US2 (T008 inventory → T009 characterization → T010/T011 causal batches → T012 reconciliation) → US3 (T013 baseline → T014 support cleanup → T015 preservation review) → T016 frozen inputs → T017 → T018 → T019 readiness → T020 independent QA → T021 final review.

Within T010/T011/T014 apply the same test-first pattern for every additional finding, including findings exposed after earlier cleanup. US3 invariants constrain US2 before its own test/support remediation phase. No application changes are unblocked by an incomplete tool contract or missing characterization.

## Parallel opportunities and examples

One implementation owner, no concurrent mutating service profiles and no automatic research agents. No task is marked [P] because each phase shares the ledger, source inventory or service state. Within US1, read-only review of dependency options and README command can be compared independently after T005. Within US2 after T009, read-only hunk review of provider versus valuation files can be independent; apply and verify sequentially. Within US3 after T013, inspect E2E subset patterns and native receipt refusals independently; preserve sequential writes and execution. These are review opportunities, not authorization to skip dependencies or launch agents.

## Implementation strategy

US1 is the tooling MVP; it establishes a trustworthy measurement, not task completion. Deliver small behavior-preserving causal batches through US2 and US3, retaining finding/hunk/test links. The complete TASK-066 outcome requires every story, frozen-source developer checks, independent QA and final review. No deploy/demo, CI integration or product feature is added here. Required quickstart is a validation guide, not application implementation.

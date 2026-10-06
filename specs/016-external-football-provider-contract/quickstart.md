# Validation guide

Run these commands from the repository root on `016-external-football-provider-contract`. The pure runner loads only the provider modules and test support, and checks that application/service clients were not started. Its selectors and ExUnit exit status are asserted by the fixtures suite.

## Prerequisites

Use `.tool-versions` (Elixir 1.20.3/OTP 29.0.6), installed Mix dependencies and the existing local PostgreSQL/Redis environment. Integration profile also requires the repository's Node 24, installed `tools/openapi` dependencies and Playwright Chromium. These are existing prerequisites, not new provider infrastructure. No football service/account/key is required; never place credentials in fixtures or the verification manifest.

Pure acceptance is intentionally independent of those local services:

```bash
python3 scripts/agentflow_check.py offline-all
```

Expected: nonempty request/catalog/performance/deadline/safety/fixture suites pass; fixture collection runs twice with identical controlled outcomes. No Mix/database/application or external client is started. Unknown selector and empty case inventory must exit nonzero. This runner must propagate actual ExUnit failures, not merely print success.

## Scenario entry points

```bash
elixir test/provider_contract_offline.exs request
elixir test/provider_contract_offline.exs catalog
elixir test/provider_contract_offline.exs performances
elixir test/provider_contract_offline.exs deadline
elixir test/provider_contract_offline.exs safety
elixir test/provider_contract_offline.exs fixtures
```

- Request: unsupported/malformed scope, bounds and timeout fail before any adapter work; normalized valid input covers all leagues and same-year seasons.
- Catalog: reordered two-source facts, repeated names, uniqueness/references, empty/missing/unsupported distinctions; fixtures use independent expected values.
- Performances: inclusive microsecond bounds/offsets, eligibility-before-full-validation, complete directory closure, current versus historical affiliation, unknown versus zero, no invented facts.
- Deadline: default/custom before/equal/after outcomes, delayed validation, all portions under one budget, late replies and real blocked-worker cleanup.
- Safety: all error categories/retry delay semantics plus sentinel leaks in full returned outcomes and inspection; no raw exception or hostile key reflection.
- Fixtures: both sources and every stable variant run twice; check five leagues/two seasons, 17 scenario links, bijective equivalence and negative same-name edge tests.

Detailed expected outcomes and stable fixture families: [contracts/fixtures.md](contracts/fixtures.md). DTO shape and lifecycle: [data-model.md](data-model.md), [contracts/provider.md](contracts/provider.md).

## Local-state regression and readiness

Start the existing dependencies only when running database-backed checks:

```bash
sh scripts/local_services.sh start
sh scripts/local_services.sh ready
python3 scripts/agentflow_check.py toolchain
python3 scripts/agentflow_check.py service-preflight
python3 scripts/agentflow_check.py catalog-isolation
python3 scripts/agentflow_check.py scope
```

Preflight prepares the guarded test database and verifies its migration probe and Redis through application clients; unavailable service causes nonzero exit. Isolation snapshots league/season/team/position/player state and selected Catalog reads before/after every failure category, and asserts zero provider calls during those reads. Scope assertions enforce dependency separation, absence of provider writes/network/scoring fields and the authorized changed production paths. No affected HTTP endpoint exists, so `runtime_required` is false; an endpoint scope change would require specification approval plus assertion-based real HTTP checks, not a bare request.

## Final developer evidence

After implementing every story, finish all source/design changes and stage new files for the existing coverage script's working-tree provenance rule. Staging is local; do not commit, push or publish:

```bash
git add -- specs/016-external-football-provider-contract docs/adr/0013-provider-contract-boundary.md mix.exs test/football_market/statistics/scope_test.exs lib/football_market/providers.ex lib/football_market/providers test/provider_contract_offline.exs test/support/provider_contract_case.ex test/support/providers test/fixtures/providers test/football_market/providers
```

Run every check in verification.json through the helper, in manifest order:

```bash
for provider_check_id in toolchain format compile service-preflight request catalog performances deadline safety fixtures offline-all catalog-isolation scope regression unit-profile integration-profile coverage; do
  python3 scripts/agentflow_check.py "$provider_check_id" || exit 1
done
python3 scripts/workflow_artifact_probe.py develop --readiness
```

Run readiness only after completing all non-gate tasks and creating `handoffs/develop.md`. Mark check tasks complete only after successful execution. Coverage remains the accepted CP1 inventory/reporting job; do not add provider modules to its denominator. Feature conformance is established by its own suites; profiles/regression/coverage preserve existing checkpoint evidence. Remote CI/Sonar verdicts remain later delivery obligations, not fabricated local results.

The helper writes canonical check receipts and reports a local output path. Follow docs/AGENT_CONTEXT_POLICY.md and docs/AGENT_VERIFICATION.md for failure excerpts; never inspect workflow-run histories. Any later source/canonical-input change requires current receipts again. Checkbox completion and output handoffs alone do not stale evidence.

The feature `.gitignore` excludes only `handoffs/check-*.json`: these receipts bind ignored workspace outputs and must remain locally present for readiness. This prevents the helper's pending receipt from triggering the unchanged coverage untracked-input guard. After creating develop.md and completing checkboxes, stage the final handoff/checklist before QA reruns coverage; this local staging changes no receipt fingerprint:

```bash
git add -- specs/016-external-football-provider-contract/handoffs/develop.md specs/016-external-football-provider-contract/tasks.md
```

QA independently runs manifest commands, compares every expected fixture/scenario and directly challenges uncovered risks. Only downstream QA/review tasks may remain unchecked before QA, and both independent reports require final `Verdict: PASS`. Live operation/league/metric feasibility is TASK-017; incomplete valuation input policy is TASK-022.

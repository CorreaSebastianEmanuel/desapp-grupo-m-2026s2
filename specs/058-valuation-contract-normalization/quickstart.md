# Validation guide — TASK-022

Run from repository root on the bound delivery branch. Named feature assertion files are implementation deliverables, not architecture-stage passing checks.

## Prerequisites

Use .tool-versions, installed locked dependencies, PostgreSQL/Redis from existing local setup, and the integration profile's Node 24/Chromium prerequisites. Use existing setup documentation; preserve service/database guards and keep credentials out of evidence. Start services with `sh scripts/local_services.sh start` if needed. No new infrastructure.

## Developer execution

Finish all source/design edits, then run in order:

```bash
python3 scripts/agentflow_check.py toolchain --reuse
python3 scripts/agentflow_check.py format --reuse
python3 scripts/agentflow_check.py compile --reuse
python3 scripts/agentflow_check.py services --reuse
python3 scripts/agentflow_check.py preparation-unit --reuse
python3 scripts/agentflow_check.py history-integration --reuse
python3 scripts/agentflow_check.py missing-data --reuse
python3 scripts/agentflow_check.py grouping --reuse
python3 scripts/agentflow_check.py scoring --reuse
python3 scripts/agentflow_check.py replay --reuse
python3 scripts/agentflow_check.py matrix --reuse
python3 scripts/agentflow_check.py architecture --reuse
python3 scripts/agentflow_check.py feedback-regression --reuse
python3 scripts/agentflow_check.py unit-profile --reuse
python3 scripts/agentflow_check.py integration-profile --reuse
```

services prepares the guarded test database and verifies migrated PostgreSQL plus Redis PING via application clients. Unavailable services fail; reuse is disabled for this transient-state check. Tests have exactly one explicit module-level profile tag. Deterministic local facts and illustrative numeric values are not production defaults.

Focused checks prove [acceptance-map.md](contracts/acceptance-map.md). Final profiles provide complete repository regression and existing actual browser E2E evidence once each. Do not add historical CP1 coverage or another default/full-profile run. Preserve coverage infrastructure/CI; preflight/browser failures block rather than justify omission.

## Expected scenarios

- Monday opening included, next Monday closing excluded; equivalent offsets identical. Matrix covers five leagues/two seasons/four groups.
- Counts 1+2/ref4 -> 0.750000 regardless of minutes; known zero -> 0.000000; nil required -> ordered insufficient-data. Empty week differs from unknown subject.
- Tackles 2 defender +1 midfielder/ref4 -> overall .750000, groups .500000/.250000. Absent goalkeeper omitted; require-all scorer fails, explicit populated-only illustrative policy can succeed.
- Rounded 1/6 times 3 -> .500001; 1/128 -> .007813. Signed half ties, large counts and negative zero match exact rules.
- Replay after late arrival/transfer/new rules stays original. Coordinated count/derived tampering, position/kickoff changes, duplicate rows and unavailable originals fail without fallback. At least 20 permutations produce identical descriptors and scores.

No HTTP endpoint is affected; domain integration assertions exercise actual PostgreSQL-backed history/replay.

## Independent verification

Developer completes all implementation/check tasks, records handoffs/develop.md (under 400 words), then runs `python3 scripts/workflow_artifact_probe.py develop --readiness`. QA executes every check independently with --stage qa, without --reuse; challenges mappings and writes report/handoff. Review uses fresh QA evidence and targeted uncovered-risk checks with --stage review. Both reports end exactly `Verdict: PASS`. Only tagged downstream tasks defer. Follow docs/AGENT_VERIFICATION.md receipts/failure limits; architecture claims no implementation or independent verification verdict.

## Internal API example (test-only scorer)

With accepted local fixture `f`, the test-support interfaces provide:

```elixir
request = FootballMarket.ValuationCase.request(f)
definition = %FootballMarket.Valuation.Definition{
  module: FootballMarket.ValuationScorers.Weighted,
  strategy_id: "illustrative", version: "1",
  config: %{weights: %{overall: %{goals: 2}}, policy: :require_all}
}
{:ok, result} = FootballMarket.Valuation.evaluate(request, definition)
{:ok, ^result} = FootballMarket.Valuation.replay(result.descriptor, definition)
```

The illustrative modules exist only under test/support; downstream production consumers supply their own reviewed module and explicit configuration. Use `prepare/1` alone for input preparation and `replay(prepared.descriptor, nil)` for preparation-only replay. See contracts/valuation-context.md for actual DTO field names and the canonical in-memory representation. All check argv/coverage in verification.json match the delivered assertion paths; no HTTP runtime check applies.

Feedback-regression runs the durable public malformed-list assertions in contract_test.exs and replay_test.exs. The preserved /tmp/task022_qa_adversarial.exs is a local diagnostic only; no permanent check depends on it.

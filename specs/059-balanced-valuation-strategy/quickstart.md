# Balanced validation guide

Run from repository root on branch 023-balanced-valuation-strategy, with pinned Elixir/OTP, existing dependencies and PostgreSQL/Redis per README.md. The production Balanced module implements the internal scorer contract; this guide covers its explicit usage and developer/QA validation.

## Preparation

```bash
sh scripts/check_toolchain.sh
docker compose up -d
mix deps.get
```

Use guarded local test-database config. Credentials remain environment-local, never in manifest/evidence. Full integration profile needs Node 24, tools/openapi/node_modules and Playwright Chromium under the existing setup. scripts/test_profile.sh integration fails closed if prerequisites are missing.

## Explicit usage

```elixir
alias FootballMarket.Valuation.{Balanced, Definition}
definition = %Definition{module: Balanced, strategy_id: "balanced", version: "1",
  config: %{weights: %{goals: 2, assists: 1, goals_conceded: -1}}}
# request includes subject, season, UTC week, historical mapping, and these rules:
# requirements: %{overall: [:goals, :assists, :goals_conceded]}
# references: %{goals: 4, assists: 2, goals_conceded: 4}
FootballMarket.Valuation.evaluate(request, definition)
# Retain result.descriptor and the original definition; replay requires both.
```

These numbers illustrate the acceptance example, not operator calibration. Use only intentional explicit weights/references supplied by the caller. TASK-025/026 own retaining and activating operator settings before market integration. No registration or endpoint is introduced.

## Developer acceptance

Finish source/design edits, then run every manifest check through the helper. Explicit development reuse verifies fingerprints and does not reuse service/environment checks:

```bash
python3 scripts/agentflow_check.py toolchain --reuse
python3 scripts/agentflow_check.py format --reuse
python3 scripts/agentflow_check.py compile --reuse
python3 scripts/agentflow_check.py services --reuse
python3 scripts/agentflow_check.py balanced-config --reuse
python3 scripts/agentflow_check.py balanced-formula --reuse
python3 scripts/agentflow_check.py balanced-outcomes --reuse
python3 scripts/agentflow_check.py balanced-arithmetic --reuse
python3 scripts/agentflow_check.py balanced-replay --reuse
python3 scripts/agentflow_check.py architecture --reuse
python3 scripts/agentflow_check.py feedback-regression --reuse
python3 scripts/agentflow_check.py unit-profile --reuse
python3 scripts/agentflow_check.py integration-profile --reuse
python3 scripts/agentflow_check.py oracle-format --reuse
python3 scripts/agentflow_check.py oracle-integrity --reuse
python3 scripts/agentflow_check.py independent-oracle --reuse
```

Service preflight prepares the guarded database and checks migration readiness/PostgreSQL connectivity/Redis PONG through application clients; unavailable dependencies fail. Targeted checks run files named in manifest. Arithmetic includes inherited normalization/scoring regressions for the shared helper. [acceptance-map.md](contracts/acceptance-map.md) defines numeric/error/evidence/original-replay/read-only assertions. Inspect bounded failures and reference local output via receipts.

Each full profile appears once; do not add the historical CP1 coverage report as a CP2 gate. Preserve coverage/CI. After two unchanged failures stop repeating, diagnose and fix affected inputs before retry. Expected red tests establish missing behavior, not successful acceptance evidence.

Only mapped QA/review tasks may remain unchecked before readiness. Create handoffs/develop.md, reconcile checkboxes with actual named files/receipts, then run `python3 scripts/workflow_artifact_probe.py develop --readiness`. Implementation acceptance does not substitute for independent gates.

## Independent QA and review

The independent 511-subset oracle regenerates its vectors in memory using Python's standard-library Fraction implementation. No expanded dataset is needed in the checkout. Run:

```bash
python3 scripts/agentflow_check.py independent-oracle --stage qa
```

The probe checks the canonical dataset checksum against oracle-summary.json, then validates features, scores and original replay for all 511 subsets. Python 3 must be available; a missing-generator regression verifies failure before scoring. oracle-integrity compares regenerated cases and every lib/test file hash with the approved baseline, asserts the dataset remains absent, and verifies generation writes no evidence files. These three oracle checks always execute because evidence paths are excluded from the common source fingerprint. Production weights/references remain explicit, and this evidence does not select presets.

QA prepares services and reruns all checks with `python3 scripts/agentflow_check.py CHECK_ID --stage qa`, without reuse, then challenges scenario mappings using the production workflow. Review uses fresh QA evidence and targeted checks with --stage review. Reports must end Verdict: PASS before workflow publication; architecture publishes nothing.

No HTTP runtime obligation exists for this internal feature; DataCase tests exercise actual local valuation reads and assert scores/errors/evidence/no writes. Operator weights/references remain explicit, not calibrated fixtures. TASK-025/026 must retain intentional effective settings before CP2 market demonstration.

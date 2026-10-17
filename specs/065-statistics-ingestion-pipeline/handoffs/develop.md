# Develop handoff

## Implementation and QA remediation

Implemented the statistics import pipeline with complete-scope validation, atomic fact/check/provenance publication, replay/conflict handling, same-season substitute-position evidence, and durable calculation intents. Independent QA then found two defects: changed participation could advance the accepted check as unchanged, and multi-performance intent IDs were compared as an ordered list by the calculation receiver. Both are corrected; intents are now published canonically and receiver comparisons normalize both sides. Regressions cover participation immutability, an eight-performance dispatch, all nine nil/zero metric pairs through import/read and provider validation, and Oban redelivery after request acceptance.

## Develop re-entry (2026-10-17) — changes

On the corrected final source, two rectifications were applied to `lib/football_market/statistics/ingestion/publisher.ex`: a formatting reflow (`mix format`) and replacing the unused parameter `state` with `_state` in `observe_fact!/9` after compile surfaced it under `--warnings-as-errors`. No behavior change. The first integration attempt then failed with 197 unique-constraint violations on `leagues_normalized_code_index` across pre-existing web controller tests — stale committed rows left in the base test DB by an earlier crashed/probe run, not feature code. Remediation: `MIX_ENV=test mix ecto.drop` (environment reset only, no source/config change); `mix test.prepare` then rebuilt it during preflight.

## Command outcomes

All five manifest checks executed fresh via `scripts/agentflow_check.py` (stage develop; receipts under `.agentflow/runs/checks/a51aee7448d14823adfa2fce949af473/065-statistics-ingestion-pipeline/develop/`): preflight 3.97s, format 1.66s, compile 0.84s, unit 37.28s, integration 392.57s — all PASS. Elapsed check time this session: ~7.5 min plus two remediated failures (format 1.4s; integration 186.4s before the DB reset). History journals retain per-attempt details. Sample integrity notes: unit failed once transiently on fingerprint churn and passed on rerun; integration failed once on the stale DB before the reset; budget is at zero consecutive failures.

## Environment and QA guidance

`MIX_OS_CONCURRENCY_LOCK=0` resolves the restricted Mix TCP lock. Run integration (and any profile using it, per `scripts/test_profile.sh` prerequisites) with `PATH=/Users/ezequielgonzalez/.nvm/versions/node/v24.21.0/bin:$PATH` for the pinned Node 24. QA must execute every check independently (`--stage qa`, no `--reuse`); do not reuse developer receipts. If mass unique-violation failures reappear, reset the test DB exactly as above before diagnosing — do not treat it as a regression. Keep T031/T032 open until each downstream gate has a fresh PASS. No commit, push, PR or merge.

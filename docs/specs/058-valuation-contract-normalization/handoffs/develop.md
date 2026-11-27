# Develop handoff — TASK-022, Feedback 2/3

Corrected improper-list handling in `lib/football_market/valuation/request.ex`, `evidence.ex` and `replay.ex`. Tail validation precedes Enumerable traversal of required metrics, mapping pairs, nested configuration, facts and scope memberships. Canonical comparison safely rejects malformed nested retained evidence. Public prepare/evaluate/score/replay return ordinary no-score failures; scorer callback exception handling and infrastructure failure visibility are preserved.

Durable regressions in `test/football_market/valuation/contract_test.exs` and `replay_test.exs` cover all four original malformed structures, adjacent nested shapes, caller-held Prepared facts/scopes and successful unchanged replay. `verification.json` now runs these repository tests for feedback-regression; it has no temporary external dependency. Updated contract, acceptance map and quickstart describe the same boundary. All 21 FR/SC IDs remain mapped.

All 15 final manifest checks executed through `python3 scripts/agentflow_check.py CHECK_ID --reuse`, exit 0, no source/input changes or reuse. Total final check time: 159.060 s; unit-profile 26.531 s; integration-profile 110.127 s, including actual browser E2E/performance without skips. Evidence and elapsed times: `handoffs/check-*.json`. Services preflight verified guarded PostgreSQL preparation and Redis readiness.

The unchanged original `/tmp/task022_qa_adversarial.exs` also passed through the helper before replacing its temporary manifest command (1.196 s; evidence `.agentflow/runs/checks/f6d3b0ecaa564e3bb58cf038a524e1f7.log`). An earlier corrective probe passed in 1.460 s; total check execution this session 161.716 s. Original diagnostic inputs remain untouched.

T001–T038 artifacts/checks reconciled; readiness command: `python3 scripts/workflow_artifact_probe.py develop --readiness` returned `valid: true` (exit 0). Only T039/T040 defer.

QA: independently execute all 15 checks with `--stage qa` and no reuse. Challenge malformed-list errors through every public entrypoint, exact arithmetic, authoritative original-fact comparison, tampered memberships and absent scopes. Use durable tests on clean checkouts; original /tmp inputs are optional diagnostics. Fresh QA and final-review PASS verdicts remain required. Descriptor retention/origin trust and production policies remain downstream obligations. No publication performed.

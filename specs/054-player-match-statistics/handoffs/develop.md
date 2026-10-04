# Develop handoff — TASK-020 CI PostgreSQL parity

## Delta and decisions

Completed T030–T032 within the plan delivery amendment. The only workflow edit replaces PostgreSQL 16 with the exact planned PostgreSQL 17.6 Alpine tag/digest from unchanged compose.yaml. The existing quality-baseline contract now parses both service images and requires exact parity; every other assertion stays intact. Refreshed the existing byte fingerprint after confirming the one-line image diff. Scope admits only the two exact CI test/fixture paths, not a broader CI prefix. No product code, migrations, CI commands, permissions, dependencies or other services changed.

## Executed evidence

Before changing CI, `MIX_ENV=test mix test test/ci/quality_baseline_contract_test.exs --warnings-as-errors` failed only the added image assertion: postgres:16 versus the required 17.6 pin (5/6 passed). After alignment, the quality-baseline and SonarCloud contracts passed all 13 tests. Evidence: qa-evidence/ci-parity/develop-red.log and develop-green.log.

Added ci_database_contract to verification.json while preserving all 18 original checks; T033/T034 are explicit independent gate deferrals. `python3 /private/tmp/task020_ci_develop_checks.py` ran all 19 checks sequentially via `python3 scripts/agentflow_check.py <id>` after final source stabilization. Every check returned zero, with source_changed false; canonical handoffs/check-*.json identify command evidence. Bounded summary: qa-evidence/ci-parity/develop-results.json. Full regression, profiles, coverage, migration preparation, storage/integrity, both concurrency checks and feature scope all passed.

Environment: restored Elixir 1.20.3 in /private/tmp/task020-elixir-1.20.3/bin and Node 24.0.0 in /private/tmp/node-v24.0.0-darwin-x64/bin. OTP is 29.0.6. Started existing Docker services without reset; readiness/preflight passed. Mix requires local socket access outside the sandbox. Coverage used a separate intent-to-add GIT_INDEX_FILE and left the real index unchanged. Initial environment attempts (missing temporary tools/stopped services and denied Mix sockets) were not attributed to the image regression; the retained red evidence is the explicit image assertion failure on the correct environment.

## Independent gates and delivery

Fresh QA must rerun every manifest check and challenge exact image parity plus corrective migration compatibility on PostgreSQL 17.6. Fresh final review must assess the one-line workflow diff, unchanged fingerprint enforcement, exact scope allowlist and current QA evidence. Earlier PASS reports apply only to the earlier revision; both amended gates remain pending. Keep canonical files stable during independent coverage; use temporary logs until it finishes.

The existing PR is #26. Update its feature branch only after fresh independent QA and final review PASS; require green remote CI for the resulting head before declaring delivery complete. Human merge authority remains unchanged. TASK-022 must still capture immutable selected input membership for quote reproducibility under late arrivals.

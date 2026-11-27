# SonarCloud Integration Verification

## Local deterministic evidence

Verified 2026-09-16 on branch `004-sonarcloud-integration`:

- `python3 -m unittest test/scripts/sonar_checkpoint_gate_test.py` — PASS, 9 tests. Covers the 0/9/10/>10 boundary, malformed measures, main revision freshness, HTTP classification, bounded retries, recovery, and redaction.
- `MIX_ENV=test mix test test/ci/sonarcloud_contract_test.exs` — PASS, 6 tests. Covers events, permissions, exact SHA checkout, immutable pins, scanner settings, scope, gate wiring, summaries, secret indirection, and the baseline oracle.
- `mix format --check-formatted` — PASS.
- `MIX_ENV=test mix compile --warnings-as-errors` — PASS.
- `scripts/ci_unit_tests.sh` — PASS, 25 tests with the complete-discovery sentinel.
- `git diff --check` — PASS.
- `.github/workflows/quality-baseline.yml` SHA-256 remains `45ad39d1c54d5157a11c74795975c498dec5cc3d261ce4500bd8419e48a8cf05`; its diff is empty.
- TASK-004 secret-canary, persisted-token, mutable-action-tag, and baseline-diff scans — PASS with no matches.

## Scope and security review

PASS for locally verifiable scope: changes are limited to repository CI, the dependency-free gate, deterministic tests/fixtures, operator documentation, and this feature's artifacts. There are no product, domain, persistence, adapter, coverage-gate, credential-value, mutable action-pin, or TASK-003 workflow changes.

## Hosted evidence still required

No PR was published and no merge was performed, as required by the implementation-stage delivery boundary. An authorized maintainer must first bind/import project `CorreaSebastianEmanuel_desapp-grupo-m-2026s2` under organization `correasebastianemanuel`, make `main` primary, disable automatic analysis, install protected `SONAR_TOKEN`, and configure the workflow as a required check. The organization was not present in SonarCloud's public project index during implementation.

QA must verify an internal PR's `opened`, `synchronize`, `reopened`, and `ready_for_review` runs; latest-head cancellation/governance; exact SHA attachment; two-action findings navigation; native-gate and categorized failure visibility. After an authorized merge, QA must record the integrated SHA, compute/analysis identity, timestamp, native gate, active profile names/keys, findings URL, and a fresh `open_issues` value from 0 through 9.

# Quickstart: Validate SonarCloud Integration

## Prerequisites

- Check out the target revision with Python 3 and the repository's pinned Elixir/Erlang toolchain available.
- An authorized maintainer has created/imported the SonarCloud project, selected `main` as primary, disabled automatic analysis, and stored `SONAR_TOKEN` as a protected GitHub repository secret.
- Non-secret project/organization identifiers match `sonar-project.properties`.

Do not paste or echo the token. Live SonarCloud execution happens only in the hosted internal-branch workflow.

## Deterministic pre-publication validation

Run the gate fixture suite and repository contract test:

```bash
python3 -m unittest test/scripts/sonar_checkpoint_gate_test.py
MIX_ENV=test mix test test/ci/sonarcloud_contract_test.exs
```

Expected: fixtures at 0 and 9 pass; 10 and larger fail; missing or stale `main` revision evidence, malformed/missing/invalid measures, and simulated service/auth/timeout failures fail with sanitized classifications. The contract test verifies events, revision identity, permissions, immutable action pins, wait behavior, revision and measure queries, source scope, exclusions, and secret handling.

Re-run the unchanged TASK-003 baseline:

```bash
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
scripts/ci_unit_tests.sh
```

Expected: all retain their prior conclusions. Confirm `.github/workflows/quality-baseline.yml` has no task-related diff.

See [contracts/sonarcloud-ci.md](contracts/sonarcloud-ci.md) for the precise contract and [data-model.md](data-model.md) for governing-result states.

## Hosted PR validation after publication

1. Open an internal pull request to `main`; repeat after synchronizing its head. Also exercise reopened/ready-for-review if applicable.
2. From the PR Checks view, confirm the required SonarCloud check is attached to the current head SHA and completes.
3. Open the check, then its findings link. Confirm this takes no more than two actions from Checks.
4. Confirm the summary separately names the exact-head PR analysis/native gate and the primary `main` `open_issues` count.
5. Push a newer head while an older run is active. The older run may cancel, but only the newer SHA's completed check governs.

## Hosted main/CP1 evidence after integration

After the revision reaches `main`, confirm the push workflow publishes a main-branch analysis and record:

- integrated commit SHA;
- SonarCloud analysis/compute identifier and timestamp;
- `open_issues` value and `< 10` decision;
- native quality-gate status;
- active quality-profile name/key for every detected language; and
- findings URL.

Expected: the analysis is published for the integrated SHA and `open_issues` is 0–9. If it is 10+, remediate findings outside this integration task as separately authorized; never weaken or relabel the gate.

## Failure diagnosis

- **Issue threshold**: analysis published, but `open_issues >= 10`; follow the findings link.
- **Native gate**: analysis published but SonarCloud's own gate failed; inspect the PR/main analysis.
- **Authentication/configuration**: scanner/API rejects credentials or identifiers; verify protected configuration without printing values.
- **Processing/publication/timeout**: upload did not become a completed published analysis; inspect the named non-secret task category and retry after service recovery.
- **API/malformed response**: checkpoint count could not be validated; treat as non-passing, not zero.

Do not manufacture live credential or timeout failures. The deterministic fixtures are the acceptance oracle for those cases.

# Contract: Repository Quality Baseline

## Hosted trigger contract

The repository exposes one GitHub Actions workflow for:

- `pull_request` events whose base branch is `main`, including subsequent commits; and
- `push` events on `main`.

The workflow uses read-only repository contents permission. One job checks out the triggering SHA once and produces one overall conclusion. Superseded runs share a PR/branch-specific concurrency group and may be cancelled.

## Enforced quality contract

After setup, the job exposes exactly these labelled categories:

1. **Formatting** — `mix format --check-formatted`
2. **Warnings as errors** — `MIX_ENV=test mix compile --warnings-as-errors`
3. **Unit tests** — `scripts/ci_unit_tests.sh`, delegating to `MIX_ENV=test mix test --warnings-as-errors`

The script preserves the repository's normal test-alias status, including test database preparation, and fails when the sentinel's unique execution marker is absent. The delegated Mix command has no stale/path/tag filters. The overall job succeeds only if setup and all categories exit successfully for the same SHA.

## Environment contract

- Elixir 1.20.3 and Erlang/OTP 29.0.6
- dependencies resolved from `mix.lock`
- ephemeral PostgreSQL with test-only credentials and health checking
- no production secret, Redis requirement, or live football-provider call

Setup steps are necessary execution support, not additional quality categories.

## Diagnostic contract

- A format difference fails Formatting without rewriting the checkout.
- A warning in `lib`, `test/support`, or a test file makes the applicable warning-fatal command nonzero.
- A failed assertion makes Unit tests nonzero and names the failed test.
- Missing expected discovery fails the Unit tests category through the sentinel-marker oracle.
- Infrastructure/setup failure fails the same visible job and is not reported as a category pass.

## Local parity contract

README documentation gives the exact toolchain/dependency prerequisites and the same three commands. With PostgreSQL available and the same revision checked out, local and hosted category outcomes must match.

## Verification lifecycle contract

Before publication, QA must parse the workflow YAML and verify triggers, permissions, concurrency, pinned environment, PostgreSQL, checkout, and the exact three labelled quality commands. QA must also run those commands locally on the pinned toolchain and exercise isolated formatting, warning, failing-test, and missing-sentinel negatives. Passing QA and final review do not require a hosted run for an uncommitted workflow.

After the feature commit is pushed and a pull request exists, its hosted run must be checked against the PR head SHA. After merge, the `main` push run must be checked against the integrated SHA. These hosted runs are post-publication checkpoint evidence and do not replace pre-publication contract or local-parity validation.

Coverage, SonarCloud, deployments, releases, E2E tests, architecture checks, and product behavior are not part of this contract.

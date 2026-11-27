# Quickstart: Validate the CI Quality Baseline

## Prerequisites

- Check out the target revision on the documented macOS/Linux environment.
- Install Elixir 1.20.3 and Erlang/OTP 29.0.6, then run `./scripts/check_toolchain.sh`.
- Start the repository PostgreSQL service with `./scripts/local_services.sh start` and wait with `./scripts/local_services.sh ready`.
- Install Hex/Rebar and fetch locked dependencies as documented in README.

The hosted workflow supplies its own ephemeral PostgreSQL. Neither environment requires production credentials, Redis for ExUnit, or a live football provider.

## Run the three local categories

From the repository root, run in order:

```bash
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
scripts/ci_unit_tests.sh
```

Expected outcome: each command exits zero; the test script displays the normal ExUnit result and confirms the unique marker emitted by `test/ci/quality_baseline_discovery_test.exs`. See [contracts/quality-baseline.md](contracts/quality-baseline.md) for exact scope.

## Validate before publication

Parse the workflow as YAML (not merely as text), then run the repository contract checks:

```bash
ruby -e 'require "yaml"; YAML.parse_file(ARGV.fetch(0)) or abort("invalid YAML")' .github/workflows/quality-baseline.yml
MIX_ENV=test mix test test/ci/quality_baseline_contract_test.exs
test/scripts/ci_unit_tests_test.sh
```

The contract check must cover eligible triggers, the exact toolchain and runner, read-only permission, revision-safe concurrency, PostgreSQL service, checkout, and the three labelled commands. It must reject failure masking, mutating formatting, narrowed test scope, secret/provider dependencies, and additional quality categories.

Run the conforming local categories above and every controlled negative below before Agentflow creates the feature commit, pushes it, and opens the PR. QA and final review may return `Verdict: PASS` when these checks pass. A hosted run cannot exist for an uncommitted workflow, so its absence is not a pre-publication blocker.

## Validate hosted behavior after publication

1. After Agentflow publishes the feature commit and opens a pull request targeting `main`, confirm the quality workflow starts for the current head SHA.
2. Confirm setup and the three labelled categories are visible and the overall job is green only after all succeed.
3. After merge, confirm a separate push run evaluates the resulting `main` SHA.
4. Update a PR twice and confirm an older superseded run can be cancelled without its result being presented as the newer SHA's result.

Record the PR-head run and integrated-`main` run as post-publication checkpoint evidence. They complement rather than replace workflow parsing, local parity, and controlled negative checks.

## Controlled negative acceptance

Use a disposable branch or temporary uncommitted edits, one case at a time. Do not retain the defects.

- Make a project source file unformatted; Formatting must fail and the file must remain unchanged.
- Add a harmless compiler warning in project-owned application/support code; Warnings as errors must fail.
- Add a warning to a temporary test file; Unit tests must fail due to warning-fatal test compilation.
- Add a failing assertion; Unit tests must fail and identify it.
- Temporarily rename/remove the discovery sentinel and run `scripts/ci_unit_tests.sh`; it must fail rather than certify an empty/incomplete baseline.

Restore each fixture before the next trial and confirm no fixture change remains in the working tree. Record the revision, exact toolchain, command, exit status, and relevant diagnostic. Do not claim coverage, SonarCloud, E2E, deployment, release, or architecture-check evidence from this task.

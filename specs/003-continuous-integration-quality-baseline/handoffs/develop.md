# Development Handoff

## Changes and decisions

- Added the single-job, three-category GitHub Actions baseline, fail-closed ExUnit wrapper/discovery sentinel, parsed workflow and shell contracts, and README parity instructions. See `.github/workflows/quality-baseline.yml`, `scripts/ci_unit_tests.sh`, `test/ci/`, `test/scripts/ci_unit_tests_test.sh`, and `README.md`.
- Created the task-required evidence artifact at `specs/003-continuous-integration-quality-baseline/verification.md` from fresh pinned-toolchain, PostgreSQL-backed positive and controlled-negative runs.
- Preserved Agentflow 2.2.1 hardening in `scripts/workflow_artifact_probe.py`, both workflow definitions, and `test/scripts/workflow_artifact_probe_test.py`. The develop gate now rejects checked tasks whose named file artifacts are missing.
- Kept hosted Actions evidence post-publication, per current human feedback; no workflow weakening or local-parity omission.

## Command outcomes

- Exact toolchain, locked dependency preparation, formatting, project warnings-as-errors, and the full wrapper suite passed; full suite: 19 tests, 0 failures, sentinel observed.
- YAML parse, focused workflow contract (4 passing), shell wrapper contract, probe regression (3 passing), and `git diff --check` passed.
- Every isolated negative failed nonzero with the intended diagnostic and was restored. Exact commands/statuses are in `verification.md`.
- Reconciled T001–T020 against every named file; all required artifacts exist and remain checked.

## Residual risks and QA guidance

- Hosted availability and cache-miss behavior cannot be proven before publication. After Agentflow opens the PR, bind the run to the PR head SHA; after merge, bind the push run to the integrated SHA and capture a cold-cache/equivalent miss.
- QA should independently rerun the README-order pinned commands with PostgreSQL, YAML/contract/wrapper tests, probe regression, and representative isolated negatives. Confirm fixture absence/restoration and exactly three enforced categories.

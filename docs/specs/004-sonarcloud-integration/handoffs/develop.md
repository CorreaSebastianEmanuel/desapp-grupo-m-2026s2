# Development Handoff

## Changes

- Added immutable-pinned SonarCloud CI in `.github/workflows/sonarcloud.yml` for every supported internal PR event and `main`, with exact-SHA checkout, native gate waiting, scoped concurrency, safe summaries, and categorized annotations.
- Added the dependency-free fail-closed gate in `scripts/sonar_checkpoint_gate.py`; it validates fresh `main` analysis identity, strict `open_issues`, the 0–9 boundary, bounded retries, and redacted failures.
- Added deterministic fixtures/tests under `test/scripts/` and repository contracts/oracle under `test/ci/`. Documented operation in `README.md`, the decision in `docs/adr/0001-sonarcloud-cp1-whole-project-gate.md`, and evidence in `verification.md`.

## Decisions

- Used repository-derived non-secret keys in `sonar-project.properties`; hosted organization/project binding remains maintainer setup because it is not yet present in SonarCloud's public project index.
- Kept `.github/workflows/quality-baseline.yml` byte-for-byte unchanged. PR count is explicitly current-`main` context; only `main` requires revision equality.

## Command outcomes

- Python gate suite: PASS (9 tests). SonarCloud contract: PASS (6 tests).
- Format and warnings-as-errors compile: PASS. Full CI unit wrapper: PASS (25 tests).
- YAML parse, `git diff --check`, secret-canary/mutable-pin scans, and baseline SHA oracle: PASS. See `verification.md` for exact commands and hash.

## Residual risks

- T031 and T032 remain unchecked: implementation was not authorized to publish a PR or merge. Hosted secrets, primary-branch selection, disabled automatic analysis, required-check configuration, profile identity, and the live 0–9 result are unverified.

## Exact QA guidance

Repeat every local command in `verification.md`. Then provision the documented SonarCloud/GitHub settings and validate T031 on an internal PR across `opened`, `synchronize`, `reopened`, and `ready_for_review`, including latest-head cancellation, exact SHA, two-click findings access, and failure classification. After authorized merge, validate T032 and record integrated SHA, analysis/compute ID, timestamp, native gate, profile names/keys, findings URL, and `open_issues` 0–9. Do not mark either task complete without that evidence.

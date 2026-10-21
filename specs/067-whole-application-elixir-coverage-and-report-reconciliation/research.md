# Focused findings — TASK-067

## Native export scope and error behavior

- **Decision**: retain Mix native exports, use only an opt-in output override and analyse every expected included-source module separately from CP1 summary filtering.
- **Rationale**: pinned local Elixir 1.20.3 source `lib/mix/lib/mix/tasks/test.coverage.ex`, `start/2`, `cover_compile/1`, `export_cover_results/2` instruments the project compile path and exports before summary ignore filtering. `generate_cover_results/1` applies ignore filtering later. Export failure logs an error, so exit zero alone is insufficient. Validate export presence/hash/import/population. Source inspected at the installed toolchain, not an archived feature implementation.
- **Alternatives considered**: broadening CP1's allowlist changes its denominator; relying on native HTML loses profile attribution; adding a coverage dependency is unnecessary.
- **Primary reference**: [OTP cover](https://www.erlang.org/doc/apps/tools/cover.html), specifically executable lines, export/import and line calls. The online page currently describes OTP 29.1.2; the repository uses 29.0.6, so installed pinned sources and native fidelity tests control version-specific behavior. Do not assume a later OTP implementation is identical.

## Existing normal partitions

- **Decision**: attach export flags to normal scheduled ExUnit invocations with unique names; never set `CP1_PROFILE_COVERAGE` for the new report.
- **Rationale**: `scripts/test_profile_runner.py:execute_exunit` currently groups unit once, splits regular integration from audit-owned committed-file invocations, prepares fresh database partitions, and bypasses this split in historical CP1 mode. `main` reconciles all native case events after cleanup and writes its own complete receipt. Keep those contracts and attach separate sidecars after success.
- **Alternatives considered**: reusing CP1 mode loses normal partitions; rerunning profiles solely for exports duplicates work; independently scheduling tests replaces the audited runner. Settled profile ownership remains ADR-0028 and `docs/TEST_PROFILES.md`.

## Source snapshot and current publication

- **Decision**: add separate run/content binding; preserve profile receipt schemas. Publish only an immutable validated run plus atomic current-attempt status.
- **Rationale**: existing receipts bind profile, nonce, counts and `config/test_profiles.json` hash but not the current source content. HEAD alone misses dirty inputs. `config/credo_inventory.json` includes maintained and archived excluded Elixir sources and is broader than the coverage denominator. An exact coverage-role inventory and fresh Git reconciliation resolve scope drift. Running/failed status cannot select a historical success as current.
- **Alternatives considered**: replacing profile receipts violates ownership; a `lib/**` glob silently classifies new files; overwriting the last successful report risks partial publication. ADR-0009 supplies the established snapshot/atomic-publication principle; ADR-0030 owns lint inventory. ADR-0031 records this feature's separate contracts.

All material unknowns are resolved. No settled technology research or research agents were needed. Remaining implementation details are reversible within the plan and must be validated by native and failure fixtures before final capture.

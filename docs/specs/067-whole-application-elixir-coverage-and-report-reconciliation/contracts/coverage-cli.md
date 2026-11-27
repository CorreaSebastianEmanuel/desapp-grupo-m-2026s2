# Application coverage tooling contract

No HTTP endpoints, application APIs or production configuration change.

## Public CLI

From repository root with existing pinned tooling, dependencies and test services:

- `python3 scripts/application_coverage.py preflight`: verify pinned BEAM/Node, Docker daemon/Compose, configured PostgreSQL and Redis, launch/close Chromium, build test assets and run `mix test.prepare` before discovery. Use `mix infrastructure.verify` for actual configured-service probes; container status alone is insufficient. Nonzero for missing/unready dependencies. Run `python3 scripts/test_inventory.py check` only after successful preparation to reconcile discovered cases. No profile or report publication.
- `python3 scripts/application_coverage.py run`: invoke preflight internally, reconcile scope, capture one unit and one integration profile via their existing wrapper, verify receipts, validate every expected native partition, generate and reread reports, recheck snapshot and publish. No second profile pair and no CP1 report invocation. Exit 0 only after complete publication and assertion-based report validation.
- `python3 scripts/application_coverage.py validate`: verify current status, run/report hashes, source snapshot, canonical inventories, partition membership and arithmetic by re-reading artifacts. Does not execute profiles or publish; no historical fallback. Exit nonzero on stale, running, failed, malformed or incomplete evidence.

Safe failure categories include `prerequisite`, `inventory`, `snapshot`, `profile-failure`, `partition`, `native-export`, `report`, `publication`, `lock`. Diagnostics identify logical profile/partition/path without raw child output, payloads or credentials. Signals preserve nonzero failure/incomplete state; successful cleanup cannot hide a test failure. CLI usage errors are nonzero. Default output root is `cover/application`; it cannot overlap CP1, JavaScript, profile receipts, source or symlink roots.

## Opt-in supervisor interface

`APPLICATION_COVERAGE_DIR` is an invocation-owned private absolute staging directory provided by the CLI, never shared with existing receipts. It causes unique export arguments at existing top-level ExUnit boundaries only. Configure Mix native output to this private directory without changing summary scope or default CP1 options. Refuse it when `CP1_PROFILE_COVERAGE=1` or conflicting CP1 output options are set. Without it the runner and Mix configuration behave exactly as before. E2E and nested test subprocesses do not collect new exports; the opt-in environment must be removed from recursive profile/native fidelity fixtures to prevent accidental recursion.

The owner writes separate sidecars only after complete native case accounting and cleanup; preserves the existing `CP1_PROFILE_RECEIPT` shape, status, inventory hash, counts and nonce. Unique export basename is bound to run, profile and logical partition. Existing `MIX_TEST_PARTITION` database selection remains independent. A zero exit without the exact expected valid native export fails coverage, even when its existing profile receipt is valid.

## Files

`cover/application/status.json` is current-attempt authority, governed by data-model.md. Each immutable `runs/RUN_ID/` contains `report.json`, escaped `report.html`, `measurements.md`, separate profile receipts/coverage sidecars and only the required native/normalized partition evidence. No old CP1/JS output or established receipt is overwritten. Publication lock and private staging precede immutable directory rename and atomic complete-status update.

Report JSON is authoritative; HTML and measurements must agree with its run/snapshot, aggregate integer counts, displayed percentage, all included per-file counts and all exclusions/reasons. `measurements.md` states actual measured results and limitations without a minimum threshold. Zero executable source files display N/A, not 100%. Native and JSON readers reject malformed types, duplicate keys/identities, foreign/missing partition, incorrect hashes, wrong snapshot, inconsistent line sets and changed current inventory. CLI `validate` recomputes arithmetic, does not merely read `status: complete`.

The native reader is invoked with `MIX_ENV=test mix run --no-start scripts/application_coverage_native.exs` with `--export EXPORT --modules MODULE_MANIFEST --output NORMALIZED_JSON` for one private export, expected compiled-module manifest and normalized output; it does not start the application or execute tests. Each import has fresh `:cover` state. Invalid input emits a safe category and exits nonzero with no accepted normalized output.

# Tooling data structures

No domain entity, database table or migration changes.

## config/credo_inventory.json (schema_version 1)

- `maintained`: sorted unique repository-relative `.ex`/`.exs` paths, exact membership expected from Git and Credo.
- `excluded`: sorted records `{path, category, reason}`; exact tracked paths only, nonempty specific reason. Initial category `archived-verification-evidence` applies only to individually listed historical specs probes. Generated/vendor/build categories require actual provenance and review, never maintained-root suppression.
- Reject unknown schema, duplicate paths, overlaps, stale records, absolute/parent-escaping paths, missing files, unknown categories and unclassified tracked Elixir paths. A reason cannot legitimize exclusion of a maintained baseline path.
- `--write-inventory` deliberately updates maintained entries only and preserves exclusions; normal reconciliation is read-only.

## tmp/credo-ci/evidence.json (schema_version 1)

Fields: `revision` (Git HEAD), `trigger_revision` (GITHUB_SHA or local HEAD), `dirty`, `source_digest`, `commands`, `credo_version`, `rule_level` (`default-priority`), `maintained`, `effective`, `excluded`, `cli_exit_status`, `oracle_exit_status`, `complete` (boolean), `status` (`passed`/`failed`), `limitations` (both required disclaimers), `errors` (safe failure categories).

Preserve sorted full path arrays without truncation. Include hashes of analyzer configuration, lock, inventory and observed source content in the digest. A different pre/post snapshot invalidates evidence. CLI failures may still have a complete oracle list but status remains failed; oracle failure means complete=false. Missing statuses are null, never inferred success. Publication is atomic; discard old output before a new attempt. Separate full text log accompanies JSON; no secrets or environment dumps.

Transitions: absent -> running -> passed or failed. Early process death may leave no JSON and must fail via command status/artifact absence. Previous passed output never survives into a new attempt.

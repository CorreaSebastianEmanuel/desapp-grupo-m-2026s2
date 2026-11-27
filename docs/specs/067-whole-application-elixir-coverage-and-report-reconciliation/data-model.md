# Coverage evidence structures

All new JSON structures use `schema_version: 1`, strict types, unique keys, normalized repository-relative paths and sorted unique identities. Paths cannot be absolute, traverse directories or resolve outside their declared root; no symlink output roots. Unknown schema versions fail. These are tooling files, not Ecto entities; no database migration.

## Coverage source inventory

`config/application_coverage_inventory.json`: `entries` containing `path`, `role`, `disposition` (`include`/`exclude`) and nonempty `reason`. Roles: `application`, `test`, `fixture`, `test-support`, `configuration`, `migration`, `script`, `root-tooling`, `archived-evidence`. Includes require role application, maintained membership in TASK-065 and `lib/` location. Other entries must be excluded with a role-specific per-path explanation. Every canonical maintained or excluded entry occurs once; canonical maintained/excluded classes are not coverage classes. Validate against Git and canonical inventory, including deletions and duplicates. Never auto-accept an unknown file.

## Run identity

Fields: `run_id` (UUID), `head`, `snapshot_algorithm`, `snapshot_digest`, toolchain identity, canonical/coverage/test inventory digests, `started_at`. Snapshot covers Git-listed tracked and nonignored untracked content including deletion markers, with explicit output exclusions and normalized task checkboxes as specified in plan. The digest is checked around every profile and before publication. Compiled-module manifest additionally binds module name, BEAM digest and actual source path/content hash; no old compiled object may silently substitute for current source.

## Profile and partition evidence

Expected partition: profile (`unit`/`integration`), logical partition ID (`main`, `regular`, or committed-file identity), selected file list/digest and export basename. Derive before execution from reviewed inventory and existing audit. Database partition is separate observed metadata. An absent optional regular partition is legitimate only when the precomputed regular file list is empty. Every scheduled partition is nonempty and mandatory.

Coverage sidecar: run identity, profile, profile receipt nonce/hash, expected partitions, and observed partition entries with native export path/hash, logical ID, selected-file digest, compiled-module manifest digest and completion. The supervisor generates these from actual successful invocations, then seals them after profile reconciliation/cleanup. No sidecar may authorize a failed profile. Check receipt expected/discovered/executed/passed counts, component counts and inventory digest using the existing verifier. Native bytes plus sidecar hash and same-source run identity are necessary, never sufficient without native validation.

## Normalized partition

Fields: run/profile/partition identity, export hash, source/module bindings and executable line records `(module, source_path, line, calls)`. Positive in-range source lines and nonnegative integer calls are required. Zero-executable files/modules are retained explicitly with evidence of successful native instrumentation/analysis. Unknown, duplicated or missing module/line populations fail. Same module must have identical executable population across partitions for the same snapshot. Compiler-generated non-source markers are labeled and excluded; they are not uncovered source lines.

## Reconciled report

Fields: `status: complete`, run identity, expected and observed profile partitions, receipt bindings, complete included/excluded source records, limitations and totals. Each included file retains module bindings, executable/covered/uncovered line identities, counts and percentage (`null` for proven zero executable lines). Excluded entries retain role/reason and no measured lines. Global identities are `(source_path,line)`; coverage is OR across valid observations, including legitimate multiple-module observations of one line. `covered + uncovered = executable`; counts must match set sizes. Aggregate percentage is `100 * covered / executable`, displayed to two decimals; preserve integer counts as authority. Whole report denominator must be nonzero. Native reports and normalized JSON are untrusted until validated; never trust submitted totals.

## Publication status

`cover/application/status.json`: attempt/run ID, `state` (`running`, `complete`, `failed`), snapshot, safe error category when failed; only complete adds immutable run-relative report path and hash. State transitions: absent/complete/failed → running → complete or failed. Crashed running remains incomplete. Existing run directories are immutable and historical unless selected by complete matching current status. Atomic current status is the only current-report authority. Concurrent writers fail on lock contention. A failed attempt does not rewrite historical successes and cannot fall back to them.

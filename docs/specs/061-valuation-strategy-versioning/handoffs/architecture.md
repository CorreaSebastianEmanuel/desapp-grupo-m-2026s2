# Architecture handoff — TASK-025

ADR-0023 resolves the critic's material findings. Exact storage preserves integer/Decimal evidence tags using typed coefficient/exponent strings; canonical equality, not numeric equality alone, is required after fresh-runtime reload. Database guards protect unused versions, metadata and history from ordinary update/delete/truncate paths. Formula dispatch remains a code-only allowlist.

Active selection is derived from the latest committed append-only change, serialized through one seeded protected lock row. Assign change order after locking; volatile direct insertion guards verify predecessors at READ COMMITTED and reject other write isolation to avoid stale pre-lock snapshots. This avoids pointer/log divergence. Expected-current remains configuration identity: delayed A requests can succeed after A→B→A. Test/document that limit rather than introducing revisions.

The plan's exact 29-path implementation inventory distinguishes lifecycle persistence from the inherited pure engine. Preserve old AST restrictions and feature allowances; extend only this feature's paths. No CI/profile/dependency changes or provider/web behavior.

Committed race/restart fixtures need isolated guarded test namespaces and distinct connections. Retain protected fixtures rather than disabling triggers for cleanup. Durability must use fresh BEAM application instances, not merely cached versions or a shared Sandbox. Parent harness retains the original descriptor; production descriptor retention remains TASK-026. Bulk permutations/numeric vectors stay in memory or ignored temporary files.

TASK-026 must protect the version/evidence binding, retain original descriptors, obtain intentional calibration and produce dated immutable quotes. TASK-027/033 retain exposure/ranking. No quote conversion, job, public management permission or preset is inferred here. This is a CP2 prerequisite, not full checkpoint completion.

No HTTP endpoint is affected, so the manifest needs service readiness but no HTTP runtime check. Owner executes all checks before independent QA. Full unit/integration profiles run once each per verification stage; do not add the historical CP1 report. Red tests permit corresponding source correction before retry; preserve attempts and avoid unchanged retries.

# Trusted internal synchronization contract

Target facade: `FootballMarket.Synchronization`. No public controller, route, new permission or CLI is introduced. Use existing trusted local IEx/application callers.

- `request_catalog(scope, options)` accepts trigger initial/manual (scheduled is internal scheduler only), explicit allowlisted source_ref, optional fixture_ref and trusted reconciliation instructions; optional valid finite policy overrides. Resolve and validate effective inputs before enqueue. Returns `{:ok, %{run_id: uuid, status: :queued | :executing | :retry_wait, disposition: :created | :coalesced}}` after durable commit, `{:error, %{category: :invalid_request, field: safe_field, recovery: safe_code}}`, `{:error, %{category: :scope_busy, run_id: uuid, recovery: :wait_for_active_run}}`, or `{:error, %{category: :store_unavailable, recovery: :retry_request}}`. No fabricated usable ID on failure.
- `get_run(run_id)` returns `{:ok, safe_run_with_numbered_attempts_and_triggers}` or safe not_found/invalid_request/store_unavailable.
- `list_runs(scope, options)` normalizes explicit scope and returns deterministic newest-requested-first history, UUID tie-break, bounded pagination (default 20, maximum 100). Invalid limits fail validation. No provider call for inspection.
- `configure_schedule(config_key, definition)` is trusted internal configuration, validating enabled/scopes/source/recurrence/policy before mutation. Disabled default; enabling without recurrence means `0 0 * * *` in UTC. Current configuration is applied on boot/reload; enabled generations persist across ordinary restart. Re-enabling/replacement opens a new interval; no pre-enable backfill.
- Internal `Scheduler.tick(now)` and `Recovery.reconcile(now)` use an injected UTC clock; public production callers do not supply provider runtime modules or arbitrary execution callbacks. Test seams are explicit and closed.

Inspection fields: run/scope/input identity and safe source/fixture attribution; original/coalesced triggers and due times; five run states; attempt numbers and known UTC times; accepted policy, next retry; closed safe categories/recovery codes; confirmed ingestion acceptance reference and distinct historical/applied counts. Unconfirmed attempts retain interruption, never synthetic success. Raw facts, exception stacks, source credentials, arbitrary transport options and secrets are excluded from job args, errors and output.

Completion outcomes preserve ingestion `accepted_with_changes`, `accepted_unchanged`, `replay`. Terminal reasons include non_retryable, exhausted, exhausted_unconfirmed, input_drift, missing_configuration; preserve safe provider category beneath the job-level reason. Drift/revocation never changes providers. Store/persistence failures remain distinguishable.

## Receipt extension

`Catalog.Ingestion.import_catalog/2` additionally accepts a validated optional `delivery_context` containing a prepared receipt UUID and fence. Publisher checks scope/fence and atomically confirms the safe Outcome for normal acceptance or replay. Invalid/revoked context fails safely without publication. Existing callers without context and existing provider request/result contracts are unchanged. No caller callback or raw source payload is persisted.

## Existing HTTP availability invariant

The runtime probe exercises existing authenticated `GET /api/players` and `GET /api/players/:id` over a real loopback listener, using fixture identities and credentials created within an isolated test scope. Assert 200, JSON content type and persisted player IDs/body before/during queued work and after denied/failed work; unauthenticated requests must retain their existing 401 behavior. Provider-call counters must stay zero for reads. Readiness must connect to PostgreSQL and wait for a real HTTP response, fail closed on unavailable services, and stop its listener/temporary runtime afterward. No endpoint behavior change is planned.

# Synchronization data model

PostgreSQL is authoritative. UUID identifiers, UTC microsecond timestamps; restrictive references and no cascade deletion of history. Prefix-aware migrations must qualify raw SQL consistently with the migration prefix. Exact names below are design targets.

| Table / schema | Fields and constraints |
|---|---|
| synchronization_runs / Run | id; operation=catalog; league_code/start_year/end_year normalized by Providers.Request; versioned canonical non-secret input material + digest; source_ref; fixture_ref/digest; original trigger; accepted attempt_limit/waits/timeout; state; requested_at/started_at/finished_at/next_retry_at; last safe reason/recovery; confirmed outcome/reference/attribution/counts. Partial unique scope index WHERE state IN queued,executing,retry_wait. Source and trigger are excluded from that key. Positive finite budget; valid state/time constraints. |
| synchronization_attempts / Attempt | id; run_id; unique(run_id, number); number positive <= snapshotted budget; delivery_id/job_id; start/finish; safe status/reason; interruption/unconfirmed marker; persisted wait/provider guidance. A prepared delivery has no numbered begun attempt until claim; preserve that distinction in Store. Begun evidence is never erased. |
| synchronization_triggers / Trigger | id; run_id; initial/manual/scheduled; request UTC; optional occurrence_id UNIQUE; no credentials. Repeated equivalent requests append associations without editing original trigger. |
| synchronization_schedules / Schedule | id; stable non-secret config key; generation; enabled; enabled_at/disabled_at; validated UTC five-field recurrence; normalized scope/input references. A per-scope definition and generation prevents cross-scope cursor loss. Generation changes on a new enabled interval or effective definition replacement. |
| synchronization_occurrences / Occurrence | id; schedule_id/generation/scope/due_at UNIQUE; pending/handled/superseded; run_id for handled; latest pending cursor and superseded range bounds/recurrence reference for compressed audit. Only latest pending candidate per enabled scope. Handled association is permanent even for failed runs. |
| catalog_delivery_receipts / DeliveryReceipt | delivery UUID; normalized scope; owner run/attempt opaque IDs; prepared/confirmed/revoked; fence UUID; confirmed safe ingestion Outcome, acceptance reference, UTC confirmation. Domain protocol does not load synchronization schemas. One receipt per prepared delivery, linked from attempt/job ledger; never stores raw provider result. |
| oban_jobs | Standard Oban migration schema; args only run/delivery IDs, queue=catalog_sync, max_attempts=1. Ledger job ID is not the run's domain result. No feature-history pruning. |

Prepared deliveries can be represented by receipt plus queued run/job before attempt numbering; do not create a fake attempt 0. Store allocates number and attaches receipt when execution actually begins, under run/receipt row locks. Delivery IDs uniquely prevent duplicate claim. Failed enqueue transactions leave no run, receipt, trigger or executable job.

## State transitions

`queued -> executing -> succeeded | failed | retry_wait`; `retry_wait -> executing` only at persisted eligibility and below budget. Before each begin allocate a new prepared receipt/job atomically if none exists. Confirmed receipts can finalize a run whose business result bookkeeping is incomplete. An executing orphan with no confirmation becomes interrupted; retry_wait if budget remains, failed/exhausted_unconfirmed otherwise. Terminal run history is immutable; deliberate manual work creates another run. Receipt prepared -> confirmed occurs only inside ingestion transaction; recovery may prepared -> revoked, and revoked receipts cannot publish. No transition infers success from Oban completed state.

Input material includes sorted typed mappings/new_players, source registry identity, fixture content digest and timeout. Digest equality also requires full canonical equality. Retry policy belongs to original run and is never overwritten by coalescing. Current access is validated separately from identity; credentials are never stored.

Do not add columns or writes to financial, quote, performance or freshness tables. Catalog acceptance remains owned by TASK-018; historical replay counts and currently applied zero counts are distinct in receipts and inspection.

Implementation representation: `synchronization_schedules.definition.previous_generations` retains old generation inputs, policy, recurrence and interval timestamps. Occurrences reference that generation for compressed supersession audit even after the current schedule definition changes. Prepared receipts and delivery jobs remain separate from numbered begun attempts.

# ADR-0025: Durable catalog run, attempt and occurrence coordination

**Status**: Accepted for TASK-019 design
**Date**: 2026-10-15

## Context

TASK-019 requires a finite budget including interruptions, confirmed publication, latest-only catch-up and immutable accepted inputs. Product challenge findings 1–4 identify a last-attempt lost reply, prolonged busy schedules, input drift and insufficient restart evidence. ADR-0013/0018/0019 remain authoritative for providers and publication; ADR-0016/0017 already mandate local Oban/PostgreSQL.

## Decision

Use PostgreSQL scope admission locks plus a partial active-run uniqueness constraint; keep a retained run/attempt/trigger ledger outside Oban's delivery state. Atomically enqueue each prepared delivery with its ledger changes. Use one-shot Oban catalog jobs; only the ledger allocates domain attempts and persisted waits. A supervised boot/periodic reconciler repairs delivery after interruption. Execution uses dedicated connection session locks for scope and bounded global slots, with monitored connection cleanup; no lock is left on a pooled connection. Recovery takes the same locks and revokes orphaned publication fences before another attempt. Domain replay remains necessary for exceptional redelivery.

Extend ingestion with an optional, validated neutral delivery receipt protocol. Record safe confirmed acceptance/replay in the existing publication transaction, under a receipt row lock that rejects revoked delivery fences. Recovery queries that receipt without another retrieval; attempt three can finalize confirmed success without a fourth attempt. Missing evidence becomes interrupted and either retries within budget or ends exhausted/unconfirmed with manual recovery guidance. Never infer acceptance from catalog contents. This bounded metadata extension does not alter reconciliation, delivery identity or the provider boundary.

Persist versioned canonical non-secret effective input material, full equality and fixture content digest. Recheck referenced input identity before every attempt; configuration drift fails safely. Resolve secrets only at execution and revalidate current access. Authorization is never snapshotted.

Persist schedule enablement generations, UTC due identity and a latest pending candidate per scope. Supersede older unhandled busy/downtime occurrences with compressed audit ranges; never later drain them individually. An occurrence associated with an equivalent run is handled even if that run fails. Disable/re-enable opens a new interval without backfill.

## Consequences and alternatives

More metadata and focused ingestion extension are required. Retain feature history without automatic pruning. Add real database races, terminated requester/worker/runtime tests, receipt fencing and final-attempt crash probes, all offline with independent expected results. Dedicated connection loss can expose redelivery; receipt fencing orders recovery against publication, and ingestion keeps its atomicity/stale/replay guards.

Oban uniqueness alone cannot deduplicate terminal occurrences or incompatible inputs. Oban automatic retry accounting cannot establish the authoritative begun-attempt ledger. Bare cron misses downtime intent; per-occurrence backlog replay violates latest-only catch-up. Fixture references without digests permit drift; secret snapshots retain obsolete authorization. Retrying retrieval after budget exhaustion violates the budget. Inference from catalog contents fabricates evidence. No new service, paid plugin, statistics, finance or public API is authorized.

Implementation details and exact inventory: [active plan](../../specs/063-scheduled-synchronization-jobs/plan.md). Product behavior remains [spec.md](../../specs/063-scheduled-synchronization-jobs/spec.md).

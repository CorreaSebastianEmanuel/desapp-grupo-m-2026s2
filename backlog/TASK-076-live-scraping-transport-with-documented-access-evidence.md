---
id: TASK-076
title: Live scraping transport with documented access evidence
type: task
checkpoint: CP2
priority: critical
workflow: thinflow-v1
status: todo
depends_on: TASK-016, TASK-055, TASK-056, TASK-019
active_run: none
---

## Outcome

Implement a real retrieval transport for the validated offline scraping pipeline (adapter task 016/055), preserving the deny-by-default policy. Scope: (1) an HTTP transport module fetching source documents per operation/scope, feeding the existing Assessment -> Source.read -> Translator -> provenance -> idempotent ingestion chain unchanged; (2) enabling is config-gated per assessed operation/league/season with documented access evidence (basis of permission, review date, documented request budget); without current evidence for a scope the transport refuses exactly like today (unsupported_capability, no contact). (3) Bounded behavior in production: retries/backoff reuse the shared synchronization policy, concurrency and volume limits enforced by the existing budget/lease machinery, and failure keeps local reads unaffected (invariant 6) while surfacing provisioning status. (4) Tests unit/E2E with recorded fixtures: deny paths (missing/expired evidence), one happy path per operation (catalog snapshot ingest, performances window ingest), budget exhaustion, and provider failure isolation. Demo plan for Nov 3 runs live for limited scopes with explicit fallback to fixtures. Out of scope: partial parsing of arbitrary pages beyond assessed endpoints; no scheduler expansion beyond existing cron/demand windows.

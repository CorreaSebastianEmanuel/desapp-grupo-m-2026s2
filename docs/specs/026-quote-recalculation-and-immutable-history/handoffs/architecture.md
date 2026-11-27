# Architecture delta — TASK-026

Resolved all three critic findings within approved scope. New ADR-0029 pins complete weekly membership in the existing acceptance transaction, defines one quote-keyed durable TASK-060 handoff, and separates valid no-score from terminal invalid/unsupported/unreproducible outcomes. See contracts for the exact matrix.

Local inspection found changed-ID-only intents, managed evaluation selecting current facts, and shared quotes without calculation linkage. Extend those existing boundaries; do not introduce another ingestion pipeline, scorer or quote store. Explicit mapping scale/version is mandatory; no production default or price floor. Original-membership evaluation requires a narrow managed entrypoint and a safe typed evidence codec, including no-score evidence.

Legacy intents without provable original membership fail explicitly rather than acquire today's membership. Freeze strategy/mapping once on first calculation start and persist before valuation fact reads; retries retain bindings. Separate request admission, logical identity, attempts and terminal results. Player-before-calculation locking, fenced leases and deferred linkage constraints protect atomic quote/result/event confirmation. TASK-060 owns effective consumption deduplication; events stay pending until that consumer exists.

Implementation guidance and boundaries are in plan.md; supporting details are in data-model.md and contracts/calculation.md. Complete tests first, then execute verification.json before independent QA. Runtime checks use fresh BEAM instances and service preflight; no affected HTTP endpoints. Run each full profile once per stage, with no historical CP1 coverage extra gate. No implementation/runtime checks were executed at architecture time.

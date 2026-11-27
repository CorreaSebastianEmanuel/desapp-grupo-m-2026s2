# Internal contract — Quotes calculation classification and orchestration

Source of truth: `specs/026-quote-recalculation-and-immutable-history/plan.md` (Admission and membership; Identity and scoring; Exact conversion and commit; Outcomes, attempts and recovery; TASK-060 handoff). This file collects the exact durable-category classification and the orchestration contract that the implementation, QA, and review must satisfy.

## Identity

- Unbound delivery requests have durable request IDs, not invented incomplete logical identities.
- A fixed calculation's unique canonical material is: player/season/week bounds + ordered immutable membership (kickoff, match identity, performance UUID) + saved configuration UUID/formula version + mapping UUID/version. Stored with a digest; conflicts compare material and fail safely on mismatch.
- Multiple import/explicit request IDs may link to one calculation. Effective time is excluded from identity; an exact retry returns the original outcome even after active selection changes.
- Imported requests resolve the active strategy exactly once at their first calculation start, before loading valuation fact values; the binding and mapping are persisted before evaluating and never re-resolved on retry.
- Legacy pending intents without snapshots must reconstruct original complete membership only from demonstrable retained acceptance evidence; otherwise record `unreproducible` and require a distinct explicit fresh request. Latest membership is never substituted.
- An unavailable mapping's supplied UUID remains inspectable as immutable `requested_mapping_id`, separate from the nullable authoritative FK. An identical retry retains its failure; any different mapping UUID conflicts. Unprovable legacy imports retain terminal per-scope requests derived only from original changed fact references, without a snapshot or fabricated configuration/mapping binding.

## Exact safe outcome mapping

| Input/result | Durable category | Retry? | Quote/event? |
|---|---|---|---|
| No accepted performances | no_quote / no_recorded_performances | No | Neither |
| Existing scorer insufficient_data, including missing required metric or no applicable required scope | no_quote / insufficient_data | No | Neither |
| Unknown metric keys, malformed request/identity/rules, inconsistent incoming membership or invalid mapping | validation_failed / whitelisted reason | No | Neither |
| Missing active selection or saved configuration/mapping | validation_failed / configuration_unavailable or mapping_unavailable | No | Neither |
| Unsupported saved formula/strategy | unsupported_strategy | No | Neither |
| Original retained fact/rule/mapping unavailable, modified or unverifiable on evaluation/replay | unreproducible / original_unavailable or evidence_mismatch | No | Neither |
| Valid score <= 0 | no_quote / nonpositive_score | No | Neither |
| Positive score converts to rounded cents <= 0 | no_quote / nonpositive_converted_result | No | Neither |
| Valid positive converted cents | successful | No | Both, atomically |
| Temporary DB/worker unavailability before confirmation | retrying / temporarily_unavailable in attempt | Yes, <=3 attempts | Neither new effect |
| Third transient failure or interruption | exhausted / retry_exhausted | No | Neither new effect |
| Committed result with lost acknowledgement | Return same immutable outcome | Recovery only | No duplicates |

Unknown position accepted under TASK-021 remains subject to TASK-025/valuation existing validation: preserve its returned kind, never manufacture a supported position. Input inconsistency is validation failure; inconsistency of retained originals is unreproducible. Store safe categories and whitelisted reasons only.

## Conversion

- `Quotes.Mappings.save(name, version, explicit_scale)` saves an immutable trusted mapping; no activation, public management, or production preset. `get(uuid)` retrieves it. Invalid scale/rounding → validation failure. Changing the scale is a new mapping version.
- score × positive finite scale → round to integer cents, ties away from zero, two-decimal Decimal, no ambient-context truncation.
- score <= 0 or rounded cents <= 0 → `no_quote` without price or floor. Negative products cannot arise from positive inputs; negative raw scores and negative scales are tested as invalid separately.

## Mutable vs protected projections

- Mutable fenced projections: pending/running state, retry schedules, lease/fence counters.
- Protected: identity/bindings, every attempt record, terminal evidence/result.
- Three attempts maximum; retry delays 60 s then 300 s for temporary persistence/worker failure only. Attempt reservation persists before work; five-minute lease; monotonically increasing fence. Recovery records interrupted attempts before rescheduling, exhausted included on the third interruption. Expired workers cannot confirm or overwrite a newer outcome.
- Confirmation always locks player before calculation; claiming only locks the calculation briefly and releases before a player lock. Caller-owned transaction nesting is rejected for APIs claiming durable confirmation.
- Recovery and Oban enqueue are durable/idempotent via durable rows, not Oban uniqueness alone; a killed worker cannot strand pending/running state or change import acceptance.

## Safety and diagnostics

Reason enums are whitelisted only; no raw provider payloads, exception text, executable modules, arbitrary atom decoding, or credential-bearing logs. A storage outage that prevents recording leaves the previously durable pending/leased request recoverable; a recorded temporary error is never claimed when its write failed.

## TASK-060 handoff

- One immutable evaluation request per committed quote, stable idempotency key `quote-evaluation:<quote_uuid>`.
- `Quotes.pending_evaluations(opts)` exposes immutable event ID, quote UUID, player UUID, calculation UUID and the stable key. Lease/attempt and `acknowledge_evaluation(event_id, fence, consumer_receipt)` retain safe delivery state separately. Duplicate matching acknowledgement is idempotent; conflicting/stale fence fails. Abandoned lease becomes pending.
- Without a configured consumer, no event is acknowledged or discarded; pending requests survive indefinitely. At-least-once delivery with exactly one durable request; TASK-060 must atomically deduplicate effective evaluation by quote UUID in its own transaction and acknowledge only after durable consumption.

## HTTP applicability

No HTTP endpoint is introduced or modified; this is an internal contract, so no HTTP assertion check applies. Runtime checks must still fail on unavailable PostgreSQL/Redis and assert durable quote/evidence/follow-up after fresh application restart, recovery after import commit, and unchanged financial state. Any future HTTP change must first align spec/plan/contracts/manifest and add readiness plus status/header/body assertions before QA.

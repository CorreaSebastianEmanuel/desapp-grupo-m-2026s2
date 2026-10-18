# Data model — TASK-026

Names are implementation targets; all UUID references are restrictive on update/delete. No destructive backfill or mutation of protected legacy rows.

## Existing stores

- `statistics_calculation_intents` and `valuation_calculation_requests`: preserve intent/check/changed-ID identity and delivery compatibility. Add child snapshots and request links rather than overwriting old immutable identities.
- `market_quotes`: add nullable `calculation_id`, saved configuration/mapping identity and per-player `performance_sequence`. Initial issuance keeps existing columns/rule and null new fields; treat its sequence as zero in reads. New performance rows require all fields, unique calculation ID and unique player/sequence; exact finite positive cents only. Keep initial partial unique index, immutability triggers and issuance constraints.
- Existing player lock is the financial write serialization boundary (ADR-0024). No holdings or issuance changes.

## ImportScopeSnapshot / SnapshotFact

Snapshot UUID, existing intent/check UUIDs, player/season UUIDs, UTC week bounds, schema version, canonical membership material/digest, recorded time. Unique intent/player/season/week. Child rows reference each original performance and match and retain canonical ordinal plus typed exact Fact snapshot; unique snapshot/performance and snapshot/ordinal. Membership covers the complete accepted week after this acceptance, not just changed IDs. Facts sort by kickoff, match identity, performance UUID; derived position groups remain strategy-dependent and are not fixed here. Empty membership is valid only for explicit trusted no-data requests, not a fabricated changed-import scope.

Immutable UPDATE/DELETE/TRUNCATE guards and FK protection; never retain raw provider payloads. New snapshots commit in import acceptance. Existing intents lacking provable original full membership receive a safe unreproducible outcome; no latest-membership backfill.

## QuoteConversionMapping

UUID, mapping name, version, schema version, canonical exact positive finite scale, rounding `two-half-away-v1`, created_at. Unique name/version. Scale uses typed coefficient/exponent representation with exact numeric conversion as needed; no float or arbitrary fixed precision. Immutable including metadata. No production mapping seed. Explicit trusted save rejects duplicate conflicting version, zero/negative/nonfinite scale and unsupported rounding.

## QuoteCalculationRequest

UUID; import request/snapshot lineage or explicit origin; subject/week; strategy selector; mapping selector; fixed configuration/mapping UUIDs after first binding; calculation UUID once canonical identity exists; requested_at. Immutable origin/scope/snapshot and write-once bindings. Separate safe projection: pending/running/retrying/terminal, lease expiry/fence, attempt_count, next_attempt_at, safe reason. Import acceptance remains accepted regardless of this projection. Explicit requests use a supplied request UUID for retrying admission, plus canonical identity for cross-request deduplication. A malformed subject/selector fails validation without inserting invalid UUID/scope rows; well-formed requests with unavailable rules/mapping retain terminal failure.

## QuoteCalculation / CalculationAttempt / CalculationResult

Calculation: UUID, player/season/week, full canonical membership material and digest, configuration UUID/formula version, mapping UUID/version, created_at. DB unique canonical identity (digest index with material equality verification on conflict); identity immutable. Multiple requests can reference it. Separate lockable execution projection coordinates one owner/fence.

Attempt: UUID, request/calculation where available, ordinal 1..3, fence, started_at; append immutable completion record with safe category/reason/time. Never edit an earlier attempt to conceal failure. An interruption consumes its reserved ordinal. Pending/running projection may change; terminal result never does.

Result/evidence: one immutable terminal result per calculation, status (`successful`, `no_quote`, `validation_failed`, `unsupported_strategy`, `unreproducible`, `exhausted`), safe reason, effective_at, exact score when available, exact unit_price only on success, original managed descriptor when available, typed rules and fact snapshots/membership, exact mapping identity/scale/rule, codec version. No-score retains nullable score and complete available inputs. Missing original admission bindings are recorded at request level, not represented as a complete calculation identity. Retryable temporary errors live in attempts, not immutable terminal results. Result lookup reproduces committed retries.

Codec uses whitelisted schema-1 structural tags, UUIDs, UTC instants, integer strings and normalized Decimal sign/coefficient/exponent; no arbitrary atoms/modules/term deserialization. References are verified against protected originals on replay, including rules and retained mapping. Evidence mismatch/missing originals fails explicitly. Database constraints link result, calculation and quote across matching player/configuration/mapping identities. Ordinary direct UPDATE/DELETE/TRUNCATE of bindings, snapshots, mappings, calculation identities, evidence, results, attempts and quote events fails. Write-once binding enforcement allows exactly the initial null-to-fixed transition.

## QuoteEvaluationRequest / DeliveryAttempt

UUID, quote UUID (unique), player UUID, calculation UUID, stable key `quote-evaluation:<quote_uuid>`, schema version and created_at; immutable core. Deferred constraint requires exactly one matching request for every performance quote and prohibits events for non-success results. Quote/result/event are committed together. Initial issuance does not create this event.

Separate delivery projection and append-only attempts contain pending/leased/acknowledged, lease/fence, safe reason and acknowledgement identity/time. TASK-060 owns effective-work deduplication keyed by quote UUID and calls acknowledgement after durable consumption. Without consumer, remain pending. Pending index supports recovery; no automatic claim of delivery success or conditional-order execution.

## State transitions and ordering

Admission -> pending -> running(fence, attempt) -> successful/no_quote/terminal failure, or retrying -> running, or exhausted after three attempts. Expired running -> interrupted attempt -> retrying/exhausted. Stale fence cannot finalize. Existing terminal logical result wins over duplicate requests and lost acknowledgement. New membership/configuration/mapping -> different identity even with equal price.

Confirmation locks player then calculation, samples DB UTC effective_at and allocates performance sequence under player lock. The lease claim transaction never waits for a player while holding calculation lock. Deferred cross-table constraints prohibit orphan successful result/quote/event and mismatched links. No successful return inside caller-owned outer transactions. Replay is read-only and original-bound, independent of current active configuration, later membership, provider availability or worker state.

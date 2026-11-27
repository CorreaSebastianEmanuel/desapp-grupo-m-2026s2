# External provider resilience

## Outcome

Provider-backed ingestion reports bounded operational signals and retries only transient failures. Access refusal and malformed provider data stop after the current attempt and never produce imported partial data. Local catalog and statistics reads remain independent of provider availability.

## Acceptance

- [ ] Provider HTTP operations emit one telemetry event on completion with provider, operation, normalized outcome, and elapsed duration. Labels use fixed allowlists; events contain no source payload, credential, URL, or raw exception.
- [ ] Successful catalog and scouting provider responses retain their existing normalized result and persistence behavior.
- [ ] Oban catalog sync retries only transient provider failures, with at most the worker's configured three attempts. Rate limiting, timeout, transport failure, and service unavailability are retryable. Access refusal, missing configuration, malformed responses, and invalid requests are terminal and do not enqueue a retry.
- [ ] Malformed provider response shapes return `:invalid_response` without raising or yielding partial catalog/player-match results.
- [ ] Provider failure leaves already persisted local records unchanged, and local reads make no provider request.
- [ ] Focused automated tests cover success, transient failure, access refusal, malformed data, safe telemetry metadata, and bounded metrics labels.

## Scope

- Add provider request telemetry and Prometheus metrics for request count and duration.
- Classify catalog-sync provider failures as retryable or terminal while retaining the existing Oban attempt limit.
- Harden current provider parsing against malformed nested response shapes and partial results.
- Add focused tests for the behaviors above.

## Non-goals

- Provider selection/configuration changes, new data sources, provider contract changes, new fallback behavior, retries or sleeps inside adapters, circuit breakers, rate-limit scheduling, persistence changes, and unrelated observability or product work.

## Risk

- Provider error classification changes job state: permanent errors become discarded immediately, while transient errors retain the existing bounded retry policy. Metrics expose only fixed provider, operation, and outcome values; no high-cardinality or sensitive labels are permitted.

## Decisions

- Follow TASK-016's boundary: retries belong to ingestion jobs, not adapters. Existing catalog-sync `max_attempts: 3` is the retry ceiling.
- Treat `rate_limited`, `timeout`, `unavailable`, and transport errors as transient. Treat access refusal, missing configuration, invalid request, and invalid response as terminal. Unknown errors fail closed as terminal.
- For catalog HTTP responses, map 401/403 to `access_refused`, 429 to `rate_limited`, other 4xx statuses to terminal `invalid_request`, and 5xx statuses to transient `unavailable`.
- Instrument the actual external operations with bounded labels and elapsed time. Do not log or attach payloads, credentials, URLs, or raw transport details.
- Use existing local persistence as the safe fallback for reads; provider failures never cause a remote request from a local read.

# ADR-0014: Football-Data Evidence and Request-owned Transport

**Status**: Accepted within TASK-017 architecture
**Date**: 2026-10-06

## Context

TASK-017's product challenge identifies season ambiguity, stale transfers, request quotas, credential containment and misleading CP2 evidence. The approved product decision permits conservative refusal, not reconciliation or new performance semantics. ADR-0013 owns the unchanged consumer boundary; ADR-0002 owns current affiliation.

## Decision

Collect sequentially: competition discovery, season-filtered team list, each team detail, each supplied player's person detail, then competition discovery again. Discovery must identify the requested competition and exact season years; its current season must equal that season. Team details must identify the listed team and requested running competition. Every person must identify the supplied player and have `currentTeam.id` equal to the enclosing squad's team. Preserve every supplied player; contradiction or absent evidence invalidates the entire catalog. Existing historical seasons return unsupported-capability before collection. Absent accessible seasons return not-found.

The [competition](https://docs.football-data.org/general/v4/competition.html), [team](https://docs.football-data.org/general/v4/team.html) and [person](https://docs.football-data.org/general/v4/person.html) resources supply the chosen evidence. Inference: bracketing unchanged source-declared current-season identity plus documented current-season team semantics establishes a source snapshot for that season. It does not establish an atomic roster snapshot or independent real-world freshness. `lastUpdated`, retrieval time, contracts and running competition alone never prove present player affiliation. A player present only in an old team's roster fails when person evidence disagrees; missing person access fails with its observed access category. Do not filter or repair transfers.

Use a direct Mint `~> 1.11` dependency, locked during implementation, for HTTP/1 connections controlled by the existing retrieval worker. This is a bounded dependency addition, not a service or stack replacement. Fixed live HTTPS origin `api.football-data.org:443`, TLS peer/hostname verification, explicit OTP trust roots, numeric resource identifiers, fixed routes, no redirects/proxies/retries and no source-selected URLs. Close connections on every ordinary terminal path; abrupt worker death must also close owned sockets. Real TLS tests independently observe peer closure after timeout/caller exit; worker death alone is insufficient evidence. [Mint ownership and TLS options](https://mint.hexdocs.pm/Mint.HTTP.html), [OTP trust roots](https://www.erlang.org/doc/apps/public_key/public_key.html#cacerts_get/0).

Test-only transport configuration is accepted only in the test environment: loopback IPs, ephemeral port, synthetic token and local CA/hostname. Production cannot activate an override. Connection failures are classified without reflecting/logging raw exceptions, headers or bodies.

Request cost is `3 + T + P` for T supplied teams and P supplied players. A hypothetical 20-team/500-player example costs 523 requests, averaging under 9.56 ms per request to finish inside 5 seconds, before translation/validation. This is an illustrative feasibility bound, not measured latency or a league-size promise. [Source quota policy](https://docs.football-data.org/general/v4/policies.html) means ordinary account limits can prevent completion. Return observed rate-limited/timeout; never sleep, retry, cache portions or purchase access. Larger valid caller budgets do not bypass quotas. Bulk teams cannot eliminate independent affiliation verification, so its uncertain squad completeness is not a success assumption.

## Consequences and alternatives

Successful synthetic catalogs establish conditional compatibility, not live usability or CP2 statistics-to-quote completion. TASK-021 must assess performance-source suitability separately. No product invariant, persistence schema, route or permission changes.

Rejected: bulk-only or squad-only membership (stale-transfer ambiguity), fabricated season discriminators (false evidence), parallel fan-out (more cancellation/quota complexity), pooled clients (ownership harder to prove), manual HTTP parsing (unnecessary protocol/security work), retries/quota waiting (outside specification).

Existing provider/statistics worktree guards require exact TASK-017 path allowances while this feature is active. Preserve all old checks and fixture fingerprints; permit only Mint/dependency/bootstrap additions and named adapter/configuration/test files. This test-only maintenance is not permission to weaken production boundaries.

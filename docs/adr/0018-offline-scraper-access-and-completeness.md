# ADR-0018: Offline scraper with explicit access and completeness evidence

**Status**: Accepted for TASK-055 design; actual live activation blocked
**Date**: 2026-10-07

## Context

TASK-055's approved product decision allows offline delivery. The critic identifies hypothetical mappings, unfalsifiable completeness, aggregate access limits and misleading CP2 readiness. ADR-0013 remains the provider contract; ADR-0016/0017 and TASK-021 feedback prohibit a second boundary or invented substitute-position frequency.

## Decision

Use one FotMob-shaped source translator behind merged Providers. Ship a read-only fixture transport and a deny-only live transport, with no network client or default provider switch. A configuration boolean cannot authorize access. Tests simulate valid assessments and aggregate admission through a transport port; they never authorize external access.

A later concrete live transport must demonstrate applicable permission, fact/season coverage, safe allowlisted destinations, revalidation before each portion/publication and atomic admission under all cadence, volume and concurrency limits across callers. No usable shared admission mechanism means no activation. Revisions invalidate in-flight work; redirect following is disabled unless each destination is explicitly assessed. Caller workers own retry scheduling, never access authorization.

Require independent scope and terminal-collection witnesses, with assessment evidence references and explicit detail coverage. HTTP success, league team counts and an empty array alone cannot prove completeness. Missing detail differs from a published empty supplied-performance collection. Completed matches with no supplied performances remain valid under TASK-016. FotMob's actual full roster and performance witnesses remain unverified.

Distinguish observed shapes, synthetic shape-preserving mutations and hypothetical completeness/field semantics in the inventory. No fictional source field is invented merely to provide required minutes/positions. Optional derived statistics remain unknown without complete evidence; no event-reconstruction algorithm is added. Current profile position never fills historical position. Fixture success cannot promote a live assessment.

## Consequences and alternatives

Delivery can pass offline while usable live statistics remain blocked; CP2 demos label fixtures and downstream tasks retain access/position-policy work. Tests use independent football-fact oracles and preserve the merged corpus.

An unrestricted HTTP client with scheduler-only limits could initiate unauthorized concurrent work. Treating current rosters/match samples as complete would mislead ingestion. Replacing the source or relaxing positions changes product scope and requires a separate decision. A dedicated distributed limiter/service is premature while access is absent; it is not introduced here.

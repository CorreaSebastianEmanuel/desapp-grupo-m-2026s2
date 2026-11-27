# Feature Specification: Scheduled Synchronization Jobs

**Feature Branch**: `019-scheduled-synchronization-jobs`

**Created**: 2026-10-15

**Status**: Draft — ready for independent product challenge.

**Task**: TASK-019 · CP2 · depends on TASK-002 and TASK-018.

**Input**: Run local initial, manual and scheduled catalog synchronization with durable history, deduplication and bounded retries. Preserve domain idempotency and reuse the job infrastructure for later statistics and conditional-order workers.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Request and Inspect a Catalog Synchronization (Priority: P1)

As a trusted local operator, I can request initial or manual synchronization for an explicit league season, continue using the local catalog, and inspect the eventual result without keeping the requesting process alive.

**Why this priority**: Catalog maintenance must survive request termination and must not block market reads.

**Independent Test**: Request an offline fixture synchronization for an empty scope, terminate the requester, execute the pending work and inspect its persisted outcome and local catalog.

**Acceptance Scenarios**:

1. **Given** valid explicit scope and source configuration, **When** the operator requests an initial load, **Then** the system returns a durable run identifier and queued status without waiting for retrieval; the worker eventually publishes the catalog through TASK-018 and records its acceptance reference and counts.
2. **Given** an existing catalog, **When** a manual update accepts changed, unchanged or replayed data, **Then** history distinguishes those outcomes, identifies zero applied changes for replay, and retains provider and fixture attribution supplied by ingestion.
3. **Given** an invalid scope, missing required source configuration or invalid execution policy, **When** a request is made, **Then** a safe validation error is returned before provider work or creation of executable work; no successful enqueue is reported.
4. **Given** the durable job store is unavailable, **When** enqueue is attempted, **Then** the request reports unavailability rather than a usable run identifier; existing local catalog data is not modified.
5. **Given** a source failure or running job, **When** a user searches or reads local player details, **Then** existing records remain readable and the read initiates zero provider requests.

---

### User Story 2 - Synchronize on a Controlled Schedule (Priority: P1)

As a local operator, I can enable periodic synchronization for configured scopes without manually issuing every request or generating a backlog storm after downtime.

**Why this priority**: Repeatable local operation must be safe when the application is stopped and restarted.

**Independent Test**: Advance a controlled clock across due instants and a simulated outage; inspect generated runs, scope boundaries and recorded trigger information.

**Acceptance Scenarios**:

1. **Given** an enabled valid schedule, **When** its due instant is reached while the application and durable store are available, **Then** one synchronization is requested for each configured scope and records its scheduled origin and UTC due instant.
2. **Given** disabled scheduling or an unconfigured scope, **When** a due instant passes or the application restarts, **Then** no scheduled job or implicit initial import is created for that scope.
3. **Given** several missed occurrences during downtime, **When** execution resumes, **Then** at most one catch-up synchronization is requested per enabled scope for the latest missed occurrence; older missed occurrences are not replayed individually.
4. **Given** two scheduler invocations for the same due occurrence, including after restart, **When** both request work, **Then** at most one new run is created; an already handled occurrence does not create another run even if its run is terminal.
5. **Given** a schedule is disabled after work was durably accepted, **When** the scheduler next checks, **Then** no new scheduled runs are created; already accepted work retains its execution and retry policy.

---

### User Story 3 - Recover Safely Without Duplicate Effects (Priority: P1)

As a local operator, I can rely on repeated requests and recoverable failures without duplicate catalog identities, hidden endless retries or lost accepted work.

**Why this priority**: Durable delivery implies redelivery; queue deduplication alone cannot protect domain state.

**Independent Test**: Submit concurrent requests, inject retryable and terminal outcomes, restart during execution and simulate a lost reply after domain publication, using independently authored offline expectations.

**Acceptance Scenarios**:

1. **Given** ten concurrent equivalent initial, manual or due scheduled requests for the same scope, **When** admitted, **Then** all reference one active run, only one normal execution is admitted for that scope, and trigger differences do not bypass deduplication.
2. **Given** an active run waiting, executing or awaiting retry, **When** another request for that scope has different effective source, fixture or reconciliation instructions, **Then** it receives a safe scope-busy conflict identifying the active run; it neither changes that run nor silently adopts incompatible settings.
3. **Given** a retryable failure followed by success, **When** the configured wait elapses, **Then** the same run gains another numbered attempt and ultimately records success; the earlier failure and wait remain inspectable.
4. **Given** repeated retryable failures, **When** the total attempt limit is reached, **Then** the run becomes failed with exhaustion reason and no further automatic attempt occurs. A later deliberate manual request can create a new run without rewriting the failed one.
5. **Given** invalid data, reconciliation conflict, stale observation, unsupported capability or denied source access, **When** ingestion reports the outcome as non-retryable, **Then** the run becomes failed immediately with safe recovery guidance and no automatic source fallback.
6. **Given** queued work, a persisted retry wait or an interrupted attempt, **When** the application restarts, **Then** accepted work remains discoverable and recovers without a second caller request, honoring remaining delay and the total attempt limit; interruption is visible rather than reported as success.
7. **Given** catalog publication committed but completion recording was interrupted, **When** delivery is repeated, **Then** domain reconciliation prevents duplicate identities or rollback of newer facts; history records only a confirmed result and does not fabricate the missing attempt's outcome.
8. **Given** Redis is absent, cleared or restarted, **When** requests and retries execute, **Then** job admission, history, deduplication and catalog correctness are unaffected.

### Edge Cases

- Deduplication covers a league season's catalog operation across all trigger types; different league seasons remain distinct. A retry wait remains active work.
- A future schedule definition is not an active run and does not prevent a manual request before it is due.
- A due occurrence coalescing into an equivalent active run is durably associated with that run. If incompatible active work blocks it, the occurrence remains due for later admission; it is not marked handled or allowed to alter the active run.
- Accepted unchanged and complete empty imports are successes; they do not imply statistics freshness or new quotes. Replay counts describe historical evidence separately from changes applied now.
- A crash before domain publication leaves no partial catalog. Redelivery after publication must still use domain replay/reconciliation protections even if a duplicate worker escapes normal queue coordination.
- Retry guidance longer than the local backoff delays the attempt; no worker retries early to satisfy a nominal schedule cadence.
- Source credentials and raw payloads never appear in job arguments, history, errors or inspection output. Source configuration is referenced without embedding secrets.
- Invalid schedule configuration is reported explicitly and cannot fall back to another provider or trigger live requests.
- Scheduler downtime does not promise real-time execution. Recovery does not recreate work for disabled scopes or turn startup into an unconditional import.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST support explicit initial-load and manual catalog requests and configurable recurring requests for supported league seasons. Each accepted request MUST durably establish pending work before acknowledging it with a run identifier. Request acceptance MUST NOT wait for provider retrieval or catalog publication. Initial load is an explicit request, not an import on every startup.
- **FR-002**: A request MUST identify a normalized supported league season and explicit effective source configuration. It MUST validate request and scheduling policy before creating executable work. It MUST reuse TASK-016 request rules and TASK-018 trusted reconciliation inputs; names or user search text MUST NOT become retrieval scopes. Provider selection MUST NOT change automatically.
- **FR-003**: Workers MUST delegate catalog retrieval and publication to [TASK-018](../057-idempotent-catalog-ingestion/spec.md), preserving its atomicity, identity, revision, replay, stale/conflict handling, safe provider outcomes, lineage and counts. Workers MUST NOT introduce an alternative import/provider boundary or modify domain reconciliation to make a job succeed.
- **FR-004**: As explicitly required by this task and the architecture, jobs and durable execution history MUST reside in PostgreSQL and execute through local Oban within the application. Redis MUST NOT own jobs, processed state, deduplication or recovery. Accepted pending work and history MUST survive application and Redis restarts. No new broker or cloud service is introduced.
- **FR-005**: At most one active catalog run MUST be admitted per normalized league season, across source choices and trigger types. Equivalent requests MUST return the existing active run; incompatible effective source, fixture or trusted reconciliation settings MUST return scope-busy without mutation. Equivalent means the same normalized scope and effective import inputs regardless of trigger or collection order in equivalent instructions. Active includes queued, executing and retry-wait states; completed or failed runs MUST NOT permanently suppress new deliberate requests.
- **FR-006**: The scheduler MUST support an explicit enabled/disabled setting, validated recurrence and configured scopes. Scheduled time MUST be interpreted and recorded in UTC. It MUST durably deduplicate each scope and due occurrence across repeated scheduler invocations and restarts, including when equivalent active work absorbs that occurrence. Blocked incompatible work MUST leave the occurrence eligible for later admission. After downtime, only the latest missed occurrence per enabled scope MUST be caught up; continuous operation then follows the configured recurrence.
- **FR-007**: Scheduling MUST default to disabled. Enabling it without a cadence override MUST use daily 00:00 UTC. Initial/manual requests MUST remain usable with scheduling disabled. Disabling scheduling MUST stop future admission without cancelling accepted work. The scheduler MUST NOT initiate work merely because an unconfigured scope has no catalog.
- **FR-008**: Each run MUST expose durable queued, executing, retry-wait, succeeded or failed state, with numbered attempts and UTC request/start/finish times where known. History MUST retain scope, effective non-secret source reference, original trigger and coalesced trigger/occurrence associations, configured attempt limit, next retry time, safe outcome/reason, and ingestion acceptance reference, attribution and counts when available. An interrupted attempt MUST be identified as interrupted or unconfirmed, never inferred successful.
- **FR-009**: Successful outcomes MUST distinguish accepted-with-changes, accepted-unchanged and replay. Failure inspection MUST distinguish non-retryable failure, exhausted retries and interruption/recovery, preserving safe ingestion/provider categories and recovery guidance. Invalid requests and store-unavailable responses MUST be distinguishable from accepted runs. Inspection MUST work through a trusted internal/local interface by run identifier and scope; a web endpoint, dashboard and new permission model are excluded.
- **FR-010**: The worker MUST automatically retry only outcomes declared retryable by the provider contract and transient persistence/concurrent-change or execution interruptions. Each retry MUST be a fresh domain attempt, honoring ingestion's revision capture and replay protections. Stale data, invalid facts, reconciliation conflicts, unsupported capability and access denial MUST NOT be automatically retried as transient failures. Unclassified failures MUST fail safely without an unbounded loop.
- **FR-011**: Execution policy MUST have a positive finite total attempt limit, including the first attempt and interrupted attempts that began execution. Defaults MUST be three total attempts, waiting at least one minute before the second and five minutes before the third. Any valid provider minimum retry delay MUST take precedence when longer. Configurable alternatives MUST remain finite, with positive retry waits. Waiting MUST release execution capacity; exhaustion MUST stop automatic execution and remain visible. A restart MUST NOT reset the budget or shorten the remaining wait.
- **FR-012**: Catalog execution concurrency MUST be bounded, defaulting to one executing catalog attempt locally. Admission coordination MUST prevent normal overlapping execution of one scope; redelivery and interruption MUST still rely on TASK-018 domain invariants rather than a claim of exactly-once delivery. Independent scopes MUST retain separate runs, outcomes and retry budgets. Scheduling MUST NOT bypass TASK-055's source admission/access controls.
- **FR-013**: Publication success MUST be recorded only after confirmed domain acceptance. Queue/completion bookkeeping failure MUST NOT undo accepted catalog data, report an unconfirmed success or lose recoverable work silently. Local reads MUST remain independent of provider availability. History MUST survive terminal completion and MUST NOT be automatically pruned in this CP2 feature; later retention changes require their own policy.
- **FR-014**: [TASK-055 access gates and fixture lineage](../../docs/adr/0018-offline-scraper-access-and-completeness.md) MUST remain intact for every trigger and retry. Offline execution MUST require zero live calls or credentials; live denial MUST stay explicit. A schedule, configuration flag or fixture success MUST NOT grant live access. TASK-017 MUST remain an explicitly selected optional catalog source, never a statistics source or silent fallback.
- **FR-015**: The shared job runtime MUST permit later statistics and conditional-order workers without making catalog scope identity or retry policy universal. This task MUST NOT implement statistics imports/TTL, valuation, quote insertion, conditional-order evaluation or execution, token minting, balance changes, PubSub UI behavior or Redis caching. Catalog completion MUST NOT imply those downstream outcomes. [CP2 architecture](../../docs/CP2_ARCHITECTURE.md) and [ADR-0017](../../docs/adr/0017-cp2-charts-and-conditional-orders.md) retain their downstream ownership.
- **FR-016**: Every acceptance scenario MUST have deterministic automated offline evidence using controlled time and independently authored expected outcomes. Required coverage includes concurrent mixed triggers, incompatible inputs, scope isolation, due-occurrence replay, catch-up, disabled scheduling, retry delays/provider guidance, budget exhaustion, interruption/restart, publication followed by lost completion, durable inspection, store failure, Redis absence and usable local reads. Tests MUST verify zero live calls and unchanged financial/statistical/quote state. Feature changes MUST NOT claim independent QA or final review before those later gates actually run.

### Key Entities

- **Synchronization Scope**: The catalog operation for one normalized league season; the active-run coordination boundary, independent of trigger and source.
- **Synchronization Run**: One durable execution request with stable identity, effective source/input references, state, retry budget and final safe outcome.
- **Execution Attempt**: A numbered invocation belonging to a run, with times, safe result or interruption, and retry eligibility; completed attempt evidence is retained.
- **Schedule and Due Occurrence**: Enabled recurrence with scopes, and a UTC occurrence tracked across admission, coalescing, restart and catch-up.
- **Catalog Acceptance Reference**: Link to TASK-018's authoritative publication evidence, separate from execution history and from future statistics or financial state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Initial, manual and scheduled offline examples each produce a durable inspectable result with correct scope, trigger, lineage and domain outcome in 100% of acceptance cases.
- **SC-002**: Ten concurrent equivalent requests across trigger types yield exactly one active run per scope. Every incompatible-input example yields an explicit conflict and zero changes to the active request.
- **SC-003**: In all controlled scheduling cases, duplicate due occurrences create zero extra runs, disabled scopes create zero scheduled runs, and five missed occurrences yield at most one catch-up run per enabled scope.
- **SC-004**: Under the default failure policy, a continuously retryable failure starts exactly three attempts and no fourth; all non-retryable cases stop after the first. No attempt starts before its applicable minimum wait, including across restart.
- **SC-005**: In every crash/restart and lost-completion example, accepted work remains discoverable, catalog identities and prior accepted facts stay correct, and history reports zero fabricated successes.
- **SC-006**: Operators can identify current state, completed attempt reasons, next eligible retry or terminal recovery action, and confirmed catalog outcome from every inspection example without reading raw source content or exceptions.
- **SC-007**: All deterministic acceptance tests run with zero external requests and zero credentials; local reads remain available during failed synchronization, and clearing or omitting the cache loses zero execution/history records.

## Assumptions

- Operators are trusted local/internal consumers. CP3 TASK-049 owns administrative UI; this feature does not broaden public access or introduce cancellation, manual attempt editing or a replay dashboard.
- Disabled-by-default scheduling, daily UTC recurrence when enabled, three attempts and one concurrent catalog attempt are conservative configurable operating defaults. They establish no live-source authorization, real-time freshness or execution latency guarantee.
- A scope with no earlier schedule history becomes due at its first configured occurrence after enablement. Catch-up concerns previously enabled schedules; it does not backfill dates before enablement. Disabling and re-enabling begins a new enabled interval.
- Runtime is local: progress requires the application and PostgreSQL to be running. Configuration supplies stable source/fixture references available again after restart; missing configuration at execution fails safely and never substitutes a source.
- TASK-002 supplies local infrastructure; TASK-018 supplies idempotent atomic ingestion and successful publication evidence; merged TASK-016 and TASK-055 supply provider contracts and gated offline retrieval. Their rules remain authoritative rather than being duplicated here.
- Later TASK-021/056 and TASK-060 own statistics/freshness and order-worker policies respectively. Reusing this runtime grants neither their business rules nor their implementation scope to TASK-019.
- This document is TASK-019's complete behavioral authority. Checklist validation establishes specification readiness only; independent product challenge, architecture, implementation, QA and final review remain later workflow stages.

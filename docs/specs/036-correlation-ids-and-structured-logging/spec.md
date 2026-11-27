# Correlation IDs and structured logging — TASK-036

**Feature Branch**: `036-correlation-ids-and-structured-logging`

Manual implementation, authorized by the user; no Agentflow stage run is claimed.
The user chose JSON application logging in every environment, retaining existing levels.

## Acceptance

- **FR-001**: Runtime Logger records are single-line JSON with UTC `timestamp`, `level`, `message` and only approved optional metadata. Unicode, truncation and report messages remain printable; no ANSI or double encoding. Compilation and CLI commands remain usable.
- **FR-002**: Preserve Plug.RequestId's existing `x-request-id` response and incoming-header rules. Establish correlation before static/parser/router handling. Emit a request start and one terminal record containing method, matched route template when available, HTTP status and elapsed milliseconds; cover static, rejected and exceptional requests without duplicate terminal events. Never log query strings or raw request paths in new lifecycle events.
- **FR-003**: A new synchronization run stores the originating valid correlation ID, or a generated one for background work. Coalescing retains the original ID. Retries, recovery, delayed calculation dispatch and quote calculations preserve it without depending on old job rows. Nullable legacy rows and unrelated jobs have stable identifier fallbacks. Logging context cannot affect input digests, uniqueness or existing response shapes.
- **FR-004**: Oban start/stop/exception logs contain correlation, job ID, worker, queue, attempt, execution state and available timing/known UUID identifiers. Timeout reporting from a different process still uses job context. Scoped metadata is restored, concurrent work is isolated, and provider subprocesses receive only approved context. Transport success is not claimed as domain success.
- **FR-005**: New lifecycle records omit raw arguments, payloads, parameters, headers, credentials, exception messages and unallowlisted diagnostics. Formatters omit unapproved metadata and safely encode approved values. Context extraction and event handling must not break business execution or detach telemetry handlers on expected malformed data.
- **FR-006**: Existing request bodies, authorization, financial behavior, immutability, retry budgets, provider deadlines and job uniqueness remain unchanged. The only schema addition is a nullable synchronization correlation field; existing rows need no rewrite.
- **FR-007**: Preserve Agentflow task ownership, architecture checks, test/source inventories and friends' TASK-029/TASK-033 records. Genuine independent QA and final review must pass before `review`; `active_run` remains `none` and human merge enables normal automatic completion.

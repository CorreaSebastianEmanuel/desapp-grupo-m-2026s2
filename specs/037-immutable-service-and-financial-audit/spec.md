## Outcome

Audit every published Phoenix HTTP service through the existing structured Logger
and Telemetry, satisfying the CP3 Web-Services audit rubric with timestamp, user,
operation/method, safe parameters and execution time.

## Acceptance

- [ ] Each HTTP response has exactly one terminal structured record, including reads,
  writes, authentication, rejected requests, parser errors and server failures.
- [ ] Records include UTC timestamp, verified account ID when established (otherwise
  `anonymous`), original HTTP method, stable route template, safe parameters,
  status and nonnegative monotonic `duration_ms`.
- [ ] Parameter capture uses an explicit typed allowlist; credentials, tokens, session
  handles, request keys, headers, raw bodies, free text and unknown fields are absent.
  Unparsed or invalid values are omitted. Routes never expose raw unmatched paths.
- [ ] Focused tests prove route coverage, verified/anonymous identity, parameter safety,
  duration, failures/rejections and terminal-event deduplication.
- [ ] Existing immutable financial evidence and settlement behavior are preserved.

## Scope

- Extend TASK-036 HTTP lifecycle logging at the endpoint boundary shared by all
  published HTTP services, including browser pages, API endpoints and static/docs
  responses. Authentication boundaries supply identity; no business rules move to web.
- Use existing Logger JSON output and Telemetry; no new persistence or infrastructure.

## Non-goals

- Financial snapshots, new audit tables, audit API/UI, financial rollback rules,
  external logging services, worker audit expansion or individual LiveView socket events.
- Workflow policy changes and unrelated refactoring.

## Risk

- Security: unsafe request capture can retain secrets. Fail closed for unknown,
  structured, oversized or malformed parameter values and unverified identity.
- Coverage: endpoint errors can emit overlapping lifecycle events; retain one
  terminal record per request and reset state for sequential requests.

## Decisions

- Human feedback 1 resolves scope using the official CP3 rubric: all published
  HTTP services, including failed/rejected attempts, rather than only settlements.
  Elixir equivalents to Spring/Log4j/logback are Phoenix, Logger and Telemetry.
- Execution time runs from the early endpoint logging plug to response preparation
  or error rendering, measured with the monotonic clock in milliseconds. Logger
  supplies the UTC event timestamp. A replay is a separate HTTP attempt and is logged.
- Stable operation identity is original method plus route template; unmatched or
  pre-router responses use a fixed `unmatched` marker, never user-supplied paths.
- Safe parameter values are bounded UUID identifiers, nonnegative integers,
  decimal price strings and ISO dates/times. Keys are `id`, `player_id`,
  `league_id`, `team_id`, `position_id`, `quantity`, `page_size`,
  `maximum_unit_price`, `date`, `from`, `to`, and `expires_at`. All other
  values are omitted, including search text and pagination cursors.
- Logger is operational evidence, not a database transaction participant. Existing
  append-only financial records remain the durable financial evidence.
- The first hosted run of PR #102 exposed two integration-only configuration
  controls still pinned to TASK-036's logging metadata. Reconcile the exact approved
  declaration with TASK-037's `actor_id` and `parameters`; retain the configuration
  hash and prove removing either audit field or adding raw arguments is rejected.
  Validate the affected integration controls before a fresh independent evaluation
  and publication to the same PR.

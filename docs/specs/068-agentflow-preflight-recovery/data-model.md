# Workflow records — TASK-070

All records are tooling-only. No Ecto entity, database migration or application state change.

## LaunchContext (in-memory only)

Fields: canonical task/feature identity (feature optional before product), launch role/stage/provider, argv, cwd, resolved executable identities, final environment, selected assignment/config digests, prerequisite-policy identity. Contains secrets in memory only; never serialize argv/environment wholesale. Store only allowlisted presence/compatibility observations and non-secret component digests. Context is built once and consumed unchanged by probe and launch; relevant mutation invalidates approval.

## PrerequisiteResult

Fields: prerequisite ID, expected-condition code, status `passed|failed|unknown|unavailable`, safe-observation code, recovery code, optional elapsed milliseconds. Exact status and ordering are deterministic for the same observed inputs; elapsed times and live-service availability are observations, not deterministic source facts. Any required non-passed result denies launch. Required probe inventory has unique IDs, bounded timeouts and no arbitrary shell evaluation.

## Manifest extensions (schema_version remains 1)

Each check optionally declares `depends_on` (unique existing check IDs), `isolation` (`isolated|shared`), `state_reads` and `state_writes` (unique symbolic state IDs), `prerequisites` (typed declarations), and existing `retry_inputs` (validated repository-relative selectors). Empty dependency/state lists plus explicit isolation mean known independence; absent metadata means unknown. Optional `execution_class` is `static` only for registered exact static/contract argv with explicit isolated effects; unknown values or forged static classifications fail closed. No dependency cycle, forward dependency or conflicting/unknown producer is silently reordered. Static-ready groups have at most two workers, stable output order and no overlap with serial checks. Invalid metadata fails validation before check execution. Old manifests remain valid for individual commands; batch continuation is conservative. `coverage`, runtime and task-stage rules retain existing validation.

## StageAttemptJournal (schema_version 1, new file)

Identity: workspace, canonical feature/task, stage, stage-command/provider configuration, attempt token and retry-component identities. Fields: state, check inventory, failing obligation IDs, per-component path/code and digest, `dependency_graph`, `retry_scope` (failed checks plus transitive dependencies), `retry_snapshot`, start/end times, elapsed milliseconds, failure count, safe cause/action and evidence references. No raw environment/commands containing secrets. Parent stage token makes nested batch/check finalization idempotent. Key does not depend on run/session ID. States: `prepared → running → passed|failed|interrupted`; only a launched attempt enters running. Recovered running becomes interrupted exactly once and, absent a trustworthy scope, is compared against all stage components. Corrupt/unsupported records block without overwriting historical proof. The third unchanged failed full attempt is refused, not recorded as another launch. A persistent sibling lock file with an OS exclusive lock serializes the complete stage journal lifecycle; a concurrent launcher is refused without changing the active record.

## CheckOutcome

One ordered outcome per required check per attempt. Fields: check ID, status `unexecuted|running|passed|failed|blocked|interrupted`, dependency/blocking IDs, contaminated state IDs, safe diagnostic, elapsed time and receipt/output references. Persist inventory before first command, running before spawn, terminal after completion with atomic same-directory replacement. A passed outcome references a valid current same-stage receipt; historical completions are not fresh acceptance. Failed writers contaminate their declared state; transitive consumers block. Missing independence metadata blocks after failure. Terminal blocked/unexecuted/interrupted required outcomes never count as pass.

## QA report and evidence

`qa-report.md` is the bounded human-readable projection plus independent QA assessment. Every required check has a row and a safe evidence reference, even before execution. Persist an initial non-PASS report and update it after each result; handled interruption finalizes, abrupt death preserves last durable non-PASS state. Recovery distinguishes earlier completed evidence from the new attempt. Final PASS additionally requires fresh complete same-attempt outcomes, independent QA semantic acceptance and existing provenance gates. Existing schema-2 check receipts and schema-1 portable evidence summary stay authoritative and compatible; stage journals cannot manufacture receipt success.

## FeedbackImpact and VerificationObligation

Reuse current impact categories, earliest-stage mapping and append-only feedback. Optional scoped checks resolve case-normalized IDs to exact manifest IDs; unknown/ambiguous IDs refuse before mutation. Set current repository feedback-cycle cap to three independently from attempt counters. Count durable feedback cycles across resumes/run IDs; permit the third repair, refuse a fourth, retain exhausted history and recommend an explicit split. No reset on restart or edits. Obligation identity includes command/env identity, profile/configuration and discovered component membership, stage/workspace and full source/canonical fingerprints plus output digest. Only intact complete matching development receipts can suppress a development duplicate. Runtime, QA and CI identities remain separate.

## Measurement record

Implementation audit records per-check monotonic elapsed milliseconds, execution class, peak workers, serial/concurrent static-fixture wall time, profile command count and source/stage identity. No token estimates or full-suite reruns solely for benchmarking.

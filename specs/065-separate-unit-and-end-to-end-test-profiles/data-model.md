# Test evidence structures

These are test-tooling JSON/event structures, not Ecto entities or migrations.

## TestInventory (config/test_profiles.json)

Schema version 1; entries have unique opaque `id`, `runner` (exunit/python/node/shell/validator), repository-relative `file`, native `case_id`, and exactly one `profile` (unit/integration/e2e). File/case/profile uniqueness is enforced. Helpers/fixtures have a separate explicit non-test path allowlist with reasons; ignored dependency/generated/historical-evidence roots are explicit. An inventory digest identifies the reviewed expected population. Updating requires an explicit command and reviewable diff; validation never writes assignments.

ExUnit case identity uses normalized file, module and native test name (including describe/parameterized expansion), not a line number. Python uses fully qualified TestCase method; Node uses file plus nested test path; custom validator and shell assertions emit stable named case IDs. No secret may occur in a case ID/name. Module profile tags must agree with every case assignment. Runtime identity is translated to an opaque ID before publication.

## Discovery and execution

DiscoveryResult: selected profile, inventory digest, discovered native case identities and discrepancy categories. Discovery enumerates source roots separately from the committed manifest; missing files, new files/cases, duplicate ownership, indirect/unsupported declarations and empty profiles fail.

CaseEvent: invocation nonce, runner, opaque case ID, state (`discovered`, `started`, `passed`, `failed`, `skipped`). Exactly one start and one terminal event per expected selected case; duplicate terminal events or an event belonging to another profile fail. Every expected case must be discovered, started and passed. A runner exit zero without these events fails.

ProfileResult: schema version 1, invocation nonce, inventory digest, profile, expected/discovered/executed/passed totals, fixed outcome (`complete` or `failed`), allowlisted discrepancy category/opaque IDs and component counts. Never retain stdout/stderr, environment, arguments, browser state or response bodies. Counts alone cannot establish membership equality; reconcile sets first.

Lifecycle: absent/stale previous receipt -> running (previous complete removed) -> failed or atomically published complete. Signals, missing prerequisites and timeouts cannot publish complete. Partial raw events live only in private temporary storage, removed on exit. Outer supervisor timeout must terminate the process group and prevent a stale receipt from being accepted.

## FixtureState

ResourceRegistry: private per-child JSON list, atomically replaced before each schema creation. Records bind `schema`, `database`, `partition` and the supervisor's resource `nonce`. Schema names must match the owned E2E UUID prefix, and every record must match the exact configured test partition and nonce before cleanup starts a repository. The separate cleanup process runs after child termination even when BEAM cleanup cannot execute. Normal cleanup and fallback are idempotent; cleanup failure prevents a complete profile. Registry contents contain no credentials. Catchable supervisor signals and timeouts are covered; killing the supervisor itself with SIGKILL cannot run its cleanup code.

Unique schema and Oban prefix, safe existing test DB identity, loopback listener port, deterministic local Accounts credentials, supported PL league/season and fixture provider publication, run IDs and expected catalog identities. Credential values stay in memory/private IPC. No production credentials. A fixture release barrier proves queued admission before retrieval. Each invocation owns only its schema/processes; cleanup never resets shared databases. Read-only snapshots of financial/quote/performance tables establish unchanged invariants around invalid requests and replay.

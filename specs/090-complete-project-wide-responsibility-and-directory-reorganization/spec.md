## Outcome

**Feature Branch**: `090-complete-project-wide-responsibility-and-directory-reorganization`

**Task**: `TASK-090`

Finish the responsibility audit and implement the confirmed organizational defects across the maintained project, preserving all observable behavior and delivery entrypoints. TASK-090 owns this work; TASK-045 remains the general architecture-test feature.

## Acceptance

- [ ] Every maintained area has the disposition below; changed areas deliver the stated separation, unchanged areas retain the stated responsibility boundary.
- [ ] Quotes delegates explicit admission, leased request execution, calculation confirmation and historical replay to cohesive owners. Player-before-request confirmation locking, current database clock checks, fences, retained facts, canonical identities and transaction boundaries remain identical.
- [ ] WorkspaceLive retains route/session/PubSub coordination; destination modules own loading and events, and destination templates retain URLs, events, labels and selectors. LocalAdminLive delegates operational IO to Infrastructure and renders a web-owned projection.
- [ ] Both ingestion publishers retain atomic acceptance ownership while record writing and provenance have explicit participants. Source separates player-profile translation from assessed document acquisition; production HTTP transport does not depend on a fixture implementation.
- [ ] Remove the empty root module after static/dynamic reference checks. Place misowned schemas and worker modules under their actual namespace without renaming runtime module identities. Consolidate the single-caller conditional-order projection.
- [ ] Directly affected characterization tests pass. Path inventories, exact scope and reviewed analyzer identities match the resulting source; no gate is relaxed. Full required checks and independent evaluation belong to the harness after development.

## Scope

Disposition matrix from the maintained source/module/caller inventory and targeted code inspection (historical artifacts excluded):

| Area | Finding, dependency disposition and concrete action |
| --- | --- |
| Accounts | Keep: registration owns its Ecto.Multi; Authentication owns JWT/Argon2 boundary and BrowserSessions owns revocation/deadlines. Web callers use these contexts, not credentials or Repo. |
| Catalog | Keep Query/cursors/profiles/scouting/seed and reconciler: query composition, pagination authentication, durable scout lifecycle and canonical reconciliation are distinct. Publisher currently also writes catalog records; move league/season/upsert/issuance participation to Records, called inside the existing publisher transaction. |
| Market | Keep purchase/sale input, stores, transaction/settlement, portfolio ledger/read snapshots, analytics, issuance and conditional evaluation: they own different auth, lock or read-consistency contracts. ConditionalOrderProjection.at/2 only sets expiry_reached and has one runtime caller, ConditionalOrderStore.project/2 (its characterization test moves to that boundary): inline there; no dynamic dispatch/config references. Small auth/validation contexts are not redundant pass-throughs. |
| Quotes | Quotes mixes explicit admission, worker lease/retry state, calculation persistence and replay. Separate Admission, ImportRequests, Engine and Replay, share retained fact decoding via EvidenceCodec and lease/initialization checks via Store. Reader owns inspection; Recovery owns pending delivery queries (remove its round trip through Quotes). Keep Closing/Membership/Conversion: nightly admission, immutable snapshots and decimal conversion have distinct contracts. Split Mapping/Evaluation/CalculationRequest schemas into namespace files. |
| Valuation | Keep pure strategies, evidence/preparation/replay and configuration codec/registry/store: scorer callback and versioned reconstruction differ from persistence. Move Valuation.CalculationRequest out of statistics ingestion schemas into valuation/calculation_request.ex. Related immutable DTO families in types.ex/managed_types.ex remain grouped; splitting each struct adds navigation without a responsibility change. |
| Statistics | Keep manual fact APIs, input/query/freshness and FotMobBinding. Publisher combines acceptance orchestration, immutable match/performance writing and provenance/fixture observations: Records and Observations become transaction participants; Publisher keeps receipt/season locks, checks, intent and atomic commit. Split ingestion schemas by owned namespace. |
| Synchronization | Keep Input/Policy/Store/Scheduler/Dispatcher/Recovery/ExecutionGuard: validated source configuration, durable state machine, scheduling and live execution serialization differ. Shared CatalogSync execution is misleadingly owned by a catalog worker although StatisticsImport calls it: move shared execution into Synchronization.Execution; both worker identities/queues remain adapters. |
| Providers | Keep provider contract DTOs/validation/runtime, football-data translation and assessment/admission. Extract player-profile interpretation from Source to PlayerProfile; Source retains assessment, deadline and portion checks. Move shared ETS lease accounting from FixtureTransport to Budget; both fixture and HTTP transports call it. Move Source helper calls (formerly used by Translator) directly to Document; remove the unused forwarding surface after caller/reflection checks. Keep HTTP endpoint allowlisting and bounded streaming together as one security boundary. |
| Ranking | Keep context auth/validation and Reader SQL: one authoritative snapshot/query, no unrelated work. |
| Observability | Keep correlation context, job metadata, logger and formatter: separate process-local propagation, durable lookup and output effects; dynamic telemetry handlers remain registered. |
| Infrastructure/application | Add LocalOperations for development operational reads/commands; no new process. Keep Repo, Redis adapter, configuration validation, DB Mix task entrypoints and supervision. Remove lib/football_market.ex: no functions, supervision, reflection, router, config or runtime string references; only coverage inventory/test references need reconciliation. |
| Web | Keep controllers/JSON/auth plugs/BrowserAuth/AdministrationLive and reusable components. Extract Workspace destination functions/templates, shared session input and presentation helpers. Extract LocalAdmin operational projection from IO and callbacks. Router/live_session/auth hooks remain unchanged. |
| Tests/support | Existing domain folders and shared cases follow context ownership; no generic test utility migration. Keep profile/E2E runtime helpers at their external contracts. Strengthen affected existing tests for expiry projection, operational commands and route rendering; register any new cases. Coverage/scope tests must describe actual maintained sources after removal. |
| scripts / tools / tests | Keep script launchers and Python modules together: agentflow imports and shell/PowerShell callers rely on these stable entrypoints. tools/openapi owns the pinned Node package used by OpenAPI and browser runners; test/scripts and root tests exercise different harness/checkpoint contracts. No confirmed duplicate implementation or unused entrypoint from import/CLI/workflow references. Reconcile only affected source identities. |
| config / assets / priv / root | Keep runtime/env composition, JS hooks/CSS/media, migrations, vendored docs/fonts and release/setup/compose entrypoints. Router selectors, build globs, Mix aliases, npm scripts, CI and setup references are live; no directory move is justified. Historical migrations remain immutable. Generated inventories change with actual source paths. |

Removal/consolidation checks cover maintained lib/config/mix/application/router, Oban worker strings, Application env, Code.ensure_loaded?/function_exported?/Module.concat/reflection sites, scripts/tooling/workflow callers, support and inventories. Root module has no runtime callers; ConditionalOrderProjection has only ConditionalOrderStore; FixtureTransport lease methods are also consumed by scraping/provider tests and remain compatible delegates to Budget. StatisticsImport and CatalogSync names persist in configuration, Oban jobs and dynamic tests. Schema module identities persist in queries and serialized/runtime references.

## Non-goals

Product features, dependencies, processes, migrations, new services, public API/module identity changes, general architecture enforcement, historical artifact rewrites, delivery-policy changes, commits, pushes, PR creation or merge during develop. No changes to monetary precision, supply, authorization, idempotency, retry, quote history or UI behavior.

## Risk

High: financial confirmation and ingestion transactions, provider admission/security and authenticated UI wiring. Mitigation is mechanical extraction with the same call order and focused existing behavior/concurrency/security tests, followed by deterministic harness checks and independent evaluation. Static/dynamic reference inspection cannot prove absence of arbitrary downstream external consumers; preserve public contexts, worker and schema identities.

## Decisions

- Use plain stateless modules and function components, not new LiveView processes; session/PubSub remains in the existing LiveView.
- Transaction participants never begin a replacement transaction or change lock order. Publishers and Engine retain their original atomic boundaries; Store owns reusable locked lease validation.
- Preserve script, setup, test-profile and browser launch interfaces. Retain cohesive small auth boundaries and related DTO families; module length alone is not a defect.

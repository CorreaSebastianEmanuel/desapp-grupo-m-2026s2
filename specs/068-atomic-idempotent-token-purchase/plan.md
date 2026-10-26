# Implementation Plan: Atomic Idempotent Token Purchase

**Branch**: `068-atomic-idempotent-token-purchase` | **Date**: 2026-10-24 | **Spec**: [spec.md](spec.md)
**Task**: TASK-029, CP2. The generated feature directory is authoritative; the spec's original 029 branch label identifies the backlog origin.

## Summary

Add a direct authenticated purchase to the existing modular Phoenix market. PostgreSQL coordinates current quote selection, conserved-token transfer, preprovisioned credit movement and completed-only idempotency. One transaction returns immutable evidence only after commit. The domain context owns rules; HTTP validates/serializes the contract. No funding or background execution is introduced. Feedback 2–9 additionally authorize bounded verification-tooling corrections; the latest architecture delta is effective sandbox identity and compatible Codex launcher flags, not a purchase behavior change.

The critic's self-purchase finding is resolved by the approved recommended rejection, now explicit in spec FR-012. Its quote-race finding is resolved by the shared player lock and post-lock current-quote decision point in ADR-0032. Funding remains exactly as recorded in backlog/feedback/TASK-029.md. ADR-0032 records the durable coordination extension to ADR-0024/0029 and the product decision provenance.

Current development feedback 6 adds two corrections within the approved boundary: reject NUL request-key bytes before database persistence so HTTP reports `invalid_request`, and include discrepancy-only markers in safe diagnostics. The existing Chromium preflight remains mandatory; integration/E2E must run with the verified `CHROMIUM_PATH` and repository-local `TMPDIR`, and any launch failure is recorded as an allowlisted cause without exposing raw browser output.

Current human feedback 10 requires two fail-closed verification corrections: profile discrepancy diagnostics identify only a registered test case, closed outcome/cause, bounded source line and lifecycle counts (never assertion or child output); Codex launcher regressions pin that `--approve-for-me` is removed only for `danger-full-access` with approval policy `never`, while conflicting CLI/config sandbox declarations refuse before spawn. The corresponding regression paths are included in the existing TASK-029 boundary and unit inventory. No purchase behavior changes.

The latest development integration failure had a safe `step=tests` marker but no registered failed case, so its exact cause could not be distinguished from a Mix failure before test events. TASK-029 adds only a bounded aggregate lifecycle summary for failed Mix test invocations; it never forwards child output or changes the feature's behavior. This correction reuses the existing runner, safe diagnostics consumer, and unit test boundary.

The complete integration inventory has 508 registered cases and exceeded its existing 20-minute profile ceiling before completion. TASK-029 increases only the bounded integration ceiling to 30 minutes; unit remains at 10 minutes and browser E2E at 3 minutes. The existing timeout cleanup and two-failure retry limit remain unchanged.

Final profile recovery found that the main integration ExUnit partition omitted the runner-owned `POSTGRES_PORT`, while committed partitions received it. That made regular integration tests fall through to the host's default database despite the isolated service. TASK-029 binds both partitions to the same invocation-owned PostgreSQL endpoint and tests this runner contract before final validation; purchase behavior and the two-failure retry limit remain unchanged.

Development revalidation also showed nested Mix invocations inherited a shared `MIX_BUILD_PATH`, causing runtime/compile configuration mismatch when the child changed `MIX_ENV` to `prod`. The TASK-029 child environment now clears the inherited build path alongside profile partitions so each child uses Mix's environment-specific build directory.

`MIX_BUILD_PATH` also changes protocol consolidation and application artifacts for top-level checks, so verification binds its effective value into retry identity for every Mix-backed check. This keeps retries honest while the default environment-specific build directories stay isolated.

Human feedback 11 explicitly includes `scripts/application_coverage.py` publication-path containment in TASK-029. Reject a symlinked output root and symlinks at or below it, and verify the resolved report stays within the resolved root. Allow symlinked ancestors outside the declared root when resolved containment holds; this supports legitimate temporary output roots on macOS. Regressions live in the already inventoried `test/scripts/application_coverage_test.py`. This protects verification artifact publication without changing purchase or coverage-report behavior. Preserve the exact-path scope guard; add no coverage report or profile.

The independent-verification entry point must use the same effective Codex sandbox resolver as the workflow launcher. `agentflow verify` currently passes `--approve-for-me` directly to Codex, silently forcing `workspace-write` and preventing QA's PostgreSQL loopback access even when the user's configured policy is `danger-full-access`. Resolve the user's policy before dispatch, normalize provider arguments through `scripts/agentflow_codex.py`, and preserve approval-policy rules. Cover the launched argv in the existing `test/scripts/agentflow_branch_test.py`; allowlist only `agentflow`, that test, and the scope-guard assertions. Do not alter QA acceptance checks or relax sandbox policy.

Database `NUMERIC` balances remain uncapped by product policy, so no financial projection operation may use the default 34-digit Decimal arithmetic context. Compute purchase totals with PostgreSQL numeric multiplication and change existing balance projections with database-side numeric increments/decrements; keep finite-cent validation and exact immutable ledger amounts. Add committed buyer and recipient regressions at `1e40` in the existing transfer integration module, proving each stored projection matches PostgreSQL's exact expected value. Do not introduce a balance cap.

The safe diagnostics consumer must preserve only conventional registered case IDs and emit `redacted` for nonconventional registered labels, while retaining the aggregate `step=tests` enum instead of copying a count into that field. Add focused consumer regressions in the existing unit-owned `test/scripts/agentflow_evidence_test.py`. Keep the launcher fake-child test independent of the host's `CODEX_HOME` by pointing it to an empty fixture config directory; never make its expected argv depend on a live user policy.


## Technical Context

**Language/Version**: Elixir 1.20.3 / OTP 29.0.6, Node 24 for existing tools.
**Dependencies**: locked Phoenix 1.8, Ecto/Postgrex, Decimal, existing auth and OpenAPI tooling. No new package or service.
**Storage**: PostgreSQL 17.6 authoritative; Redis 8.2.1 remains an existing prerequisite, never a financial lock or ledger.
**Testing**: ExUnit unit/integration plus committed-connection races, existing E2E profile, real HTTP runtime assertions; existing profile inventory and Credo checks.
**Target**: existing local modular web application and CI.
**Performance goals**: correctness under contention, bounded runtime readiness and race waits. No new latency/throughput SLA in this spec; TASK-043 owns SLA validation.
**Constraints**: exact cents, fixed 100-token supply, no negative balance/inventory, append-only financial evidence and quotes, completed-only durable idempotency, no external-provider requests.
**Scope**: one purchase endpoint and reusable domain operation, balance projection and operation/transfer/ledger evidence. All three P1 stories are required for release.

## Constitution Check

Before design: PASS against principles I–V: approved spec/feedback, existing modular monolith, no new infrastructure, behavior tests required, independent gates retained. The only product ambiguity identified by the critic was approved by this stage's instruction and encoded explicitly. No unsettled technology research.
After design: PASS by artifact review: ADR-0032 defines exact lock ordering and quote linearization; data-model protects evidence/supply; contracts keep identity and price authoritative. TDD precedes every new behavior and DB guard. QA/review are downstream and cannot substitute for owner checks. Implementation and independent verification have not run at architecture stage. No constitutional exemption is needed.

## Supporting applicability

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve quote coordination, credit projection and the authorized browser diagnostic producer/consumer gap through focused local inspection."},
  "data_model": {"required": true, "reason": "Add exact balance projections and immutable purchase, credit-entry and token-transfer structures."},
  "contracts": {"required": true, "reason": "Add protected direct purchase interfaces and define the safe browser-preflight diagnostic protocol."},
  "quickstart": {"required": true, "reason": "Feature-specific provisioned fixtures, service preflight and real HTTP validation need runnable guidance."}
}
```

## Project Structure

Documentation: this directory contains spec.md, plan.md, tasks.md, verification.json, research.md, data-model.md, contracts/purchase.md, quickstart.md and concise handoffs. Durable decision: docs/adr/0032-atomic-purchase-coordination-and-completed-idempotency.md and docs/adr/0033-allowlisted-browser-preflight-diagnostics.md, docs/adr/0034-check-environment-retry-identity.md and docs/adr/0035-effective-sandbox-check-identity.md.

Implementation boundaries:
- lib/football_market/market.ex delegates purchase; lib/football_market/market/purchases.ex owns orchestration and internal lookup; market/purchase_input.ex owns pure validation; market/purchase_store.ex owns transactions/locks; market/purchase.ex, credit_balance.ex, credit_entry.ex and token_transfer.ex own Ecto structures. Reuse market/holding.ex, quote.ex, error.ex and consistency.ex without changing issuance behavior.
- priv/repo/migrations/20261023000000_create_market_purchases.exs owns new tables/guards. No destructive data reset or fabricated opening credit.
- lib/football_market_web/controllers/purchase_controller.ex and purchase_json.ex adapt the contract; lib/football_market_web/router.ex adds the protected route; priv/static/openapi.json documents it. The existing error_json.ex adds a route-specific malformed-JSON category without changing other routes.
- test/football_market/market/purchases/ contains input, transfer, storage, idempotency, quote-order, duplicate-race, concurrency, rejection and rollback tests. test/support/purchases/case.ex and runtime_probe.ex provide deterministic fixtures/isolated committed stores. test/football_market_web/controllers/purchase_controller_test.exs owns HTTP contract tests. test/runtime/purchase_http.exs is the standalone live HTTP assertion runner.
- Compatibility assertions touched by the new public purchase operation stay scoped: the legacy market boundary test recognizes the added facade while keeping issuance paths isolated, the synchronization scope test preserves the already configured recovery plugin, and the catalog OpenAPI browser/contract checks select only player operations. The purchase HTTP tests own the new operation's behavior and schema.
- config/test_profiles.json registers new ExUnit cases; test/support/workflow_scope.ex and test/ci/workflow_scope_test.exs register and constrain the exact active feature paths; config/credo_inventory.json includes the new maintained sources (Git intent-to-add enables the existing tracked-source oracle); extend the existing profile runner only as authorized below. Do not classify ordinary HTTP persistence cases as browser E2E.
- scripts/application_coverage.py owns containment checks for coverage artifact publication; test/scripts/application_coverage_test.py owns symlink-root, unsafe-ancestor, and resolved-report regressions. These are the only application-coverage paths included by feedback 11; the existing unit inventory executes the regressions.

## Phase 0: Focused resolution

research.md resolves the feature-specific integration unknowns using current code. ADR-0024/0029 settle issuance/quote trust; docs/ARCHITECTURE.md and docs/TEST_PROFILES.md settle technology and profile ownership. No web or research agents required.

## Phase 1: Transaction and interfaces

1. Pure validation establishes canonical UUIDs, strict integer quantity and exact request key. Authenticate before the adapter invokes Market; never accept client financial authority.
2. Own READ COMMITTED transaction. Acquire buyer/key advisory lock, read completed evidence, replay or conflict before checking mutable market eligibility. Unique buyer/key index remains mandatory.
3. Lock player FOR UPDATE; lock buyer and fixed recipient user rows in ascending UUID order; lock balances in the same order. No nested transaction, global issuance lock or further player lock. Resolve recipient from durable market singleton and issuance, never request/config override.
4. Under these locks revalidate coherent issued state and supply, reject self-purchase, read the current quote via Quotes.latest/1. That statement is the authoritative decision point. Existing confirmation and quote/holding triggers hold the same player lock through commit. Retain identical quote facts for price and evidence, with no stale fallback.
5. Check exact Decimal total against pre-existing buyer credits and full designated-recipient inventory. Missing buyer balance is zero; invalid/nonpositive pricing is quote_unavailable; contradictory retained evidence is inconsistent_state. No partial fill, business retry or repair.
6. Atomically debit/credit, redistribute holdings, insert operation/transfer and paired ledger. DB constraints/append-only guards validate linked evidence at commit. Return after commit. Any failure rolls back every projection/evidence change, including lazily inserted zero projections; no failed key remains.
7. Internal buyer-scoped retrieval supports future history consumers and restart tests; public listing/presentation is deferred. Use safe HTTP categories in contracts/purchase.md.

## Authorized verification recovery (feedback 2)

The existing development handoff reports two integration failures before ExUnit, categorized browser-prerequisite. Human feedback records successful local Chromium launch with the exact Node 24.21.0/TMPDIR/integration environment and authorizes actionable safe causes. That observation does not prove the profile or purchases passed. Preserve the reported attempts and retry guards; do not open historical run directories for planning.

Local inspection finds the browser launch catch in scripts/test_profile_runner.py discards its cause, run() only forwards the existing openapi-browser safe marker, and scripts/agentflow_check.py safe_failure_diagnostics() only exposes locations/counts/stages. Extend this producer-to-consumer path with the closed protocol in contracts/profile-diagnostics.md and ADR-0033. Do not retain or print raw Playwright errors. Keep existing openapi-browser diagnostics and receipt semantics compatible. The producer is `browser_preflight_command()`; its private classifier maps only the five documented causes, with launch-failed as fallback. The supervisor recognizes that specific inline probe for timeout reporting, and the helper adds `browser_prerequisite_causes` only when a complete allowlisted record is present. Native unit cases are named in contracts/profile-diagnostics.md and verification.json.

The bounded verification boundary adds scripts/test_profile_runner.py, scripts/agentflow_check.py, scripts/agentflow_verification.py, docs/AGENT_VERIFICATION.md, docs/adr/0034-check-environment-retry-identity.md, test/scripts/test_profile_runner_test.py and test/scripts/agentflow_evidence_test.py. Reuse the inline Node preflight; no new service, dependency or browser runner. Test first with deterministic child failures, injected launch errors, timeout, retry-environment identity and secret sentinels; then implement cause classification, strict allowlist forwarding and hashed environment binding. Add only these exact paths to TASK-029 in test/support/workflow_scope.ex and update positive/negative assertions in test/ci/workflow_scope_test.exs. Register native Python case additions in config/test_profiles.json under unit ownership; existing full unit runs execute those regressions. No new full-profile wrapper is needed.

Feedback 3 extends this same inline preflight: when inherited `CHROMIUM_PATH` is nonempty, pass it as Playwright's `executablePath`; when unset, omit the option so Playwright keeps its pinned default. Regression coverage asserts both option sets through the existing native unit case. Retry-environment regressions cover hashed identity changes and invalid declarations.

Independent QA also requires the closed browser-prerequisite producer/forwarder contract and the opaque-only legacy `PROFILE_DISCREPANCY` marker. The browser producer maps missing executables, missing dependencies, permission denial, timeouts, and other launch failures to the five documented safe causes; unknown raw output remains private. CI parity validates the existing `unit` and `integration` manifest checks together with their wrapper, without adding a profile or coverage report. QA further requires the stage command and final summary to preserve registered discrepancy state/cause/lifecycle counts and bounded profile lifecycle summaries. These are workflow obligations within TASK-029, covered by T048–T050 and the existing native unit inventory.

The profile retry guard must also recognize a changed browser executable as a real check-input change. Add optional `retry_env` to the verification manifest: validate unique, nonsecret environment names and bind their current values into the hashed check identity, never into receipts or failure output. Declare `CHROMIUM_PATH` and, under feedback 7, `AGENTFLOW_CODEX_SANDBOX_MODE` only for integration and E2E, where it changes the real browser launch. The environment value change then starts a new retry scope; repeated failures with the same path remain stopped.

The implementation owner must make the relevant diagnostic source correction before retrying integration. Planning edits alone do not authorize another attempt. Finish source, inventories and canonical design edits before the final manifest round; stale prior receipts are not proof for changed inputs. Run each manifest check through the helper, allowing explicit development reuse only if the helper validates freshness. Stop and diagnose two unchanged failures. Reach development readiness before independent QA; the previous develop handoff's suggestion that QA diagnose first is superseded by current feedback. QA reruns independently.

Current feedback 5 addresses isolated integration-runner failures in nested `catalog.seed` subprocess assertions. In `test/mix/tasks/catalog.seed_test.exs`, resolve the active `mix` executable per invocation and pass a controlled child environment: explicitly select the requested `MIX_ENV`, clear inherited `MIX_TEST_PARTITION`, and set bounded scheduler / sandbox-lock values. Keep the checked-in capability-denial and production-before-startup assertions. Register the focused environment regression in the existing integration inventory and allow only this exact compatibility test path in TASK-029 workflow scope. No application behavior or purchase acceptance changes.

## Feedback 7: Effective sandbox identity

Human feedback establishes a current environment distinction: Chromium launches from the terminal and Agentflow with the selected global danger-full-access mode, but fails with permission-denied under explicitly selected workspace-write. The historical effective mode is unknown; do not relabel its cause or compare it as though recorded. ADR-0035 and contracts/profile-diagnostics.md define the deterministic forward contract.

Extend scripts/agentflow_codex.py to resolve one closed sandbox mode before child startup, forward it explicitly, and overwrite inherited `AGENTFLOW_CODEX_SANDBOX_MODE` with that resolved value in the child environment. This variable is an output of launcher resolution, never evidence inferred from a browser error or an arbitrary inherited label. Preserve user-selected policy; no automatic retry in a broader mode. Default selection must respect the existing explicit user configuration, including the feedback's global choice; absent a configured choice use workspace-write. Unknown/conflicting policy must stop before a child is launched. Preserve frozen model/effort selection and existing network configuration semantics.

Add scripts/agentflow_codex.py, test/scripts/agentflow_models_test.py and docs/adr/0035-effective-sandbox-check-identity.md as exact additional TASK-029 workflow paths; reuse the already authorized helper/verifier, evidence-test, documentation, scope-test and inventory paths. Add native unit regressions for default/configured/explicit modes, malformed/conflicting flags, stale inherited identity overwrite, child argv/environment agreement, safe enum output and existing launch/model behavior. In test/scripts/agentflow_evidence_test.py prove mode changes alter integration/E2E identity, same mode remains stopped after two failures, unrelated variables do not reset budgets, and unset/invalid mode fails before these checks spawn. Only the closed selected mode may appear as sandbox diagnostic metadata; no config contents or paths.

verification.json declares `AGENTFLOW_CODEX_SANDBOX_MODE` alongside `CHROMIUM_PATH` in integration/E2E retry_env; never hard-code a selected sandbox in check.env. scripts/agentflow_check.py must reject missing/invalid mode for these declared checks before command execution; scripts/agentflow_verification.py retains the existing hashed retry environment identity. A manually invoked helper must use the actual selected session mode, not choose another label to obtain retries. Current session is workspace-write; planning does not change it. Implementation must perform the relevant launcher/helper corrections before the next authorized attempt, then use Agentflow with the user's selected policy and execute the full required manifest once. If browser launch still fails, retain the closed cause and stop at the normal retry limit. QA reruns independently under its actual recorded mode.

## Feedback 9: Codex approval preset compatibility

Codex CLI's `--approve-for-me` preset selects workspace-write and is incompatible with an explicit `--sandbox danger-full-access`. The launcher removes that preset only when forwarding the selected danger-full-access mode; the configured approval policy remains in force. It preserves `--approve-for-me` for other modes and never uses `--dangerously-bypass-approvals-and-sandbox`.

## Validation design and traceability

Every manifest check runs under `mise exec --` so child commands use the pinned Elixir 1.20.3 / OTP 29.0.6 and Node 24 toolchain; the disposable `_task029_20261023` partition remains selected. Incremental storage/domain/HTTP checks were temporary narrow selections, replaced by their containing full profiles after development. No required final check was removed. The revised unit expectation includes feedback-2–7 safe-diagnostic, launcher and retry-identity regressions; integration/E2E retain real browser preflight and fail closed on unavailable prerequisites. The catalog seed subprocess regression proves the QA partition does not leak into the child Mix environment.

verification.json owns actual argv arrays and every FR/SC mapping. No AC-n identifiers exist in this spec; the numbered story scenarios are mapped below. Owner executes every manifest check after final edits; QA reruns independently without reuse. Runtime checks fail on absent services and assert status/header/body and stored effects, not a bare request. One unit/integration full-profile pair plus one existing E2E profile; no historical CP1 or application-coverage report is added. Preserve CI and coverage infrastructure.

| Spec scenarios / invariants | Test oracle and ownership |
| --- | --- |
| US1.1–3; exact arithmetic, supply/isolation, preprovisioned funds | transfer_test.exs: exact initial-price transfer; quote_order_test.exs: 3*1.25=3.75 and failed-key recovery at the later quote; balances net zero, one ledger pair/transfer; other player/users unchanged; storage_test.exs guards |
| US1.4; inventory/balance/quote races | quote_order_test.exs and concurrency_test.exs: independent committed connections, barriers proving quote-first and purchase-first order; same-player inventory and cross-player buyer overspending; total supply and operation/quote equality |
| US2.1–4; buyer-scoped key, no rewrite | idempotency_test.exs and duplicate_race_test.exs: sequential/concurrent duplicate, conflicting player and quantity, separate buyers sharing key, lost acknowledgement and fresh-BEAM replay after quote/funds/inventory change |
| US3.1–7; no partial effect / failure-key retention | rejection_test.exs and rollback_test.exs: snapshot before/after, each rejection, injected failure after each mutation and deferred commit failure; retry same key after funds/inventory recovery uses later current quote |
| Request/key bounds, authority, self-purchase | input_test.exs and purchase_controller_test.exs: 128/129 Unicode characters, missing/blank/nonstring, quantity limits/floats/strings, malformed JSON/UUID, auth/overrides, distinct safe categories |
| Financial/quote append-only; restart retrieval | storage_test.exs ordinary UPDATE/DELETE/TRUNCATE and corrupt linkage attempts; idempotency_test.exs fresh process reads original operation after later activity |
| HTTP execution | test/runtime/purchase_http.exs uses isolated migrated schema, actual loopback Endpoint and real authenticated HTTP; readiness SELECT 1/Redis PING and bounded endpoint probe, persisted-state assertions and owned cleanup |

Concurrency tests must use separate committed connections/processes, never merely shared Sandbox ownership; explicit barriers replace timing sleeps. Provision non-production fixtures only. Failure injection stays in test-owned repository wrappers/transactions and cannot be supplied through a production request. Reuse established owned-resource registration/cleanup patterns; teardown must preserve unrelated schemas. Add targeted boundary architecture assertions alongside controller tests to catch financial Repo access from the adapter; keep persistence inside Market.

## Delivery and checkpoint coverage

TASK-010 auth, TASK-026 quotes and TASK-028 issuance remain dependency contracts. CP2 direct trading is completed by all three stories; isolated success-only US1 is the development MVP, not releasable without idempotency/rejection. Existing separate unit/integration/E2E profiles remain required safeguards; charts, sale, history presentation and conditional orders belong to their existing tasks. No CP3 cache, monitoring, funding or provider work enters this boundary.

## Complexity Tracking

No constitutional violations. The new financial tables and shared-recipient serialization are necessary for durable exact transfer and audit; projections and evidence are distinct because mutable balances cannot serve as immutable history. Risks: lock-order drift by future writers and false race tests; ADR-0032 and committed barrier regressions address both.

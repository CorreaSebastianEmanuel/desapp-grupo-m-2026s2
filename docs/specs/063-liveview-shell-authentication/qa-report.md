# Independent QA — TASK-046 / PR #39 CI correction

2026-10-16. Branch `046-liveview-application-shell-and-authentication`; feature `specs/063-liveview-shell-authentication`; HEAD `c2b46738778f2e1687a9a5fa1e2e67be788f6384` plus the frozen correction. Previous QA/review verdicts were not acceptance evidence. Reviewed AGENTS, context/verification policies, PRODUCT, ARCHITECTURE, CHECKPOINTS, constitution, full canonical spec/plan/tasks/manifest/contract, current feedback, architecture/development handoffs, ADR-0026, affected file diffs, new JavaScript sources and actual lifecycle/runtime assertions.

## Executed acceptance

Every check ran as `python3 scripts/agentflow_check.py CHECK_ID --stage qa`, without reuse; DB suites ran sequentially. Local bind and PostgreSQL at 15432/Redis at 6379 succeeded before checks. The initial default-port 5432 probe was refused; discovery confirmed the existing configured 15432 mapping, with no permission denial or service mutation.

| Check | Outcome | Seconds | Canonical receipt |
| --- | --- | ---: | --- |
| preflight | PASS | 2.406 | `handoffs/check-preflight.json` |
| format | PASS | 0.787 | `handoffs/check-format.json` |
| compile | PASS | 0.676 | `handoffs/check-compile.json` |
| openapi | PASS | 0.631 | `handoffs/check-openapi.json` |
| unit | PASS | 21.912 | `handoffs/check-unit.json` |
| integration | PASS | 174.265 | `handoffs/check-integration.json` |
| foundation | PASS | 1.630 | `handoffs/check-foundation.json` |
| feature | PASS | 9.031 | `handoffs/check-feature.json` |
| javascript | PASS | 0.170 | `handoffs/check-javascript.json` |
| ci | PASS | 168.400 | `handoffs/check-ci.json` |

Total check time: 379.908s. No failed check executions, retries, counter resets or source/design changes. All receipts share source fingerprint `4029989e1ddb13f82713beee68109a1f66e8a8d043321499c24820d8488ff35c` and canonical-input fingerprint `d8107ba6f4519bd36ccb2adc326a2c59b2d80f0d9483fa32663ccb61478a779d`. Each receipt records command identity, timing, evidence path and output SHA-256. Consolidated receipts/hashes: `qa-evidence/ci-correction-independent-20261016/summary.json`. Raw run logs were not inspected; no assertion about new suite totals is inferred from the earlier 547-test CI count.

## CI-failure disposition and adversarial review

- Optional metadata: the actual Market scope reader handles absent/read-error, malformed JSON and unexpected shapes as nil; only string metadata is returned. Executed temporary-file regression covers missing/malformed/array/empty object/non-string/valid string cases without touching the real pointer. Nil and unknown features still obtain no shell allowances; other feature scope guards retain their explicit inventories. Clean CI needs no local pointer because a clean checkout has no changed worktree paths to authorize. Exact CI entry point now passes locally. Real pointer SHA-256 remained `d4e015bc34244c73efbd406ad84ad9abe253b0b72b75060aa0c845c0b6370a57`.
- Browser lifecycle: the injected factory encloses recovery state per instance and preserves the production export, event registration and app hook wiring. Tests execute that export first, then independent injected instances. Assertions verify immediate private DOM removal, socket disconnect, one safe no-store same-origin read, duplicate recovery suppression, 500ms failed-read retry, history events, workspace-only network events and absent socket/notice. `void retry()` explicitly handles the internally caught detached operation; no behavior or authority is added.
- Native coverage: inspected generated LCOV, not merely configuration strings: real `assets/js/workspace_session.js`, 35/35 lines, 21/21 branches, 10/10 functions, no zero-hit lines/branches. SHA-256 `58f4bbad03dfb5d4efe08e9a707d3fefe755070228ffb82332b23b6180895257`. Evidence copy: `qa-evidence/ci-correction-independent-20261016/workspace.lcov.info`; generated report is ignored at `cover/workspace/lcov.info`. Runner uses Node's native coverage reporter and enforces all three 100% thresholds. Isolated /tmp copies of the exact runner returned exit 1 for an intentional assertion failure and for successful but incomplete module execution. No production/test inputs were changed for these probes.
- Workflow: Node 24 setup is SHA-pinned and coverage executes before the unchanged pinned scanner with native quality-gate wait/timeout. SONAR_TOKEN exists only in scanner/gate step environments, outside JS execution; no job-wide token or new source exclusion/coverage exclusion. Failure propagation remains enabled. Scope allowance grows exactly 34 to 36 for the documented workflow and contract test. No financial/domain/provider source changed.
- Quality baseline SHA-256 `4651228af0e897a2c6bad41c5a7c2778fe467fd4dc272701b9a814e40559915a` matches its unchanged byte oracle. Config SHA-256 `1a347fb56ebd241dd8103d2edb241dde19b5d14d2377e0edab55762759d3b78f` is unchanged; executed scope tests preserve normalized oracle `b2f9904816f5efed3b630e782e7519058f96b18dc8b5d101dcbeb81ec8577251` and reject unrelated config mutations.

## Requirements and browser stories

FR-001–002 / SC-001: normalized email with exact password, generic invalid failure/password clearing, anonymous authority rotation/retirement, stale authenticated form isolation and simultaneous retirement assertions. FR-003–006 / SC-002,004: microsecond-before/exact/after exclusive deadline, no renewal, revoked/tampered replay denial, callback guards, subscribe/revalidate race, periodic fallback, missing accounts/outage, independent session/API survival and trusted actor ownership denial.

FR-007–008 / SC-003: both direct destinations and active shell identity, exact safe returns, honest placeholders, no financial controls. FR-009–011 / SC-005: decoded mount payload/telemetry secrecy, escaped text, no-store/HttpOnly/SameSite/deployment Secure settings, sequential missing-CSRF then hostile Origin rejection, forged websocket 403, denial 403 without foreign content and usable recovery, revoke failure retaining retry authority before committed invalidation.

FR-012–015 / SC-004–006: real Chromium runs independently via integration and feature checks. Assertions cover two users/tabs, logout/expiry removal <=2s, history/account switching, changed persisted state after reconnect, buffered event non-replay, offline concealment, transport explicitly removed and confirmed absent before ended notice and successful re-login, keyboard sign-in/navigation/sign-out, focus/labels/field errors/live feedback and 1280x800 width. Public routes and cookie-only API rejection remain covered alongside existing credential precedence regressions. These satisfy the manifest mappings and four product-challenge findings without adding business scope.

## Limits and disposition

No remote GitHub CI or SonarCloud execution was performed or claimed; the code is unpushed. Local native coverage proves execution, not remote importer acceptance or resolution of the service-reported issue. Browser history was exercised; persisted pageshow/bfcache dispatch is covered deterministically by native tests, without claiming Chromium necessarily used a real bfcache snapshot. Removal deadlines are asserted <=2s; the harness does not publish individual timings. Broader responsive UI, charts/orders and CP3 remain outside this task. No CP1 report/new CI job, implementation/design/manifest/workflow edits, delegation, Agentflow invocation, commits, push, PR mutation or merge occurred.

No concrete acceptance blocker found. T028 complete; T029 remains pending for a separate fresh reviewer before updating the existing PR.

Verdict: PASS

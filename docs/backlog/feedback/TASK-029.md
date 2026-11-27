# Feedback — TASK-029

## Feedback 1

- Time: 2026-10-23T16:25:13+00:00
- Author: ezequielgonzalez
- Restart from: product
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

Product decision: buyers may purchase only from credits already provisioned in their account. Funding, deposits, withdrawals, and credit grants are outside TASK-029; tests may provision buyer balances as setup.

## Feedback 2

- Time: 2026-10-23T18:42:47+00:00
- Author: ezequielgonzalez
- Restart from: architecture
- Impact: verification
- Required regressions: cited discrepancy plus required manifest checks

Human authorization: complete TASK-029, including a narrowly scoped change to shared test-profile browser preflight diagnostics needed to make browser-prerequisite failures actionable. The integration check failed twice before ExUnit execution with category browser-prerequisite; the handoff names both attempts. Reproduced the exact Node 24.21.0, TMPDIR, and integration environment locally and Chromium launch now passes. Extend the profile runner and safe evidence reporting to emit only allowlisted, non-sensitive launch cause categories, add regression tests, and update TASK-029 workflow scope/plan/verification accordingly. Do not expose raw Playwright errors, alter application purchase behavior, bypass or reset retry guards, or mark checks complete without execution. Once this relevant source change is made, rerun integration and all remaining checks through the existing helper; reach development readiness before independent QA/review.

## Feedback 3

- Time: 2026-10-23T19:30:36+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Development feedback: the allowlisted diagnostics now identify integration and E2E failure cause permission-denied before browser acceptance. The exact pinned Node 24.21.0 profile environment can launch Chromium from the parent shell, and /Applications/Google Chrome.app/Contents/MacOS/Google Chrome also launches successfully. The existing OpenAPI browser adapter already honors CHROMIUM_PATH. Extend the profile-runner preflight to use CHROMIUM_PATH when set and preserve Playwright's pinned default when unset; add red/green regression coverage for both paths, update exact TASK-029 scope and inventory/verification as needed, then resume with inherited CHROMIUM_PATH set to the verified system Chrome. Preserve all browser gates and retry limits; do not weaken checks or alter purchase behavior.

## Feedback 4

- Time: 2026-10-23T21:41:52+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: UNIT, INTEGRATION, E2E

QA remediation authorized: classify Node real module-resolution failures (including Cannot find module / MODULE_NOT_FOUND) as dependency-missing with a regression; add the missing concurrent quote-first purchase ordering test. Reproduce QA unit and browser failures with TMPDIR set to the repository local tmp directory and CHROMIUM_PATH set to the launchable workspace Chromium; correct invocation/environment causes without editing unrelated coverage behavior or weakening profile gates. Run current required manifests and reach fresh independent QA/review.

## Feedback 5

- Time: 2026-10-24T00:41:25+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: INTEGRATION

QA final integration failed only at catalog.seed subprocess assertions; local focused rerun with the same QA partition and local TMPDIR passed. Diagnose the isolated QA runner difference and make nested Mix invocation deterministic while preserving all disabled capability and production startup assertions. Add focused regression; run integration and current manifest checks before fresh QA/review.

## Feedback 6

- Time: 2026-10-24T04:55:31+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: UNIT, INTEGRATION, E2E

Fresh QA found a real malformed-key defect: authenticated POST with request_key containing NUL returns 503 although spec FR-012/SC-006 requires 400 invalid_request; the byte reaches PostgreSQL text storage. Validate unsupported text bytes before persistence and add focused domain plus real HTTP regressions, asserting unchanged snapshots. QA also found safe_failure_diagnostics returns {} for PROFILE_DISCREPANCY because its early-return omits parsed discrepancies; fix and test strict allowlisting. Finally diagnose QA child Chromium launch-failed/permission-denied: preserve browser gates, reproduce exact nested profile environment, and make the configured launch work or report the concrete blocker without bypass. Rerun required manifests and fresh independent gates.
## Feedback 7

- Time: 2026-10-24T18:27:06+00:00
- Author: ezequielgonzalez
- Restart from: architecture
- Impact: verification
- Required regressions: cited discrepancy plus required manifest checks
- Checks: INTEGRATION, E2E

Diagnostic follow-up: the official Chromium preflight passes from the Mac terminal and through the Agentflow launcher under the global danger-full-access configuration; it fails with permission-denied when workspace-write is explicitly selected. The historical run does not record its effective sandbox, so the failure mode cannot be compared reliably. Bind the effective Codex sandbox mode to integration/E2E retry identity, ensure the launcher forwards the selected mode deterministically and exposes only the closed mode value, and add regression coverage for default/explicit selection and identity changes. Preserve retry limits, browser preflight, and privacy; do not weaken profile checks. After this relevant environment input is represented, run the required checks through Agentflow.

## Feedback 8

- Time: 2026-10-24T18:50:45+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: INTEGRATION, E2E

The feedback-7 implementation correctly resolves and forwards the configured sandbox for newly launched Codex stages, but the development session that produced it was still running under workspace-write. Its integration attempts therefore used the old effective mode and failed at the browser preflight. Re-enter development in a fresh Agentflow stage so the launcher explicitly selects the configured danger-full-access mode and sets AGENTFLOW_CODEX_SANDBOX_MODE; execute integration/E2E only after confirming the launched mode, and rely on the declared retry_env identity change rather than resetting prior attempts. Preserve all gates.

## Feedback 9

- Time: 2026-10-24T18:52:54+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: UNIT, INTEGRATION, E2E

Codex CLI rejects --approve-for-me together with --sandbox danger-full-access; --approve-for-me selects the workspace-write sandbox and caused the new development launch to exit before checks. Update the launcher to resolve the configured approval policy, remove this incompatible flag only when the selected danger-full-access mode is paired with approval_policy=never, and otherwise fail closed with a safe message. Add regressions for the conflict and approved removal. Do not use --dangerously-bypass-approvals-and-sandbox. Keep sandbox mode bound to integration/E2E retry identity; preserve retry guards.

## Feedback 10

- Time: 2026-10-24T20:15:43+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: UNIT, INTEGRATION, E2E

QA independiente 2026-10-24: siete discrepancias del perfil unitario repetibles se concentran en application_coverage_test.py, pero el runner solo publicó discrepancias en línea 0 sin aserción ni causa específica; conservar los dos intentos y no repetir sin cambio causal. Además, launcher_adversarial confirmó que sandbox_launch_args elimina --approve-for-me con approval_policy on-request y untrusted, cuando solo está autorizado retirarlo con danger-full-access + approval_policy=never, y resolve_sandbox_mode acepta en silencio --sandbox danger-full-access junto con -c sandbox_mode=workspace-write. Corregir ambas políticas con rechazo seguro y regresiones; obtener la evidencia detallada de las discrepancias unitarias o mejorar el reporte allowlisted para mostrar sus causas, sin filtrar salidas sensibles. Mantener retry guards y gates requeridos; volver a correr perfiles solo después de cambios relevantes.

## Feedback 11

- Time: 2026-10-26
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: publication path containment and TASK-029 exact-path scope assertions

Human decision: include the existing `scripts/application_coverage.py` publication-path containment hardening and its regression coverage in TASK-029. Document the narrow security scope in plan/tasks, retain the exact-path allowlist, and rerun development plus independent QA/review gates before delivery.

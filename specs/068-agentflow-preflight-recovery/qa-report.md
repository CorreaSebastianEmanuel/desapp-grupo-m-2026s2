# Independent QA — TASK-070

## Fresh manifest history

| Attempt | Result | Elapsed | Safe CI profile diagnostic |
|---|---|---:|---|
| QA 1 | 20/21 passed; `ci_profiles` failed | 620,056 ms | Generic `profile`, `test-failure` |
| QA 2 | 20/21 passed; `ci_profiles` failed | 624,686 ms | Generic `profile`, `test-failure` |
| QA 3 | 20/21 passed; `ci_profiles` failed | 629,987 ms | Integration profile, `profile` and `test-failure`; no registered case identity |
| QA 4, latest source | **21/21 passed** | 1,333,820 ms | `ci_profiles` passed in 1,224,461 ms |

The earlier failed attempts referenced `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/ci_profiles/cf6764305ece45cc9bd46e978bba3406.log`, `.../c58f0fa12a1f46168b09df54735bfbd5.log`, and `.../3c7c36e1560b47028b52e810059b5e36.log`, respectively. Their generic/safe profile failure categories and QA 3 attribution are preserved above. Latest QA ran after the command-step/partition diagnostic and integration-partition changes.

## Latest fresh QA 4 outcomes

Invocation: `PATH=/Users/ezequielgonzalez/.nvm/versions/node/v24.22.1/bin:$PATH python3 scripts/agentflow_stage_checks.py --stage qa` (no reuse). Safe summary: `python3 scripts/agentflow_stage_checks.py --summary --stage qa` — 21 required checks, 21 passed, 0 failed, 0 blocked. No development receipts were reused.

| Check | Result | Evidence |
|---|---|---|
| `plan-artifacts` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/plan-artifacts/78fdc8ffe8f04cd5af095df389885d0f.log` |
| `ci-parity` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/ci-parity/02af9915a6b9480d862b671a881df50f.log` |
| `services` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/services/fa2a19d7bbd34e4a93f2c32dc3728f6c.log` |
| `launch-preflight` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/launch-preflight/32f02a3632f1405c841829e334e47b01.log` |
| `toolchain` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/toolchain/cb8bb8fa6ed144719937395f0203b463.log` |
| `format` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/format/ce94bde663474e52897742a5df126f99.log` |
| `compile` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/compile/73df3a4e25cb4d0d88a1ba5c91bd06e4.log` |
| `credo` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/credo/1fc53baaf6da440788504632c8f1234b.log` |
| `assets` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/assets/254dd467e49a41fcbb030f0313811f79.log` |
| `database` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/database/d1a00ede6c0841d4aa99e5eb1e9578b4.log` |
| `preflight-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/preflight-tests/c120fa97dd9e4f09873aaf5bebd8e6e1.log` |
| `provider-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/provider-tests/6ca9003b394744cc8179d33f6e315d2e.log` |
| `continuation-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/continuation-tests/4af025ba1178472c94b1b9a16c8ca7c7.log` |
| `evidence-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/evidence-tests/a91c1f10991541e5809a136d0614fa71.log` |
| `recovery-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/recovery-tests/6af5b915b23040c28f37ce8afd3ea8cc.log` |
| `feedback-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/feedback-tests/cf7c3eebb4134742a1a38396a3dee862.log` |
| `dedup-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/dedup-tests/6c4628f318534556819e8a0655ff70ee.log` |
| `policy-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/policy-tests/e628c839d8fb43fd97440cd7e9b370dc.log` |
| `legacy-tests` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/legacy-tests/f7f6ec8c637f44c283810f5b822b3e03.log` |
| `inventory` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/inventory/269224ee89a34f9daaac8aec77f96966.log` |
| `ci_profiles` | passed | `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/qa/ci_profiles/46f28d4eaa084c8292095a392c02549e.log` |

## Independent acceptance review

Reviewed the four P1 stories, FR-001–FR-013 and SC-001–SC-007 against `verification.json`, `plan.md`, `data-model.md`, the recovery contract and the new profile-specific regressions. Focused checks cover effective child context, safe diagnostics and redaction, independent check continuation and dependency blocking, interruption/partial-report behavior, same-input retry scopes and concurrent stage locks, feedback routing, duplicate-run parity, legacy/provider compatibility, and HTTP runtime assertions.

The profile diagnostic test asserts that only allowlisted profile/step/partition data and registered identities are returned; unregistered values and canary traceback text are discarded. The runner test verifies committed integration files are separated into distinct Mix partitions with `test.prepare`, while coverage mode retains its intended combined invocation. The affected `test/football_market/quotes/outcomes_test.exs` remains four registered integration cases; direct comparison with baseline `HEAD` confirmed its IDs, identities, and profile assignments are unchanged. `test/support/test_profile_audit.ex` lists the file among committed integration files, and the fresh full CI profile pair passed.

No unresolved acceptance gaps remain. No raw run logs were inspected. Current check results come from the safe stage summary; profile-specific history came from the safe registered-diagnostic interface. Scope remains workflow tooling; no market application behavior was changed.

Verdict: PASS

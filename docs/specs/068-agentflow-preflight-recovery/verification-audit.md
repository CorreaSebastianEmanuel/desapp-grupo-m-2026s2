# Verification and launch audit — TASK-070

## Current execution identities

| Consumer | Current command/context | Source and stage | Planned current invocations |
|---|---|---|---|
| Local baseline (`ci_baseline`) | `MIX_ENV=test scripts/ci_unit_tests.sh`; absent filter executes `unit` then `integration` via `scripts/test_profile.sh`, receipt validation and private output capture | delivery workflow, after `develop_ready`; workflow runner snapshot may retain this step | Replace with read-only wrapper/manifest parity; zero native profiles |
| Development manifest (`ci_profiles`) | `scripts/ci_unit_tests.sh` with `MIX_ENV=test`; script prepares private receipts and runs both profiles | `specs/068.../verification.json`, development receipts bind workspace, feature, stage and current source | One unit+integration pair per frozen source state; reuse only intact current development receipt |
| Independent QA | Same manifest command in a distinct `qa` stage | independent QA session and report | One fresh unit+integration pair; development receipt cannot satisfy it |
| Remote CI quality baseline | `scripts/ci_unit_tests.sh` with CI receipt directory after database preparation | `.github/workflows/quality-baseline.yml` | Preserved; not locally inferred from parity |
| Remote E2E | `mix test.prepare`, then `sh scripts/test_profile.sh e2e` | `.github/workflows/quality-baseline.yml` end-to-end job | Preserved; distinct runtime obligation |
| HTTP acceptance | No endpoint is introduced by TASK-070; runtime assertions remain enforced by manifest validation whenever a spec/contract declares a route | `scripts/agentflow_verification.py` contract detector and runtime check metadata | No new TASK-070 HTTP request |

## Launch and receipt consumers

`agentflow.monitor_process` creates provider shims and launches the Specify workflow. `start` and `resume` prepare task/model assignment state before invoking it. `scripts/agentflow_codex.py` and `scripts/agentflow_opencode.py` apply stage model arguments and each launch a provider process. Preflight must gate the outer workflow child and both actual provider spawn points; matching checks are required for the final argv, cwd and environment. Existing per-check receipts are written by `scripts/agentflow_check.py`; no stage-wide receipt currently exists. Current check identities cover argv/env; source freshness uses git-listed inputs and feature canonical artifacts.

## Required adaptation and counts

The manifest retains one `ci_profiles` obligation, whose wrapper invokes exactly two native profiles (unit and integration) in a successful development run and again in fresh QA. The current workflow baseline adds a second unit+integration pair locally. The parity replacement must compare both workflow copies, the active manifest command/env and the CI wrapper contract, while invoking only the isolated shell contract fixture. It must never call a native profile or count as a receipt. The legacy resume adapter may translate only the known baseline step in memory; snapshots remain byte-identical and unknown commands refuse.

## Fixture measurements and current check evidence

The parity check executed its isolated wrapper contract fixture once (2.555 s) and reported `native_profile_runs=0`; the fixture launches stub profile children only. The registered static scheduler test measured a controlled two-command fixture serially at 124 ms (peak 1 worker) and with two workers at 93 ms (peak 2). This is one short fixture observation, not a general speed claim. The focused check receipts are under `.agentflow/runs/checks/21a2d61a625d48d88df73020985e5e95/068-agentflow-preflight-recovery/develop/`; see `ci-parity/31f1700817fb46da93dcc2bf6d736253.log` and `continuation-tests/6941ab8e3dc6408180f1245204cb425e.log`.

No native unit/integration pair, E2E profile, live HTTP check or provider call has run in development yet. Once the manifest is frozen, the intended local profile invocation count is one unit+integration pair in develop and one fresh pair in independent QA; remote CI and E2E remain separate. Current test identities and full source list remain discoverable from `config/test_profiles.json` and the feature manifest; this feature registers workflow tests without moving existing assignments.

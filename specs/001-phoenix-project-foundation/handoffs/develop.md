# Development Handoff: Phoenix Project Foundation

## Result

TASK-001 implementation is complete and ready for fresh independent QA. Development incorporated both human-feedback cycles, including the latest delivery rule: clean-checkout acceptance was exercised in an isolated source snapshot containing the complete pending feature diff and excluding ignored build artifacts. No commit, push, PR, or merge was performed.

T001–T020 remain complete. T021 remains intentionally pending because the constitution requires fresh, independent QA and final-review owners; the sole implementation owner cannot manufacture those verdicts.

## Changes and decisions

- Kept the root Phoenix modular monolith, database-independent startup, inert `FootballMarket.Repo`, loopback-only development endpoint, application-owned default page, endpoint contract test, bounded HTTP oracle, shell failure tests, exact toolchain checker, and contributor lifecycle documentation.
- Removed the incomplete `ecto.setup` and `ecto.reset` Mix aliases. TASK-001 neither activates persistence nor provides migrations or seeds; retaining those aliases contradicted the approved plan and prior handoff claims.
- Kept `mix setup` limited to dependency and asset preparation. No standard contributor command contacts PostgreSQL or Redis.
- Changed `spec.md` lifecycle metadata from `Draft` to `Review Ready`. Branch creation and Git provenance remain Agentflow responsibilities after both verification gates pass.
- Verified `.gitignore` covers Mix outputs, dependencies, generated assets, environment files, credentials, logs, and editor artifacts. No Docker, ESLint, Prettier, npm-publishing, Terraform, or Helm ignore file is applicable.
- Used a tar snapshot generated from `git ls-files --cached --others --exclude-standard`, so QA receives the complete pending deliverable while ignored runtime/build artifacts remain absent. This follows human feedback without requiring an implementation commit.

## Commands and results

All Elixir commands selected `/private/tmp/elixir-1.20.3-otp29/bin` first in `PATH` to use the exact documented toolchain.

| Command/check | Result |
|---|---|
| `./scripts/check_toolchain.sh` | PASS; Elixir 1.20.3, OTP 29.0.3, ERTS 17.0.6, Mix 1.20.3. |
| `mix deps.get --locked` | PASS; lock resolved unchanged. |
| `mix assets.setup && mix assets.build` | PASS. |
| `mix format --check-formatted` | PASS. |
| `mix compile --warnings-as-errors` twice | PASS on both runs. |
| `mix test` | PASS; 5 tests passed. |
| `test/scripts/verify_foundation_test.sh` | PASS; 5 oracle success/failure cases passed. |
| `git diff --check` | PASS. |
| Isolated pending-diff snapshot preparation and complete suite | PASS; `_build/`, `deps/`, and `priv/static/assets/` were absent before preparation. |
| Final 186-source-file snapshot after handoff updates | PASS; fresh preparation, two compiles, and `mix precommit` passed. |
| Isolated `mix precommit` | PASS; 5 tests passed. |
| Disposable wrong-marker test | Expected FAIL; exit 2, `Assertion with =~ failed`, `Result: 4/5 passed`. |
| Isolated HTTP lifecycle, cycle 1 | PASS; ready in 5s, HTTP 200 + marker, stopped in 1s, post-stop curl exit 7. |
| Isolated HTTP lifecycle, cycle 2 | PASS; ready in 4s, HTTP 200 + marker, stopped in 1s, post-stop curl exit 7. |

The first sandboxed Mix command could not acquire its TCP filesystem lock (`:eperm`). The identical suite passed after granting Mix the execution permission required for that local lock; this was an environment restriction, not an application failure.

## Risks

- A fresh dependency compilation prints diagnostics originating in locked upstream packages under Elixir 1.20.3. The required application command `mix compile --warnings-as-errors` exits 0; QA should preserve and report this distinction.
- Dev/test Repo configuration contains inactive generated `postgres` placeholders. Repo is not supervised, tests do not start SQL Sandbox, and the documented lifecycle has no database command.
- The pending deliverable remains intentionally uncommitted. QA must assess the isolated complete-diff snapshot, not a clone containing only the current `HEAD`; Agentflow establishes feature-branch provenance only after QA and review pass.
- Existing `qa-report.md`, `handoffs/qa.md`, `review-report.md`, and `handoffs/review.md` are stale FAIL artifacts from before this feedback-driven pass. They must be replaced only by fresh independent sessions.

## Exact guidance for QA

1. Read the governing docs, all feature artifacts and handoffs, `backlog/feedback/TASK-001.md`, and this handoff. Treat the latest human feedback as authoritative over stale QA/review assumptions.
2. Build an isolated snapshot from `git ls-files --cached --others --exclude-standard`; verify ignored `_build/`, `deps/`, and `priv/static/assets/` are absent. Do not require a feature commit before the two verification gates pass.
3. Select exact Elixir 1.20.3 with OTP 29.0.3/ERTS 17.0.6. Run `./scripts/check_toolchain.sh`; any mismatch is a failure.
4. In the isolated snapshot, follow README preparation, then run `mix format --check-formatted`, two `mix compile --warnings-as-errors` invocations, `mix test`, `test/scripts/verify_foundation_test.sh`, and `mix precommit`.
5. Confirm five ExUnit tests run and the page test crosses the Phoenix endpoint, asserting HTTP 200 plus `Football Player Market`.
6. In a disposable copy, change only the expected marker; require `mix test` to exit nonzero and leave the implementation unchanged.
7. With PostgreSQL and Redis unavailable and port 4000 initially free, start `mix phx.server`; require a real loopback GET to return 200 and the marker within 30 seconds. Interrupt it, require exit and port release within 10 seconds, require post-stop curl failure, then repeat the full start/probe/stop cycle.
8. Confirm `FootballMarket.Repo` is absent from application children; confirm `ecto.setup`/`ecto.reset`, migrations, seeds, business entities, external adapters, later-backlog features, secrets, and generated assets are absent from the deliverable.
9. If acceptance passes, replace the stale QA artifacts with fresh reports ending exactly `Verdict: PASS`, then hand the unchanged implementation to a separate final reviewer. QA and review must not modify implementation.

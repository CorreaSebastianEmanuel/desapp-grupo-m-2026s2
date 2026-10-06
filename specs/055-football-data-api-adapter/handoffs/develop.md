# Develop handoff — TASK-017 feedback 2

## Changes and decisions

`FootballData.Errors` now retains HTTP-date differences in microseconds and uses the same unit for delta/reset source expiries. Public milliseconds are floored from the remaining source interval; Runner continues refining at complete normalized readiness. Numeric status classification, header precedence/duplicates/fallback, public Error, deadline/cancellation rules, legacy adapters and original TASK-016 fixtures remain protected.

`retry_expiry_test.exs` adds FD-E05-B2 full-facade literal oracles: four fractional UTC receipts, three independently varied monotonic origins, parsing-only/normalization-only/split costs, positive/exact-1-ms/sub-ms/exact-expiry/expired waits, later UTC changes and repeatability. `verification.json` retains all 23 requirement mappings and records this stronger retry-expiry expectation. Feedback EOF formatting is corrected.

## Command evidence

The new portable regression failed before correction (999 versus 1000 ms) and passed afterward. Original review and QA probes are preserved under `/tmp/task017-review/http-date-precision.exs`, `/tmp/task017-independent-qa/delay-acceptance.exs` and `delay-http.exs`; local rerun outputs are `/tmp/task017-develop-http-date-precision.log`, `delay-acceptance.log` and `delay-http.log`.

Owner acceptance runs every manifest check through `python3 scripts/agentflow_check.py CHECK_ID`, including service preflight, real TLS runtime, regression, both profiles and coverage. Canonical command outcomes/freshness/output hashes are in `handoffs/check-*.json`; full output paths are referenced there. T044 requires final develop readiness and the named-artifact audit. No commit/publication occurs in this stage.

## Residual risks and exact QA guidance

Rerun all 20 manifest checks independently and the three preserved probes. Challenge fractional receipt 2026-10-06T12:00:00.000999Z with readiness offsets 999001/1998001/1999001 us: expected 1000/1/nil ms. Confirm parsing and later normalization each consume the original window, without wall-clock renewal; test sub-ms unknown waits and unchanged fallback semantics. Recheck original 217 fingerprints, constrained Runner guards, legacy equality, strict deadline/caller cancellation and peer-observed socket closure, including HTTPS Retry-After:1 with 1200-ms normalization.

Live subscription feasibility, request cost, snapshot roster consistency, unsupported historical squads/performance and incomplete CP2 valuation remain as documented in `docs/FOOTBALL_DATA.md`. Only independent QA/final-review tasks remain downstream; fresh terminal PASS verdicts are required before publication.

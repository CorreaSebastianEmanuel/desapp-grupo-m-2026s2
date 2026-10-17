# QA Handoff — TASK-021

## Verdict summary

Independent QA (stage qa, no `--reuse`) re-ran all five manifest checks on the remediated tree: preflight 2.3s, format 1.5s, compile 0.8s, unit 34.8s (58 modules), integration 363.8s (117 modules) — all PASS. All three prior findings (QA-01 replay mapping conflict/pointer advance, QA-02 JSONB string vs typed maps, QA-03 late child basis guard) are remediated and verified at code, test, and live-database level. Full evidence: `specs/065-statistics-ingestion-pipeline/qa-report.md`.

## Blockers

None.

## Residual risks (non-blocking)

1. No literal non-object `frequencies` JSONB test variant in `integrity_test.exs`; the rejection is database-enforced (`statistics_position_basis_validate`, `jsonb_typeof` check) and was live-verified by a rolled-back psql probe. Cosmetically nice-to-have test, no behavior gap.
2. `verification.json` runtime_required=false holds: the feature diff touches no web router/controller/endpoint. Final review should confirm nothing in later commit branches adds an HTTP surface.
3. Integration must still run with Node 24 on PATH (`~/.nvm/versions/node/v24.21.0/bin`); a missing PATH fails fast with `category=node-runtime`, not a test regression.

## Reviewer guidance

- Verify responses to the replay/unchanged conflict path keep `last_accepted_check_id` and observation counts unchanged (replay_test.exs:109-127) and that review does not mistake the DBReset remediation (stale `leagues_normalized_code_index` violations followed by documented `ecto.drop`) for a regression.
- Favor targeted risk checks on frozen position evidence against concurrent later imports and calculation-dispatch exhaustion paths rather than re-running both audited full profiles.
- Preserve feedback 5 discipline: no receipt reuse by later gates that fail to refresh artifacts; a returning FAIL must name the surviving finding.

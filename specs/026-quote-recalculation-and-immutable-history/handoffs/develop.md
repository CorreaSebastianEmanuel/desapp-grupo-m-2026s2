# Develop delta — TASK-026

Implementation and all seven developer checks are complete; readiness passed. Only independent QA/review remain downstream.

Feedback 17: added forward-only `priv/repo/migrations/20261018001100_require_successful_quote_confirmation.exs`. Its initially deferred INSERT constraint requires exactly one matching performance quote/evaluation for a successful calculation. Existing unique indexes enforce cardinality; player, configuration, mapping, price and effective time must match. No scoring or interface changes. Kept the existing deletion guard and post-lock database-clock lease fixes from feedback 15–16.

`test/football_market/quotes/immutability_test.exs` now commits the adversarial direct INSERT: rejection must occur at commit, roll back the orphan, preserve the original persisted calculation and leave financial state unchanged. Updated exact scope allowances, test inventory, plan migration inventory and task scenario mapping.

All checks use `python3 scripts/agentflow_check.py CHECK_ID --reuse`; these final receipts executed freshly. Evidence root: `.agentflow/runs/checks/a51aee7448d14823adfa2fce949af473/026-quote-recalculation-and-immutable-history/develop/`. Each entry is `CHECK_ID/UUID.log`.

| Check | Exit | Seconds | UUID |
|---|---:|---:|---|
| preflight | 0 | 1.525 | 26cca8f424db4c23a8f540732f5a5669 |
| format | 0 | 1.343 | 4284e91b008f4b8a920e437e66e526bc |
| compile | 0 | 0.913 | 87d9ca55a5f54623bf1c3e3820d0e774 |
| quote-regressions | 0 | 75.643 | fb6c5b07c8aa49a0b3df435537b61b8c |
| unit | 0 | 287.224 | bde12051d7b442a388478f2e671110a9 |
| integration | 0 | 727.011 | d420290920834f42b8af35a429239087 |
| runtime | 0 | 12.572 | 3fc660a082e74dbca07c989f5046575e |

Regressions: 25 passed; unit: 495/495; integration: 482/482; runtime: QUOTE_RUNTIME_ASSERTIONS_PASS (fixture-module reload warning). Final checks: 1106.231s; all helper attempts: 1305.452s. Integration first failed at browser-prerequisite (42.641s, `integration/65f09d2c784c4e6395de1d9e3991d883.log`); the permitted retry outside the restricted sandbox passed. No check was weakened.

Earlier evidence: `quote-regressions/3cbf87e6e44a41a3a49d24f931d95eae.log` reproduced the orphan (75.339s); `quote-regressions/f8203736128642f3b9cac06421464484.log` showed enforcement worked but a test compared built/loaded Ecto metadata (75.495s); corrected by reading the original persisted row before comparison.

Residual scope: migration protects new inserts, without historical repair. QA must rerun the manifest with `--stage qa`, without reuse, and independently challenge direct SQL linkage, delete protection, blocked calculation/ACK expiry, atomic rollback, replay and restart. QA/review gates remain open. No commits or publishing.

`python3 scripts/workflow_artifact_probe.py develop --readiness`: exit 0, valid=true, 0.608s; evidence `tmp/task026-develop-readiness.log`. T001–T029 reconciled against named files; only T030/T031 unchecked. No extension hooks registered.

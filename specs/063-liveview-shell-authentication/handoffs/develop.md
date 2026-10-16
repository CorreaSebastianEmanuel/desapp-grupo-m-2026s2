# Development delta — TASK-046

Implemented the existing spec/plan: digest-only PostgreSQL browser sessions,
exclusive 900-second expiry, row-locked authority rotation, revocation, encrypted
HttpOnly transport, CSRF/Origin protection, separate browser/API policies,
LiveView guards and accessible workspace placeholders. No financial features.

Integrated origin/main at 7f8d4ba (TASK-019), preserving both exact feature
allowances in three scope tests. Test configuration merged; the locked Oban
dependency and guarded migrations were prepared. Browser ADR is ADR-0026 to avoid
TASK-019's ADR-0025. Manifest preflight now prepares the test DB before profile
startup. No broad/dynamic allowance or configuration-fingerprint bypass.

Previous QA corrections added fresh-connection adversarial HTTP sequencing,
integrated test-only denial/recovery, forged websocket rejection and fractional
cookie retention without extending server authorization. Independent QA accepted
those cases. Initial integration exit 2 remains unexplained; a diagnostic and the
original manifest later passed. Do not hide that reproducibility limitation.

Final-review B1 correction: missing/invalid protected HTTP authority now receives
the existing ended notice, because removed cookie transport cannot reveal expiry.
Public direct sign-in remains notice-free. No new marker, cookie retention or
session authority. HTTP regression covers both destinations, no-store/private
content exclusion and direct sign-in. Chromium disconnects, advances server time,
removes the actual session cookie, verifies absence, returns to recovery without
private content, and signs in again. Feature check failed before correction
(42.474s). All affected receipts and QA/review must be refreshed after the fix.

Evidence lives in canonical check-*.json receipts. Run all eight manifest checks
before acceptance; never infer current PASS from historical reports. Mix needs
local sockets: use appropriate permission initially instead of retrying :eperm.
QA uses independent execution without reuse and should challenge transport
removal separately from retained-cookie/controlled-clock expiry. Review targets
B1 and current independent QA. Only T028/T029 are downstream gates. No publication
before both independent terminal PASS verdicts; no merge.

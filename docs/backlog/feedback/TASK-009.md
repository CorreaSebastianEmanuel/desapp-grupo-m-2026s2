# Feedback — TASK-009

## Feedback 1

- Time: 2026-09-24T14:20:23+00:00
- Author: ezequielgonzalez
- Restart from: develop

Final review found mandatory FR-014 non-disclosure regression coverage incomplete. Add focused tests with distinct sentinels for signing key, complete issued token, verified and unverified claims/JTI, password, and account data across captured logs, successful and failed telemetry, inspected authentication/account structures, and raised/configuration errors. Preserve the sole allowed disclosure of the complete token in a successful login result. Re-run focused/full checks, independent QA, and final review; correct QA evidence to name only exercised surfaces.

## Feedback 2

- Time: 2026-09-24T14:27:06+00:00
- Author: ezequielgonzalez
- Restart from: develop

Independent QA found remaining mandatory test gaps. Extend the non-disclosure sentinel regression to include the verified JTI, verified account ID, and account/email sentinel across every applicable captured log, telemetry, inspection, error, and failure surface while allowing their explicit successful projections. Add automated login cases for blank binary email, blank binary password, and syntactically malformed email, all returning the generic authentication failure. Expand invalid-token tests to delete and reject every required JWT claim individually: sub, jti, iat, exp, iss, and aud. Re-run focused/full checks, QA, and final review.


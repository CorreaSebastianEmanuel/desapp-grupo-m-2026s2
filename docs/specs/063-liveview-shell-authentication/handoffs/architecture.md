# Architecture delta — TASK-046

ADR-0026 adds revocable PostgreSQL browser sessions; cookie-only authority cannot satisfy copied-authority logout. Browser credentials reuse Accounts verification without issuing JWTs or changing API failure semantics. Fixed 900-second expiry is checked exclusively on every protected boundary; timer/periodic validation and PubSub provide separate two-second display convergence.

All critic findings are resolved in plan.md: commit-before-success logout with honest failure/retry, authenticated stale-form redirect plus serialized anonymous-session retirement, clock-boundary versus scheduler tests, and Chromium evidence for tabs/history/reconnect. Raw authority must stay out of LiveView serialized session tokens; connected mounts read server-side cookie connect_info. Hide on disconnect/pagehide and destroy stale sockets before validated reload; no queued mutations replay.

Implementation remains limited to shell/authentication/placeholders. No financial/provider/worker changes, no production fixture routes, and no new browser toolchain. Reuse existing playwright-core and shared-sandbox listener pattern. TASK-063 retains broader profile separation. No TASK-046 feedback file or extensions.yml exists.

Delivery branch is 046-liveview-application-shell-and-authentication; feature directory is 063-liveview-shell-authentication. Keep explicit binding; do not rename from setup's directory-derived alias. Execute verification.json checks before QA, then independent QA/review. Full profiles each execute once; historical CP1 coverage report is intentionally omitted under current policy, with its infrastructure preserved.

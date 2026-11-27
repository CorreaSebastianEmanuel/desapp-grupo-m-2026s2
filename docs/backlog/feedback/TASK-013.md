# Feedback — TASK-013

## Feedback 1

- Time: 2026-09-28T19:20:20+00:00
- Author: independent-qa
- Restart from: develop

Independent QA found two blockers (see specs/013-openapi-cp1-contracts/qa-report.md): the 200 examples in priv/static/openapi.json use NWSL, outside the five allowed leagues in docs/PRODUCT.md; replace both with representative allowed-league fictional data and rerun contract/browser checks. The exact pinned toolchain gate was unverified on the default Elixir 1.20.4 host; Elixir 1.20.3/OTP 29 is now available at /tmp/task13-elixir-v1.20.3-otp-29/bin. Run check_toolchain.sh and all required QA gates with that directory first on PATH. Preserve the existing spec and plan.


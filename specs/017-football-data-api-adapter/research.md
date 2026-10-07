# Feature research — TASK-017

Settled decisions: modular monolith and layer separation in `docs/ARCHITECTURE.md`; current affiliation in ADR-0002; unchanged result/deadline/identity semantics in ADR-0013 and `specs/016-external-football-provider-contract/contracts/provider.md`. No research agents, live calls, subscription work or stack survey were needed. Sources inspected 2026-10-06.

## Scope and affiliation evidence

- Decision: use competition discovery, season-filtered teams, team details, person details and final discovery; accept only an unchanged current season and matching per-person current team. Detailed interpretation and limitations are recorded once in [ADR-0014](../../docs/adr/0014-football-data-evidence-and-owned-transport.md).
- Rationale: [competition documentation](https://docs.football-data.org/general/v4/competition.html) exposes available/current seasons and a team-list season filter. [Team documentation](https://docs.football-data.org/general/v4/team.html) supplies squads/running competitions; [Person documentation](https://docs.football-data.org/general/v4/person.html) supplies `currentTeam`. Source examples contain no squad-specific season discriminator. Fixtures must use actual fields, not invented evidence.
- Alternatives considered: bulk squads alone, squad-only affiliation and historical reconstruction; rejected for insufficient evidence. Bracketing is explicitly an inference with no atomicity guarantee.

## Quota and completion

- Decision: sequential complete collection with no retries; cost and latency bound in ADR-0014. Full-sized quota-exhaustion and deterministic large successful exchanges are separate tests.
- Rationale: [policies](https://docs.football-data.org/general/v4/policies.html) document throttling and current-season squad defaults. A successful small fixture does not prove operational feasibility.
- Alternatives considered: concurrency, waiting and paid access; unnecessary complexity or excluded scope.

## Status and delay translation

- Decision: numeric status mapping and delay parsing are owned by [contracts/football-data.md](contracts/football-data.md). Never inspect source message text to decide a category.
- Rationale: the [vendor API reference](https://www.football-data.org/documentation/api#errors) documents 400/403/404/429. The v4 [header table](https://docs.football-data.org/general/v4/lookup_tables.html) defines `X-RequestCounter-Reset` as seconds remaining; this is not an absolute timestamp. `Retry-After` interpretation follows [RFC 9110 section 10.2.3](https://www.rfc-editor.org/rfc/rfc9110.html#section-10.2.3). The older reference is used only for statuses, never for v4 payload shapes.
- Alternatives considered: guessed waits, quota counters as waits and message matching; rejected.

## Concrete transport lifecycle

- Decision: Mint HTTP/1 owned by the existing worker; fixed live origin, explicit TLS verification and OTP CA roots. A local TLS harness exercises the real production transport rather than replacing it with a fake.
- Rationale: [Mint](https://mint.hexdocs.pm/Mint.HTTP.html) exposes explicit ownership/close and TLS controls. [OTP CA loading](https://www.erlang.org/doc/apps/public_key/public_key.html#cacerts_get/0) allows platform trust without a custom trust service. See ADR-0014 for cleanup evidence and alternatives.
- Alternatives considered: shared pools and manual HTTP; rejected as documented there.

## Feedback 1: complete-boundary retry freshness

- Decision: source receipt anchors plus the private readiness seam in [ADR-0015](../../docs/adr/0015-source-anchored-retry-expiry.md). Preserve existing architecture/source decisions in ADR-0014; no technology research is reopened.
- Rationale: the local independent QA probes `/tmp/task017-independent-qa/delay-acceptance.exs` and `delay-http.exs` compare the emitted public delay with full normalized readiness. Runner currently normalizes after Errors.delay fixes a duration, explaining 1500/1000/500 instead of 1000/nil/nil. FixtureRuntime returns function outcomes opaquely and supplies readiness after execution, so no runtime-port change is needed. Existing private transport envelopes can carry a safe receipt pair without altering Adapter.read/3.
- Alternatives considered: subtract only inside Errors.delay (misses later time), remove every delay (loses valid known future waits), add expiry to public failures (violates the existing key allowlist), alter Runtime (unnecessary), provider-specific Runner branch (couples the boundary to vendor code).
- Research scope: local code/probe inspection resolves this concrete unknown. No new external source claim, live call or delegated research is needed.

All concrete unknowns are resolved conservatively. Live scope availability, account grants, roster freshness and latency remain documented source risks, not unapproved implementation assumptions.

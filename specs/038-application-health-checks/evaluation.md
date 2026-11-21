# Independent evaluation — TASK-038

Reviewed the shared SQL sandbox setup in the working-tree repair and its effect on the public health-route tests. The fixture gives both the test process and the monitored request process access to PostgreSQL for the real readiness query.

| Acceptance | Evidence |
| --- | --- |
| Public liveness remains available independently of dependencies | The liveness action performs no probes. The router policy test confirms public access, and the refused-Redis test receives HTTP 200 from liveness. |
| Readiness returns HTTP 200 when PostgreSQL and Oban are ready, including Redis-only degradation | The HTTP tests exercise the real readiness path. A refused Redis connection yields HTTP 200 with Redis degraded, and the monitored request exits normally. |
| PostgreSQL or Oban unavailability returns HTTP 503 | Probe-policy tests exercise each dependency failure independently. The controller test confirms HTTP 503 for the unavailable result. |
| Probes are bounded and responses contain only status fields | PostgreSQL executes a live `SELECT 1` with a 500 ms timeout. Redis uses a bounded PING and a 1,500 ms worker deadline. Oban checks the configured instance in its registry. The controller serializes only overall and dependency statuses. |

The focused controller, infrastructure, and route policy run passed all 12 tests with local socket access. ThinFlow validated the current candidate digest and evidence hashes for all five high-risk checks: CI contracts, harness tests, formatting, compilation, and the unit profile. The test fixture repair is present in the evaluated working tree and must be included in the CI candidate.

No blocking or advisory findings in the repair delta. Live PostgreSQL and Oban outages and a stalled Redis peer were outside the focused run. Exact-head hosted CI and human merge remain pending.

Verdict: PASS

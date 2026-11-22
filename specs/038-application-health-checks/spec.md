# Outcome specification: Application health checks

## Outcome

Expose public HTTP liveness and readiness endpoints for the application and its PostgreSQL, Redis, and Oban infrastructure.

## Acceptance

- [ ] `GET /health/live` returns HTTP 200 while the HTTP application serves requests, independently of dependency availability.
- [ ] `GET /health/ready` reports `status` plus PostgreSQL, Redis, and Oban statuses. PostgreSQL and Oban must be ready for HTTP 200; unavailable PostgreSQL or Oban returns HTTP 503. If only Redis is unavailable, return HTTP 200 and identify Redis as `degraded`.
- [ ] PostgreSQL readiness uses a bounded live query; Redis readiness uses a bounded `PING`; Oban readiness checks that the configured Oban instance is registered and available.
- [ ] Both endpoints are public, and responses contain no credentials, connection strings, or exception details.
- [ ] Automated tests cover healthy responses, Redis-only degradation, PostgreSQL and Oban unavailability, public authentication policy, and liveness independence from dependencies.

## Scope

- Add the two operational HTTP endpoints and a small infrastructure health-check module using existing adapters.
- Add focused infrastructure and HTTP tests for the acceptance behavior.
- Keep response fields limited to overall status and each dependency status.

## Non-goals

- Metrics, dashboards, alerting, deep diagnostics, dependency recovery, or changes to runtime supervision and retry policies.
- Changes to business behavior or the existing infrastructure verification task.

## Risk

Medium: unauthenticated service availability can affect traffic routing; responses must stay minimal and dependency probes bounded.

## Decisions

- Liveness reports only whether the HTTP application is serving requests.
- PostgreSQL and Oban determine readiness. Redis is a disposable cache, so its probe failure is reported as degraded while the application remains ready.
- Endpoint paths are `/health/live` and `/health/ready`; readiness JSON uses `status` and a `dependencies` map with `postgresql`, `redis`, and `oban` statuses (`ready`, `degraded`, or `unavailable`).

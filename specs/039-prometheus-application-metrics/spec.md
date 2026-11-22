# Outcome specification: Prometheus application metrics

**Feature Branch**: `039-prometheus-application-metrics`

**Task**: `TASK-039`

## Outcome

Expose operational Phoenix, Repo, BEAM VM, and Oban measurements in Prometheus
text through a protected `GET /metrics` endpoint.

## Acceptance

- [ ] An authorized scrape returns valid Prometheus exposition text with HTTP
  request count, error count, and duration; Repo query duration; VM memory and
  run-queue gauges; and Oban job count and duration.
- [ ] HTTP labels are bounded route templates and status classes. Output
  contains no credentials, request parameters, user identifiers, or job
  arguments.
- [ ] `GET /metrics` requires `Authorization: Bearer <token>` matching the
  deployment-configured `METRICS_SCRAPE_TOKEN`. Missing configuration, missing
  credentials, and invalid credentials all deny the scrape. Public liveness and
  readiness endpoints and existing product authentication are unchanged.
- [ ] Focused tests prove scrape authorization and response format, plus
  representative telemetry updates for HTTP, Repo, VM, and Oban metric
  families.
- [ ] Deployment documentation shows how to configure the scraper using
  placeholders only; it contains no real credentials.

## Scope

- Add a Prometheus reporter, a protected Phoenix scrape route, and bounded
  telemetry for HTTP requests and Oban jobs; retain the existing Repo and VM
  measurements.
- Load the scrape token from runtime deployment configuration and fail closed
  when it is absent.
- Add focused endpoint and telemetry tests, and document scraper configuration.
- Register every task-owned path with the workflow scope guard and reconcile
  affected source, lint, and test inventories.

## Non-goals

- Dashboards, alert rules, a separate metrics service or listener, and unrelated
  product behavior or refactors.

## Risk

- Metrics disclose operational information. The dedicated scrape token,
  fail-closed configuration, bounded labels, and exclusion of sensitive values
  protect the scrape boundary.

## Decisions

- Scrapes require a deployment-configured Bearer token named
  `METRICS_SCRAPE_TOKEN`; missing or invalid values receive an unauthorized
  response, and no token means scraping stays closed.
- The endpoint runs through the existing Phoenix server so the same route
  enforces authorization; public health routes and product authentication
  remain unchanged.
- Request labels use normalized route templates and status classes. Oban
  labels use only bounded queue and outcome values; worker arguments and
  identifiers are never exported.

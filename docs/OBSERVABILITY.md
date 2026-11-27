# Monitoring and Prometheus scraping

## Health and operational endpoints (Actuator equivalents)

The application exposes bounded public operational endpoints without credentials or sensitive configuration details:

- `GET /health/live` — HTTP application liveness (`{"status": "live"}`).
- `GET /health/ready` — bounded dependency readiness for PostgreSQL, Redis (reported as `degraded` without failing readiness), and Oban.
- `GET /health/info` — safe build and runtime metadata (`application`, `version`, `elixir`, `otp_release`).

## Prometheus scraping (`GET /metrics`)

The application exposes operational metrics in Prometheus text exposition format (`0.0.4`) at `GET /metrics`, covering HTTP requests/errors/latency, Ecto repository query latency, BEAM VM memory and run queues, Oban job outcomes/latency, external provider requests, and active-strategy ranking cache lookups (`football_market_ranking_cache_total`). Scraping is disabled until the deployment sets a dedicated token; the public health endpoints do not use this credential.

Set `METRICS_SCRAPE_TOKEN` in the application environment using the deployment's
secret manager. Configure Prometheus with the same secret through a protected
credentials file:

```yaml
scrape_configs:
  - job_name: football-market
    metrics_path: /metrics
    authorization:
      type: Bearer
      credentials_file: /run/secrets/football-market-metrics-token
    static_configs:
      - targets: ["<application-host>:<application-port>"]
```

The credentials file should contain only the deployment's token. Keep the token
out of source control, URLs, labels, and logs. Replace the target placeholders
with the deployment's application address. Without a non-empty
`METRICS_SCRAPE_TOKEN`, the endpoint returns `401 Unauthorized` for every
request.

### Optional local Prometheus demonstration

To scrape a locally running Phoenix server on port `4000` without altering the core `compose.yaml` contract:

```bash
mkdir -p tmp/prometheus
printf '%s' "$METRICS_SCRAPE_TOKEN" > tmp/prometheus/metrics-token
cp docs/observability/prometheus.yml.example tmp/prometheus/prometheus.yml
docker compose -f docs/observability/compose.prometheus.yaml up
```

Then open Prometheus at `http://127.0.0.1:9090`. Stop it with `docker compose -f docs/observability/compose.prometheus.yaml down`.

## Advanced business metrics (`GET /api/business-metrics`)

Authenticated administrators can query `GET /api/business-metrics` (documented in `priv/static/openapi.json`) for a consistent `REPEATABLE READ, READ ONLY` snapshot of retained quotes, conditional orders, portfolio trading activity, ingestion records, and Oban job states.

## SonarCloud CI & Local SonarQube (Elixir)

### SonarCloud in GitHub Actions

SonarCloud does not provide a native Elixir language analyzer and does not allow third-party plugins (see `docs/specs/069-verify-sonarcloud-external-elixir-report-compatibility/sonarcloud-probe.md`). To surface real Elixir static-analysis findings in SonarCloud alongside JavaScript LCOV coverage, `.github/workflows/sonarcloud.yml` generates a Sonar Generic Issue Import report from **Credo** and **Sobelow** on every PR and `main` run:

```bash
python3 scripts/sonar_elixir_reports.py issues --output tmp/sonar-elixir
```

### Full local Elixir analysis with SonarQube Community Build + `sonar-elixir`

For full Elixir `ncloc`, syntax highlighting, code smells, security issues, and imported Elixir test coverage (`tmp/sonar-elixir/coverage.xml`) inside a SonarQube UI, run the optional local SonarQube Community Build stack with the `hpopp/sonar-elixir` plugin (does not modify `compose.yaml` or SonarCloud):

```bash
./scripts/sonarqube_local.sh start
# Open http://127.0.0.1:9000 (default credentials admin / admin) and generate a user token
SONAR_LOCAL_TOKEN="<your-local-token>" ./scripts/sonarqube_local.sh scan
# Stop when finished (preserves volumes and scan history)
./scripts/sonarqube_local.sh stop
```

Pass `--reuse-coverage` to `scan` to reuse an existing `cover/application/status.json` report.

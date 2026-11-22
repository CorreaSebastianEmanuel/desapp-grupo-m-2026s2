# Prometheus scraping

The application exposes operational metrics at `GET /metrics`. Scraping is
disabled until the deployment sets a dedicated token; the public health
endpoints do not use this credential.

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

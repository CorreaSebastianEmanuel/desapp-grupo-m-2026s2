import Config

config :football_market, FootballMarket.Synchronization,
  enabled: false,
  automatic: config_env() != :test,
  recurrence: "0 0 * * *",
  sources: %{},
  schedules: [],
  concurrency: 1,
  tick_ms: 15_000

config :football_market, Oban,
  repo: FootballMarket.Repo,
  queues: [catalog_sync: 1, statistics_import: 1, quote_calculation: 2],
  plugins: [
    {Oban.Plugins.Cron, crontab: [{"* * * * *", FootballMarket.Workers.QuoteRecovery}]}
  ],
  lifeline: [rescue_after: {5, :minutes}, interval: {1, :minute}]

# Trusted source options are selected by exact {league_code, start_year, end_year}.
# No source is enabled implicitly; detail reads remain local when unconfigured.
config :football_market, FootballMarket.Statistics.Freshness,
  ttl_seconds: 86_400,
  cooldown_seconds: 3_600,
  refresh_options_by_scope: %{}

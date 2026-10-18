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
  queues: [catalog_sync: 1, statistics_import: 1],
  plugins: [],
  lifeline: [rescue_after: {5, :minutes}, interval: {1, :minute}]

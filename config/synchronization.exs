import Config

if config_env() != :test do
  config :football_market,
         :provider_rate_limit_backend,
         FootballMarket.Infrastructure.ProviderRateLimit
end

config :football_market, FootballMarket.Synchronization,
  enabled: false,
  automatic: config_env() != :test,
  recurrence: "0 0 * * *",
  sources: %{},
  # Search scouting is disabled unless an operator explicitly binds trusted
  # league/season scopes to an already configured provider source.
  scouting_scopes: [],
  schedules: [],
  concurrency: 1,
  tick_ms: 15_000

football_data_org_token = System.get_env("FOOTBALL_DATA_ORG_TOKEN")

football_data_configured? =
  is_binary(football_data_org_token) and String.valid?(football_data_org_token) and
    String.trim(football_data_org_token) != "" and
    football_data_org_token == String.trim(football_data_org_token) and
    not Regex.match?(~r/[\p{Cc}\p{Cf}]/u, football_data_org_token) and
    config_env() != :test

{configured_sources, configured_schedules} =
  if football_data_configured? do
    today = Date.utc_today()
    current_year = today.year
    start_year = if today.month >= 7, do: current_year, else: current_year - 1
    timeout_ms = 1_800_000

    scopes =
      for code <- ["PL", "BL1", "PD", "SA", "FL1"], into: %{} do
        {"football-data-org-#{code}",
         %{
           scope: %{
             league_code: code,
             start_year: start_year,
             end_year: start_year + 1,
             timeout_ms: timeout_ms
           },
           source_ref: "football-data-org",
           recurrence: "0 2 * * *",
           enabled: true,
           policy: %{
             attempt_limit: 3,
             waits: [60, 300],
             worker_timeout_ms: timeout_ms + 30_000
           }
         }}
      end

    sources = %{
      "football-data-org" => %{
        provider: {FootballMarket.Providers.FootballDataOrg, %{token: football_data_org_token}},
        identity: %{api: "football-data.org", version: "v4", season_rule: "utc-july"}
      }
    }

    {sources, Map.to_list(scopes)}
  else
    {%{}, []}
  end

if config_env() == :dev do
  sources =
    Map.put(configured_sources, "fotmob-public-html", %{
      provider: {FootballMarket.Providers.Scraping, %{mode: :live}},
      identity: %{
        site: "fotmob.com",
        access: "authorized-public-search-and-html",
        parser: "player-profile-history-v2",
        version: 5
      }
    })

  config :football_market, FootballMarket.Synchronization,
    enabled: true,
    sources: sources,
    schedules: configured_schedules
end

if config_env() == :prod and football_data_configured? do
  config :football_market, FootballMarket.Synchronization,
    enabled: true,
    sources: configured_sources,
    schedules: configured_schedules
end

config :football_market, Oban,
  repo: FootballMarket.Repo,
  queues: [
    catalog_sync: 1,
    catalog_scout: 1,
    statistics_import: 1,
    quote_calculation: 2,
    conditional_orders: 1
  ],
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"* * * * *", FootballMarket.Workers.QuoteRecovery},
       {"* * * * *", FootballMarket.Workers.QuoteClose},
       {"* * * * *", FootballMarket.Workers.ConditionalOrderRecovery}
     ]}
  ],
  lifeline: [rescue_after: {5, :minutes}, interval: {1, :minute}]

# Manual test execution opts into startup wakes explicitly against an owned
# store; production startup remains enabled independently of catalog syncing.
config :football_market, FootballMarket.Market.OrderEvaluation, startup: config_env() != :test

# Trusted source options are selected by exact {league_code, start_year, end_year}.
# No source is enabled implicitly; detail reads remain local when unconfigured.
config :football_market, FootballMarket.Statistics.Freshness,
  ttl_seconds: 86_400,
  cooldown_seconds: 3_600,
  request_timeout_ms: 20_000,
  refresh_options_by_scope: %{}

if config_env() == :dev do
  today = Date.utc_today()
  start_year = if today.month >= 7, do: today.year, else: today.year - 1
  end_year = start_year + 1

  config :football_market, FootballMarket.Statistics.Freshness,
    request_timeout_ms: 20_000,
    refresh_options_by_scope:
      Map.new(["PL", "BL1", "PD", "SA", "FL1"], fn league_code ->
        {{league_code, start_year, end_year},
         [
           source_ref: "fotmob-public-html",
           policy: %{
             attempt_limit: 3,
             waits: [60, 300],
             worker_timeout_ms: 120_000
           }
         ]}
      end)
end

config :football_market, FootballMarket.Quotes.Closing,
  default_recurrence: "0 0 * * *",
  recurrences: %{}

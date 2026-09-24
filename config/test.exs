import Config

config :football_market, development_seed_enabled: true

parse_port = fn value ->
  case Integer.parse(value) do
    {port, ""} when port in 1..65_535 -> port
    _ -> value
  end
end

partition = System.get_env("MIX_TEST_PARTITION", "")
test_database = System.get_env("TEST_DATABASE_NAME", "football_market_test#{partition}")
development_database = System.get_env("POSTGRES_DB", "football_market_dev")

if test_database != "football_market_test#{partition}" or test_database == development_database do
  raise "unsafe test database identity (expected football_market_test#{partition})"
end

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :football_market, FootballMarket.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "127.0.0.1"),
  port: parse_port.(System.get_env("POSTGRES_PORT", "5432")),
  database: test_database,
  show_sensitive_data_on_connection_error: false,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :football_market, FootballMarketWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "FwrkOJ1dwzn3DL7e7e/3OACyrATL7OMcLbB3Nzrnl599wrXOjN8Ju9ny1tyG66AW",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

config :football_market, :redis,
  host: System.get_env("REDIS_HOST", "127.0.0.1"),
  port: parse_port.(System.get_env("REDIS_PORT", "6379")),
  password: System.get_env("REDIS_PASSWORD")

# The dependency documents m_cost: 8 as its test-only low-cost setting.
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8,
  parallelism: 1,
  argon2_type: 2

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true

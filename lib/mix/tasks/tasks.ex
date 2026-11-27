# Custom Mix tasks for local setup, database management, seeding, and health verification:
#   * `mix catalog.seed` — loads the demo catalog in dev/test
#   * `mix infrastructure.database.{create,migrate,setup,test_prepare}` — safe DB commands
#   * `mix infrastructure.verify` — verifies PostgreSQL and Redis connectivity

defmodule Mix.Tasks.Catalog.Seed do
  @moduledoc false
  use Mix.Task

  alias FootballMarket.Catalog.DevelopmentSeed

  @shortdoc "Loads the fixed development catalog"

  @impl Mix.Task
  def run(_args) do
    unless DevelopmentSeed.enabled?() do
      Mix.raise("catalog seed failed: category=disabled entity=seed identity=development-seed")
    end

    Mix.Task.run("app.start")

    case DevelopmentSeed.run() do
      {:ok, summary} ->
        t = summary.totals

        Mix.shell().info(
          "catalog seed complete: total=#{summary.total} created=#{summary.created} " <>
            "reused=#{summary.reused} leagues=#{t.leagues} seasons=#{t.seasons} " <>
            "teams=#{t.teams} positions=#{t.positions} players=#{t.players}"
        )

      {:error, error} ->
        Mix.raise("catalog seed failed: #{inspect(error)}")
    end
  end
end

defmodule Mix.Tasks.Infrastructure.Database do
  @moduledoc false

  @test_prefix "football_market_test"

  def guard! do
    if Mix.env() == :test do
      env = System.get_env()
      partition = Map.get(env, "MIX_TEST_PARTITION", "")
      expected = @test_prefix <> partition
      test_db = Map.get(env, "TEST_DATABASE_NAME", expected)
      dev_db = Map.get(env, "POSTGRES_DB", "football_market_dev")

      if test_db != expected or test_db == dev_db do
        raise ArgumentError, "unsafe test database identity (expected #{expected})"
      end
    end
  end

  def create do
    guard!()
    config = Application.fetch_env!(:football_market, FootballMarket.Repo)

    case Ecto.Adapters.Postgres.storage_up(config) do
      :ok -> Mix.shell().info("database created")
      {:error, :already_up} -> Mix.shell().info("database already exists")
      {:error, reason} -> Mix.raise("PostgreSQL database creation failed: #{inspect(reason)}")
    end
  end

  def migrate do
    guard!()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(FootballMarket.Repo, &Ecto.Migrator.run(&1, :up, all: true))

    Mix.shell().info("migrations current")
  end
end

defmodule Mix.Tasks.Infrastructure.Database.Create do
  @moduledoc false
  use Mix.Task
  @requirements ["app.config"]
  def run(_), do: Mix.Tasks.Infrastructure.Database.create()
end

defmodule Mix.Tasks.Infrastructure.Database.Migrate do
  @moduledoc false
  use Mix.Task
  @requirements ["app.config"]
  def run(_), do: Mix.Tasks.Infrastructure.Database.migrate()
end

defmodule Mix.Tasks.Infrastructure.Database.Setup do
  @moduledoc false
  use Mix.Task
  @requirements ["app.config"]

  def run(_) do
    Mix.Tasks.Infrastructure.Database.create()
    Mix.Tasks.Infrastructure.Database.migrate()
  end
end

defmodule Mix.Tasks.Infrastructure.Database.TestPrepare do
  @moduledoc false
  use Mix.Task
  @requirements ["app.config"]

  def run(_) do
    Mix.Tasks.Infrastructure.Database.guard!()
    Mix.Tasks.Infrastructure.Database.create()
    Mix.Tasks.Infrastructure.Database.migrate()
  end
end

defmodule Mix.Tasks.Infrastructure.Verify do
  @moduledoc false
  use Mix.Task
  @requirements []

  @shortdoc "Verifies PostgreSQL and Redis connectivity"

  def run(_) do
    Application.load(:football_market)
    Application.ensure_all_started(:ecto_sql)
    Application.ensure_all_started(:postgrex)
    Application.ensure_all_started(:redix)
    if Mix.env() == :test, do: Mix.Tasks.Infrastructure.Database.guard!()

    results = [check_postgres(), check_redis()]

    Enum.each(results, fn {label, target, status} ->
      rendered =
        case status do
          :ok -> "OK"
          {:error, category} -> "ERROR #{category}"
        end

      Mix.shell().info("#{label}: #{rendered} (#{target})")
    end)

    unless Enum.all?(results, fn {_, _, status} -> status == :ok end) do
      Mix.raise("infrastructure verification failed")
    end
  end

  defp check_postgres do
    env = System.get_env()
    mode = Mix.env()
    partition = if mode == :test, do: Map.get(env, "MIX_TEST_PARTITION", ""), else: ""

    default_db =
      if mode == :test, do: "football_market_test" <> partition, else: "football_market_dev"

    db =
      Map.get(env, if(mode == :test, do: "TEST_DATABASE_NAME", else: "POSTGRES_DB"), default_db)

    host = Map.get(env, "POSTGRES_HOST", "127.0.0.1")
    port = parse_port!(Map.get(env, "POSTGRES_PORT", "5432"))
    target = "postgresql://#{host}:#{port}/#{db}"

    opts = [
      username: Map.get(env, "POSTGRES_USER", "postgres"),
      password: Map.get(env, "POSTGRES_PASSWORD", "postgres"),
      hostname: host,
      port: port,
      database: db,
      name: :infrastructure_verify_repo,
      pool_size: 1,
      timeout: 5_000,
      connect_timeout: 5_000,
      show_sensitive_data_on_connection_error: false
    ]

    status =
      case FootballMarket.Repo.start_link(opts) do
        {:ok, pid} ->
          res =
            case Ecto.Adapters.SQL.query(
                   pid,
                   "SELECT marker FROM infrastructure_probe WHERE key = 'migration'",
                   [],
                   timeout: 5_000
                 ) do
              {:ok, _} ->
                :ok

              {:error, %DBConnection.ConnectionError{}} ->
                {:error, :unavailable_or_authentication_failure}

              {:error, _} ->
                {:error, :migration_failure}
            end

          GenServer.stop(pid)
          res

        {:error, _} ->
          {:error, :unavailable_or_authentication_failure}
      end

    {"PostgreSQL", target, status}
  rescue
    _ -> {"PostgreSQL", "postgresql://invalid-configuration", {:error, :invalid_configuration}}
  end

  defp check_redis do
    env = System.get_env()
    host = Map.get(env, "REDIS_HOST", "127.0.0.1")
    port = parse_port!(Map.get(env, "REDIS_PORT", "6379"))

    password =
      case Map.get(env, "REDIS_PASSWORD") do
        "" -> nil
        value -> value
      end

    target = "redis://#{host}:#{port}"
    config = [host: host, port: port, password: password]

    status =
      if FootballMarket.Infrastructure.Health.ping_redis(config, 5_000) == :ready,
        do: :ok,
        else: {:error, :unavailable_or_authentication_failure}

    {"Redis", target, status}
  rescue
    _ -> {"Redis", "redis://invalid-configuration", {:error, :invalid_configuration}}
  end

  defp parse_port!(value) do
    case Integer.parse(to_string(value)) do
      {port, ""} when port in 1..65_535 -> port
      _ -> raise ArgumentError, "invalid port"
    end
  end
end

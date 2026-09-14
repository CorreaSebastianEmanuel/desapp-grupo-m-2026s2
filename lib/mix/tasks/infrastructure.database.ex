defmodule Mix.Tasks.Infrastructure.Database do
  @moduledoc false
  alias FootballMarket.Infrastructure.Configuration

  def guard! do
    if Mix.env() == :test do
      test = Configuration.postgres(System.get_env(), :test)
      dev = Configuration.postgres(System.get_env(), :dev)
      Configuration.validate_test_database!(test.database, dev.database)
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
  use Mix.Task
  @requirements ["app.config"]
  def run(_), do: Mix.Tasks.Infrastructure.Database.create()
end

defmodule Mix.Tasks.Infrastructure.Database.Migrate do
  use Mix.Task
  @requirements ["app.config"]
  def run(_), do: Mix.Tasks.Infrastructure.Database.migrate()
end

defmodule Mix.Tasks.Infrastructure.Database.Setup do
  use Mix.Task
  @requirements ["app.config"]
  def run(_) do
    Mix.Tasks.Infrastructure.Database.create()
    Mix.Tasks.Infrastructure.Database.migrate()
  end
end

defmodule Mix.Tasks.Infrastructure.Database.TestPrepare do
  use Mix.Task
  @requirements ["app.config"]
  def run(_) do
    Mix.Tasks.Infrastructure.Database.guard!()
    Mix.Tasks.Infrastructure.Database.create()
    Mix.Tasks.Infrastructure.Database.migrate()
  end
end

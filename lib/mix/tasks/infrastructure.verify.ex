defmodule Mix.Tasks.Infrastructure.Verify do
  use Mix.Task
  @requirements []

  alias FootballMarket.Infrastructure.{Configuration, Redis, Verification}

  @shortdoc "Verifies PostgreSQL and Redis through application-owned clients"
  def run(_) do
    Application.load(:football_market)
    Application.ensure_all_started(:ecto_sql)
    Application.ensure_all_started(:postgrex)
    Application.ensure_all_started(:redix)
    if Mix.env() == :test, do: Mix.Tasks.Infrastructure.Database.guard!()

    results = [postgres_result(), redis_result()]
    Mix.shell().info(Verification.render(results))
    if Verification.exit_status(results) != 0, do: Mix.raise("infrastructure verification failed")
  end

  defp postgres_result do
    config = Configuration.postgres(System.get_env(), Mix.env())
    target = Configuration.safe_target(:postgresql, config)

    opts =
      Map.to_list(config) ++
        [
          name: :infrastructure_verify_repo,
          pool_size: 1,
          timeout: 5_000,
          connect_timeout: 5_000,
          show_sensitive_data_on_connection_error: false
        ]

    status =
      case FootballMarket.Repo.start_link(opts) do
        {:ok, pid} ->
          result =
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
          result

        {:error, _} ->
          {:error, :unavailable_or_authentication_failure}
      end

    %{dependency: :postgresql, target: target, status: status}
  rescue
    _ ->
      %{
        dependency: :postgresql,
        target: "postgresql://invalid-configuration",
        status: {:error, :invalid_configuration}
      }
  end

  defp redis_result do
    config = Configuration.redis()
    target = Configuration.safe_target(:redis, config)
    previous = Process.flag(:trap_exit, true)

    status =
      try do
        case Redis.start_link(config) do
          {:ok, pid} ->
            result =
              if Redis.ping(pid) == {:ok, "PONG"},
                do: :ok,
                else: unavailable_error()

            GenServer.stop(pid)
            result

          {:error, _} ->
            unavailable_error()
        end
      after
        Process.flag(:trap_exit, previous)
      end

    %{dependency: :redis, target: target, status: status}
  rescue
    _ ->
      %{
        dependency: :redis,
        target: "redis://invalid-configuration",
        status: {:error, :invalid_configuration}
      }
  end

  defp unavailable_error, do: {:error, :unavailable_or_authentication_failure}
end

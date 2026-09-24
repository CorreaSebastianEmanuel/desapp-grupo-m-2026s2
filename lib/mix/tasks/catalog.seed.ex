defmodule Mix.Tasks.Catalog.Seed do
  use Mix.Task

  alias FootballMarket.Catalog.DevelopmentSeed

  @shortdoc "Loads the fixed development catalog"

  @impl Mix.Task
  def run(_args) do
    unless DevelopmentSeed.enabled?() do
      Mix.raise(
        format_error(%{
          category: :disabled,
          entity: :seed,
          identity: "development-seed"
        })
      )
    end

    result = with_quiet_logs(&start_and_seed/0)

    case result do
      {:ok, summary} -> Mix.shell().info(format_summary(summary))
      {:error, error} -> Mix.raise(format_error(error))
    end
  end

  defp with_quiet_logs(fun) do
    previous_level = :logger.get_primary_config() |> Map.fetch!(:level)
    previous_configured_level = Application.get_env(:logger, :level)
    Application.put_env(:logger, :level, :none)
    :ok = :logger.set_primary_config(:level, :none)

    try do
      fun.()
    after
      restore_logger_config(previous_configured_level)
      :ok = :logger.set_primary_config(:level, previous_level)
    end
  end

  defp start_and_seed do
    try do
      Mix.Task.run("app.start")
      :ok = :logger.set_primary_config(:level, :none)
      DevelopmentSeed.run()
    rescue
      _exception in [DBConnection.ConnectionError, Postgrex.Error] -> database_unavailable()
    catch
      :exit, _reason -> database_unavailable()
    end
  end

  defp database_unavailable do
    {:error,
     DevelopmentSeed.public_error(%{
       category: :persistence,
       entity: :seed,
       identity: "development-seed",
       cause: :database_unavailable
     })}
  end

  defp restore_logger_config(nil), do: Application.delete_env(:logger, :level)
  defp restore_logger_config(level), do: Application.put_env(:logger, :level, level)

  defp format_summary(summary) do
    totals = summary.totals

    "catalog seed complete: total=#{summary.total} created=#{summary.created} reused=#{summary.reused} " <>
      "leagues=#{totals.leagues} seasons=#{totals.seasons} teams=#{totals.teams} " <>
      "positions=#{totals.positions} players=#{totals.players}"
  end

  @doc false
  def format_error(error) do
    public_error = DevelopmentSeed.public_error(error)
    cause = if public_error[:cause], do: " cause=#{public_error.cause}", else: ""

    "catalog seed failed: category=#{public_error.category} entity=#{public_error.entity} " <>
      "identity=#{public_error.identity}#{cause}"
  end
end

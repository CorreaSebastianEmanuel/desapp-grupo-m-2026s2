defmodule FootballMarket.Observability do
  @moduledoc "Owned lifecycle subscriptions; no external logging service."

  @subscriptions [
    {FootballMarketWeb.RequestLogger,
     [[:phoenix, :endpoint, :start], [:phoenix, :endpoint, :stop], [:phoenix, :error_rendered]]},
    {FootballMarket.Observability.JobLogger,
     [[:oban, :job, :start], [:oban, :job, :stop], [:oban, :job, :exception]]}
  ]

  def attach do
    Enum.each(@subscriptions, fn {module, events} ->
      case :telemetry.attach_many({__MODULE__, module}, events, &module.handle_event/4, nil) do
        :ok -> :ok
        {:error, :already_exists} -> :ok
      end
    end)
  end

  def detach do
    Enum.each(@subscriptions, fn {module, _} -> :telemetry.detach({__MODULE__, module}) end)
  end
end

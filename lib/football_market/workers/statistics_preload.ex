defmodule FootballMarket.Workers.StatisticsPreload do
  @moduledoc "Durable wake for stale configured player statistics refreshes."
  use Oban.Worker,
    queue: :statistics_import,
    max_attempts: 3,
    unique: [
      period: 3_600,
      fields: [:worker],
      keys: [],
      states: [:available, :scheduled, :executing, :retryable]
    ]

  @impl Oban.Worker
  def perform(_job) do
    _ = FootballMarket.Statistics.Freshness.preload()
    :ok
  end

  def startup do
    Oban.insert(new(%{}))
  rescue
    _ -> {:error, :unavailable}
  catch
    :exit, _ -> {:error, :unavailable}
  end
end

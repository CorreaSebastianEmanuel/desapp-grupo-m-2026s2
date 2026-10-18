defmodule FootballMarket.Workers.StatisticsImport do
  @moduledoc "One-shot Oban delivery for statistics imports; shared synchronization policy owns retries."
  use Oban.Worker, queue: :statistics_import, max_attempts: 1

  @impl Oban.Worker
  def perform(job), do: FootballMarket.Workers.CatalogSync.perform(job)

  @impl Oban.Worker
  def timeout(job), do: FootballMarket.Workers.CatalogSync.timeout(job)
end

defmodule FootballMarket.Workers.CatalogSync do
  @moduledoc "Catalog delivery adapter for durable synchronization execution."
  use Oban.Worker, queue: :catalog_sync, max_attempts: 1

  @impl Oban.Worker
  def perform(job), do: FootballMarket.Synchronization.Execution.perform(job)

  @impl Oban.Worker
  def timeout(job), do: FootballMarket.Synchronization.Execution.timeout(job)
end

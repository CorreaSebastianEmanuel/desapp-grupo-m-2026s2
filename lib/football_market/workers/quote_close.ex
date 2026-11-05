defmodule FootballMarket.Workers.QuoteClose do
  @moduledoc false
  use Oban.Worker, queue: :quote_calculation, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"mode" => "manual"}}),
    do: FootballMarket.Quotes.Closing.admit_now()

  def perform(%Oban.Job{}), do: FootballMarket.Quotes.Closing.admit_due()
end

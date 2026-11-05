defmodule FootballMarket.Workers.QuoteRecovery do
  @moduledoc false
  use Oban.Worker, queue: :quote_calculation, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{}), do: FootballMarket.Quotes.Recovery.recover_pending()
end

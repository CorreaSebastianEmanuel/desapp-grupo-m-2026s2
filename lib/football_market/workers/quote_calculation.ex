defmodule FootballMarket.Workers.QuoteCalculation do
  @moduledoc false
  use Oban.Worker,
    queue: :quote_calculation,
    max_attempts: 3,
    unique: [
      period: 3_600,
      keys: [:request_id],
      states: [:available, :scheduled, :executing, :retryable]
    ]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"request_id" => id}}),
    do: FootballMarket.Quotes.process_import_request(id)
end

defmodule FootballMarket.Workers.QuoteRecovery do
  @moduledoc false
  use Oban.Worker, queue: :quote_calculation, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{}), do: FootballMarket.Quotes.Recovery.recover_pending()
end

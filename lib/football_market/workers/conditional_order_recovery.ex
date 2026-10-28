defmodule FootballMarket.Workers.ConditionalOrderRecovery do
  @moduledoc false
  use Oban.Worker, queue: :conditional_orders, max_attempts: 3
  alias FootballMarket.Market.OrderEvaluation

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) when args == %{}, do: OrderEvaluation.recover(nil)

  def perform(%Oban.Job{args: %{"after" => id} = args}) when map_size(args) == 1 do
    case Ecto.UUID.cast(id) do
      {:ok, id} -> OrderEvaluation.recover(id)
      _ -> {:discard, :invalid_args}
    end
  end

  def perform(_), do: {:discard, :invalid_args}

  @impl Oban.Worker
  def backoff(%Oban.Job{attempt: 1}), do: 5
  def backoff(_), do: 30
end

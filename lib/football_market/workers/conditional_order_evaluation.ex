defmodule FootballMarket.Workers.ConditionalOrderEvaluation do
  @moduledoc false
  use Oban.Worker, queue: :conditional_orders, max_attempts: 3
  alias FootballMarket.Market.OrderEvaluation

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"source" => source} = args}) do
    if valid_args?(source, args), do: dispatch(source, args), else: {:discard, :invalid_args}
  end

  def perform(_), do: {:discard, :invalid_args}

  defp valid_args?(source, args) when source in ["order", "quote", "recovery", "continuation"] do
    allowed =
      case source do
        "order" -> ["source", "order_id"]
        "quote" -> ["source", "event_id"]
        "recovery" -> ["source", "event_id"]
        "continuation" -> ["source"]
      end

    Enum.all?(args, fn
      {"source", _} -> true
      {key, id} -> key in allowed and match?({:ok, _}, Ecto.UUID.cast(id))
    end) and (source != "quote" or Map.has_key?(args, "event_id"))
  end

  defp valid_args?(_, _), do: false

  defp dispatch("continuation", _), do: OrderEvaluation.run(false)
  defp dispatch(source, _) when source in ["order", "recovery"], do: OrderEvaluation.run(true)

  defp dispatch("quote", %{"event_id" => id}) do
    case OrderEvaluation.accept_event(id) do
      {:ok, _} ->
        :ok

      {:error, reason} when reason in [:already_leased, :already_acknowledged] ->
        :ok

      {:error, reason} when reason in [:not_found, :receipt_conflict] ->
        {:discard, :invalid_event}

      _ ->
        {:error, :temporarily_unavailable}
    end
  end

  @impl Oban.Worker
  def backoff(%Oban.Job{attempt: 1}), do: 5
  def backoff(_), do: 30
end

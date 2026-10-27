defmodule FootballMarket.Market.OrderEvaluation do
  @moduledoc "Durable acceptance, ordered evaluation and missed-work recovery."
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Market.{ConditionalOrderStore, OrderEvaluationStore, OrderNotifications}
  alias FootballMarket.Quotes.{Evaluation, Recovery}
  alias FootballMarket.Workers.{ConditionalOrderEvaluation, ConditionalOrderRecovery}

  def oban_name do
    :football_market
    |> Application.get_env(FootballMarket.Synchronization, [])
    |> Keyword.get(:oban_name, Oban)
  end

  def enqueue!(args) do
    name = oban_name()

    if is_nil(Oban.Registry.lookup(name)),
      do: ConditionalOrderStore.reject(:temporarily_unavailable)

    Oban.insert!(name, ConditionalOrderEvaluation.new(args))
  end

  def startup, do: Oban.insert(oban_name(), ConditionalOrderRecovery.new(%{}))

  def accept_event(id) do
    ConditionalOrderStore.safely(fn -> Repo.transaction(fn -> accept_locked!(id) end) end)
  end

  defp accept_locked!(id) do
    # Nested claim/ack transactions share this outer transaction: neither
    # the fenced receipt nor the wake can survive an insertion failure.
    event = Repo.one(from e in Evaluation, where: e.id == ^id, lock: "FOR UPDATE")
    receipt = "conditional-evaluation:" <> id

    case event do
      nil -> Repo.rollback(:not_found)
      %{state: "acknowledged", consumer_receipt: ^receipt} -> :ok
      %{state: "acknowledged"} -> Repo.rollback(:receipt_conflict)
      _ -> accept_claim!(id, receipt)
    end
  end

  defp accept_claim!(id, receipt) do
    case Recovery.claim_evaluation(id) do
      {:ok, claim} ->
        enqueue!(%{"source" => "recovery", "event_id" => id})

        case Recovery.acknowledge_evaluation(id, claim.fence, receipt) do
          :ok -> :ok
          {:error, reason} -> Repo.rollback(reason)
        end

      {:error, reason} ->
        Repo.rollback(reason)
    end
  end

  def run(wake) when is_boolean(wake) do
    with :ok <- request(wake), do: steps(100)
  end

  defp request(false), do: :ok
  defp request(true), do: unwrap(OrderEvaluationStore.request_pass())

  defp steps(0), do: unwrap(OrderEvaluationStore.continue())

  defp steps(left) do
    case OrderEvaluationStore.step() do
      {:ok, :idle} ->
        :ok

      {:ok, :rescan} ->
        steps(left)

      {:ok, {:decided, {order, changed}}} ->
        if changed, do: OrderNotifications.changed(order.id)
        steps(left - 1)

      {:error, _} ->
        {:error, :temporarily_unavailable}
    end
  end

  # Bounded keyset pages also recover expired leases. Acknowledged events need
  # no redelivery: the all-pending pass repairs even a lost accepted job.
  def recover(after_id), do: ConditionalOrderStore.safely(fn -> recover_page(after_id) end)

  defp recover_page(after_id) do
    now = FootballMarket.Quotes.Store.database_clock_now!()

    query =
      from e in Evaluation,
        where: e.state == "pending" or (e.state == "leased" and e.lease_until <= ^now),
        order_by: e.id,
        limit: 100,
        select: e.id

    query = if after_id, do: from(e in query, where: e.id > ^after_id), else: query
    ids = Repo.all(query)

    with :ok <- accept_page(ids),
         {:ok, _} <- OrderEvaluationStore.request_pass() do
      Repo.transaction(fn -> persist_recovery_continuation!(ids) end) |> unwrap()
    else
      _ -> {:error, :temporarily_unavailable}
    end
  end

  defp persist_recovery_continuation!(ids) do
    enqueue!(%{"source" => "continuation"})

    if length(ids) == 100 do
      Oban.insert!(oban_name(), ConditionalOrderRecovery.new(%{"after" => List.last(ids)}))
    end
  end

  defp accept_page(ids) do
    Enum.reduce_while(ids, :ok, fn id, _ ->
      case accept_event(id) do
        {:ok, _} -> {:cont, :ok}
        {:error, reason} when reason in [:already_leased, :already_acknowledged] -> {:cont, :ok}
        _ -> {:halt, {:error, :temporarily_unavailable}}
      end
    end)
  end

  defp unwrap({:ok, _}), do: :ok
  defp unwrap({:error, _}), do: {:error, :temporarily_unavailable}
end

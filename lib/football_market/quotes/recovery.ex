defmodule FootballMarket.Quotes.Recovery do
  @moduledoc "Re-enqueue durable pending quote calculations and expose pending TASK-060 work."
  import Ecto.Query
  alias FootballMarket.{Repo, Quotes.CalculationRequest}
  alias FootballMarket.Quotes.{Evaluation, Store}
  alias FootballMarket.Workers.QuoteCalculation
  alias FootballMarket.Observability.JobContext

  def recover_pending do
    now = Store.database_now!()

    request_ids =
      Repo.all(
        from r in CalculationRequest,
          where:
            ((r.source != "import" or not is_nil(r.admitted_at)) and
               r.state in ["pending", "running"]) or
              (r.state == "retrying" and not is_nil(r.next_attempt_at) and
                 r.next_attempt_at <= ^now and
                 (r.source != "import" or not is_nil(r.admitted_at))),
          order_by: [asc: r.inserted_at, asc: r.id],
          select: r.id,
          limit: 500
      )

    correlations = JobContext.for_calculations(request_ids)

    Enum.each(request_ids, fn id ->
      job =
        %{"request_id" => id}
        |> QuoteCalculation.new()
        |> JobContext.annotate(Map.get(correlations, id, id))

      Oban.insert!(oban_name(), job)
    end)

    {:ok, length(request_ids)}
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  # Follows the dispatcher/job-store isolation contract: tests may substitute an
  # isolated Oban instance through the synchronization configuration.
  defp oban_name do
    :football_market
    |> Application.get_env(FootballMarket.Synchronization, [])
    |> Keyword.get(:oban_name, Oban)
  end

  def pending_evaluations, do: FootballMarket.Quotes.pending_evaluations()

  def claim_evaluation(event_id, lease_seconds \\ 300)

  def claim_evaluation(event_id, lease_seconds)
      when is_integer(lease_seconds) and lease_seconds in 1..300 do
    case Ecto.UUID.cast(event_id) do
      {:ok, id} -> claim_evaluation_by_id(id, lease_seconds)
      _ -> {:error, :invalid_event}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def claim_evaluation(_, _), do: {:error, :invalid_lease}

  defp claim_evaluation_by_id(event_id, lease_seconds) do
    Repo.transaction(fn ->
      event = Repo.one(from e in Evaluation, where: e.id == ^event_id, lock: "FOR UPDATE")
      now = Store.database_clock_now!()
      claim_locked(event, lease_seconds, now)
    end)
  end

  defp claim_locked(nil, _lease_seconds, _now), do: Repo.rollback(:not_found)

  defp claim_locked(%{state: "acknowledged"}, _lease_seconds, _now),
    do: Repo.rollback(:already_acknowledged)

  defp claim_locked(%{state: "leased", lease_until: until_time} = event, lease_seconds, now)
       when not is_nil(until_time) do
    if DateTime.compare(until_time, now) == :gt,
      do: Repo.rollback(:already_leased),
      else: claim_available(event, lease_seconds, now)
  end

  defp claim_locked(event, lease_seconds, now), do: claim_available(event, lease_seconds, now)

  defp claim_available(event, lease_seconds, now) do
    record_expired_delivery(event, now)

    claimed =
      event
      |> Ecto.Changeset.change(
        state: "leased",
        delivery_attempts: event.delivery_attempts + 1,
        lease_fence: event.lease_fence + 1,
        lease_started_at: now,
        lease_until: DateTime.add(now, lease_seconds, :second)
      )
      |> Repo.update!()

    %{event: claimed, fence: claimed.lease_fence, key: claimed.idempotency_key}
  end

  defp record_expired_delivery(%{state: "leased", delivery_attempts: attempts} = event, now)
       when attempts > 0,
       do: insert_delivery_attempt!(event, "expired", "lease_expired", now)

  defp record_expired_delivery(_event, _now), do: :ok

  def acknowledge_evaluation(event_id, fence, receipt)
      when is_integer(fence) and is_binary(receipt) and byte_size(receipt) in 1..200 do
    case valid_acknowledgement(event_id, receipt) do
      {:ok, id} -> acknowledge_by_id(id, fence, receipt)
      _ -> {:error, :invalid_receipt}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def acknowledge_evaluation(_, _, _), do: {:error, :invalid_receipt}

  defp valid_acknowledgement(event_id, receipt) do
    if Regex.match?(~r/\A[a-zA-Z0-9:_-]+\z/, receipt),
      do: Ecto.UUID.cast(event_id),
      else: {:error, :invalid_receipt}
  end

  defp acknowledge_by_id(event_id, fence, receipt) do
    Repo.transaction(fn ->
      event = Repo.one(from e in Evaluation, where: e.id == ^event_id, lock: "FOR UPDATE")
      # The row lock may outlast the lease. Validate against the current DB
      # clock after acquiring it, rather than the transaction's start time.
      now = Store.database_clock_now!()
      acknowledge_locked(event, fence, receipt, now)
    end)
    |> case do
      {:ok, :ok} -> :ok
      {:ok, value} -> {:ok, value}
      {:error, reason} -> {:error, reason}
    end
  end

  defp acknowledge_locked(event, fence, receipt, now) do
    case acknowledgement_action(event, fence, receipt, now) do
      :acknowledged -> :ok
      {:error, reason} -> Repo.rollback(reason)
      :acknowledge -> persist_acknowledgement!(event, receipt, now)
    end
  end

  defp acknowledgement_action(nil, _fence, _receipt, _now), do: {:error, :not_found}

  defp acknowledgement_action(
         %{state: "acknowledged", consumer_receipt: receipt},
         _fence,
         receipt,
         _now
       ),
       do: :acknowledged

  defp acknowledgement_action(%{state: "acknowledged"}, _fence, _receipt, _now),
    do: {:error, :receipt_conflict}

  defp acknowledgement_action(%{state: state}, _fence, _receipt, _now)
       when state != "leased",
       do: {:error, :stale_fence}

  defp acknowledgement_action(
         %{lease_fence: current_fence, lease_until: until_time},
         fence,
         _receipt,
         now
       ) do
    if current_fence == fence and DateTime.compare(until_time, now) == :gt,
      do: :acknowledge,
      else: {:error, :stale_fence}
  end

  defp persist_acknowledgement!(event, receipt, now) do
    insert_delivery_attempt!(event, "acknowledged", nil, now, receipt)

    Repo.update!(
      Ecto.Changeset.change(event,
        state: "acknowledged",
        acknowledged_at: now,
        consumer_receipt: receipt,
        lease_started_at: nil,
        lease_until: nil
      )
    )

    :ok
  end

  defp insert_delivery_attempt!(event, status, reason, now, receipt \\ nil) do
    claimed_at = event.lease_started_at || now

    Repo.insert_all("quote_evaluation_delivery_attempts", [
      %{
        id: Ecto.UUID.dump!(Ecto.UUID.generate()),
        event_id: Ecto.UUID.dump!(event.id),
        attempt_number: event.delivery_attempts,
        fence: event.lease_fence,
        claimed_at: claimed_at,
        finished_at: now,
        status: status,
        reason: reason,
        consumer_receipt: receipt
      }
    ])
  end
end

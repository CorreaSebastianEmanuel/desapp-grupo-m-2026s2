defmodule FootballMarket.Quotes.Recovery do
  @moduledoc "Re-enqueue durable pending quote calculations and expose pending TASK-060 work."
  import Ecto.Query
  alias FootballMarket.{Repo, Quotes.CalculationRequest}
  alias FootballMarket.Quotes.{Evaluation, Store}
  alias FootballMarket.Workers.QuoteCalculation

  def recover_pending do
    now = Store.database_now!()

    request_ids =
      Repo.all(
        from r in CalculationRequest,
          where:
            r.state in ["pending", "running"] or
              (r.state == "retrying" and not is_nil(r.next_attempt_at) and
                 r.next_attempt_at <= ^now),
          order_by: [asc: r.inserted_at, asc: r.id],
          select: r.id,
          limit: 500
      )

    Enum.each(request_ids, fn id ->
      Oban.insert!(QuoteCalculation.new(%{"request_id" => id}))
    end)

    {:ok, length(request_ids)}
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def pending_evaluations, do: FootballMarket.Quotes.pending_evaluations()

  def claim_evaluation(event_id, lease_seconds \\ 300)

  def claim_evaluation(event_id, lease_seconds)
      when is_integer(lease_seconds) and lease_seconds in 1..300 do
    with {:ok, event_id} <- Ecto.UUID.cast(event_id) do
      Repo.transaction(fn ->
        event = Repo.one(from e in Evaluation, where: e.id == ^event_id, lock: "FOR UPDATE")
        now = Store.database_now!()

        cond do
          is_nil(event) ->
            Repo.rollback(:not_found)

          event.state == "acknowledged" ->
            Repo.rollback(:already_acknowledged)

          event.state == "leased" and not is_nil(event.lease_until) and
              DateTime.compare(event.lease_until, now) == :gt ->
            Repo.rollback(:already_leased)

          true ->
            if event.state == "leased" and event.delivery_attempts > 0 do
              insert_delivery_attempt!(event, "expired", "lease_expired", now)
            end

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
      end)
    else
      _ -> {:error, :invalid_event}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def claim_evaluation(_, _), do: {:error, :invalid_lease}

  def acknowledge_evaluation(event_id, fence, receipt)
      when is_integer(fence) and is_binary(receipt) and byte_size(receipt) in 1..200 do
    with true <- Regex.match?(~r/\A[a-zA-Z0-9:_-]+\z/, receipt),
         {:ok, event_id} <- Ecto.UUID.cast(event_id) do
      Repo.transaction(fn ->
        event = Repo.one(from e in Evaluation, where: e.id == ^event_id, lock: "FOR UPDATE")
        now = Store.database_now!()

        cond do
          is_nil(event) ->
            Repo.rollback(:not_found)

          event.state == "acknowledged" and event.consumer_receipt == receipt ->
            :ok

          event.state == "acknowledged" ->
            Repo.rollback(:receipt_conflict)

          event.state != "leased" or event.lease_fence != fence ->
            Repo.rollback(:stale_fence)

          DateTime.compare(event.lease_until, now) != :gt ->
            Repo.rollback(:stale_fence)

          true ->
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
      end)
      |> case do
        {:ok, :ok} -> :ok
        {:ok, value} -> {:ok, value}
        {:error, reason} -> {:error, reason}
      end
    else
      _ -> {:error, :invalid_receipt}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def acknowledge_evaluation(_, _, _), do: {:error, :invalid_receipt}

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

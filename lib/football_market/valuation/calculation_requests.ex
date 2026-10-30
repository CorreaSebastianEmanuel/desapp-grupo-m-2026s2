defmodule FootballMarket.Valuation.CalculationRequests do
  @moduledoc "Idempotent receiving boundary for accepted statistics calculation intents."
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.Ingestion.CalculationIntent
  alias FootballMarket.Valuation.CalculationRequest

  def accept(intent_id, check_id, changed_ids) when is_list(changed_ids) and changed_ids != [] do
    with {:ok, intent_id} <- Ecto.UUID.cast(intent_id),
         {:ok, check_id} <- Ecto.UUID.cast(check_id),
         {:ok, ids} <- normalize_ids(changed_ids) do
      do_accept(intent_id, check_id, ids)
    else
      _ -> {:error, :invalid_request}
    end
  end

  def accept(_, _, _), do: {:error, :invalid_request}

  def get(intent_id) do
    with {:ok, intent_id} <- Ecto.UUID.cast(intent_id),
         %CalculationRequest{} = request <- Repo.get_by(CalculationRequest, intent_id: intent_id) do
      {:ok, request}
    else
      _ -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp do_accept(intent_id, check_id, ids) do
    Repo.transaction(fn ->
      request = accept_locked(intent_id, check_id, ids)
      FootballMarket.Quotes.Membership.record_import!(intent_id)
      request
    end)
    |> case do
      {:ok, request} -> {:ok, request}
      {:error, :calculation_request_conflict} -> {:error, :calculation_request_conflict}
      {:error, _} -> {:error, :temporarily_unavailable}
    end
  rescue
    error in Postgrex.Error ->
      if error.postgres && error.postgres.code == :unique_violation,
        do: existing_request(intent_id, check_id, ids),
        else: {:error, :temporarily_unavailable}

    _ ->
      {:error, :temporarily_unavailable}
  end

  defp normalize_ids(ids) do
    if Enum.all?(ids, &match?({:ok, _}, Ecto.UUID.cast(&1))) do
      normalized =
        Enum.map(ids, fn id ->
          {:ok, uuid} = Ecto.UUID.cast(id)
          uuid
        end)
        |> Enum.uniq()
        |> Enum.sort()

      if length(normalized) == length(ids),
        do: {:ok, normalized},
        else: {:error, :invalid_request}
    else
      {:error, :invalid_request}
    end
  end

  defp existing_request(intent_id, check_id, ids) do
    request = Repo.one(from r in CalculationRequest, where: r.intent_id == ^intent_id)

    if request && request.accepted_check_id == check_id && request.changed_performance_ids == ids,
      do: {:ok, request},
      else: {:error, :calculation_request_conflict}
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp insert_request(intent_id, check_id, ids) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    Repo.insert!(%CalculationRequest{
      id: Ecto.UUID.generate(),
      intent_id: intent_id,
      accepted_check_id: check_id,
      changed_performance_ids: ids,
      accepted_at: now,
      state: "requested"
    })
  end

  defp matching_intent?(intent, check_id, intent_ids, ids),
    do: intent && intent.accepted_check_id == check_id && intent_ids == {:ok, ids}

  defp accept_locked(intent_id, check_id, ids) do
    intent =
      Repo.one(from i in CalculationIntent, where: i.id == ^intent_id, lock: "FOR UPDATE")

    intent_ids = if intent, do: normalize_ids(intent.changed_performance_ids), else: nil

    unless matching_intent?(intent, check_id, intent_ids, ids),
      do: Repo.rollback(:calculation_request_conflict)

    case Repo.one(
           from r in CalculationRequest, where: r.intent_id == ^intent_id, lock: "FOR UPDATE"
         ) do
      nil ->
        insert_request(intent_id, check_id, ids)

      request
      when request.accepted_check_id == check_id and request.changed_performance_ids == ids ->
        request

      _ ->
        Repo.rollback(:calculation_request_conflict)
    end
  end
end

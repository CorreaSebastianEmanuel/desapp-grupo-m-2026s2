defmodule FootballMarket.Quotes.ImportRequests do
  @moduledoc "Leased request execution, binding, retry and attempt history."
  import Ecto.Query
  alias FootballMarket.{Repo, Valuation}
  alias FootballMarket.Quotes.{Engine, EvidenceCodec, Store}

  def process_import_request(request_id) do
    case claim_import_request(request_id) do
      {:ok, req, fence} when is_nil(req.mapping_id) ->
        finish_request(req, "validation_failed", "mapping_unavailable", nil, fence)

      {:ok, req, fence} ->
        with {:ok, req, selector} <- fix_request_binding(req),
             {:ok, facts} <- request_recovery_facts(req) do
          process_recovered_request(req, selector, facts, fence)
        else
          {:error, :original_unavailable} ->
            finish_request(req, "unreproducible", "original_unavailable", nil, fence)

          {:error, :unsupported_strategy} ->
            finish_request(req, "unsupported_strategy", "configuration_unavailable", nil, fence)

          {:error, :configuration_unavailable} ->
            finish_request(req, "validation_failed", "configuration_unavailable", nil, fence)

          {:error, _} ->
            retry_request(req, fence)
        end

      :not_due ->
        :ok

      {:error, _} ->
        {:error, :calculation_unavailable}
    end
  rescue
    _ -> {:error, :calculation_unavailable}
  end

  # Recovers the calculation's original accepted facts. Explicit requests
  # retain their own durable fact material (their import intent is nil);
  # import requests still resolve their snapshot row. A missing original row
  # stays a terminal unreproducible outcome while decode failures retry.
  defp request_recovery_facts(%{source: source} = req) when source in ["explicit", "ttl"] do
    case EvidenceCodec.request_facts(req) do
      {:ok, _request, facts} -> {:ok, facts}
      error -> error
    end
  end

  defp request_recovery_facts(req) do
    with {:ok, rows} <- FootballMarket.Quotes.Membership.snapshots(req.intent_id),
         row when not is_nil(row) <-
           Enum.find(rows, fn [sid | _] -> Ecto.UUID.load!(sid) == req.snapshot_id end) do
      [_sid, _player, _season, _start, _end, _ids, fact_material, _digest] = row
      FootballMarket.Quotes.Membership.facts(fact_material)
    else
      nil -> {:error, :original_unavailable}
      {:error, _} = error -> error
    end
  end

  defp process_recovered_request(req, selector, facts, fence) do
    result =
      Engine.request_membership(
        %{
          player_id: req.player_id,
          season_id: req.season_id,
          week_start: req.week_start,
          week_end: req.week_end
        },
        selector,
        req.mapping_id,
        facts,
        req.id,
        {req.id, fence},
        if(req.source == "ttl", do: %{"admission_key" => req.admission_key}, else: %{})
      )

    case result do
      {:ok, %{calculation: calc}} ->
        finish_request(req, calc.status, calc.reason, calc.id, fence)

      {:error, _} ->
        retry_request(req, fence)
    end
  end

  defp fix_request_binding(%{configuration_version_id: id} = req) when not is_nil(id),
    do: {:ok, req, {:version, id}}

  defp fix_request_binding(req) do
    case selector(req.selector) do
      :active ->
        case Valuation.Configurations.active() do
          {:ok, version} -> persist_binding(req, version)
          _ -> {:error, :configuration_unavailable}
        end

      {:version, id} ->
        case Valuation.Configurations.get(id) do
          {:ok, %{version: version}} -> persist_binding(req, version)
          _ -> {:error, :configuration_unavailable}
        end

      :invalid ->
        {:error, :unsupported_strategy}
    end
  end

  defp persist_binding(req, version) do
    Repo.transaction(fn ->
      current = Store.ensure_confirmation_lease!({req.id, req.lease_fence})

      if current.configuration_version_id do
        current
      else
        current
        |> Ecto.Changeset.change(configuration_version_id: version.id)
        |> Repo.update!()
      end
    end)
    |> case do
      {:ok, bound} -> {:ok, bound, {:version, bound.configuration_version_id}}
      {:error, :stale_fence} -> {:error, :stale_worker}
      _ -> {:error, :temporarily_unavailable}
    end
  end

  defp claim_import_request(id) do
    Repo.transaction(fn ->
      req =
        Repo.one(
          from r in FootballMarket.Quotes.CalculationRequest,
            where: r.id == ^id,
            lock: "FOR UPDATE"
        )

      now = Store.database_clock_now!()
      claim_import_locked(req, now)
    end)
    |> case do
      {:ok, {:claimed, req, fence}} -> {:ok, req, fence}
      {:ok, :not_due} -> :not_due
      {:error, reason} -> {:error, reason}
    end
  end

  defp claim_import_locked(nil, _now), do: Repo.rollback(:not_found)

  defp claim_import_locked(%{source: "import", admitted_at: nil}, _now), do: :not_due

  defp claim_import_locked(%{state: state}, _now)
       when state in [
              "successful",
              "no_quote",
              "validation_failed",
              "unsupported_strategy",
              "unreproducible",
              "exhausted"
            ],
       do: :not_due

  defp claim_import_locked(req, now) do
    cond do
      import_request_not_due?(req, now) ->
        :not_due

      req.attempt_count >= 3 ->
        exhaust_import_request(req, now)

      true ->
        reserve_import_attempt(req, now)
    end
  end

  defp import_request_not_due?(%{state: "running", lease_until: until_time}, now)
       when not is_nil(until_time),
       do: DateTime.compare(until_time, now) == :gt

  defp import_request_not_due?(%{state: "retrying", next_attempt_at: next_time}, now)
       when not is_nil(next_time),
       do: DateTime.compare(next_time, now) == :gt

  defp import_request_not_due?(_req, _now), do: false

  defp exhaust_import_request(req, now) do
    if req.state == "running" and not is_nil(req.lease_until),
      do: record_attempt!(req, "interrupted", "worker_interrupted", now)

    Repo.update!(
      Ecto.Changeset.change(req,
        state: "exhausted",
        reason: "retry_exhausted",
        lease_until: nil
      )
    )

    :not_due
  end

  defp reserve_import_attempt(req, now) do
    if req.state == "running" and req.attempt_count > 0,
      do: record_attempt!(req, "interrupted", "worker_interrupted", now)

    next =
      req
      |> Ecto.Changeset.change(
        state: "running",
        attempt_count: req.attempt_count + 1,
        lease_fence: req.lease_fence + 1,
        lease_until: DateTime.add(now, 300, :second),
        next_attempt_at: nil
      )
      |> Repo.update!()

    {:claimed, next, next.lease_fence}
  end

  defp finish_request(req, status, reason, calculation_id, fence) do
    Repo.transaction(fn ->
      current =
        Repo.one(
          from r in FootballMarket.Quotes.CalculationRequest,
            where: r.id == ^req.id,
            lock: "FOR UPDATE"
        )

      if current && current.state == "running" && current.lease_fence == fence do
        now = Store.database_now!()
        record_attempt!(current, status, reason, now)

        Repo.update!(
          Ecto.Changeset.change(current,
            state: status,
            reason: reason,
            calculation_id: calculation_id,
            lease_until: nil
          )
        )
      else
        Repo.rollback(:stale_fence)
      end
    end)
    |> case do
      {:ok, _} -> :ok
      _ -> {:error, :stale_worker}
    end
  end

  defp retry_request(req, fence) do
    Repo.transaction(fn ->
      current =
        Repo.one(
          from r in FootballMarket.Quotes.CalculationRequest,
            where: r.id == ^req.id,
            lock: "FOR UPDATE"
        )

      retry_locked_request(current, fence)
    end)
    |> case do
      {:ok, _} -> :ok
      _ -> {:error, :stale_worker}
    end
  end

  defp retry_locked_request(%{state: "running", lease_fence: fence} = request, fence),
    do: persist_retry_transition(request)

  defp retry_locked_request(_request, _fence), do: Repo.rollback(:stale_fence)

  defp persist_retry_transition(request) do
    now = Store.database_now!()
    {state, status, reason, next_attempt_at} = retry_transition(request, now)
    record_attempt!(request, status, reason, now)

    Repo.update!(
      Ecto.Changeset.change(request,
        state: state,
        reason: reason,
        next_attempt_at: next_attempt_at,
        lease_until: nil
      )
    )
  end

  defp retry_transition(%{attempt_count: attempts}, _now) when attempts >= 3,
    do: {"exhausted", "exhausted", "retry_exhausted", nil}

  defp retry_transition(%{attempt_count: attempts}, now) do
    wait = Enum.at([60, 300], attempts - 1, 300)
    {"retrying", "retryable", "temporarily_unavailable", DateTime.add(now, wait, :second)}
  end

  defp record_attempt!(req, status, reason, now) do
    Repo.insert_all("quote_calculation_attempts", [
      %{
        id: Ecto.UUID.dump!(Ecto.UUID.generate()),
        request_id: Ecto.UUID.dump!(req.id),
        attempt_number: req.attempt_count,
        fence: req.lease_fence,
        started_at:
          if(req.lease_until, do: DateTime.add(req.lease_until, -300, :second), else: now),
        finished_at: now,
        status: status,
        reason: reason
      }
    ])
  end

  defp selector("active"), do: :active

  defp selector("version:" <> id) do
    case Ecto.UUID.cast(id) do
      {:ok, normalized} -> {:version, normalized}
      _ -> :invalid
    end
  end

  defp selector(_), do: :invalid
end

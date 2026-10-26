defmodule FootballMarket.Statistics.Freshness.Refresh do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.Ingestion.ScopeCheck
  alias FootballMarket.Synchronization.{Run, Store}

  @active ~w(queued executing retry_wait)
  @reasons ~w(exhausted exhausted_unconfirmed non_retryable input_drift missing_configuration
              rate_limited unavailable timeout unsupported_capability invalid_response access_refused
              immutable_conflict persistence_failure interrupted)

  def ensure(player, settings, now) do
    Repo.transaction(fn ->
      Repo.query!("SET LOCAL lock_timeout = '100ms'")
      if not Store.try_lock_scope(settings.input.scope), do: Repo.rollback(:busy)
      decide(player, settings, now)
    end)
    |> case do
      {:ok, refresh} -> refresh
      {:error, :busy} -> status("busy", nil, "scope_busy")
      {:error, _} -> status("unavailable", nil, "temporarily_unavailable")
    end
  rescue
    _ -> status("unavailable", nil, "temporarily_unavailable")
  end

  def fresh?(nil, _, _), do: false
  def fresh?(%{last_checked_at: nil}, _, _), do: false

  def fresh?(row, ttl, now),
    do: DateTime.compare(now, DateTime.add(row.last_checked_at, ttl, :second)) == :lt

  def status(state, run \\ nil, reason \\ nil, next_attempt_at \\ nil) do
    %{state: state, run_id: run && run.id, reason: reason, next_attempt_at: next_attempt_at}
  end

  defp decide(player, settings, now) do
    query = runs(settings.input)
    active = Repo.one(from r in query, where: r.state in @active)

    cond do
      active && active.input == settings.input.material ->
        status(active.state, active, safe_reason(active), active.next_retry_at)

      active ->
        status("busy", nil, "scope_busy")

      fresh?(ScopeCheck.find(settings.provider, player.season_id), settings.ttl, now) ->
        status("idle")

      true ->
        latest =
          Repo.one(
            from r in query,
              where:
                r.source_ref == ^settings.input.material["source_ref"] and
                  r.input_digest == ^settings.input.digest and r.input == ^settings.input.material,
              order_by: [desc_nulls_last: r.finished_at, desc: r.requested_at, desc: r.id],
              limit: 1
          )

        retry_or_admit(latest, settings, now)
    end
  end

  defp retry_or_admit(%{state: "failed"} = run, settings, now) do
    if run.input == settings.input.material do
      after_failure(run, settings, now)
    else
      admit(settings.input, now)
    end
  end

  defp retry_or_admit(_, settings, now), do: admit(settings.input, now)

  defp after_failure(run, settings, now) do
    if transient?(run) and run.finished_at do
      hint = run.outcome["retry_after_ms"]

      wait =
        if is_integer(hint) and hint > 0,
          do: max(settings.cooldown, div(hint + 999, 1000)),
          else: settings.cooldown

      eligible = DateTime.add(run.finished_at, wait, :second)

      if DateTime.compare(now, eligible) == :lt,
        do: status("cooldown", run, safe_reason(run), eligible),
        else: admit(settings.input, now)
    else
      status("blocked", run, safe_reason(run))
    end
  end

  defp transient?(%{reason: "exhausted", outcome: outcome}) when is_map(outcome) do
    outcome["status"] in ~w(persistence_failure concurrent_change interrupted) or
      (outcome["status"] == "provider_failure" and outcome["retryable"] == true and
         outcome["category"] in ~w(rate_limited unavailable timeout))
  end

  defp transient?(_), do: false

  defp admit(input, now) do
    case Store.admit_locked(input, now, nil) do
      %{run_id: id, status: state} -> %{status(Atom.to_string(state)) | run_id: id}
      {:error, _} -> Repo.rollback(:admission_failed)
    end
  end

  defp runs(input) do
    scope = input.scope

    from r in Run,
      where:
        r.operation == "statistics" and r.league_code == ^scope.league_code and
          r.start_year == ^scope.start_year and r.end_year == ^scope.end_year
  end

  defp safe_reason(run) do
    reason = (run.outcome || %{})["category"] || run.reason
    if reason in @reasons, do: reason, else: nil
  end
end

defmodule FootballMarket.Catalog.ScoutStore do
  @moduledoc "PostgreSQL admission and lifecycle for catalog scout runs."
  import Ecto.Query

  alias FootballMarket.Repo
  alias FootballMarket.Catalog.ScoutRun
  alias FootballMarket.Workers.CatalogScout

  @active ["queued", "scouting"]
  @negative_ttl 86_400
  @hourly_limit 10

  def admit(display_name, normalized_name, scopes, now \\ DateTime.utc_now()) do
    if scopes == [] do
      status(:unavailable, nil, 0)
    else
      digest = FootballMarket.Catalog.Scouting.digest(scopes)

      case Repo.transaction(fn ->
             admit_locked(display_name, normalized_name, scopes, digest, now)
           end) do
        {:ok, result} -> result
        _ -> status(:unavailable, nil, length(scopes))
      end
    end
  rescue
    _ -> status(:unavailable, nil, 0)
  end

  def get(id), do: Repo.get(ScoutRun, id)

  def attach_sync_runs(id, run_ids, error_category \\ nil) do
    Repo.transaction(fn ->
      scout = Repo.one!(from s in ScoutRun, where: s.id == ^id, lock: "FOR UPDATE")

      scout
      |> Ecto.Changeset.change(
        state: "scouting",
        synchronization_run_ids: run_ids,
        request_count: length(run_ids),
        error_category: error_category
      )
      |> Repo.update!()
    end)
  end

  def finish(%ScoutRun{} = scout, state, error_category \\ nil)
      when state in ["found", "not_found", "provider_failure"] do
    now = DateTime.utc_now()

    result =
      Repo.transaction(fn ->
        locked = Repo.one!(from s in ScoutRun, where: s.id == ^scout.id, lock: "FOR UPDATE")

        locked
        |> Ecto.Changeset.change(
          state: state,
          finished_at: now,
          next_attempt_at: cache_deadline(state, now, locked),
          error_category: error_category
        )
        |> Repo.update!()
      end)

    case result do
      {:ok, updated} ->
        Phoenix.PubSub.broadcast(
          FootballMarket.PubSub,
          "catalog_scouts",
          {:catalog_scout_changed, updated.normalized_name}
        )

        {:ok, updated}

      error ->
        error
    end
  rescue
    _ -> {:error, :unavailable}
  end

  def terminal?(state), do: state in ["succeeded", "failed"]

  defp admit_locked(display_name, normalized_name, scopes, digest, now) do
    global_lock()

    existing =
      Repo.one(
        from s in ScoutRun, where: s.normalized_name == ^normalized_name, lock: "FOR UPDATE"
      )

    case reusable(existing, digest, now) do
      {:reuse, status} ->
        status

      :new ->
        case rate_limit_deadline(now) do
          nil -> create_run(display_name, normalized_name, scopes, digest, now, existing)
          deadline -> status(:rate_limited, deadline, length(scopes))
        end
    end
  end

  defp reusable(%ScoutRun{config_digest: digest, state: state} = scout, digest, _now)
       when state in @active,
       do: {:reuse, status(:scouting, nil, scout.configured_scope_count)}

  defp reusable(%ScoutRun{config_digest: digest, state: "found"} = scout, digest, _now),
    do: {:reuse, status(:found, nil, scout.configured_scope_count)}

  defp reusable(%ScoutRun{config_digest: digest, state: state} = scout, digest, now)
       when state in ["not_found", "provider_failure"] do
    retry_at = scout.next_attempt_at || DateTime.add(scout.finished_at, @negative_ttl, :second)

    if DateTime.compare(now, retry_at) == :lt do
      {:reuse,
       status(
         if(state == "not_found", do: :cached_miss, else: :provider_failure),
         retry_at,
         scout.configured_scope_count
       )}
    else
      :new
    end
  end

  defp reusable(_, _, _), do: :new

  defp create_run(display_name, normalized_name, scopes, digest, now, nil) do
    run = insert_run(display_name, normalized_name, scopes, digest, now)
    queue(run)
  end

  defp create_run(display_name, _normalized_name, scopes, digest, now, existing) do
    run =
      existing
      |> Ecto.Changeset.change(
        display_name: display_name,
        state: "queued",
        config_digest: digest,
        admitted_at: now,
        finished_at: nil,
        next_attempt_at: nil,
        scope_inputs: Map.new(scopes, &{&1["league_code"], &1}),
        synchronization_run_ids: [],
        configured_scope_count: length(scopes),
        request_count: 0,
        error_category: nil
      )
      |> Repo.update!()

    queue(run)
  end

  defp insert_run(display_name, normalized_name, scopes, digest, now) do
    Repo.insert!(%ScoutRun{
      normalized_name: normalized_name,
      display_name: display_name,
      state: "queued",
      config_digest: digest,
      admitted_at: now,
      configured_scope_count: length(scopes),
      scope_inputs: Map.new(scopes, &{&1["league_code"], &1})
    })
  end

  defp queue(run) do
    job = Oban.insert!(oban_name(), CatalogScout.new(%{"scout_id" => run.id}))
    Repo.update!(Ecto.Changeset.change(run, job_id: job.id))
    status(:queued, nil, run.configured_scope_count)
  end

  defp oban_name do
    :football_market
    |> Application.get_env(FootballMarket.Synchronization, [])
    |> Keyword.get(:oban_name, Oban)
  end

  defp rate_limit_deadline(now) do
    cutoff = DateTime.add(now, -3_600, :second)

    recent =
      Repo.all(
        from s in ScoutRun,
          where: s.admitted_at >= ^cutoff,
          order_by: s.admitted_at,
          select: s.admitted_at
      )

    if length(recent) >= @hourly_limit,
      do: recent |> Enum.at(length(recent) - @hourly_limit) |> DateTime.add(3_600, :second)
  end

  defp cache_deadline("not_found", now, _scout), do: DateTime.add(now, @negative_ttl, :second)
  defp cache_deadline("provider_failure", _now, _scout), do: next_nightly()
  defp cache_deadline(_, _, _), do: nil

  defp next_nightly do
    config = Application.get_env(:football_market, FootballMarket.Quotes.Closing, [])
    recurrence = Keyword.get(config, :default_recurrence, "0 0 * * *")
    now = DateTime.utc_now()

    with {:ok, expression} <- Oban.Cron.Expression.parse(recurrence),
         %DateTime{} = next <- Oban.Cron.Expression.next_at(expression, now) do
      DateTime.add(next, 0, :microsecond)
    else
      _ -> DateTime.add(now, 86_400, :second)
    end
  end

  defp global_lock do
    <<key::signed-64, _::binary>> = :crypto.hash(:sha256, "catalog-scout-global-admission")
    Repo.query!("SELECT pg_advisory_xact_lock($1)", [key])
  end

  defp status(state, retry_at, scope_count),
    do: %{state: state, next_attempt_at: retry_at, configured_scope_count: scope_count}
end

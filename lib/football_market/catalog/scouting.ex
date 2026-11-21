defmodule FootballMarket.Catalog.Scouting do
  @moduledoc """
  Bounded, durable scouting for validated local catalog misses.

  When a local catalog search finds no player, this module validates the query,
  deduplicates & rate-limits scout requests in PostgreSQL, enqueues a
  `CatalogScout` Oban worker, and publishes status updates over PubSub.
  """

  import Ecto.Query

  alias FootballMarket.Catalog.ScoutRun
  alias FootballMarket.{Catalog, Providers, Repo, Synchronization}
  alias FootballMarket.Workers.CatalogScout

  @max_name_length 80
  @scope_fields [:league_code, :start_year, :end_year, :source_ref]
  @active_states ["queued", "scouting"]
  @negative_ttl_seconds 86_400
  @hourly_limit 10

  # --- Public Search & Normalization API ---

  def search(term) do
    case normalize_name(term) do
      {:ok, display_name, normalized_name} ->
        search_normalized(display_name, normalized_name)

      :error ->
        {:ok, [], %{state: :rejected, next_attempt_at: nil, configured_scope_count: 0}}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def normalize_name(term) when is_binary(term) do
    if String.valid?(term) do
      display_name = term |> String.trim() |> String.split() |> Enum.join(" ")
      normalized_name = normalize_identity(display_name)
      if valid_name?(display_name), do: {:ok, display_name, normalized_name}, else: :error
    else
      :error
    end
  end

  def normalize_name(_), do: :error

  def normalize_identity(value) when is_binary(value) do
    value
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{M}/u, "")
    |> String.downcase()
    |> String.trim()
    |> String.split()
    |> Enum.join(" ")
  end

  def configured_scopes do
    config = Application.get_env(:football_market, Synchronization, [])
    config |> Keyword.get(:scouting_scopes, []) |> validate_scopes()
  rescue
    _ -> []
  end

  def digest(scopes),
    do: :crypto.hash(:sha256, Jason.encode!(scopes)) |> Base.encode16(case: :lower)

  # --- Scout Run Lifecycle & Persistence ---

  def admit(display_name, normalized_name, scopes, now \\ DateTime.utc_now())

  def admit(_display_name, _normalized_name, [], _now),
    do: scout_status(:unavailable, nil, 0)

  def admit(display_name, normalized_name, scopes, now) do
    config_digest = digest(scopes)

    case Repo.transaction(fn ->
           admit_locked(display_name, normalized_name, scopes, config_digest, now)
         end) do
      {:ok, result} -> result
      _ -> scout_status(:unavailable, nil, length(scopes))
    end
  rescue
    _ -> scout_status(:unavailable, nil, 0)
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
          next_attempt_at: cache_deadline(state, now),
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

  # --- Private Helpers ---

  defp search_normalized(display_name, normalized_name) do
    with {:ok, players} <- Catalog.search_local_players(display_name) do
      status =
        if players == [], do: admit(display_name, normalized_name, configured_scopes())

      {:ok, players, status}
    end
  end

  defp admit_locked(display_name, normalized_name, scopes, config_digest, now) do
    acquire_global_lock()

    existing =
      Repo.one(
        from s in ScoutRun, where: s.normalized_name == ^normalized_name, lock: "FOR UPDATE"
      )

    case check_reusable(existing, config_digest, now) do
      {:reuse, status} ->
        status

      :new ->
        case rate_limit_deadline(now) do
          nil ->
            create_or_reset_run(
              display_name,
              normalized_name,
              scopes,
              config_digest,
              now,
              existing
            )

          deadline ->
            scout_status(:rate_limited, deadline, length(scopes))
        end
    end
  end

  defp check_reusable(%ScoutRun{config_digest: digest, state: state} = scout, digest, _now)
       when state in @active_states,
       do: {:reuse, scout_status(:scouting, nil, scout.configured_scope_count)}

  defp check_reusable(%ScoutRun{config_digest: digest, state: "found"} = scout, digest, _now),
    do: {:reuse, scout_status(:found, nil, scout.configured_scope_count)}

  defp check_reusable(%ScoutRun{config_digest: digest, state: state} = scout, digest, now)
       when state in ["not_found", "provider_failure"] do
    retry_at =
      scout.next_attempt_at || DateTime.add(scout.finished_at, @negative_ttl_seconds, :second)

    if DateTime.compare(now, retry_at) == :lt do
      reason = if state == "not_found", do: :cached_miss, else: :provider_failure
      {:reuse, scout_status(reason, retry_at, scout.configured_scope_count)}
    else
      :new
    end
  end

  defp check_reusable(_, _, _), do: :new

  defp create_or_reset_run(display_name, normalized_name, scopes, config_digest, now, nil) do
    run =
      Repo.insert!(%ScoutRun{
        normalized_name: normalized_name,
        display_name: display_name,
        state: "queued",
        config_digest: config_digest,
        admitted_at: now,
        configured_scope_count: length(scopes),
        scope_inputs: Map.new(scopes, fn scope -> {scope["league_code"], scope} end)
      })

    enqueue_scout_job(run)
  end

  defp create_or_reset_run(display_name, _normalized_name, scopes, config_digest, now, existing) do
    run =
      existing
      |> Ecto.Changeset.change(
        display_name: display_name,
        state: "queued",
        config_digest: config_digest,
        admitted_at: now,
        finished_at: nil,
        next_attempt_at: nil,
        scope_inputs: Map.new(scopes, fn scope -> {scope["league_code"], scope} end),
        synchronization_run_ids: [],
        configured_scope_count: length(scopes),
        request_count: 0,
        error_category: nil
      )
      |> Repo.update!()

    enqueue_scout_job(run)
  end

  defp enqueue_scout_job(run) do
    job = Oban.insert!(oban_name(), CatalogScout.new(%{"scout_id" => run.id}))
    Repo.update!(Ecto.Changeset.change(run, job_id: job.id))
    scout_status(:queued, nil, run.configured_scope_count)
  end

  defp oban_name do
    :football_market
    |> Application.get_env(Synchronization, [])
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

  defp cache_deadline("not_found", now), do: DateTime.add(now, @negative_ttl_seconds, :second)
  defp cache_deadline("provider_failure", _now), do: next_nightly_close()
  defp cache_deadline(_, _), do: nil

  defp next_nightly_close do
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

  defp acquire_global_lock do
    <<key::signed-64, _::binary>> = :crypto.hash(:sha256, "catalog-scout-global-admission")
    Repo.query!("SELECT pg_advisory_xact_lock($1)", [key])
  end

  defp scout_status(state, retry_at, scope_count),
    do: %{state: state, next_attempt_at: retry_at, configured_scope_count: scope_count}

  defp validate_scopes(scopes) when is_list(scopes) and length(scopes) <= 5 do
    values = Enum.map(scopes, &validate_scope/1)

    if Enum.any?(values, &is_nil/1) or duplicate_leagues?(values),
      do: [],
      else: Enum.sort_by(values, fn scope -> scope["league_code"] end)
  end

  defp validate_scopes(_), do: []

  defp validate_scope(scope) when is_map(scope) do
    allowed_league? =
      Enum.any?(Providers.Request.leagues(), fn {code, _name} -> scope.league_code == code end)

    if Enum.sort(Map.keys(scope)) == Enum.sort(@scope_fields) and allowed_league? do
      request = Map.take(scope, [:league_code, :start_year, :end_year])

      with {:ok, _} <- Providers.Request.normalize(:catalog, request),
           true <- is_binary(scope.source_ref),
           {:ok, _} <- Synchronization.Input.normalize(request, source_ref: scope.source_ref) do
        %{
          "league_code" => scope.league_code,
          "start_year" => scope.start_year,
          "end_year" => scope.end_year,
          "source_ref" => scope.source_ref
        }
      else
        _ -> nil
      end
    end
  end

  defp validate_scope(_), do: nil

  defp duplicate_leagues?(scopes) do
    leagues = Enum.map(scopes, fn scope -> scope["league_code"] end)
    length(leagues) != length(Enum.uniq(leagues))
  end

  defp valid_name?(value) do
    length = String.length(value)
    letters = Regex.scan(~r/\p{L}/u, value) |> length()

    length in 2..@max_name_length and letters >= 2 and
      Regex.match?(~r/\A[\p{L}\p{M}][\p{L}\p{M}0-9 .’'-]*\z/u, value)
  end
end

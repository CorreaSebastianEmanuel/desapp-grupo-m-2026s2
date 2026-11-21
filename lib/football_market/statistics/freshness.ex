defmodule FootballMarket.Statistics.Freshness do
  @moduledoc """
  Scoped statistics freshness, deduplicated background refresh admission, and
  player valuation status summary.

  Owns:
    * `preload/0` — periodic initial refresh checks for tracked catalog players
    * `for_player/1` — computes freshness state, triggers async refresh when stale,
      and attaches latest quote / valuation status
    * `refresh_now/1` — forces an on-demand deduplicated refresh run
  """

  import Ecto.Query

  alias FootballMarket.Catalog
  alias FootballMarket.Market.Quote
  alias FootballMarket.Quotes.CalculationRequest
  alias FootballMarket.Repo
  alias FootballMarket.Statistics.Ingestion.ScopeCheck
  alias FootballMarket.Synchronization.{Clock, Input, Run, Store}

  @active_run_states ~w(queued executing retry_wait)
  @safe_failure_reasons ~w(
    exhausted exhausted_unconfirmed non_retryable input_drift missing_configuration
    rate_limited unavailable timeout unsupported_capability invalid_response access_refused
    immutable_conflict persistence_failure interrupted
  )
  @running_quote_states ~w(running retrying)
  @failed_quote_states ~w(validation_failed unsupported_strategy unreproducible exhausted)

  # --- Public API ---

  def preload do
    now = Clock.now()

    Catalog.list_players_for_statistics()
    |> Enum.each(fn player ->
      case load_settings(player) do
        {:ok, settings} ->
          initial_input = %{settings.input | trigger: :initial}
          _ = submit_refresh(player, %{settings | input: initial_input}, now, false)

        _ ->
          :ok
      end
    end)

    :ok
  end

  def for_player(player) do
    base = base_status(player)

    case load_settings(player) do
      {:ok, settings} ->
        configured_status(player, settings, base)

      {:error, {:unconfigured, ttl}} ->
        %{base | ttl_seconds: ttl}

      {:error, :invalid_configuration} ->
        %{
          base
          | freshness: "unavailable",
            refresh: refresh_status("unavailable", nil, "invalid_configuration")
        }
    end
  rescue
    _ ->
      %{
        base_status(player)
        | freshness: "unavailable",
          refresh: refresh_status("unavailable", nil, "temporarily_unavailable")
      }
  end

  def refresh_now(player) do
    case load_settings(player) do
      {:ok, settings} ->
        submit_refresh(player, settings, Clock.now(), true)

      {:error, {:unconfigured, ttl}} ->
        refresh_status("unconfigured", nil, "missing_source_or_player_binding", nil)
        |> Map.put(:ttl_seconds, ttl)

      {:error, :invalid_configuration} ->
        refresh_status("unavailable", nil, "invalid_configuration")
    end
  rescue
    _ -> refresh_status("unavailable", nil, "temporarily_unavailable")
  end

  # --- Settings Resolution ---

  defp load_settings(player) do
    config = Application.get_env(:football_market, __MODULE__, [])
    ttl = Keyword.get(config, :ttl_seconds, 86_400)
    cooldown = Keyword.get(config, :cooldown_seconds, 3_600)
    timeout_ms = Keyword.get(config, :request_timeout_ms, 20_000)
    sources = Keyword.get(config, :refresh_options_by_scope, %{})
    season = player.team.season

    scope = %{
      league_code: season.league.code,
      start_year: season.start_year,
      end_year: season.end_year
    }

    scope_key = {scope.league_code, scope.start_year, scope.end_year}

    with true <- is_integer(ttl) and ttl > 0 and is_integer(cooldown) and cooldown > 0,
         true <- is_integer(timeout_ms) and timeout_ms in 1..28_999,
         true <- is_map(sources) do
      case Map.fetch(sources, scope_key) do
        :error ->
          {:error, {:unconfigured, ttl}}

        {:ok, options} ->
          resolve_provider_input(player, scope, options, ttl, cooldown, timeout_ms)
      end
    else
      _ -> {:error, :invalid_configuration}
    end
  rescue
    _ -> {:error, :invalid_configuration}
  end

  defp resolve_provider_input(player, scope, options, ttl, cooldown, timeout_ms) do
    case Input.normalize(:statistics, scope, options) do
      {:ok, input} ->
        {provider, _state} = input.source.provider
        label = provider.provider_label()

        case provider do
          FootballMarket.Providers.Scraping ->
            build_scraping_input(player, scope, options, timeout_ms, label, ttl, cooldown)

          _ ->
            {:ok, %{input: input, provider: label, ttl: ttl, cooldown: cooldown}}
        end

      _ ->
        {:error, :invalid_configuration}
    end
  end

  defp build_scraping_input(player, scope, options, timeout_ms, label, ttl, cooldown) do
    source_id = Catalog.provider_player_id(player.id, label)

    targeted_options =
      Keyword.merge(options,
        player_id: player.id,
        player_source_id: source_id,
        player_name: player.display_name,
        player_team_name: player.team.name,
        player_position_code: player.position && player.position.code
      )

    scoped_with_timeout = Map.put(scope, :timeout_ms, timeout_ms)

    case Input.normalize(:statistics, scoped_with_timeout, targeted_options) do
      {:ok, input} -> {:ok, %{input: input, provider: label, ttl: ttl, cooldown: cooldown}}
      _ -> {:error, :invalid_configuration}
    end
  end

  # --- Refresh Admission & Deduplication ---

  defp submit_refresh(player, settings, now, force) do
    result =
      Repo.transaction(fn ->
        Repo.query!("SET LOCAL lock_timeout = '100ms'")
        if not Store.try_lock_scope(settings.input.scope), do: Repo.rollback(:busy)
        decide_refresh(player, settings, now, force)
      end)

    case result do
      {:ok, refresh} -> refresh
      {:error, :busy} -> refresh_status("busy", nil, "scope_busy")
      {:error, _} -> refresh_status("unavailable", nil, "temporarily_unavailable")
    end
  rescue
    _ -> refresh_status("unavailable", nil, "temporarily_unavailable")
  end

  defp decide_refresh(player, settings, now, force) do
    query = matching_runs_query(settings.input)
    active = Repo.one(from run in query, where: run.state in @active_run_states)

    cond do
      active && active.input == settings.input.material ->
        reuse_active_run(active, settings.input)

      active ->
        refresh_status("busy", nil, "scope_busy")

      not force and
          fresh_check?(
            ScopeCheck.find(
              settings.provider,
              player.season_id,
              settings.input.material["player_id"]
            ),
            settings.ttl,
            now
          ) ->
        refresh_status("idle")

      true ->
        latest =
          Repo.one(
            from run in query,
              where:
                run.source_ref == ^settings.input.material["source_ref"] and
                  run.input_digest == ^settings.input.digest and
                  run.input == ^settings.input.material,
              order_by: [desc: run.requested_at, desc_nulls_last: run.finished_at, desc: run.id],
              limit: 1
          )

        retry_or_admit(latest, settings, now)
    end
  end

  defp reuse_active_run(active, input) do
    if input.trigger != :initial, do: Store.prioritize_statistics(active)
    refresh_status(active.state, active, safe_reason(active), active.next_retry_at)
  end

  defp retry_or_admit(%{state: "failed", reason: "missing_configuration"} = run, settings, now) do
    case Input.execution(run.input) do
      {:ok, _options} -> admit_run(settings.input, now)
      _ -> refresh_status("blocked", run, safe_reason(run))
    end
  end

  defp retry_or_admit(%{state: "failed"} = run, settings, now) do
    if run.input == settings.input.material do
      apply_failure_cooldown(run, settings, now)
    else
      admit_run(settings.input, now)
    end
  end

  defp retry_or_admit(_, settings, now), do: admit_run(settings.input, now)

  defp apply_failure_cooldown(run, settings, now) do
    if transient_failure?(run) and run.finished_at do
      hint = run.outcome["retry_after_ms"]

      wait_seconds =
        if is_integer(hint) and hint > 0,
          do: max(settings.cooldown, div(hint + 999, 1000)),
          else: settings.cooldown

      eligible_at = DateTime.add(run.finished_at, wait_seconds, :second)

      if DateTime.compare(now, eligible_at) == :lt,
        do: refresh_status("cooldown", run, safe_reason(run), eligible_at),
        else: admit_run(settings.input, now)
    else
      refresh_status("blocked", run, safe_reason(run))
    end
  end

  defp transient_failure?(%{reason: "exhausted", outcome: outcome}) when is_map(outcome) do
    outcome["status"] in ~w(persistence_failure concurrent_change interrupted) or
      (outcome["status"] == "provider_failure" and outcome["retryable"] == true and
         outcome["category"] in ~w(rate_limited unavailable timeout))
  end

  defp transient_failure?(_), do: false

  defp admit_run(input, now) do
    case Store.admit_locked(input, now, nil) do
      %{run_id: id, status: state} -> %{refresh_status(Atom.to_string(state)) | run_id: id}
      {:error, _} -> Repo.rollback(:admission_failed)
    end
  end

  defp matching_runs_query(input) do
    scope = input.scope
    player_id = input.material["player_id"] || ""

    from run in Run,
      where:
        run.operation == "statistics" and
          run.league_code == ^scope.league_code and
          run.start_year == ^scope.start_year and
          run.end_year == ^scope.end_year and
          fragment("coalesce(?->>'player_id', '') = ?", run.input, ^player_id)
  end

  defp safe_reason(run) do
    reason = (run.outcome || %{})["category"] || run.reason
    if reason in @safe_failure_reasons, do: reason, else: nil
  end

  defp fresh_check?(nil, _, _), do: false
  defp fresh_check?(%{last_checked_at: nil}, _, _), do: false

  defp fresh_check?(row, ttl, now),
    do: DateTime.compare(now, DateTime.add(row.last_checked_at, ttl, :second)) == :lt

  defp refresh_status(state, run \\ nil, reason \\ nil, next_attempt_at \\ nil) do
    %{state: state, run_id: run && run.id, reason: reason, next_attempt_at: next_attempt_at}
  end

  # --- Player Status & Valuation Summary ---

  defp configured_status(player, settings, base) do
    now = Clock.now()
    refresh = submit_refresh(player, settings, now, false)
    targeted_player_id = settings.input.material["player_id"]
    check_row = ScopeCheck.find(settings.provider, player.season_id, targeted_player_id)
    last_checked_at = check_row && check_row.last_checked_at
    {_provider, provider_state} = settings.input.source.provider

    source_mode =
      if is_map(provider_state) and provider_state[:mode] == :live, do: "live", else: "fixture"

    freshness =
      cond do
        is_nil(last_checked_at) -> "never_checked"
        fresh_check?(check_row, settings.ttl, now) -> "fresh"
        true -> "stale"
      end

    coverage = if targeted_player_id, do: "player_season", else: "league_season"

    %{
      base
      | scope:
          base.scope |> Map.put(:provider, settings.provider) |> Map.put(:coverage, coverage),
        source_mode: source_mode,
        last_checked_at: last_checked_at,
        expires_at: last_checked_at && DateTime.add(last_checked_at, settings.ttl, :second),
        ttl_seconds: settings.ttl,
        freshness: freshness,
        refresh: refresh
    }
  end

  defp base_status(player) do
    season = player.team.season

    %{
      scope: %{
        player_id: player.id,
        season_id: player.season_id,
        league_code: season.league.code,
        start_year: season.start_year,
        end_year: season.end_year,
        provider: nil,
        coverage: "league_season"
      },
      source_mode: "unconfigured",
      last_checked_at: nil,
      expires_at: nil,
      ttl_seconds: 86_400,
      freshness: "never_checked",
      refresh: refresh_status("unconfigured"),
      valuation: valuation_status_for_player(player)
    }
  end

  defp valuation_status_for_player(player) do
    latest_quote =
      Repo.one(
        from q in Quote,
          where: q.player_id == ^player.id,
          order_by: [desc: q.effective_at],
          select: %{unit_price: q.unit_price, effective_at: q.effective_at},
          limit: 1
      )

    last_quoted_at = latest_quote && latest_quote.effective_at

    current_quote =
      latest_quote &&
        latest_quote.unit_price |> Decimal.round(2) |> Decimal.to_string(:normal)

    result =
      Repo.query!(
        """
        SELECT i.id, i.state, i.attempts
        FROM statistics_calculation_intents i
        WHERE EXISTS (
          SELECT 1 FROM quote_import_scope_snapshots s
          WHERE s.intent_id = i.id AND s.player_id = $1 AND s.season_id = $2
        ) OR EXISTS (
          SELECT 1 FROM player_match_performances p
          WHERE p.id = ANY(i.changed_performance_ids) AND p.player_id = $1 AND p.season_id = $2
        )
        ORDER BY i.requested_at DESC, i.id DESC LIMIT 1
        """,
        [Ecto.UUID.dump!(player.id), Ecto.UUID.dump!(player.season_id)]
      )

    case result.rows do
      [] ->
        empty_valuation_status("not_requested", last_quoted_at, current_quote)

      [[id, state, attempts]] ->
        summarize_valuation(
          Ecto.UUID.load!(id),
          state,
          attempts,
          player.id,
          last_quoted_at,
          current_quote
        )
    end
  rescue
    _ -> empty_valuation_status("unavailable", nil, nil)
  end

  defp summarize_valuation(
         intent_id,
         dispatch,
         attempts,
         player_id,
         last_quoted_at,
         current_quote
       ) do
    counts =
      Repo.all(
        from req in CalculationRequest,
          where: req.intent_id == ^intent_id and req.player_id == ^player_id,
          group_by: req.state,
          select: {req.state, count(req.id)}
      )
      |> Map.new()

    %{
      state: derive_valuation_state(counts, dispatch, attempts),
      calculation_intent_id: intent_id,
      request_states: counts,
      last_quoted_at: last_quoted_at,
      current_quote: current_quote
    }
  end

  defp derive_valuation_state(_, "failed", _), do: "failed"
  defp derive_valuation_state(_, "pending", attempts) when attempts >= 3, do: "failed"
  defp derive_valuation_state(_, "pending", _), do: "pending"

  defp derive_valuation_state(counts, _, _) do
    cond do
      Enum.any?(@running_quote_states, fn key -> Map.has_key?(counts, key) end) -> "running"
      Map.has_key?(counts, "pending") -> "pending"
      Enum.any?(@failed_quote_states, fn key -> Map.has_key?(counts, key) end) -> "failed"
      map_size(counts) == 0 -> "pending"
      Enum.all?(Map.keys(counts), fn key -> key in ~w(successful no_quote) end) -> "completed"
      true -> "unavailable"
    end
  end

  defp empty_valuation_status(state, last_quoted_at, current_quote) do
    %{
      state: state,
      calculation_intent_id: nil,
      request_states: %{},
      last_quoted_at: last_quoted_at,
      current_quote: current_quote
    }
  end
end

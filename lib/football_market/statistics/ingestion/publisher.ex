defmodule FootballMarket.Statistics.Ingestion.Publisher do
  @moduledoc "Atomic acceptance of immutable facts, provenance, checks and calculation intent."
  import Ecto.Query
  alias FootballMarket.{Market, Repo}
  alias FootballMarket.Synchronization.DeliveryReceipt

  alias FootballMarket.Statistics.Ingestion.{
    Check,
    ScopeCheck,
    CalculationIntent,
    Canonical,
    Outcome,
    Records,
    Observations
  }

  def publish(result, options) do
    context = Keyword.get(options, :delivery_context)
    provider = result.provenance.provider

    Repo.transaction(fn ->
      publish_locked(result, context, provider, options)
    end)
    |> case do
      {:ok, outcome} -> {:ok, outcome}
      {:error, reason} -> Outcome.failure(status(reason), result.scope, reason)
    end
  rescue
    error in Postgrex.Error ->
      if error.postgres && error.postgres.code == :unique_violation,
        do: Outcome.failure(:immutable_conflict, result.scope, :immutable_fact_conflict),
        else: Outcome.failure(:persistence_failure, result.scope, :publication_failed)

    _ ->
      Outcome.failure(:persistence_failure, result.scope, :publication_failed)
  end

  defp accept_new!(scope_row, result, receipt, attempt_id, encoded, options, season) do
    provider = result.provenance.provider
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    scope_row =
      scope_row ||
        Repo.insert!(%ScopeCheck{
          id: Ecto.UUID.generate(),
          provider: provider,
          identity_namespace: provider,
          league_code: result.scope.league_code,
          start_year: result.scope.start_year,
          end_year: result.scope.end_year,
          season_id: season.id,
          player_id: Keyword.get(options, :player_id)
        })

    initialize_player_inventory!(options)

    {matches, match_count} = Records.persist_matches!(result, season, options)
    prior = Records.history_for_season(season.id)

    {performances, new_performance_count} =
      Records.persist_performances!(result, matches, season, prior, options)

    evidence = Canonical.normalize(result.completeness)

    outcome = accepted_outcome(match_count, new_performance_count, result)

    check =
      Repo.insert!(%Check{
        scope_id: scope_row.id,
        run_id: receipt.run_id,
        attempt_id: attempt_id,
        accepted_at: now,
        retrieved_at: result.provenance.retrieved_at,
        evidence_version: result.completeness.version,
        evidence: evidence,
        outcome: outcome,
        canonical_digest: encoded.digest,
        canonical_material: encoded.material,
        changed_matches: match_count,
        changed_performances: new_performance_count
      })

    artifact = Observations.fixture_artifact!(result)

    for {fact, id, kind, state} <- matches do
      Observations.observe_fact!(
        result,
        {fact, id, kind, state},
        check,
        receipt,
        artifact,
        encoded
      )
    end

    for {fact, id, kind, state} <- performances do
      Observations.observe_fact!(
        result,
        {fact, id, kind, state},
        check,
        receipt,
        artifact,
        encoded
      )
    end

    intent =
      if new_performance_count > 0 do
        Repo.insert!(%CalculationIntent{
          accepted_check_id: check.id,
          changed_performance_ids:
            performances
            |> Enum.filter(&(elem(&1, 3) != :existing))
            |> Enum.map(&elem(&1, 1))
            |> Enum.sort(),
          requested_at: now
        })
      end

    if intent do
      changed_ids =
        performances |> Enum.filter(&(elem(&1, 3) != :existing)) |> Enum.map(&elem(&1, 1))

      FootballMarket.Quotes.Membership.snapshot_import!(intent.id, changed_ids)
    end

    scope_row
    |> Ecto.Changeset.change(last_checked_at: now, last_accepted_check_id: check.id)
    |> then(fn cs ->
      if scope_row.__meta__.state == :built, do: Repo.insert!(cs), else: Repo.update!(cs)
    end)

    result_outcome = %Outcome{
      status: outcome_status(outcome),
      scope: result.scope,
      run_id: receipt.run_id,
      check_id: check.id,
      calculation_intent_id: intent && intent.id
    }

    safe_outcome =
      result_outcome
      |> Map.from_struct()
      |> Canonical.normalize()
      |> Jason.encode!()
      |> Jason.decode!()

    receipt
    |> Ecto.Changeset.change(state: "confirmed", outcome: safe_outcome, confirmed_at: now)
    |> Repo.update!()

    result_outcome
  end

  defp accepted_replay!(check, scope_row, result, receipt, attempt_id, encoded, options) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    initialize_player_inventory!(options)

    replay =
      Repo.insert!(%Check{
        scope_id: scope_row.id,
        run_id: receipt.run_id,
        attempt_id: attempt_id,
        accepted_at: now,
        retrieved_at: result.provenance.retrieved_at,
        evidence_version: result.completeness.version,
        evidence: Canonical.normalize(result.completeness),
        outcome: "replay",
        canonical_digest: encoded.digest,
        canonical_material: encoded.material,
        changed_matches: 0,
        changed_performances: 0,
        replay_of_id: check.id
      })

    Observations.append_replay_observations!(result, replay)

    Repo.update!(
      Ecto.Changeset.change(scope_row, last_checked_at: now, last_accepted_check_id: replay.id)
    )

    Repo.update!(
      Ecto.Changeset.change(receipt,
        state: "confirmed",
        outcome: %{"status" => "replay", "check_id" => replay.id},
        confirmed_at: now
      )
    )

    %Outcome{status: :replay, scope: result.scope, run_id: receipt.run_id, check_id: replay.id}
  end

  defp initialize_player_inventory!(options) do
    case Keyword.get(options, :player_id) do
      nil ->
        :ok

      player_id ->
        case Market.initialize_primary_player_in_transaction(player_id) do
          %{outcome: _status} -> :ok
          {:ok, _status} -> :ok
          {:error, reason} -> Repo.rollback({:initial_player_issuance_failed, reason})
        end
    end
  end

  defp get_scope!(result, provider, season_id, player_id) do
    case ScopeCheck.find(provider, season_id, player_id) do
      nil ->
        nil

      scope_row ->
        expected = {result.scope.league_code, result.scope.start_year, result.scope.end_year}
        actual = {scope_row.league_code, scope_row.start_year, scope_row.end_year}
        if expected == actual, do: scope_row, else: Repo.rollback(:immutable_conflict)
    end
  end

  defp lock_season!(season_id) do
    <<key::signed-64, _::binary>> = :crypto.hash(:sha256, "statistics-season-v1:" <> season_id)
    Repo.query!("SELECT pg_advisory_xact_lock($1)", [key])
  end

  defp outcome_status("accepted_changes"), do: :accepted_changes
  defp outcome_status("accepted_unchanged"), do: :accepted_unchanged
  defp outcome_status("accepted_empty"), do: :accepted_empty

  defp status(:immutable_conflict), do: :immutable_conflict
  defp status(:invalid_position), do: :invalid_incomplete

  defp status(reason)
       when reason in [
              :unbound_identity,
              :unapproved_fixture,
              :missing_delivery_context,
              :missing_attempt
            ],
       do: :invalid_incomplete

  defp status(_), do: :persistence_failure

  defp classify_result!(scope_row, encoded, result, receipt, attempt_id, options, season) do
    replay =
      if scope_row,
        do:
          Repo.one(
            from c in Check,
              where: c.scope_id == ^scope_row.id and c.canonical_digest == ^encoded.digest,
              order_by: [desc: c.accepted_at, desc: c.id],
              limit: 1,
              lock: "FOR UPDATE"
          )

    if replay && replay.canonical_material != encoded.material,
      do: Repo.rollback(:immutable_conflict)

    if replay && replay.retrieved_at == result.provenance.retrieved_at do
      accepted_replay!(replay, scope_row, result, receipt, attempt_id, encoded, options)
    else
      accept_new!(scope_row, result, receipt, attempt_id, encoded, options, season)
    end
  end

  defp publish_locked(result, context, provider, options) do
    receipt =
      DeliveryReceipt.lock!(
        Map.take(context || %{}, [:receipt_id, :fence]),
        result.scope,
        "statistics"
      )

    unless receipt, do: Repo.rollback(:missing_delivery_context)
    attempt_id = Map.get(context, :attempt_id)
    unless match?({:ok, _}, Ecto.UUID.cast(attempt_id)), do: Repo.rollback(:missing_attempt)
    run = Repo.get!(FootballMarket.Synchronization.Run, receipt.run_id)
    encoded = Canonical.encode(result, run.input["source_identity"])

    season = Records.resolve_season!(result, options)

    # Replay cannot bypass a changed trusted target mapping. Resolve every
    # retained catalog identity before classifying the source material.
    Enum.each(
      result.facts.teams,
      &Records.resolve_catalog_binding!(result, "team", &1.ref, options)
    )

    Enum.each(
      result.facts.players,
      &Records.resolve_catalog_binding!(result, "player", &1.ref, options)
    )

    Enum.each(result.facts.matches, &Records.validate_match_mapping!(result, &1, season, options))

    lock_season!(season.id)
    scope_row = get_scope!(result, provider, season.id, Keyword.get(options, :player_id))

    classify_result!(scope_row, encoded, result, receipt, attempt_id, options, season)
  end

  defp accepted_outcome(match_count, new_performance_count, result) do
    cond do
      match_count + new_performance_count > 0 -> "accepted_changes"
      result.facts.matches == [] and result.facts.performances == [] -> "accepted_empty"
      true -> "accepted_unchanged"
    end
  end
end

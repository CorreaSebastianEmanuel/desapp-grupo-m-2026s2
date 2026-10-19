defmodule FootballMarket.Statistics.Ingestion.Publisher do
  @moduledoc "Atomic acceptance of immutable facts, provenance, checks and calculation intent."
  import Ecto.Query
  alias FootballMarket.{Repo, Catalog}
  alias FootballMarket.Catalog.Ingestion.{Scope, SourceBinding}
  alias FootballMarket.Synchronization.DeliveryReceipt
  alias FootballMarket.Statistics.{Match, Performance}

  alias FootballMarket.Statistics.Ingestion.{
    Check,
    ScopeCheck,
    MatchBinding,
    FactProvenance,
    FactObservation,
    FixtureArtifact,
    CalculationIntent,
    Canonical,
    Positions,
    Outcome,
    Identity,
    Provenance
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
          season_id: season.id
        })

    {matches, match_count} = persist_matches!(result, season, options)
    prior = history_for_season(season.id)

    {performances, new_performance_count} =
      persist_performances!(result, matches, season, prior, options)

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

    artifact = fixture_artifact!(result)

    for {fact, id, kind, state} <- matches do
      observe_fact!(result, {fact, id, kind, state}, check, receipt, artifact, encoded)
    end

    for {fact, id, kind, state} <- performances do
      observe_fact!(result, {fact, id, kind, state}, check, receipt, artifact, encoded)
    end

    intent =
      if new_performance_count > 0 do
        Repo.insert!(%CalculationIntent{
          accepted_check_id: check.id,
          changed_performance_ids:
            performances
            |> Enum.filter(&(elem(&1, 3) == :new))
            |> Enum.map(&elem(&1, 1))
            |> Enum.sort(),
          requested_at: now
        })
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

  defp accepted_replay!(check, scope_row, result, receipt, attempt_id, encoded) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

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

    append_replay_observations!(result, replay)

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

  defp append_replay_observations!(result, check) do
    facts =
      Enum.map(result.facts.matches, &{:match, &1}) ++
        Enum.map(result.facts.performances, &{:performance, &1})

    Enum.each(facts, fn {kind, fact} ->
      identity = Provenance.identity(result, kind, fact)

      provenance =
        Repo.get_by!(FactProvenance,
          provider: result.provenance.provider,
          source_identity: identity
        )

      Repo.insert!(%FactObservation{
        id: Ecto.UUID.generate(),
        provenance_id: provenance.id,
        check_id: check.id
      })
    end)
  end

  defp persist_matches!(result, season, options) do
    Enum.map_reduce(result.facts.matches, 0, fn fact, count ->
      persist_match!(fact, count, result, season, options)
    end)
  end

  defp persist_performances!(result, matches, season, history, options) do
    match_ids = Map.new(matches, fn {fact, id, _, _} -> {fact.ref, id} end)

    Enum.map_reduce(result.facts.performances, 0, fn fact, count ->
      persist_performance!(fact, count, result, match_ids, season, history, options)
    end)
  end

  defp history_for_season(season_id) do
    Repo.all(
      from p in Performance,
        join: m in Match,
        on: m.id == p.match_id,
        where: p.season_id == ^season_id and not is_nil(p.position_id),
        select: %{
          id: p.id,
          player_id: p.player_id,
          season_id: p.season_id,
          match_id: p.match_id,
          position_id: p.position_id,
          kickoff_at: m.kickoff_at
        }
    )
  end

  defp get_scope!(result, provider, season_id) do
    case ScopeCheck.find(provider, season_id) do
      nil ->
        nil

      scope_row ->
        expected = {result.scope.league_code, result.scope.start_year, result.scope.end_year}
        actual = {scope_row.league_code, scope_row.start_year, scope_row.end_year}
        if expected == actual, do: scope_row, else: Repo.rollback(:immutable_conflict)
    end
  end

  defp resolve_catalog_binding!(result, kind, ref, options) do
    source_id = source_id!(result, String.to_existing_atom(kind), ref)

    scope =
      Repo.get_by(Scope,
        league_code: result.scope.league_code,
        start_year: result.scope.start_year,
        end_year: result.scope.end_year
      )

    existing =
      if scope,
        do:
          Repo.get_by(SourceBinding,
            scope_id: scope.id,
            provider: result.provenance.provider,
            kind: kind,
            source_id: source_id
          )

    mapped =
      Enum.find(
        Keyword.get(options, :mappings, []),
        &(&1.kind == String.to_existing_atom(kind) and &1.source_id == source_id)
      )

    id = binding_target_id!(existing, mapped, kind)

    retain_mapping!(id, existing, mapped, scope, result, kind, source_id)

    case id &&
           Repo.get(
             String.to_existing_atom("Elixir.FootballMarket.Catalog." <> String.capitalize(kind)),
             id
           ) do
      nil -> Repo.rollback(:unbound_identity)
      row -> row
    end
  end

  defp source_id!(result, kind, ref) do
    Identity.fetch!(result, kind, ref)
  rescue
    _ -> Repo.rollback(:unbound_identity)
  end

  defp validate_match_mapping!(result, fact, season, options) do
    source_id = source_id!(result, :match, fact.ref)

    binding =
      Repo.get_by(MatchBinding,
        provider: result.provenance.provider,
        league_code: result.scope.league_code,
        start_year: result.scope.start_year,
        end_year: result.scope.end_year,
        source_id: source_id
      )

    mapping =
      Enum.find(
        Keyword.get(options, :mappings, []),
        &(&1.kind == :match and &1.source_id == source_id)
      )

    if binding && mapping && binding.match_id != mapping.target_id,
      do: Repo.rollback(:immutable_conflict)

    target_id = (binding && binding.match_id) || (mapping && mapping.target_id)

    validate_match_target!(target_id, result, fact, season, options)

    :ok
  end

  defp position_id_for_ref!(_result, id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> uuid
      _ -> Repo.rollback(:invalid_position)
    end
  end

  defp fixture_artifact!(%{provenance: %{fixture_id: nil}}), do: nil

  defp fixture_artifact!(result) do
    ref = result.provenance.fixture_id
    path = Path.expand("test/fixtures/statistics_ingestion/documents.exs")
    {inventory, _} = Code.eval_file("test/fixtures/statistics_ingestion/inventory.exs")
    metadata = Map.get(inventory, ref) || Repo.rollback(:unapproved_fixture)
    {:ok, bytes} = File.read(path)
    sha = :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)

    if Map.get(metadata, :non_live) != true or Map.get(metadata, :digest) != sha,
      do: Repo.rollback(:unapproved_fixture)

    row = Repo.get_by(FixtureArtifact, fixture_id: ref, sha256: sha)

    row ||
      Repo.insert!(%FixtureArtifact{
        id: Ecto.UUID.generate(),
        fixture_id: ref,
        artifact_path: "test/fixtures/statistics_ingestion/documents.exs",
        sha256: sha,
        origin: metadata.origin,
        synthetic_created_at: metadata.created_at,
        expected_case: ref,
        rule_ids: metadata.rules,
        non_live: true
      })
  end

  defp observe_fact!(result, {fact, id, kind, _state}, check, receipt, artifact, encoded) do
    provenance =
      Repo.get_by(
        FactProvenance,
        if(kind == :match, do: [match_id: id], else: [performance_id: id])
      ) ||
        insert_provenance!(result, fact, id, kind, check, receipt, artifact, encoded)

    Repo.insert!(%FactObservation{
      id: Ecto.UUID.generate(),
      provenance_id: provenance.id,
      check_id: check.id
    })
  end

  defp insert_provenance!(result, fact, id, kind, check, receipt, artifact, encoded) do
    identity = Provenance.identity(result, kind, fact)

    attrs = %{
      id: Ecto.UUID.generate(),
      match_id: if(kind == :match, do: id),
      performance_id: if(kind == :performance, do: id),
      accepted_check_id: check.id,
      run_id: receipt.run_id,
      provider: result.provenance.provider,
      retrieved_at: result.provenance.retrieved_at,
      source_identity: identity,
      source_material: encoded.material,
      fixture_artifact_id: artifact && artifact.id
    }

    Repo.insert!(
      %FactProvenance{}
      |> Ecto.Changeset.cast(attrs, Map.keys(attrs))
      |> Ecto.Changeset.validate_required([
        :accepted_check_id,
        :run_id,
        :provider,
        :retrieved_at,
        :source_identity,
        :source_material
      ])
    )
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

  defp retain_existing_performance!(fact, count, existing, team) do
    same_position = same_retained_position?(fact, existing)

    same_counts =
      Enum.all?(
        FootballMarket.Statistics.Input.metrics(),
        &(Map.get(existing, &1) == Map.get(fact.counts, &1))
      )

    same_participation =
      existing.participation ==
        (fact.participation && Atom.to_string(fact.participation))

    unless same_position and same_counts and same_participation and
             existing.team_id == team.id and
             existing.minutes_played == fact.minutes_played,
           do: Repo.rollback(:immutable_conflict)

    {{fact, existing.id, :performance, :existing}, count}
  end

  defp same_retained_position?(fact, existing) do
    expected_position =
      if fact.position_ref, do: Repo.get_by(Catalog.Position, code: fact.position_ref)

    if fact.position_ref,
      do:
        expected_position && existing.position_id == expected_position.id &&
          existing.position_basis == "direct_source",
      else:
        existing.participation == "substitute_entered" and
          existing.position_basis in ["derived_history", "unknown_history"]
  end

  defp position_evidence!(fact, position, player, season, match, prior, result) do
    if fact.position_ref do
      %{
        position_id: position && position.id,
        basis: "direct_source",
        participation: fact.participation && Atom.to_string(fact.participation),
        reason: nil,
        policy_version: 1,
        frequencies: %{},
        basis_rows: []
      }
    else
      if fact.participation != :substitute_entered,
        do: Repo.rollback(:invalid_position)

      {:ok, derived} =
        Positions.derive(
          %{player_id: player.id, season_id: season.id, kickoff_at: match.kickoff_at},
          prior
        )

      %{
        position_id:
          if(derived.position_id,
            do: position_id_for_ref!(result, derived.position_id),
            else: nil
          ),
        basis: if(derived.position_id, do: "derived_history", else: "unknown_history"),
        participation: "substitute_entered",
        reason: derived.reason && Atom.to_string(derived.reason),
        policy_version: 1,
        frequencies:
          Map.new(derived.frequencies, fn {position, frequency} -> {position, frequency} end),
        basis_rows: derived.basis
      }
    end
  end

  defp insert_performance!(fact, count, {position, player, season, match, prior, result, team}) do
    evidence = position_evidence!(fact, position, player, season, match, prior, result)

    if fact.position_ref && is_nil(position), do: Repo.rollback(:invalid_position)

    attrs =
      %{
        match_id: match.id,
        player_id: player.id,
        team_id: team.id,
        position_id: evidence.position_id,
        minutes_played: fact.minutes_played
      }
      |> Map.merge(fact.counts)

    changeset =
      Performance.changeset(attrs, match)
      |> Ecto.Changeset.put_change(:position_basis, evidence.basis)
      |> Ecto.Changeset.put_change(:participation, evidence.participation)
      |> Ecto.Changeset.put_change(:position_reason, evidence.reason)
      |> Ecto.Changeset.put_change(:position_evidence, Map.drop(evidence, [:basis_rows]))

    performance = Repo.insert!(changeset)

    Enum.each(evidence.basis_rows, fn row ->
      Repo.insert_all("statistics_position_basis", [
        %{
          performance_id: Ecto.UUID.dump!(performance.id),
          prior_performance_id: Ecto.UUID.dump!(row.performance_id),
          position_id: Ecto.UUID.dump!(row.position_id),
          frequency: evidence.frequencies[row.position_id]
        }
      ])
    end)

    {{fact, performance.id, :performance, :new}, count + 1}
  end

  defp persist_performance!(fact, count, result, match_ids, season, history, options) do
    match_id = Map.fetch!(match_ids, fact.match_ref)
    player = resolve_catalog_binding!(result, "player", fact.player_ref, options)
    team = resolve_catalog_binding!(result, "team", fact.team_ref, options)
    position = if fact.position_ref, do: Repo.get_by(Catalog.Position, code: fact.position_ref)
    match = Repo.get!(Match, match_id)
    existing = Repo.get_by(Performance, player_id: player.id, match_id: match.id)

    prior =
      Enum.filter(
        history,
        &(&1.player_id == player.id and DateTime.compare(&1.kickoff_at, match.kickoff_at) == :lt)
      )

    if existing do
      retain_existing_performance!(fact, count, existing, team)
    else
      insert_performance!(fact, count, {position, player, season, match, prior, result, team})
    end
  end

  defp persist_unbound_match!(fact, count, result, season, options, source_id) do
    mapping =
      Enum.find(
        Keyword.get(options, :mappings, []),
        &(&1.kind == :match and &1.source_id == source_id)
      )

    if mapping do
      match = Repo.get(Match, mapping.target_id)
      unless match && match.season_id == season.id, do: Repo.rollback(:unbound_identity)
      home = resolve_catalog_binding!(result, "team", fact.home_team_ref, options)
      away = resolve_catalog_binding!(result, "team", fact.away_team_ref, options)

      unless match.kickoff_at == fact.kickoff_at and match.home_team_id == home.id and
               match.away_team_id == away.id,
             do: Repo.rollback(:immutable_conflict)

      Repo.insert!(%MatchBinding{
        id: Ecto.UUID.generate(),
        provider: result.provenance.provider,
        league_code: result.scope.league_code,
        start_year: result.scope.start_year,
        end_year: result.scope.end_year,
        source_id: source_id,
        match_id: match.id
      })

      {{fact, match.id, :match, :mapped}, count}
    else
      {home, away} =
        {resolve_catalog_binding!(result, "team", fact.home_team_ref, options),
         resolve_catalog_binding!(result, "team", fact.away_team_ref, options)}

      identity = "provider:v1:" <> result.provenance.provider <> ":" <> source_id

      attrs = %{
        match_identity: identity,
        kickoff_at: fact.kickoff_at,
        season_id: season.id,
        home_team_id: home.id,
        away_team_id: away.id
      }

      match = Repo.insert!(Match.changeset(attrs, season))

      Repo.insert!(%MatchBinding{
        id: Ecto.UUID.generate(),
        provider: result.provenance.provider,
        league_code: result.scope.league_code,
        start_year: result.scope.start_year,
        end_year: result.scope.end_year,
        source_id: source_id,
        match_id: match.id
      })

      {{fact, match.id, :match, :new}, count + 1}
    end
  end

  defp persist_match!(fact, count, result, season, options) do
    source_id = source_id!(result, :match, fact.ref)

    existing_binding =
      Repo.get_by(MatchBinding,
        provider: result.provenance.provider,
        league_code: result.scope.league_code,
        start_year: result.scope.start_year,
        end_year: result.scope.end_year,
        source_id: source_id
      )

    case existing_binding do
      %MatchBinding{match_id: id} ->
        match = Repo.get!(Match, id)

        if match.kickoff_at != fact.kickoff_at or
             match.home_team_id !=
               resolve_catalog_binding!(result, "team", fact.home_team_ref, options).id or
             match.away_team_id !=
               resolve_catalog_binding!(result, "team", fact.away_team_ref, options).id,
           do: Repo.rollback(:immutable_conflict)

        {{fact, match.id, :match, :existing}, count}

      nil ->
        persist_unbound_match!(fact, count, result, season, options, source_id)
    end
  end

  defp resolve_season!(result, options) do
    season = resolve_catalog_binding!(result, "season", result.facts.season.ref, options)
    league = Repo.get!(Catalog.League, season.league_id)

    unless season.start_year == result.scope.start_year and
             season.end_year == result.scope.end_year and
             league.code == result.scope.league_code,
           do: Repo.rollback(:unbound_identity)

    season
  end

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
      accepted_replay!(replay, scope_row, result, receipt, attempt_id, encoded)
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

    season = resolve_season!(result, options)

    # Replay cannot bypass a changed trusted target mapping. Resolve every
    # retained catalog identity before classifying the source material.
    Enum.each(result.facts.teams, &resolve_catalog_binding!(result, "team", &1.ref, options))

    Enum.each(
      result.facts.players,
      &resolve_catalog_binding!(result, "player", &1.ref, options)
    )

    Enum.each(result.facts.matches, &validate_match_mapping!(result, &1, season, options))

    lock_season!(season.id)
    scope_row = get_scope!(result, provider, season.id)

    classify_result!(scope_row, encoded, result, receipt, attempt_id, options, season)
  end

  defp accepted_outcome(match_count, new_performance_count, result) do
    cond do
      match_count + new_performance_count > 0 -> "accepted_changes"
      result.facts.matches == [] and result.facts.performances == [] -> "accepted_empty"
      true -> "accepted_unchanged"
    end
  end

  defp binding_target_id!(existing, mapped, kind) do
    target = existing && Map.get(existing, String.to_existing_atom(kind <> "_id"))
    if target && mapped && target != mapped.target_id, do: Repo.rollback(:immutable_conflict)
    target || (mapped && mapped.target_id)
  end

  defp retain_mapping!(id, existing, mapped, scope, result, kind, source_id) do
    if id && is_nil(existing) && mapped do
      unless scope, do: Repo.rollback(:unbound_identity)

      attrs = %{
        scope_id: scope.id,
        season_scope_id: scope.season_id,
        league_scope_id: scope.league_id,
        provider: result.provenance.provider,
        kind: kind,
        source_id: source_id
      }

      attrs = Map.put(attrs, String.to_existing_atom(kind <> "_id"), id)
      Repo.insert!(SourceBinding.changeset(%SourceBinding{}, attrs))
    end
  end

  defp validate_match_target!(target_id, result, fact, season, options) do
    if target_id do
      match = Repo.get(Match, target_id)
      unless match && match.season_id == season.id, do: Repo.rollback(:unbound_identity)

      home = resolve_catalog_binding!(result, "team", fact.home_team_ref, options)
      away = resolve_catalog_binding!(result, "team", fact.away_team_ref, options)

      unless match.kickoff_at == fact.kickoff_at and match.home_team_id == home.id and
               match.away_team_id == away.id,
             do: Repo.rollback(:immutable_conflict)
    end
  end
end

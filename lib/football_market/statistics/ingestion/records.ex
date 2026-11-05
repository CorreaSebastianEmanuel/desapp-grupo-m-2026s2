defmodule FootballMarket.Statistics.Ingestion.Records do
  @moduledoc "Immutable fact writing and trusted target binding inside the publisher transaction."
  import Ecto.Query
  alias FootballMarket.{Repo, Catalog}
  alias FootballMarket.Catalog.Ingestion.{Scope, SourceBinding}
  alias FootballMarket.Statistics.{Match, Performance}
  alias FootballMarket.Statistics.Ingestion.{MatchBinding, Identity, Positions, FotMobBinding}

  def persist_matches!(result, season, options) do
    Enum.map_reduce(result.facts.matches, 0, fn fact, count ->
      persist_match!(fact, count, result, season, options)
    end)
  end

  def persist_performances!(result, matches, season, history, options) do
    match_ids = Map.new(matches, fn {fact, id, _, _} -> {fact.ref, id} end)

    Enum.map_reduce(result.facts.performances, 0, fn fact, count ->
      persist_performance!(fact, count, result, match_ids, season, history, options)
    end)
  end

  def history_for_season(season_id) do
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

  def resolve_catalog_binding!(result, kind, ref, options) do
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

    existing =
      existing || FotMobBinding.maybe_bind(result, kind, ref, source_id, scope, options)

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

  def validate_match_mapping!(result, fact, season, options) do
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

  def resolve_season!(result, options) do
    season = resolve_catalog_binding!(result, "season", result.facts.season.ref, options)
    league = Repo.get!(Catalog.League, season.league_id)

    unless season.start_year == result.scope.start_year and
             season.end_year == result.scope.end_year and
             league.code == result.scope.league_code,
           do: Repo.rollback(:unbound_identity)

    season
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

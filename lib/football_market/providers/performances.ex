defmodule FootballMarket.Providers.Performances do
  @moduledoc "Proven eligibility, retained closure and event-time player facts."
  alias FootballMarket.Providers.{Catalog, Instant, Request, Match, Performance}

  @counts [
    :goals,
    :assists,
    :shots_on_target,
    :tackles,
    :interceptions,
    :saves,
    :goals_conceded,
    :yellow_cards,
    :red_cards
  ]
  @statuses [:completed, :scheduled, :live, :postponed, :abandoned]
  def count_keys, do: @counts

  def validate(facts, bindings, request, positions) do
    Catalog.shape!(
      facts,
      [:league, :season, :teams, :positions, :players, :matches, :performances],
      :scope
    )

    for key <- [:teams, :positions, :players, :matches, :performances],
        do: Catalog.require!(is_list(facts[key]), key)

    # Validate requested envelope independently from unused directories.
    envelope =
      Catalog.directory(%{facts | teams: [], positions: [], players: []}, request, positions)

    selected = Enum.filter(facts.matches, &eligible?(&1, request))
    selected_refs = Enum.map(selected, & &1.ref)
    # Retain duplicate declarations, including an excluded copy of an eligible ref.
    declarations = Enum.filter(facts.matches, &(Map.get(&1, :ref) in selected_refs))
    Catalog.unique!(declarations, & &1.ref, :matches)
    declared_refs = Enum.map(facts.matches, & &1.ref)

    retained_performances =
      Enum.filter(facts.performances, fn p ->
        Catalog.require!(
          is_map(p) and Map.has_key?(p, :match_ref) and p.match_ref in declared_refs,
          :performances
        )

        p.match_ref in selected_refs
      end)

    player_refs = Enum.map(retained_performances, & &1.player_ref)
    players = retain(facts.players, player_refs)

    team_refs =
      Enum.flat_map(selected, &[&1.home_team_ref, &1.away_team_ref]) ++
        Enum.map(retained_performances, & &1.team_ref) ++ Enum.map(players, & &1.team_ref)

    position_refs =
      Enum.map(retained_performances, & &1.position_ref) ++ Enum.map(players, & &1.position_ref)

    directory =
      Catalog.directory(
        %{
          facts
          | teams: retain(facts.teams, team_refs),
            players: players,
            positions: retain(facts.positions, position_refs)
        },
        request,
        positions
      )

    Catalog.require!(
      Enum.all?(player_refs, &Map.has_key?(Catalog.indexed(directory.players), &1)),
      :players
    )

    teams = Catalog.indexed(directory.teams)

    matches =
      Catalog.rows!(
        Enum.map(selected, &Map.delete(&1, :scope)),
        [:ref, :season_ref, :status, :kickoff_at, :home_team_ref, :away_team_ref],
        :matches,
        Match,
        fn m ->
          Catalog.require!(
            m.season_ref == envelope.season.ref and m.home_team_ref != m.away_team_ref and
              Map.has_key?(teams, m.home_team_ref) and Map.has_key?(teams, m.away_team_ref),
            :matches
          )

          {:ok, instant} = Instant.normalize(m.kickoff_at)
          %{m | kickoff_at: instant}
        end
      )

    match_index = Catalog.indexed(matches)
    player_index = Catalog.indexed(directory.players)
    position_index = Catalog.indexed(directory.positions)

    performances =
      Catalog.rows!(
        retained_performances,
        [:ref, :match_ref, :player_ref, :team_ref, :position_ref, :minutes_played, :counts],
        :performances,
        Performance,
        fn p ->
          match = Map.fetch!(match_index, p.match_ref)
          player = Map.fetch!(player_index, p.player_ref)

          Catalog.require!(
            player.season_ref == match.season_ref and
              p.team_ref in [match.home_team_ref, match.away_team_ref] and
              Map.has_key?(position_index, p.position_ref),
            :performances
          )

          Catalog.require!(
            is_integer(p.minutes_played) and p.minutes_played >= 0,
            :minutes_played
          )

          Catalog.require!(
            is_map(p.counts) and not is_struct(p.counts) and
              Enum.all?(Map.keys(p.counts), &(&1 in @counts)),
            :performances
          )

          counts =
            Map.new(@counts, fn key ->
              value = Map.get(p.counts, key)
              Catalog.require!(is_nil(value) or (is_integer(value) and value >= 0), key)
              {key, value}
            end)

          %{p | counts: counts}
        end
      )

    Catalog.unique!(performances, &{&1.player_ref, &1.match_ref}, :performances)
    final = Map.merge(directory, %{matches: matches, performances: performances})
    {final, retained_bindings(bindings, facts, final)}
  end

  defp eligible?(m, request) do
    Catalog.require!(is_map(m) and not is_struct(m), :matches)
    Catalog.ref!(Map.get(m, :ref), :matches)
    Catalog.shape!(Map.get(m, :scope), [:league_code, :start_year, :end_year], :matches)
    {:ok, scope} = Request.scope(m.scope)
    Catalog.require!(Map.get(m, :status) in @statuses, :matches)
    same_scope = scope == Map.take(request.scope, [:league_code, :start_year, :end_year])

    if same_scope and m.status == :completed do
      {:ok, kickoff} = Instant.normalize(Map.get(m, :kickoff_at))

      (is_nil(request.scope.from) or DateTime.compare(kickoff, request.scope.from) != :lt) and
        (is_nil(request.scope.to) or DateTime.compare(kickoff, request.scope.to) != :gt)
    else
      false
    end
  end

  defp retain(rows, refs), do: Enum.filter(rows, &(Map.get(&1, :ref) in refs))

  defp targets(facts) do
    [{:league, facts.league.ref}, {:season, facts.season.ref}] ++
      Enum.flat_map([{:team, :teams}, {:player, :players}, {:match, :matches}], fn {kind, field} ->
        Enum.map(facts[field], &{kind, Map.get(&1, :ref)})
      end)
  end

  defp retained_bindings(bindings, declared, final) do
    Catalog.require!(is_list(bindings), :bindings)
    all = targets(declared)
    wanted = targets(final)

    Enum.filter(bindings, fn b ->
      Catalog.shape!(b, [:kind, :ref, :source_id], :bindings)
      Catalog.require!({b.kind, b.ref} in all, :bindings)
      {b.kind, b.ref} in wanted
    end)
  end
end

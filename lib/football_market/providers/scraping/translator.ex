defmodule FootballMarket.Providers.Scraping.Translator do
  @moduledoc "Fixed-key source translation, preserving identities and unknown metric semantics."
  alias FootballMarket.Providers.Request
  alias FootballMarket.Providers.Scraping.Source

  def base(request, context, row, teams) do
    %{
      league: %{
        ref: "league",
        code: request.scope.league_code,
        name: Request.leagues()[request.scope.league_code]
      },
      season: %{
        ref: "season",
        league_ref: "league",
        start_year: request.scope.start_year,
        end_year: request.scope.end_year
      },
      teams:
        Enum.map(teams, fn t ->
          %{ref: ref(:team, t["id"]), season_ref: "season", name: t["name"], code: t["shortCode"]}
        end),
      positions:
        Enum.map(Enum.uniq(Map.values(row.positions)), fn code ->
          %{ref: code, code: code, name: context.positions[code]}
        end),
      players: []
    }
  end

  def catalog(request, context, row, teams, rosters) do
    facts = base(request, context, row, teams)

    players =
      for {team, players} <- rosters, p <- players do
        %{
          ref: ref(:player, p["id"]),
          season_ref: "season",
          display_name: p["name"],
          team_ref: ref(:team, team),
          position_ref: position!(p["positionCode"], row)
        }
      end

    %{facts | players: players}
  end

  @metric_keys %{
    goals: "goals",
    assists: "assists",
    shots_on_target: "ShotsOnTarget",
    tackles: "matchstats.headers.tackles",
    interceptions: "interceptions",
    saves: "saves",
    goals_conceded: "goals_conceded",
    yellow_cards: "yellow_cards",
    red_cards: "red_cards"
  }
  def eligible!(match, request) do
    Source.id!(match["id"])

    Source.require!(
      match["status"] in ["completed", "scheduled", "live", "postponed", "abandoned"]
    )

    if match["status"] == "completed" do
      {:ok, instant} = FootballMarket.Providers.Instant.normalize(match["kickoff"])

      (is_nil(request.scope.from) or DateTime.compare(instant, request.scope.from) != :lt) and
        (is_nil(request.scope.to) or DateTime.compare(instant, request.scope.to) != :gt)
    else
      false
    end
  end

  def performances(request, context, row, teams, details) do
    wanted =
      Enum.flat_map(details, fn {m, ps} ->
        [m["home"], m["away"]] ++ Enum.flat_map(ps, &[&1["teamId"], &1["currentTeamId"]])
      end)

    teams = Enum.filter(teams, &(is_map(&1) and &1["id"] in wanted))
    facts = base(request, context, row, teams)

    matches =
      for {m, _} <- details do
        %{
          ref: ref(:match, m["id"]),
          scope: Map.take(request.scope, [:league_code, :start_year, :end_year]),
          season_ref: "season",
          status: :completed,
          kickoff_at: m["kickoff"],
          home_team_ref: ref(:team, m["home"]),
          away_team_ref: ref(:team, m["away"])
        }
      end

    players =
      for {_, ps} <- details, p <- ps do
        %{
          ref: ref(:player, p["id"]),
          season_ref: "season",
          display_name: p["name"],
          team_ref: ref(:team, p["currentTeamId"]),
          position_ref: position!(p["usualPosition"], row)
        }
      end

    # A player may have multiple dated appearances, but conflicting profile declarations fail.
    player_groups = Enum.group_by(players, & &1.ref)

    for {_, declarations} <- player_groups,
        do: Source.require!(length(Enum.uniq(declarations)) == 1)

    players = Enum.uniq(players)

    performances =
      for {m, ps} <- details, p <- ps do
        stats =
          for group <- Source.list!(p["stats"]), stat <- Source.list!(group["stats"]), do: stat

        stats = Enum.filter(stats, &(&1["key"] in ["minutes_played" | Map.values(@metric_keys)]))
        keys = Enum.map(stats, & &1["key"])
        Source.require!(length(keys) == length(Enum.uniq(keys)))
        measured = Map.new(stats, &{&1["key"], &1["stat"]["value"]})

        counts =
          Map.new(@metric_keys, fn {key, external} ->
            value = if row.metrics[key].status == :verified, do: measured[external], else: nil
            {key, value}
          end)

        %{
          ref: "performance:" <> Source.id!(m["id"]) <> ":" <> Source.id!(p["id"]),
          match_ref: ref(:match, m["id"]),
          player_ref: ref(:player, p["id"]),
          team_ref: ref(:team, p["teamId"]),
          position_ref: position!(p["positionId"], row),
          minutes_played: measured["minutes_played"],
          counts: counts
        }
      end

    Map.merge(%{facts | players: players}, %{matches: matches, performances: performances})
  end

  def position!(id, row) do
    position = row.positions[id]
    Source.require!(is_binary(position))
    position
  end

  def ref(kind, id), do: Atom.to_string(kind) <> ":" <> Source.id!(id)

  def bindings(facts, row) do
    [
      %{kind: :league, ref: "league", source_id: row.competition},
      %{kind: :season, ref: "season", source_id: row.season}
    ] ++
      for {kind, field} <- [{:team, :teams}, {:player, :players}, {:match, :matches}],
          r <- Map.get(facts, field, []) do
        %{
          kind: kind,
          ref: r.ref,
          source_id: String.replace_prefix(r.ref, Atom.to_string(kind) <> ":", "")
        }
      end
  end
end

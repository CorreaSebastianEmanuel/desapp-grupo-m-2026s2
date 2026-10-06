defmodule FootballMarket.Providers.FootballData.Translator do
  @moduledoc "Supplied football facts with separate decimal source bindings."
  alias FootballMarket.Providers.{Request, FootballData.Scope}

  def player!(player, state) do
    Scope.id!(player["id"], state.token)
    Scope.text!(player["name"], state.token)

    for field <- ["type", "role"],
        do:
          Scope.require!(
            not Map.has_key?(player, field) or String.downcase(player[field]) == "player"
          )

    label = Scope.text!(player["position"], state.token) |> String.downcase()
    position = state.position_mapping[label]
    Scope.require!(is_binary(position))
    Map.put(player, :position, position)
  end

  def candidate(request, evidence, portions, state, context) do
    teams =
      for {team, _} <- portions,
          do: %{
            ref: "t#{team[:index]}",
            season_ref: "s",
            name: String.trim(team["name"]),
            code: String.trim(team["tla"])
          }

    supplied = for {team, players} <- portions, player <- players, do: {team, player}

    players =
      supplied
      |> Enum.with_index()
      |> Enum.map(fn {{team, p}, i} ->
        %{
          ref: "p#{i}",
          season_ref: "s",
          display_name: String.trim(p["name"]),
          team_ref: "t#{team[:index]}",
          position_ref: p[:position]
        }
      end)

    positions =
      players
      |> Enum.map(& &1.position_ref)
      |> Enum.uniq()
      |> Enum.map(&%{ref: &1, code: &1, name: context.positions[&1]})

    bindings =
      [
        %{kind: :league, ref: "l", source_id: Integer.to_string(evidence.competition)},
        %{kind: :season, ref: "s", source_id: Integer.to_string(evidence.season.id)}
      ] ++
        for(
          {team, _} <- portions,
          do: %{kind: :team, ref: "t#{team[:index]}", source_id: Integer.to_string(team["id"])}
        ) ++
        (supplied
         |> Enum.with_index()
         |> Enum.map(fn {{_, p}, i} ->
           %{kind: :player, ref: "p#{i}", source_id: Integer.to_string(p["id"])}
         end))

    %{
      operation: :catalog,
      scope: request.scope,
      facts: %{
        league: %{ref: "l", code: evidence.code, name: Request.leagues()[evidence.code]},
        season: %{
          ref: "s",
          league_ref: "l",
          start_year: request.scope.start_year,
          end_year: request.scope.end_year
        },
        teams: teams,
        players: players,
        positions: positions
      },
      bindings: bindings,
      fixture_id: state.fixture_id
    }
  end
end

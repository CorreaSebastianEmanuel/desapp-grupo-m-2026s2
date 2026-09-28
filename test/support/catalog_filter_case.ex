defmodule FootballMarket.CatalogFilterCase do
  @moduledoc false

  alias FootballMarket.Catalog
  import FootballMarket.CatalogCase

  def build! do
    positions =
      for {code, name} <- [
            {"GK", "Goalkeeper"},
            {"DF", "Defender"},
            {"MF", "Midfielder"},
            {"FW", "Forward"}
          ] do
        {:ok, position} = Catalog.create_position(%{code: code, name: name})
        position
      end

    records =
      for {{code, name}, league_number} <- Enum.with_index(Catalog.supported_leagues()),
          season_number <- 0..1,
          position <- positions,
          player_number <- 1..2 do
        league = league!(code, name)
        season = season!(league, 2024 + season_number)
        team = team!(season)

        {:ok, player} =
          Catalog.create_player(
            player_attrs(team, position, %{
              display_name: if(player_number == 1, do: " Tie ", else: "tie"),
              catalog_identity:
                "filter-#{league_number}-#{season_number}-#{position.code}-#{player_number}"
            })
          )

        player
      end

    target = hd(records)
    team = target.team
    position = target.position

    extras =
      for index <- 1..105 do
        {:ok, player} =
          Catalog.create_player(
            player_attrs(team, position, %{
              display_name: "Extra #{String.pad_leading(to_string(index), 3, "0")}",
              catalog_identity: "filter-extra-#{index}"
            })
          )

        player
      end

    %{players: records ++ extras, target: target, positions: positions}
  end

  def expected(players, filters \\ %{}) do
    players
    |> Enum.filter(fn player ->
      Enum.all?(filters, fn
        {:league_id, id} -> player.team.season.league.id == id
        {:team_id, id} -> player.team.id == id
        {:position_id, id} -> player.position.id == id
      end)
    end)
    |> Enum.sort_by(fn player ->
      {player.display_name |> String.trim() |> String.downcase(), player.id}
    end)
    |> Enum.map(& &1.id)
  end

  defp league!(code, name) do
    case Catalog.get_league_by_code(code) do
      {:ok, league} ->
        league

      {:error, :not_found} ->
        {:ok, league} = Catalog.create_league(%{code: code, name: name})
        league
    end
  end

  defp season!(league, year) do
    case Catalog.get_season(league.id, year, year + 1) do
      {:ok, season} ->
        season

      {:error, :not_found} ->
        {:ok, season} =
          Catalog.create_season(%{league_id: league.id, start_year: year, end_year: year + 1})

        season
    end
  end

  defp team!(season) do
    case Catalog.get_team_by_code(season.id, "SAME") do
      {:ok, team} ->
        team

      {:error, :not_found} ->
        {:ok, team} =
          Catalog.create_team(%{season_id: season.id, code: "SAME", name: "Same Club"})

        team
    end
  end
end

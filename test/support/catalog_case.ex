defmodule FootballMarket.CatalogCase do
  def unique_code(prefix), do: "#{prefix}#{System.unique_integer([:positive])}"

  def league_attrs(overrides \\ %{}),
    do: Map.merge(%{code: "PL", name: "Premier League"}, overrides)

  def season_attrs(league, overrides \\ %{}),
    do: Map.merge(%{league_id: league.id, start_year: 2025, end_year: 2026}, overrides)

  def team_attrs(season, overrides \\ %{}),
    do:
      Map.merge(
        %{season_id: season.id, code: unique_code("T"), name: unique_code("Team ")},
        overrides
      )

  def position_attrs(overrides \\ %{}),
    do: Map.merge(%{code: unique_code("P"), name: unique_code("Position ")}, overrides)

  def player_attrs(team, position, overrides \\ %{}) do
    Map.merge(
      %{
        team_id: team.id,
        position_id: position.id,
        catalog_identity: unique_code("player-"),
        display_name: "Player"
      },
      overrides
    )
  end

  def insert_hierarchy! do
    {:ok, league} = FootballMarket.Catalog.create_league(league_attrs())
    {:ok, season} = FootballMarket.Catalog.create_season(season_attrs(league))
    {:ok, team} = FootballMarket.Catalog.create_team(team_attrs(season))
    %{league: league, season: season, team: team}
  end
end

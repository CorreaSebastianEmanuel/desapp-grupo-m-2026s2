defmodule FootballMarket.StatisticsCase do
  alias FootballMarket.{Catalog, Repo}
  alias FootballMarket.Catalog.{League, Position}
  import FootballMarket.CatalogCase
  import Ecto.Query

  def fixture(code \\ "PL", year \\ 2025) do
    league =
      Repo.one(from l in League, where: l.code == ^code) ||
        elem(
          Catalog.create_league(
            league_attrs(%{code: code, name: Map.new(Catalog.supported_leagues())[code]})
          ),
          1
        )

    {:ok, season} =
      Catalog.create_season(season_attrs(league, %{start_year: year, end_year: year + 1}))

    {:ok, home} = Catalog.create_team(team_attrs(season))
    {:ok, away} = Catalog.create_team(team_attrs(season))

    position =
      Repo.one(from p in Position, limit: 1) || elem(Catalog.create_position(position_attrs()), 1)

    players =
      for team <- [home, away], do: elem(Catalog.create_player(player_attrs(team, position)), 1)

    %{season: season, home: home, away: away, position: position, players: players}
  end

  def unique_fixture do
    # The dedicated partition retains immutable fixtures across VM restarts.
    year = Repo.one(from s in FootballMarket.Catalog.Season, select: max(s.end_year)) || 10000
    fixture("PL", year + 1)
  end

  def match_attrs(f, overrides \\ %{}) do
    Map.merge(
      %{
        match_identity: unique_code("event-"),
        kickoff_at: "2026-01-01T12:00:00.123456Z",
        season_id: f.season.id,
        home_team_id: f.home.id,
        away_team_id: f.away.id
      },
      overrides
    )
  end

  def performance_attrs(f, match, overrides \\ %{}) do
    Map.merge(
      %{
        match_id: match.id,
        player_id: hd(f.players).id,
        team_id: f.home.id,
        position_id: f.position.id,
        minutes_played: 123
      },
      overrides
    )
  end

  def metrics,
    do: [
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
end

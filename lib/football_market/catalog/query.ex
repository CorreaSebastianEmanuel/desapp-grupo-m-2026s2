defmodule FootballMarket.Catalog.Query do
  import Ecto.Query

  alias FootballMarket.Catalog.{League, Player, Position, Season, Team}

  @player_filters [:league_id, :season_id, :team_id, :position_id]

  def by_id(schema, id), do: from(record in schema, where: record.id == ^id)

  def league_by(field, value) when field in [:code, :name] do
    from league in League,
      where:
        fragment("lower(btrim(?))", field(league, ^field)) == fragment("lower(btrim(?))", ^value)
  end

  def season(league_id, start_year, end_year),
    do:
      from(season in Season,
        where:
          season.league_id == ^league_id and season.start_year == ^start_year and
            season.end_year == ^end_year
      )

  def team_by(season_id, field, value) when field in [:code, :name] do
    from team in Team,
      where: team.season_id == ^season_id,
      where:
        fragment("lower(btrim(?))", field(team, ^field)) == fragment("lower(btrim(?))", ^value)
  end

  def position_by(field, value) when field in [:code, :name] do
    from position in Position,
      where:
        fragment("lower(btrim(?))", field(position, ^field)) ==
          fragment("lower(btrim(?))", ^value)
  end

  def player(season_id, catalog_identity) do
    from player in base_players(),
      where: player.season_id == ^season_id,
      where:
        fragment("lower(btrim(?))", player.catalog_identity) ==
          fragment("lower(btrim(?))", ^catalog_identity)
  end

  def players(filters) do
    unknown = Map.keys(filters) -- @player_filters

    if unknown == [] do
      query = Enum.reduce(filters, base_players(), &apply_filter/2)
      {:ok, from(player in query, order_by: [asc: player.id])}
    else
      {:error, {:unknown_filters, Enum.sort(unknown)}}
    end
  end

  defp base_players do
    from player in Player,
      join: team in assoc(player, :team),
      join: season in assoc(team, :season),
      join: league in assoc(season, :league),
      join: position in assoc(player, :position),
      preload: [team: {team, season: {season, league: league}}, position: position]
  end

  defp apply_filter({:league_id, value}, query),
    do: from([player, team, season, league, position] in query, where: league.id == ^value)

  defp apply_filter({:season_id, value}, query),
    do: from([player, team, season, league, position] in query, where: season.id == ^value)

  defp apply_filter({:team_id, value}, query),
    do: from([player, team, season, league, position] in query, where: team.id == ^value)

  defp apply_filter({:position_id, value}, query),
    do: from([player, team, season, league, position] in query, where: position.id == ^value)
end

defmodule FootballMarket.Catalog do
  @moduledoc "The persistence boundary for the local football catalog."

  import Ecto.Changeset

  alias FootballMarket.Catalog.{League, Player, Position, Query, Season, Team}
  alias FootballMarket.Repo

  @supported_leagues [
    {"PL", "Premier League"},
    {"BL1", "Bundesliga"},
    {"PD", "La Liga"},
    {"SA", "Serie A"},
    {"FL1", "Ligue 1"}
  ]

  def supported_leagues, do: @supported_leagues

  def create_league(attrs), do: %League{} |> League.changeset(attrs) |> Repo.insert()
  def create_season(attrs), do: %Season{} |> Season.changeset(attrs) |> Repo.insert()
  def create_team(attrs), do: %Team{} |> Team.changeset(attrs) |> Repo.insert()
  def create_position(attrs), do: %Position{} |> Position.changeset(attrs) |> Repo.insert()

  def create_player(attrs) do
    with {:ok, team} <- existing_team(attrs) do
      %Player{}
      |> Player.create_changeset(attrs, team.season_id)
      |> Repo.insert()
      |> preload_player()
    end
  end

  def update_player(%Player{} = player, attrs) do
    team_id = Map.get(attrs, :team_id, Map.get(attrs, "team_id", player.team_id))

    case team_id do
      nil ->
        {:error, player |> change() |> add_error(:team_id, "does not exist")}

      team_id ->
        case Repo.get(Team, team_id) do
          %Team{season_id: season_id} when season_id == player.season_id ->
            player
            |> Player.update_changeset(attrs, season_id)
            |> Repo.update()
            |> preload_player()

          %Team{} ->
            {:error,
             player |> change() |> add_error(:team_id, "must belong to the player's season")}

          nil ->
            {:error, player |> change() |> add_error(:team_id, "does not exist")}
        end
    end
  end

  def delete_league(%League{} = league), do: league |> League.delete_changeset() |> Repo.delete()
  def delete_season(%Season{} = season), do: season |> Season.delete_changeset() |> Repo.delete()
  def delete_team(%Team{} = team), do: team |> Team.delete_changeset() |> Repo.delete()

  def delete_position(%Position{} = position),
    do: position |> Position.delete_changeset() |> Repo.delete()

  def get_league(id), do: one(Query.by_id(League, id))
  def fetch_league!(id), do: Repo.get!(League, id)
  def get_league_by_code(code), do: one(Query.league_by(:code, code))
  def get_league_by_name(name), do: one(Query.league_by(:name, name))

  def get_season(id), do: one(Query.by_id(Season, id))

  def get_season(league_id, start_year, end_year),
    do: one(Query.season(league_id, start_year, end_year))

  def get_team(id), do: one(Query.by_id(Team, id))
  def get_team_by_code(season_id, code), do: one(Query.team_by(season_id, :code, code))
  def get_team_by_name(season_id, name), do: one(Query.team_by(season_id, :name, name))
  def get_position(id), do: one(Query.by_id(Position, id))
  def get_position_by_code(code), do: one(Query.position_by(:code, code))
  def get_position_by_name(name), do: one(Query.position_by(:name, name))

  def get_player(id), do: Query.by_id(Player, id) |> Repo.one() |> preload_one_player()

  def get_player(season_id, identity),
    do: Query.player(season_id, identity) |> Repo.one() |> preload_one_player()

  def list_players(filters \\ %{}) do
    case Query.players(Map.new(filters)) do
      {:ok, query} -> Repo.all(query)
      {:error, reason} -> {:error, reason}
    end
  end

  def explain_player_lookup(filters) do
    filter_columns = [
      league_id: "s.league_id",
      season_id: "p.season_id",
      team_id: "p.team_id",
      position_id: "p.position_id"
    ]

    selected = Enum.filter(filter_columns, fn {key, _column} -> Map.has_key?(filters, key) end)

    clauses =
      selected
      |> Enum.with_index(1)
      |> Enum.map(fn {{_key, column}, index} -> "#{column} = $#{index}" end)

    values =
      Enum.map(selected, fn {key, _column} -> filters |> Map.fetch!(key) |> Ecto.UUID.dump!() end)

    sql =
      "EXPLAIN SELECT p.id FROM players p JOIN seasons s ON s.id = p.season_id WHERE " <>
        Enum.join(clauses, " AND ")

    %{rows: rows} = Ecto.Adapters.SQL.query!(Repo, sql, values)
    rows |> List.flatten() |> Enum.join("\n")
  end

  defp existing_team(attrs) do
    team_id = Map.get(attrs, :team_id, Map.get(attrs, "team_id"))

    case team_id do
      nil ->
        {:error, %Player{} |> change() |> add_error(:team_id, "does not exist")}

      team_id ->
        case Repo.get(Team, team_id) do
          nil -> {:error, %Player{} |> change() |> add_error(:team_id, "does not exist")}
          team -> {:ok, team}
        end
    end
  end

  defp one(query) do
    case Repo.one(query) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  defp preload_player({:ok, player}),
    do: {:ok, Repo.preload(player, team: [season: :league], position: [])}

  defp preload_player(error), do: error
  defp preload_one_player(nil), do: {:error, :not_found}

  defp preload_one_player(player),
    do: {:ok, Repo.preload(player, team: [season: :league], position: [])}
end

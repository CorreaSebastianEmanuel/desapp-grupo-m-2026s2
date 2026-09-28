defmodule FootballMarketWeb.PlayerJSON do
  def index(%{page: %{players: players, pagination: pagination}}) do
    %{data: Enum.map(players, &player/1), pagination: pagination}
  end

  def show(%{player: record}), do: %{data: player(record)}

  defp player(record) do
    %{
      id: record.id,
      display_name: record.display_name,
      catalog_identity: record.catalog_identity,
      position: %{id: record.position.id, code: record.position.code, name: record.position.name},
      team: %{id: record.team.id, short_code: record.team.code, name: record.team.name},
      season: %{
        id: record.team.season.id,
        start_year: record.team.season.start_year,
        end_year: record.team.season.end_year
      },
      league: %{
        id: record.team.season.league.id,
        code: record.team.season.league.code,
        name: record.team.season.league.name
      }
    }
  end
end

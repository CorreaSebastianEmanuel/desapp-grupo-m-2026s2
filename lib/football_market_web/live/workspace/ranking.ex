defmodule FootballMarketWeb.Workspace.Ranking do
  @moduledoc false
  import Phoenix.Component, only: [assign: 2]
  import FootballMarketWeb.Workspace.Session
  alias FootballMarket.Ranking

  def load_ranking(socket) do
    case Ranking.read() do
      {:ok, ranking} ->
        entries =
          Enum.map(ranking.entries, &Map.put(&1, :player_name, player_name(&1.player_id)))

        assign(socket, ranking: %{ranking | entries: entries}, ranking_error: nil)

      {:error, :no_active_configuration} ->
        assign(socket, ranking: nil, ranking_error: nil)

      _ ->
        assign(socket,
          ranking: nil,
          ranking_error: "El ranking no está disponible temporalmente."
        )
    end
  end
end

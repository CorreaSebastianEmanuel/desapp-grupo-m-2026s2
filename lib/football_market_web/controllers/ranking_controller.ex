defmodule FootballMarketWeb.RankingController do
  use FootballMarketWeb, :controller

  alias FootballMarket.Ranking

  def index(conn, _params) do
    case Ranking.read() do
      {:ok, result} ->
        conn |> put_resp_header("cache-control", "no-store") |> render(:index, result: result)

      {:error, :no_active_configuration} ->
        error(conn, 409, "no_active_configuration")

      {:error, :storage_unavailable} ->
        error(conn, 503, "storage_unavailable")
    end
  end

  defp error(conn, status, code) do
    conn
    |> put_resp_header("cache-control", "no-store")
    |> put_status(status)
    |> json(%{error: %{code: code}})
  end
end

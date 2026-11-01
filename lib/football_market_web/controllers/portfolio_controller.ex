defmodule FootballMarketWeb.PortfolioController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarket.Market.Analytics.Input
  alias FootballMarketWeb.PortfolioJSON

  plug :private_response

  def allocation(conn, _params) do
    respond(conn, Market.portfolio_allocation(conn.assigns[:authenticated_actor]))
  end

  def history(conn, _params) do
    case Input.decode(conn.query_string) do
      {:ok, options} ->
        respond(conn, Market.portfolio_history(conn.assigns[:authenticated_actor], options))

      {:error, reason} ->
        error(conn, 400, reason)
    end
  end

  defp respond(conn, {:ok, data}), do: json(conn, %{data: PortfolioJSON.data(data)})

  defp respond(conn, {:error, %{kind: kind}}) do
    status =
      case kind do
        :unauthenticated -> 401
        :temporarily_unavailable -> 503
        _ -> 400
      end

    error(conn, status, kind)
  end

  defp error(conn, status, code), do: conn |> put_status(status) |> json(%{error: %{code: code}})
  defp private_response(conn, _), do: put_resp_header(conn, "cache-control", "private, no-store")
end

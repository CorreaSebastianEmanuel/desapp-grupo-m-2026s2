defmodule FootballMarketWeb.SaleController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market

  def create(conn, _params) do
    with {:ok, input} <- input(conn.body_params),
         {:ok, sale} <- Market.sale(conn.assigns[:authenticated_actor], input) do
      json(conn, %{data: FootballMarketWeb.SaleJSON.data(sale)})
    else
      {:error, %{kind: kind}} -> error(conn, kind)
      _ -> error(conn, :invalid_request)
    end
  end

  defp input(params) when is_map(params) do
    if Enum.sort(Map.keys(params)) == ~w(player_id quantity request_key) do
      {:ok,
       %{
         player_id: params["player_id"],
         quantity: params["quantity"],
         request_key: params["request_key"]
       }}
    else
      {:error, :invalid_request}
    end
  end

  defp input(_), do: {:error, :invalid_request}

  defp error(conn, kind) do
    status =
      case kind do
        :unauthenticated -> 401
        :invalid_request -> 400
        :player_not_found -> 404
        :temporarily_unavailable -> 503
        _ -> 409
      end

    conn |> put_status(status) |> json(%{error: %{code: kind}})
  end
end

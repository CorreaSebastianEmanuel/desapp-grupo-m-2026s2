defmodule FootballMarketWeb.ConditionalOrderController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market.ConditionalOrders
  alias FootballMarketWeb.ConditionalOrderJSON
  @fields ~w(player_id quantity maximum_unit_price expires_at)

  def create(conn, _params) do
    with :ok <- query(conn),
         {:ok, terms} <- terms(conn.body_params),
         {:ok, order} <- ConditionalOrders.create(conn.assigns[:authenticated_actor], terms) do
      conn
      |> put_resp_header("location", "/api/conditional-orders/" <> order.id)
      |> put_status(201)
      |> json(%{data: ConditionalOrderJSON.data(order)})
    else
      failure -> error(conn, failure)
    end
  end

  def index(conn, _params) do
    with :ok <- query(conn),
         {:ok, orders} <- ConditionalOrders.list(conn.assigns[:authenticated_actor]) do
      json(conn, %{data: Enum.map(orders, &ConditionalOrderJSON.data/1)})
    else
      failure -> error(conn, failure)
    end
  end

  def show(conn, %{"id" => id}) do
    with :ok <- query(conn),
         {:ok, order} <- ConditionalOrders.get(conn.assigns[:authenticated_actor], id) do
      json(conn, %{data: ConditionalOrderJSON.data(order)})
    else
      failure -> error(conn, failure)
    end
  end

  def cancel(conn, %{"id" => id}) do
    with :ok <- query(conn),
         true <- conn.body_params == %{},
         {:ok, order} <- ConditionalOrders.cancel(conn.assigns[:authenticated_actor], id) do
      json(conn, %{data: ConditionalOrderJSON.data(order)})
    else
      false -> error(conn, {:error, :invalid_request})
      failure -> error(conn, failure)
    end
  end

  defp query(conn), do: if(conn.query_params == %{}, do: :ok, else: {:error, :invalid_request})

  defp terms(params) when is_map(params) do
    if Enum.sort(Map.keys(params)) == Enum.sort(@fields) do
      {:ok, Map.new(@fields, fn key -> {String.to_existing_atom(key), params[key]} end)}
    else
      {:error, :invalid_request}
    end
  end

  defp terms(_), do: {:error, :invalid_request}
  defp error(conn, {:error, %{kind: kind}}), do: error(conn, {:error, kind})

  defp error(conn, {:error, kind}) do
    status =
      case kind do
        :unauthenticated -> 401
        :invalid_request -> 400
        kind when kind in [:not_found, :player_not_found] -> 404
        :temporarily_unavailable -> 503
        _ -> 409
      end

    conn |> put_status(status) |> json(%{error: %{code: kind}})
  end
end

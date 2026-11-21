defmodule FootballMarketWeb.TradeControllerHelper do
  @moduledoc false
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [json: 2]
  alias FootballMarketWeb.ApiJSON

  def execute(conn, action) do
    with {:ok, input} <- parse_input(conn.body_params),
         {:ok, trade} <- action.(conn.assigns[:authenticated_actor], input) do
      json(conn, %{data: ApiJSON.trade_data(trade)})
    else
      {:error, %{kind: kind}} -> trade_error(conn, kind)
      _ -> trade_error(conn, :invalid_request)
    end
  end

  defp parse_input(params) when is_map(params) do
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

  defp parse_input(_), do: {:error, :invalid_request}

  defp trade_error(conn, kind) do
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

defmodule FootballMarketWeb.PurchaseController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarketWeb.TradeControllerHelper

  def create(conn, _params), do: TradeControllerHelper.execute(conn, &Market.purchase/2)
end

defmodule FootballMarketWeb.SaleController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarketWeb.TradeControllerHelper

  def create(conn, _params), do: TradeControllerHelper.execute(conn, &Market.sale/2)
end

defmodule FootballMarketWeb.TransactionController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarketWeb.TransactionJSON

  def index(conn, _params) do
    with {:ok, options} <- pagination(conn.query_string),
         {:ok, page} <- Market.transaction_history(conn.assigns[:authenticated_actor], options) do
      json(conn, %{
        data: Enum.map(page.data, &TransactionJSON.data/1),
        pagination: page.pagination
      })
    else
      {:error, :invalid_page_size} -> error(conn, 400, "invalid_page_size")
      {:error, :invalid_cursor} -> error(conn, 400, "invalid_cursor")
      {:error, %{kind: :unauthenticated}} -> error(conn, 401, "unauthenticated")
      {:error, %{kind: :temporarily_unavailable}} -> error(conn, 503, "temporarily_unavailable")
    end
  end

  defp pagination(query) do
    pairs = Enum.to_list(URI.query_decoder(query))

    with {:ok, size} <- value(pairs, "page_size", :invalid_page_size),
         {:ok, cursor} <- value(pairs, "cursor", :invalid_cursor),
         {:ok, page_size} <- page_size(size),
         :ok <- valid_cursor(cursor) do
      {:ok, %{page_size: page_size, cursor: cursor}}
    end
  rescue
    _ -> {:error, :invalid_page_size}
  end

  defp value(pairs, key, error) do
    case values(pairs, key) do
      {:ok, value} -> structured(pairs, key, value, error)
      :error -> {:error, error}
    end
  end

  defp values(pairs, key) do
    case for({candidate, v} <- pairs, candidate == key, do: v) do
      [] -> {:ok, nil}
      [v] -> {:ok, v}
      _ -> :error
    end
  end

  defp structured(pairs, key, value, error) do
    repeats =
      Enum.any?(pairs, fn {candidate, _} -> String.starts_with?(candidate, key <> "[") end)

    if repeats, do: {:error, error}, else: {:ok, value}
  end

  defp page_size(nil), do: {:ok, 25}

  defp page_size(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value) do
      case Integer.parse(value) do
        {n, ""} when n in 1..100 -> {:ok, n}
        _ -> {:error, :invalid_page_size}
      end
    else
      {:error, :invalid_page_size}
    end
  end

  defp valid_cursor(nil), do: :ok
  defp valid_cursor(""), do: {:error, :invalid_cursor}
  defp valid_cursor(_), do: :ok
  defp error(conn, status, code), do: conn |> put_status(status) |> json(%{error: %{code: code}})
end

defmodule FootballMarketWeb.PortfolioController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarket.Market.Analytics
  alias FootballMarketWeb.PortfolioJSON

  plug :private_response

  def allocation(conn, _params) do
    respond(conn, Market.portfolio_allocation(conn.assigns[:authenticated_actor]))
  end

  def history(conn, _params) do
    case Analytics.decode_query(conn.query_string) do
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

defmodule FootballMarketWeb.QuoteController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Quotes

  def current(conn, %{"player_id" => id}), do: respond(conn, Quotes.latest(id), :show)
  def history(conn, %{"player_id" => id}), do: respond(conn, Quotes.list_history(id), :index)

  def at(conn, %{"player_id" => id}) do
    case requested_date(conn.query_string) do
      {:ok, date} -> respond(conn, Quotes.at_date(id, date), :show)
      {:error, :invalid_date} -> respond(conn, {:error, :invalid_date}, :show)
    end
  end

  defp requested_date(query_string) do
    values =
      query_string
      |> URI.query_decoder()
      |> Enum.filter(fn {key, _} -> key == "date" or String.starts_with?(key, "date[") end)

    with [{"date", value}] <- values,
         true <- Regex.match?(~r/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/, value),
         {:ok, date} <- Date.from_iso8601(value) do
      {:ok, date}
    else
      _ -> {:error, :invalid_date}
    end
  rescue
    _ -> {:error, :invalid_date}
  end

  defp respond(conn, {:ok, records}, :index), do: render(conn, :index, quotes: records)
  defp respond(conn, {:ok, record}, :show), do: render(conn, :show, quote: record)

  defp respond(conn, {:error, reason}, _) do
    status =
      case reason do
        :invalid_date -> 400
        :player_not_found -> 404
        :quote_not_found -> 404
        :temporarily_unavailable -> 503
      end

    conn |> put_status(status) |> json(%{error: %{code: Atom.to_string(reason)}})
  end
end

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

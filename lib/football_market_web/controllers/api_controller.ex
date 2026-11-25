# All REST API controllers and JSON serializers live in this single file.
# Every endpoint matches the OpenAPI 3 contract in `priv/static/openapi.json`.

defmodule FootballMarketWeb.ApiJSON do
  @moduledoc "Shared exact-money and domain JSON serialization helpers."

  def money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)

  def trade(record) do
    record
    |> Map.drop([:transfer, :ledger])
    |> Map.update!(:unit_price, &money/1)
    |> Map.update!(:total, &money/1)
  end

  def player(record) do
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

  def quote_record(record) do
    %{
      id: record.id,
      player_id: record.player_id,
      unit_price: money(record.unit_price),
      effective_at: DateTime.to_iso8601(record.effective_at),
      inserted_at: DateTime.to_iso8601(record.inserted_at),
      rule_id: record.rule_id,
      rule_version: record.rule_version,
      calculation_id: record.calculation_id,
      configuration_version_id: record.configuration_version_id,
      mapping_id: record.mapping_id,
      performance_sequence: record.performance_sequence
    }
  end

  def portfolio(%Decimal{} = value), do: Decimal.to_string(value, :normal)
  def portfolio(%DateTime{} = value), do: DateTime.to_iso8601(value)
  def portfolio(%Date{} = value), do: Date.to_iso8601(value)
  def portfolio(value) when is_list(value), do: Enum.map(value, &portfolio/1)

  def portfolio(value) when is_map(value) do
    Map.new(value, fn
      {:unit_price, %Decimal{} = price} -> {:unit_price, money(price)}
      {key, item} -> {key, portfolio(item)}
    end)
  end

  def portfolio(value), do: value

  def conditional_order(order) do
    order
    |> Map.take([
      :id,
      :player_id,
      :quantity,
      :maximum_unit_price,
      :created_at,
      :expires_at,
      :status,
      :expiry_reached,
      :completed_at,
      :rejection_reason,
      :execution
    ])
    |> Map.update!(:maximum_unit_price, &money/1)
    |> Map.update!(:execution, fn
      nil -> nil
      exec -> exec |> Map.update!(:unit_price, &money/1) |> Map.update!(:total, &money/1)
    end)
  end
end

defmodule FootballMarketWeb.ErrorJSON do
  @moduledoc false

  def render("400.json", %{conn: %{request_path: "/api/purchases"}}),
    do: %{error: %{code: "invalid_request"}}

  def render("400.json", %{conn: %{request_path: "/api/sales"}}),
    do: %{error: %{code: "invalid_request"}}

  def render("400.json", %{conn: %{request_path: "/api/conditional-orders"}}),
    do: %{error: %{code: "invalid_request"}}

  def render("400.json", %{conn: %{request_path: "/api/conditional-orders/" <> _}}),
    do: %{error: %{code: "invalid_request"}}

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end

defmodule FootballMarketWeb.PlayerController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Catalog
  alias FootballMarketWeb.ApiJSON

  def index(conn, _params) do
    with {:ok, page_size, cursor, filters} <- pagination_params(conn.query_string),
         {:ok, page} <-
           Catalog.list_player_page(%{page_size: page_size, cursor: cursor, filters: filters}) do
      json(conn, %{data: Enum.map(page.players, &ApiJSON.player/1), pagination: page.pagination})
    else
      {:error, reason} ->
        conn |> put_status(400) |> json(%{error: %{code: Atom.to_string(reason)}})
    end
  end

  def show(conn, %{"player_id" => player_id}) do
    case Catalog.player_card(player_id) do
      {:ok, detail} ->
        json(conn, %{
          data: ApiJSON.player(detail.player),
          statistics_status: detail.statistics_status,
          statistics: detail.statistics
        })

      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: %{code: "player_not_found"}})

      {:error, :temporarily_unavailable} ->
        conn |> put_status(503) |> json(%{error: %{code: "temporarily_unavailable"}})
    end
  end

  defp pagination_params(query_string) do
    pairs = Enum.to_list(URI.query_decoder(query_string))

    with {:ok, size_raw} <- unique_param(pairs, "page_size", :invalid_page_size),
         {:ok, page_size} <- parse_page_size(size_raw),
         {:ok, league_id} <- uuid_param(pairs, "league_id", :invalid_league_id),
         {:ok, team_id} <- uuid_param(pairs, "team_id", :invalid_team_id),
         {:ok, position_id} <- uuid_param(pairs, "position_id", :invalid_position_id),
         {:ok, cursor} <- unique_param(pairs, "cursor", :invalid_cursor),
         :ok <- if(cursor == "", do: {:error, :invalid_cursor}, else: :ok) do
      filters =
        [league_id: league_id, team_id: team_id, position_id: position_id]
        |> Enum.reject(fn {_k, v} -> is_nil(v) end)
        |> Map.new()

      {:ok, page_size, cursor, filters}
    end
  rescue
    _ -> {:error, :invalid_page_size}
  end

  defp unique_param(pairs, key, err) do
    if Enum.any?(pairs, fn {k, _} -> String.starts_with?(k, key <> "[") end),
      do: {:error, err},
      else: pick_single_value(pairs, key, err)
  end

  defp pick_single_value(pairs, key, err) do
    case for({^key, v} <- pairs, do: v) do
      [] -> {:ok, nil}
      [v] -> {:ok, v}
      _ -> {:error, err}
    end
  end

  defp uuid_param(pairs, key, err) do
    with {:ok, raw} <- unique_param(pairs, key, err), do: parse_optional_uuid(raw, err)
  end

  defp parse_optional_uuid(nil, _err), do: {:ok, nil}

  defp parse_optional_uuid(val, err) do
    with true <- Regex.match?(~r/\A[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\z/, val),
         {:ok, uuid} <- Ecto.UUID.cast(val) do
      {:ok, uuid}
    else
      _ -> {:error, err}
    end
  end

  defp parse_page_size(nil), do: {:ok, 25}

  defp parse_page_size(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value) do
      case Integer.parse(value) do
        {size, ""} when size in 1..100 -> {:ok, size}
        _ -> {:error, :invalid_page_size}
      end
    else
      {:error, :invalid_page_size}
    end
  end
end

defmodule FootballMarketWeb.QuoteController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Quotes
  alias FootballMarketWeb.ApiJSON

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
      |> Enum.filter(fn {k, _} -> k == "date" or String.starts_with?(k, "date[") end)

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

  defp respond(conn, {:ok, records}, :index),
    do: json(conn, %{data: Enum.map(records, &ApiJSON.quote_record/1)})

  defp respond(conn, {:ok, record}, :show),
    do: json(conn, %{data: ApiJSON.quote_record(record)})

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
  alias FootballMarketWeb.ApiJSON

  def index(conn, _params) do
    case Ranking.read() do
      {:ok, result} ->
        conn
        |> put_resp_header("cache-control", "no-store")
        |> json(%{
          configuration: %{
            configuration_version_id: result.configuration.id,
            strategy_id: result.configuration.strategy_id,
            formula_version: result.configuration.formula_version
          },
          data:
            Enum.map(result.entries, fn row ->
              %{
                position: row.position,
                player_id: row.player_id,
                quote_id: row.quote_id,
                unit_price: ApiJSON.money(row.unit_price),
                effective_at: DateTime.to_iso8601(row.effective_at)
              }
            end)
        })

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

defmodule FootballMarketWeb.PurchaseController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market

  def create(conn, _params),
    do: FootballMarketWeb.SaleController.run_trade(conn, &Market.purchase/2)
end

defmodule FootballMarketWeb.SaleController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarketWeb.ApiJSON

  def create(conn, _params), do: run_trade(conn, &Market.sale/2)

  def run_trade(conn, action) do
    with {:ok, input} <- parse_trade_input(conn.body_params),
         {:ok, trade} <- action.(conn.assigns[:authenticated_actor], input) do
      json(conn, %{data: ApiJSON.trade(trade)})
    else
      {:error, %{kind: kind}} -> trade_error(conn, kind)
      _ -> trade_error(conn, :invalid_request)
    end
  end

  defp parse_trade_input(params) when is_map(params) do
    if Enum.sort(Map.keys(params)) == ~w(player_id quantity request_key) and
         is_binary(params["player_id"]) and byte_size(params["player_id"]) == 36 do
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

  defp parse_trade_input(_), do: {:error, :invalid_request}

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

defmodule FootballMarketWeb.TransactionController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarketWeb.ApiJSON

  def index(conn, _params) do
    with {:ok, options} <- parse_pagination(conn.query_string),
         {:ok, page} <- Market.transaction_history(conn.assigns[:authenticated_actor], options) do
      data =
        Enum.map(page.data, fn row ->
          row
          |> Map.update!(:unit_price, &ApiJSON.money/1)
          |> Map.update!(:total, &ApiJSON.money/1)
        end)

      json(conn, %{data: data, pagination: page.pagination})
    else
      {:error, :invalid_page_size} -> error(conn, 400, "invalid_page_size")
      {:error, :invalid_cursor} -> error(conn, 400, "invalid_cursor")
      {:error, %{kind: :unauthenticated}} -> error(conn, 401, "unauthenticated")
      {:error, %{kind: :temporarily_unavailable}} -> error(conn, 503, "temporarily_unavailable")
    end
  end

  defp parse_pagination(query) do
    pairs = Enum.to_list(URI.query_decoder(query))

    with {:ok, size_raw} <- unique_param(pairs, "page_size", :invalid_page_size),
         {:ok, cursor} <- unique_param(pairs, "cursor", :invalid_cursor),
         {:ok, page_size} <- parse_page_size(size_raw),
         :ok <- if(cursor == "", do: {:error, :invalid_cursor}, else: :ok) do
      {:ok, %{page_size: page_size, cursor: cursor}}
    end
  rescue
    _ -> {:error, :invalid_page_size}
  end

  defp unique_param(pairs, key, err) do
    if Enum.any?(pairs, fn {k, _} -> String.starts_with?(k, key <> "[") end),
      do: {:error, err},
      else: pick_single_value(pairs, key, err)
  end

  defp pick_single_value(pairs, key, err) do
    case for({^key, v} <- pairs, do: v) do
      [] -> {:ok, nil}
      [v] -> {:ok, v}
      _ -> {:error, err}
    end
  end

  defp parse_page_size(nil), do: {:ok, 25}

  defp parse_page_size(value) do
    if Regex.match?(~r/\A[0-9]+\z/, value) do
      case Integer.parse(value) do
        {n, ""} when n in 1..100 -> {:ok, n}
        _ -> {:error, :invalid_page_size}
      end
    else
      {:error, :invalid_page_size}
    end
  end

  defp error(conn, status, code), do: conn |> put_status(status) |> json(%{error: %{code: code}})
end

defmodule FootballMarketWeb.PortfolioController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market
  alias FootballMarket.Market.Portfolio
  alias FootballMarketWeb.ApiJSON

  plug :private_response

  def allocation(conn, _params) do
    respond(conn, Market.portfolio_allocation(conn.assigns[:authenticated_actor]))
  end

  def history(conn, _params) do
    case Portfolio.decode_history_query(conn.query_string) do
      {:ok, options} ->
        respond(conn, Market.portfolio_history(conn.assigns[:authenticated_actor], options))

      {:error, reason} ->
        error(conn, 400, reason)
    end
  end

  defp respond(conn, {:ok, data}), do: json(conn, %{data: ApiJSON.portfolio(data)})

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

defmodule FootballMarketWeb.ConditionalOrderController do
  use FootballMarketWeb, :controller
  alias FootballMarket.Market.Orders
  alias FootballMarketWeb.ApiJSON

  @fields ~w(player_id quantity maximum_unit_price expires_at)

  def create(conn, _params) do
    with :ok <- no_query(conn),
         {:ok, terms} <- parse_terms(conn.body_params),
         {:ok, order} <- Orders.create(conn.assigns[:authenticated_actor], terms) do
      conn
      |> put_resp_header("location", "/api/conditional-orders/" <> order.id)
      |> put_status(201)
      |> json(%{data: ApiJSON.conditional_order(order)})
    else
      failure -> error(conn, failure)
    end
  end

  def index(conn, _params) do
    with :ok <- no_query(conn),
         {:ok, orders} <- Orders.list(conn.assigns[:authenticated_actor]) do
      json(conn, %{data: Enum.map(orders, &ApiJSON.conditional_order/1)})
    else
      failure -> error(conn, failure)
    end
  end

  def show(conn, %{"id" => id}) do
    with :ok <- no_query(conn),
         {:ok, order} <- Orders.get(conn.assigns[:authenticated_actor], id) do
      json(conn, %{data: ApiJSON.conditional_order(order)})
    else
      failure -> error(conn, failure)
    end
  end

  def cancel(conn, %{"id" => id}) do
    with :ok <- no_query(conn),
         true <- conn.body_params == %{},
         {:ok, order} <- Orders.cancel(conn.assigns[:authenticated_actor], id) do
      json(conn, %{data: ApiJSON.conditional_order(order)})
    else
      false -> error(conn, {:error, :invalid_request})
      failure -> error(conn, failure)
    end
  end

  defp no_query(conn),
    do: if(conn.query_params == %{}, do: :ok, else: {:error, :invalid_request})

  defp parse_terms(params) when is_map(params) do
    if Enum.sort(Map.keys(params)) == Enum.sort(@fields) do
      {:ok, Map.new(@fields, fn key -> {String.to_existing_atom(key), params[key]} end)}
    else
      {:error, :invalid_request}
    end
  end

  defp parse_terms(_), do: {:error, :invalid_request}

  defp error(conn, {:error, %{kind: kind}}), do: error(conn, {:error, kind})

  defp error(conn, {:error, kind}) do
    status =
      case kind do
        :unauthenticated -> 401
        :invalid_request -> 400
        k when k in [:not_found, :player_not_found] -> 404
        :temporarily_unavailable -> 503
        _ -> 409
      end

    conn |> put_status(status) |> json(%{error: %{code: kind}})
  end
end

defmodule FootballMarketWeb.BusinessMetricsController do
  use FootballMarketWeb, :controller
  alias FootballMarket.BusinessMetrics

  def index(conn, _params) do
    conn = put_resp_header(conn, "cache-control", "private, no-store")

    case BusinessMetrics.snapshot(conn.assigns[:authenticated_actor]) do
      {:ok, snapshot} ->
        status = if is_nil(snapshot.as_of), do: 503, else: 200
        conn |> put_status(status) |> json(%{data: snapshot})

      {:error, :forbidden} ->
        conn |> put_status(403) |> json(%{error: %{code: "forbidden"}})

      {:error, :unauthenticated} ->
        conn |> put_status(401) |> json(%{error: %{code: "unauthenticated"}})
    end
  end
end

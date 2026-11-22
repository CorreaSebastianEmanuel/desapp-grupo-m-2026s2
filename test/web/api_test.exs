defmodule FootballMarketWeb.ApiTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :integration

  test "rejects unauthenticated and dual-credential requests to /api/*" do
    market = create_tradable_market!()

    conn = get(build_conn(), "/api/players")
    assert conn.status == 401
    assert json_response(conn, 401) == %{"error" => %{"code" => "unauthenticated"}}

    dual_conn = build_conn() |> with_jwt(market.investor) |> with_api_key(market.investor)
    assert get(dual_conn, "/api/players").status == 401
  end

  test "serves players, quotes, ranking, trades, transactions, portfolio, and conditional orders over REST API" do
    market = create_tradable_market!("1000.00")
    jwt_conn = build_conn() |> with_jwt(market.investor)
    key_conn = build_conn() |> with_api_key(market.investor)

    # Players list & detail
    players = jwt_conn |> get("/api/players?page_size=10") |> json_response(200)
    assert length(players["data"]) == 1
    assert players["pagination"]["returned_count"] == 1

    detail = key_conn |> get("/api/players/#{market.player.id}") |> json_response(200)
    assert detail["data"]["id"] == market.player.id
    assert detail["statistics"]["recorded_match_count"] == 1

    # Quotes current, history, at date
    current =
      jwt_conn |> get("/api/players/#{market.player.id}/quotes/current") |> json_response(200)

    assert current["data"]["id"] == market.quote.id

    history =
      jwt_conn |> get("/api/players/#{market.player.id}/quotes/history") |> json_response(200)

    assert length(history["data"]) == 2

    today = Date.to_iso8601(Date.utc_today())

    at_resp =
      jwt_conn
      |> get("/api/players/#{market.player.id}/quotes/at?date=#{today}")
      |> json_response(200)

    assert at_resp["data"]["id"] == market.quote.id

    # Ranking
    ranking = jwt_conn |> get("/api/ranking") |> json_response(200)
    assert length(ranking["data"]) == 1
    assert hd(ranking["data"])["player_id"] == market.player.id

    # Purchase & Sale
    buy =
      jwt_conn
      |> post("/api/purchases", %{
        "player_id" => market.player.id,
        "quantity" => 2,
        "request_key" => "api-buy-1"
      })
      |> json_response(200)

    assert buy["data"]["quantity"] == 2

    sell =
      jwt_conn
      |> post("/api/sales", %{
        "player_id" => market.player.id,
        "quantity" => 1,
        "request_key" => "api-sell-1"
      })
      |> json_response(200)

    assert sell["data"]["quantity"] == 1

    # Transactions & Portfolio analytics
    txs = jwt_conn |> get("/api/transactions?page_size=10") |> json_response(200)
    assert length(txs["data"]) == 2

    alloc = jwt_conn |> get("/api/portfolio/allocation") |> json_response(200)
    assert length(alloc["data"]["positions"]) == 1

    hist =
      jwt_conn |> get("/api/portfolio/history?from=#{today}&to=#{today}") |> json_response(200)

    assert length(hist["data"]["points"]) == 1

    # Conditional orders CRUD + cancel
    expires = DateTime.add(DateTime.utc_now(), 3600, :second) |> DateTime.to_iso8601()

    created =
      jwt_conn
      |> post("/api/conditional-orders", %{
        "player_id" => market.player.id,
        "quantity" => 1,
        "maximum_unit_price" => "1.00",
        "expires_at" => expires
      })
      |> json_response(201)

    order_id = created["data"]["id"]

    assert jwt_conn
           |> get("/api/conditional-orders")
           |> json_response(200)
           |> Map.fetch!("data")
           |> length() == 1

    assert jwt_conn
           |> get("/api/conditional-orders/#{order_id}")
           |> json_response(200)
           |> get_in(["data", "id"]) == order_id

    cancelled =
      jwt_conn |> post("/api/conditional-orders/#{order_id}/cancel", %{}) |> json_response(200)

    assert cancelled["data"]["status"] == "cancelled"
  end
end

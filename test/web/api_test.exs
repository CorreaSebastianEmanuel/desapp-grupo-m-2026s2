defmodule FootballMarketWeb.ApiTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :integration

  import ExUnit.CaptureLog

  alias FootballMarketWeb.RequestQuota

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

    other = build_conn() |> with_api_key(market.admin)

    assert other |> get("/api/conditional-orders/#{order_id}") |> json_response(404) ==
             %{"error" => %{"code" => "not_found"}}

    assert other |> post("/api/conditional-orders/#{order_id}/cancel", %{}) |> json_response(404) ==
             %{"error" => %{"code" => "not_found"}}

    cancelled =
      jwt_conn |> post("/api/conditional-orders/#{order_id}/cancel", %{}) |> json_response(200)

    assert cancelled["data"]["status"] == "cancelled"
  end

  test "public health endpoints report liveness and bounded dependency readiness", %{conn: conn} do
    alias FootballMarket.Infrastructure.Health

    assert conn |> get("/health/live") |> json_response(200) == %{"status" => "live"}

    ready = conn |> get("/health/ready") |> json_response(200)
    assert ready["status"] == "ready"
    assert ready["dependencies"]["postgresql"] == "ready"
    assert ready["dependencies"]["oban"] == "ready"
    assert ready["dependencies"]["redis"] in ["ready", "degraded"]

    assert %{status: :ready, dependencies: %{postgresql: :ready, oban: :ready, redis: :degraded}} =
             Health.readiness(%{
               postgresql: fn -> :ready end,
               oban: fn -> :ready end,
               redis: fn -> :unavailable end
             })

    assert %{status: :unavailable, dependencies: %{postgresql: :unavailable}} =
             Health.readiness(%{
               postgresql: fn -> :unavailable end,
               oban: fn -> :ready end,
               redis: fn -> :ready end
             })
  end

  test "shares the authenticated API quota across credentials and routes" do
    user = create_user!()
    jwt = with_jwt(build_conn(), user)
    key = with_api_key(build_conn(), user)

    assert get(put_req_header(key, "authorization", "Bearer invalid"), "/api/players").status ==
             401

    for _ <- 1..60 do
      assert get(jwt, "/api/players").status == 200
      assert get(key, "/api/transactions").status == 200
    end

    blocked = get(with_api_key(build_conn(), user), "/api/players")
    assert json_response(blocked, 429) == %{"error" => %{"code" => "rate_limited"}}
    assert [seconds] = get_resp_header(blocked, "retry-after")
    assert {delay, ""} = Integer.parse(seconds)
    assert delay in 1..60

    assert get(with_jwt(build_conn(), create_user!()), "/api/players").status == 200
    assert get(build_conn(), "/health/live").status == 200
  end

  test "fails closed on browser POSTs and admits only authenticated API requests during an outage" do
    supervisor = FootballMarket.Supervisor
    conn = with_api_key(build_conn(), create_user!())
    [secret] = get_req_header(conn, "x-api-key")
    :ok = Supervisor.terminate_child(supervisor, RequestQuota)
    on_exit(fn -> {:ok, _} = Supervisor.restart_child(supervisor, RequestQuota) end)

    assert post(build_conn(), "/sign-in", %{}).status == 503
    assert post(build_conn(), "/register", %{}).status == 503
    assert get(build_conn(), "/api/players").status == 401

    log = capture_log(fn -> assert get(conn, "/api/players").status == 200 end)
    assert log =~ "Authenticated API rate limiter unavailable"
    refute log =~ secret
  end

  test "returns generic errors for malformed trade inputs without logging parameter values" do
    conn = with_api_key(build_conn(), create_user!())
    [secret] = get_req_header(conn, "x-api-key")
    marker = "task050-secret-marker"
    previous_level = Logger.level()
    on_exit(fn -> Logger.configure(level: previous_level) end)
    Logger.configure(level: :debug)

    log =
      capture_log(fn ->
        assert conn
               |> post("/api/purchases", %{
                 "player_id" => "0123456789abcdef",
                 "quantity" => 1,
                 "request_key" => marker
               })
               |> json_response(400) == %{"error" => %{"code" => "invalid_request"}}

        assert conn
               |> post("/api/purchases", %{"authorization" => marker, "api_key" => secret})
               |> json_response(400) == %{"error" => %{"code" => "invalid_request"}}
      end)

    assert log =~ "Processing with FootballMarketWeb.PurchaseController"
    refute log =~ marker
    refute log =~ secret

    invalid_body = ~s({"password":) <> marker <> ~s(})
    json_conn = put_req_header(conn, "content-type", "application/json")

    assert {400, _headers, body} =
             assert_error_sent(400, fn -> post(json_conn, "/api/purchases", invalid_body) end)

    refute body =~ marker

    assert_raise ArgumentError, "malformed JSON request", fn ->
      FootballMarketWeb.RequestJSON.decode!(invalid_body)
    end
  end
end

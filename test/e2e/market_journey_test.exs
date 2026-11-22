defmodule FootballMarket.E2E.MarketJourneyTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :e2e

  alias FootballMarket.{Market, Quotes, Ranking, Statistics}
  alias FootballMarket.Market.OrderEvaluation

  test "complete end-to-end investor and administrator market lifecycle" do
    # 1. Admin & investor accounts + catalog + initial 100-token issuance
    admin = create_admin!("admin@e2e.example.com")
    investor = create_user!("investor@e2e.example.com")
    fixture = create_catalog_fixture!()
    {:ok, %{outcome: :issued}} = Market.initialize_player(fixture.player.id)
    {:ok, _} = Market.credit_account(investor.id, Decimal.new("1000.00"))
    {:ok, _} = Market.credit_account(admin.id, Decimal.new("1000.00"))

    # 2. Admin activates strategy and publishes a quote from recorded match statistics
    %{mapping: mapping} = create_active_strategy_and_mapping!(fixture.positions)
    published = record_performance_and_quote!(fixture, mapping.id, %{goals: 2, assists: 1})
    assert published.quote.performance_sequence == 1

    # 3. Verify ranking includes the quoted player
    assert {:ok, %{entries: [%{player_id: pid, position: 1}]}} = Ranking.read()
    assert pid == fixture.player.id

    # 4. Investor buys tokens via REST API
    jwt_conn = build_conn() |> with_jwt(investor)

    buy_resp =
      jwt_conn
      |> post("/api/purchases", %{
        "player_id" => fixture.player.id,
        "quantity" => 3,
        "request_key" => "e2e-buy-1"
      })
      |> json_response(200)

    assert buy_resp["data"]["quantity"] == 3

    # 5. Investor places a conditional buy order that executes automatically on recovery pass
    expires = DateTime.add(DateTime.utc_now(), 3600, :second) |> DateTime.to_iso8601()

    order_resp =
      jwt_conn
      |> post("/api/conditional-orders", %{
        "player_id" => fixture.player.id,
        "quantity" => 1,
        "maximum_unit_price" =>
          published.quote.unit_price
          |> Decimal.add(Decimal.new("10.00"))
          |> Decimal.to_string(:normal),
        "expires_at" => expires
      })
      |> json_response(201)

    order_id = order_resp["data"]["id"]
    assert :ok = OrderEvaluation.recover()

    final_order = jwt_conn |> get("/api/conditional-orders/#{order_id}") |> json_response(200)
    assert final_order["data"]["status"] == "executed"

    # 6. Investor sells 1 token and verifies live browser workspace & portfolio analytics
    sell_resp =
      jwt_conn
      |> post("/api/sales", %{
        "player_id" => fixture.player.id,
        "quantity" => 1,
        "request_key" => "e2e-sell-1"
      })
      |> json_response(200)

    assert sell_resp["data"]["quantity"] == 1

    alloc = jwt_conn |> get("/api/portfolio/allocation") |> json_response(200)
    assert hd(alloc["data"]["positions"])["quantity"] == 3

    browser_conn = build_conn() |> with_browser_session(investor)
    {:ok, _view, html} = live(browser_conn, "/portfolio")
    assert html =~ fixture.player.display_name
    assert {:ok, %{recorded_match_count: 1}} = Statistics.recorded_summary(fixture.player)
    assert {:ok, _} = Quotes.latest(fixture.player.id)
  end
end

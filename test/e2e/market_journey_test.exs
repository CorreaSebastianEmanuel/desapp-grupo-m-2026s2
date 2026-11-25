defmodule FootballMarket.E2E.MarketJourneyTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :e2e

  alias FootballMarket.{Catalog, Market, Quotes, Ranking, Statistics}
  alias FootballMarket.Market.OrderEvaluation
  alias FootballMarketWeb.PortfolioComponents

  @tag timeout: 120_000

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
    {:ok, portfolio, html} = live(browser_conn, "/portfolio")
    assert html =~ fixture.player.display_name
    GenServer.stop(portfolio.pid)
    assert {:ok, %{recorded_match_count: 1}} = Statistics.recorded_summary(fixture.player)
    assert {:ok, _} = Quotes.latest(fixture.player.id)

    assert_live_references(
      browser_conn,
      fixture.player.id,
      published.quote,
      buy_resp,
      final_order
    )

    assert_missing_quote_values(investor, fixture.player.id)
    assert_browser_parity(investor, fixture, published.quote)
  end

  defp assert_missing_quote_values(investor, player_id) do
    actor = actor_for(investor)
    assert {:ok, allocation} = Market.portfolio_allocation(actor)
    assert [position] = allocation.positions

    today = Date.utc_today()
    assert {:ok, history} = Market.portfolio_history(actor, %{from: today, to: today})
    assert [point] = history.points

    missing_totals = %{
      market_value: nil,
      unrealized_profit_loss: nil,
      total_profit_loss: nil,
      valuation_complete: false,
      missing_quote_player_ids: [player_id]
    }

    allocation = %{
      allocation
      | positions: [
          %{position | quote: nil, market_value: nil, unrealized_profit_loss: nil, weight: nil}
        ],
        totals: Map.merge(allocation.totals, missing_totals)
    }

    html =
      render_component(&PortfolioComponents.portfolio_tables/1,
        allocation: allocation,
        portfolio_history: %{history | points: [Map.merge(point, missing_totals)]}
      )

    document = LazyHTML.from_fragment(html)
    assert text_at(document, "#allocation-missing-quotes") =~ player_id
    assert text_at(document, "#portfolio-allocation-table tbody td:nth-child(5)") == "Sin datos"

    assert text_at(document, "#portfolio-allocation-table tbody td:last-child") =~
             "Sin cotización disponible"

    assert text_at(document, "#portfolio-history-table tbody td:nth-of-type(2)") == "Sin datos"
    assert text_at(document, "#portfolio-history-table tbody td:last-child") == player_id
  end

  defp text_at(document, selector),
    do: document |> LazyHTML.query(selector) |> LazyHTML.text() |> String.trim()

  defp assert_browser_parity(investor, fixture, quote) do
    spectator = create_user!("spectator@e2e.example.com")

    assert {:ok, second_player} =
             Catalog.create_player(%{
               team_id: fixture.player.team_id,
               position_id: fixture.player.position_id,
               catalog_identity: "saka-junior",
               display_name: "Bukayo Saka Junior"
             })

    assert {:ok, server} =
             start_supervised({Bandit, plug: @endpoint, ip: {127, 0, 0, 1}, port: 0})

    assert {:ok, {{127, 0, 0, 1}, port}} = ThousandIsland.listener_info(server)

    arguments = %{
      player: fixture.player.id,
      nextPlayer: second_player.id,
      name: fixture.player.display_name,
      filters: %{
        league_id: fixture.league.id,
        team_id: fixture.player.team_id,
        position_id: fixture.player.position_id
      },
      marketValue: Decimal.to_string(Decimal.mult(quote.unit_price, 2), :normal),
      tradingValue: Decimal.to_string(Decimal.mult(quote.unit_price, 4), :normal),
      date: Date.utc_today()
    }

    {output, status} =
      System.cmd("node", ["tools/openapi/e2e_parity.mjs", "http://127.0.0.1:#{port}"],
        env: [
          {"E2E_PARITY", Jason.encode!(arguments)},
          {"E2E_EMAIL", investor.email},
          {"E2E_PASSWORD", investor.password},
          {"E2E_SPECTATOR_EMAIL", spectator.email},
          {"E2E_SPECTATOR_PASSWORD", spectator.password}
        ],
        stderr_to_stdout: true
      )

    assert status == 0, output
    assert output == "E2E_PARITY status=complete\n"
  end

  defp assert_live_references(conn, player_id, quote, purchase, order) do
    date = DateTime.to_date(quote.effective_at)
    {:ok, card, _html} = live(conn, "/players?player_id=#{player_id}&date=#{date}")

    for selector <- ["#quote-provenance", "#dated-quote-provenance"] do
      details = card |> element(selector) |> render()
      assert details =~ quote.id
      assert details =~ quote.configuration_version_id
      assert details =~ quote.mapping_id
      assert details =~ quote.calculation_id
    end

    {:ok, transactions, _html} = live(conn, "/transactions")
    purchase_id = purchase["data"]["id"]

    assert transactions |> element("#transaction-#{purchase_id} details code") |> render() =~
             quote.id

    GenServer.stop(transactions.pid)

    {:ok, ranking, _html} = live(conn, "/ranking")
    ranking_details = ranking |> element("#ranking-player-#{player_id} details") |> render()
    assert ranking_details =~ quote.id
    assert ranking_details =~ quote.configuration_version_id
    GenServer.stop(ranking.pid)

    {:ok, orders, _html} = live(conn, "/conditional-orders")
    order_id = order["data"]["id"]
    assert orders |> element("#conditional-order-#{order_id}") |> render() =~ quote.id
    GenServer.stop(orders.pid)

    request_key = :sys.get_state(card.pid).socket.assigns.trade_key

    render_submit(card, "trade", %{
      "side" => "sell",
      "quantity" => "1",
      "request_key" => request_key
    })

    confirmation = card |> element("#trade-confirmation") |> render()
    assert confirmation =~ request_key
    assert confirmation =~ quote.id
    assert confirmation =~ quote.configuration_version_id
    assert confirmation =~ quote.mapping_id
    GenServer.stop(card.pid)
  end
end

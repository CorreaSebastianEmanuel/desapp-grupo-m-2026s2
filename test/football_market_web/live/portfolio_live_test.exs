defmodule FootballMarketWeb.PortfolioLiveTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias FootballMarket.{Catalog, Market, PurchasesCase}

  @endpoint FootballMarketWeb.Endpoint

  setup_all do
    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)

    on_exit(fn ->
      assert Application.fetch_env(:football_market, :initial_issuance_recipients) == previous,
             "portfolio tests leaked initial issuance configuration after module cleanup"
    end)

    :ok
  end

  setup do
    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)

    on_exit(fn ->
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end)

    :ok
  end

  test "authenticated portfolio displays the user's current positions and exact values" do
    buyer = account("portfolio-ui-buyer@example.com")
    owner = account("portfolio-ui-owner@example.com")
    %{team: team} = FootballMarket.CatalogCase.insert_hierarchy!()
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    {:ok, player} = Catalog.create_player(FootballMarket.CatalogCase.player_attrs(team, position))

    Application.put_env(:football_market, :initial_issuance_recipients, [owner.id])

    assert {:ok, _} = Market.initialize_player(player.id)
    PurchasesCase.fund(buyer, "100")
    actor = PurchasesCase.actor(buyer)

    assert {:ok, _} =
             Market.purchase(actor, %{
               player_id: player.id,
               quantity: 3,
               request_key: "portfolio-ui"
             })

    {:ok, view, _html} = live(authenticated_conn(buyer), "/portfolio")

    assert has_element?(view, "#portfolio-positions")
    assert has_element?(view, "a[href='/players?player_id=#{player.id}']", player.display_name)
    assert has_element?(view, "#portfolio-position-#{player.id}", player.display_name)
    assert has_element?(view, "#portfolio-position-#{player.id}", "3")
    assert has_element?(view, "#portfolio-position-#{player.id}", "1")
    assert has_element?(view, "#allocation-chart")
    assert has_element?(view, "#portfolio-history")
  end

  test "portfolio chart marks missing quote data as a gap, not zero" do
    point = %{
      date: ~D[2026-10-30],
      cutoff_at: ~U[2026-10-30 12:00:00Z],
      market_value: Decimal.new("1"),
      realized_profit_loss: Decimal.new(0),
      unrealized_profit_loss: Decimal.new("0"),
      purchase_expenditure: Decimal.new("1"),
      sale_proceeds: Decimal.new("0")
    }

    points = [
      point,
      %{point | date: ~D[2026-10-31], cutoff_at: ~U[2026-10-31 12:00:00Z], market_value: nil},
      %{
        point
        | date: ~D[2026-11-01],
          cutoff_at: ~U[2026-11-01 12:00:00Z],
          market_value: Decimal.new("2")
      }
    ]

    html =
      render_component(&FootballMarketWeb.WorkspaceComponents.history_chart/1, %{
        points: points,
        metric: :market_value,
        label: "Portfolio market value"
      })

    assert html =~ "Unknown"
    assert length(Regex.scan(~r/M[0-9.]+,[0-9.]+/, html)) == 2
    assert html =~ "Scale: 1 to 2 credits."
    assert html =~ "2026-10-30T12:00:00Z"

    incomplete_allocation =
      render_component(&FootballMarketWeb.WorkspaceComponents.portfolio_charts/1, %{
        allocation: %{
          positions: [%{player_name: "Alex Example", weight: nil}],
          totals: %{valuation_complete: false},
          as_of: ~U[2026-10-30 12:00:00Z]
        },
        allocation_unavailable: false,
        history: %{points: [], from: ~D[2026-10-30], to: ~D[2026-10-30]},
        history_unavailable: false
      })

    assert incomplete_allocation =~ "Unknown"

    assert incomplete_allocation =~
             "Allocation is unknown until every held player has a current quote."

    realized =
      render_component(&FootballMarketWeb.WorkspaceComponents.history_chart/1, %{
        points: points,
        metric: :realized_profit_loss,
        label: "Realized profit/loss"
      })

    assert realized =~ "<td>0</td>"
    refute realized =~ "<td>Unknown</td>"
  end

  test "portfolio charts offer accessible empty allocation and history states" do
    html =
      render_component(&FootballMarketWeb.WorkspaceComponents.portfolio_charts/1, %{
        allocation: %{positions: [], totals: %{}, as_of: ~U[2026-10-30 12:00:00Z]},
        allocation_unavailable: false,
        history: %{points: [], from: ~D[2026-10-01], to: ~D[2026-10-30]},
        history_unavailable: false
      })

    assert html =~ "No current holdings to allocate."
    assert html =~ "No portfolio history yet."
    refute html =~ "history-chart-market_value"
  end

  test "portfolio charts render accessible populated values and report unavailable reads" do
    point = %{
      date: ~D[2026-10-30],
      cutoff_at: ~U[2026-10-30 12:00:00Z],
      market_value: Decimal.new("4"),
      realized_profit_loss: Decimal.new("1"),
      unrealized_profit_loss: Decimal.new("2"),
      purchase_expenditure: Decimal.new("3"),
      sale_proceeds: Decimal.new("0")
    }

    html =
      render_component(&FootballMarketWeb.WorkspaceComponents.portfolio_charts/1, %{
        allocation: %{
          positions: [%{player_name: "Alex Example", weight: Decimal.new("1")}],
          totals: %{valuation_complete: true},
          as_of: ~U[2026-10-30 12:00:00Z]
        },
        allocation_unavailable: false,
        history: %{points: [point], from: point.date, to: point.date},
        history_unavailable: false
      })

    assert html =~ "Alex Example"
    assert html =~ "100.0%"
    assert html =~ "Portfolio market value by day"
    assert html =~ "Realized profit/loss by day"
    assert html =~ "Unrealized profit/loss by day"
    assert html =~ "2026-10-30T12:00:00Z"

    unavailable =
      render_component(&FootballMarketWeb.WorkspaceComponents.portfolio_charts/1, %{
        allocation: nil,
        allocation_unavailable: true,
        history: nil,
        history_unavailable: true
      })

    assert unavailable =~ "Current allocation is temporarily unavailable"
    assert unavailable =~ "Portfolio history is temporarily unavailable"
    refute unavailable =~ "No portfolio history yet"
  end

  test "player card preserves missing data and search-to-order links" do
    user = account("card@example.com")
    %{players: [player]} = FootballMarket.CatalogCase.insert_catalog!()
    {:ok, view, _} = live(authenticated_conn(user), "/players")
    view |> form("#player-catalog-search", player_search: player.display_name) |> render_submit()
    assert has_element?(view, "a[href='/players?player_id=#{player.id}']", "View player")

    assert has_element?(
             view,
             "a[href='/conditional-orders?player_id=#{player.id}']",
             "Create order"
           )

    {:ok, card, _} = live(authenticated_conn(user), "/players?player_id=#{player.id}")
    assert has_element?(card, "#player-card", player.team.name)
    assert has_element?(card, "#player-statistics", "Unknown")
    assert has_element?(card, "#player-quote-missing")
    assert has_element?(card, "#player-freshness", "never_checked")
    assert has_element?(card, "#player-card", "coverage may be incomplete")
    {:ok, missing, _} = live(authenticated_conn(user), "/players?player_id=invalid")
    assert has_element?(missing, "[role=alert]", "Player details are unavailable")
  end

  test "buy and sell forms use immutable retry terms and immediately reload owner positions" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
    PurchasesCase.fund(f.buyer, "100")
    PurchasesCase.fund(f.owner, "100")
    conn = authenticated_conn(f.buyer)
    {:ok, open_portfolio, _} = live(conn, "/portfolio")
    {:ok, view, _} = live(conn, "/players?player_id=#{f.player.id}")
    assert has_element?(view, "#player-quote", "Effective at")

    key =
      view
      |> element("#trade-form input[name=request_key]")
      |> render()
      |> then(&Regex.run(~r/value="([^"]+)"/, &1))
      |> List.last()

    assert render_submit(view, "trade", %{side: "invalid", quantity: "1", request_key: key}) =~
             "Choose Buy or Sell"

    assert render_submit(view, "trade", %{side: "buy", quantity: "1.5", request_key: key}) =~
             "positive integer"

    assert render_submit(view, "trade", %{side: "buy", quantity: "3", request_key: key}) =~
             "Trade confirmed"

    assert has_element?(view, "#trade-position-#{f.player.id}", "3 tokens")
    render_submit(view, "trade", %{side: "buy", quantity: "3", request_key: key})
    assert has_element?(view, "#trade-position-#{f.player.id}", "3 tokens")

    assert render_submit(view, "trade", %{side: "sell", quantity: "1", request_key: key}) =~
             "different terms"

    view |> element("#new-trade") |> render_click()
    view |> form("#trade-form", side: "sell", quantity: "1") |> render_submit()
    assert has_element?(view, "#trade-position-#{f.player.id}", "2 tokens")
    assert has_element?(open_portfolio, "#portfolio-position-#{f.player.id}", "2")
    {:ok, reconnected, _} = live(conn, "/portfolio")
    assert has_element?(reconnected, "#portfolio-position-#{f.player.id}", "2")
    other = account("other-positions@example.com")
    {:ok, other_view, _} = live(authenticated_conn(other), "/portfolio")
    send(other_view.pid, {:conditional_order_changed, "untrusted-id"})
    assert has_element?(other_view, "#no-positions")
    refute has_element?(other_view, "#portfolio-position-#{f.player.id}")

    assert {:ok, _} =
             Market.purchase(PurchasesCase.actor(f.buyer), %{
               player_id: f.player.id,
               quantity: 1,
               request_key: "external-conditional"
             })

    Phoenix.PubSub.broadcast(
      FootballMarket.PubSub,
      "conditional_orders:" <> f.buyer.id,
      {:conditional_order_changed, "hint"}
    )

    assert has_element?(view, "#trade-position-#{f.player.id}", "3 tokens")
    assert has_element?(reconnected, "#portfolio-position-#{f.player.id}", "3")
    refute has_element?(other_view, "#portfolio-position-#{f.player.id}")
  end

  test "business failures remain safe and allow starting a corrected trade" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
    {:ok, view, _} = live(authenticated_conn(f.buyer), "/players?player_id=#{f.player.id}")
    view |> form("#trade-form", side: "buy", quantity: "1") |> render_submit()
    assert has_element?(view, "#trade-error", "Insufficient credits")
    view |> element("#new-trade") |> render_click()
    view |> form("#trade-form", side: "sell", quantity: "1") |> render_submit()
    assert has_element?(view, "#trade-error")
    refute has_element?(view, "#trade-notice")
  end

  test "ranking and card routes require browser authentication" do
    for path <- ["/portfolio", "/players?player_id=" <> Ecto.UUID.generate(), "/ranking"] do
      conn = build_conn() |> get(path)
      assert redirected_to(conn, 303) =~ "/sign-in"
    end
  end

  test "ranking component preserves domain ordering and explicit states" do
    configuration = %{strategy_id: "balanced", formula_version: "1", id: Ecto.UUID.generate()}
    entries = for n <- [3, 1], do: %{player_id: Integer.to_string(n), unit_price: Decimal.new(n)}

    html =
      render_component(&FootballMarketWeb.WorkspaceComponents.ranking_view/1,
        ranking: %{configuration: configuration, entries: entries}
      )

    assert html =~ "Active strategy: balanced"
    assert [_, first, second] = Regex.run(~r/ranking-player-(3).*ranking-player-(1)/s, html)
    assert {first, second} == {"3", "1"}

    assert render_component(&FootballMarketWeb.WorkspaceComponents.ranking_view/1,
             ranking: %{configuration: configuration, entries: []}
           ) =~ "No eligible quotes"

    assert render_component(&FootballMarketWeb.WorkspaceComponents.ranking_view/1,
             error: "Ranking is temporarily unavailable."
           ) =~ "temporarily unavailable"

    {:ok, view, _} = live(authenticated_conn(account("ranking-empty@example.com")), "/ranking")
    assert has_element?(view, "#ranking", "Active strategy ranking")

    assert render_component(&FootballMarketWeb.WorkspaceComponents.ranking_view/1,
             error: "No active strategy configured."
           ) =~ "No active strategy configured"
  end

  defp authenticated_conn(user) do
    {:ok, anonymous} = FootballMarket.Accounts.BrowserSessions.create_anonymous()
    {:ok, handle} = FootballMarket.Accounts.BrowserSessions.authenticate(anonymous, user.id)

    build_conn()
    |> Plug.Test.init_test_session(%{browser_handle: handle})
    |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})
  end
end

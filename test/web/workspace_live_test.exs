defmodule FootballMarketWeb.WorkspaceLiveTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :integration

  test "renders all workspace LiveView tabs and executes live trade and order actions" do
    market = create_tradable_market!("1000.00")
    conn = build_conn() |> with_browser_session(market.investor)

    # /players list & player card
    {:ok, _view, html} = live(conn, "/players")
    assert html =~ market.player.display_name

    {:ok, card_view, card_html} = live(conn, "/players?player_id=#{market.player.id}")
    assert card_html =~ market.player.display_name
    assert card_html =~ Decimal.to_string(market.quote.unit_price, :normal)

    # Execute a live buy through the trade event
    trade_key = :sys.get_state(card_view.pid).socket.assigns.trade_key

    after_buy =
      render_submit(card_view, "trade", %{
        "side" => "buy",
        "quantity" => "2",
        "request_key" => trade_key
      })

    assert after_buy =~ "Operación confirmada."

    # /portfolio reflects the purchased position
    {:ok, _port_view, port_html} = live(conn, "/portfolio")
    assert port_html =~ market.player.display_name

    # /transactions reflects the purchase
    {:ok, _tx_view, tx_html} = live(conn, "/transactions")
    assert tx_html =~ market.player.display_name

    # /ranking lists the quoted player
    {:ok, _rank_view, rank_html} = live(conn, "/ranking")
    assert rank_html =~ market.player.display_name

    # /conditional-orders create and cancel via LiveView
    {:ok, order_view, _order_html} =
      live(conn, "/conditional-orders?player_id=#{market.player.id}")

    future =
      DateTime.add(DateTime.utc_now(), 3600, :second) |> Calendar.strftime("%Y-%m-%dT%H:%M")

    created_html =
      render_submit(order_view, "create_order", %{
        "player_id" => market.player.id,
        "quantity" => "1",
        "maximum_unit_price" => "1.00",
        "expires_at" => future
      })

    assert created_html =~ "Orden creada."
    assert created_html =~ "Pendiente"
  end

  test "keeps the workspace connected when a form event has malformed values or missing state" do
    market = create_tradable_market!()
    conn = with_browser_session(build_conn(), market.investor)
    {:ok, players, _} = live(conn, "/players")
    malformed = %{"nested" => "value"}

    assert is_binary(render_change(players, "search_players", %{"player_search" => malformed}))
    assert is_binary(render_change(players, "search_players", %{"league_id" => malformed}))
    assert is_binary(render_change(players, "quote_date", %{"date" => "2026-11-25"}))
    {:ok, card, _} = live(conn, "/players?player_id=#{market.player.id}")
    assert is_binary(render_change(card, "quote_date", %{"date" => malformed}))
    assert is_binary(render_change(card, "trade_preview", %{"quantity" => malformed}))

    assert render_submit(card, "trade", %{"side" => "buy", "quantity" => malformed}) =~
             "Ingresá una cantidad"

    {:ok, portfolio, _} = live(conn, "/portfolio")
    assert is_binary(render_change(portfolio, "portfolio_range", %{"from" => malformed}))

    {:ok, transactions, _} = live(conn, "/transactions")

    assert is_binary(
             render_change(transactions, "transaction_page_size", %{"page_size" => malformed})
           )

    {:ok, orders, _} = live(conn, "/conditional-orders")

    assert render_submit(orders, "create_order", %{"quantity" => malformed}) =~
             "Revisá el jugador"

    assert is_binary(render_click(orders, "cancel_order", %{}))
  end

  test "shows buy and sell confirmations, investor holdings, and operation history" do
    market = create_tradable_market!()
    conn = with_browser_session(build_conn(), market.investor)
    {:ok, card, _} = live(conn, "/players?player_id=#{market.player.id}")

    buy_request_key = :sys.get_state(card.pid).socket.assigns.trade_key

    buy_html =
      render_submit(card, "trade", %{
        "side" => "buy",
        "quantity" => "4",
        "request_key" => buy_request_key
      })

    assert buy_html =~ "Operación confirmada."
    assert buy_html =~ "Detalles de la operación confirmada"
    assert buy_html =~ "Precio unitario"
    assert buy_html =~ "Total"
    assert buy_html =~ "Cotización efectiva"

    buy_record = :sys.get_state(card.pid).socket.assigns.trade_record
    assert buy_record.type == "buy"

    render_click(card, "new_trade", %{})
    sell_request_key = :sys.get_state(card.pid).socket.assigns.trade_key

    sell_html =
      render_submit(card, "trade", %{
        "side" => "sell",
        "quantity" => "1",
        "request_key" => sell_request_key
      })

    assert sell_html =~ "Operación confirmada."
    sell_record = :sys.get_state(card.pid).socket.assigns.trade_record
    assert sell_record.type == "sell"

    {:ok, _portfolio, portfolio_html} = live(conn, "/portfolio")
    assert portfolio_html =~ "Cantidad"
    assert portfolio_html =~ "Costo promedio"
    assert portfolio_html =~ "Valor estimado"
    assert portfolio_html =~ "Ganancia/pérdida realizada"
    assert portfolio_html =~ "Ganancia/pérdida no realizada"
    assert portfolio_html =~ "3</td>"

    expected_quote =
      market.quote.unit_price |> Decimal.normalize() |> Decimal.to_string(:normal)

    assert portfolio_html =~ expected_quote
    assert portfolio_html =~ "0.00"

    {:ok, transactions, transactions_html} = live(conn, "/transactions")
    assert transactions_html =~ "Historial de operaciones"
    assert transactions_html =~ market.player.display_name
    assert transactions_html =~ buy_record.id
    assert transactions_html =~ sell_record.id
    assert transactions_html =~ market.quote.id
    assert transactions_html =~ "Compra"
    assert transactions_html =~ "Venta"

    paged_html =
      render_change(transactions, "transaction_page_size", %{"page_size" => "1"})

    assert paged_html =~ "id=\"transactions-next\""
    assert paged_html =~ "page_size=1"
  end

  test "shows a rejected purchase without a success confirmation" do
    market = create_tradable_market!("1.00")
    conn = with_browser_session(build_conn(), market.investor)
    {:ok, card, _} = live(conn, "/players?player_id=#{market.player.id}")

    html =
      render_submit(card, "trade", %{
        "side" => "buy",
        "quantity" => "99",
        "request_key" => :sys.get_state(card.pid).socket.assigns.trade_key
      })

    assert html =~ "No tenés créditos suficientes."
    refute html =~ "Operación confirmada."
    refute html =~ "trade-confirmation"
  end

  test "portfolio and operation history are scoped to the authenticated investor" do
    market = create_tradable_market!()

    {:ok, _purchase} =
      FootballMarket.Market.purchase(actor_for(market.investor), %{
        player_id: market.player.id,
        quantity: 2,
        request_key: "owner-only"
      })

    other_user = create_user!()
    conn = with_browser_session(build_conn(), other_user)

    {:ok, _portfolio, portfolio_html} = live(conn, "/portfolio")
    assert portfolio_html =~ "Tu portafolio empieza acá"
    refute portfolio_html =~ market.player.display_name

    {:ok, _transactions, transactions_html} = live(conn, "/transactions")
    assert transactions_html =~ "Todavía no hay operaciones."
    refute transactions_html =~ market.player.display_name
  end
end

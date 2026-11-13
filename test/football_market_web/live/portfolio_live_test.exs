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
    f = FootballMarket.QuotesCase.fixture()
    player = f.player
    FootballMarket.QuotesCase.dated_quote(f, DateTime.add(DateTime.utc_now(), -60), "1")
    PurchasesCase.fund(buyer, "100")
    actor = PurchasesCase.actor(buyer)

    assert {:ok, _} =
             Market.purchase(actor, %{
               player_id: player.id,
               quantity: 3,
               request_key: "portfolio-ui"
             })

    {:ok, view, _html} = live(authenticated_conn(buyer), "/portfolio")

    assert has_element?(view, "#credit-balance", "Créditos disponibles: 97.00")
    assert has_element?(view, "#portfolio-positions")
    assert has_element?(view, "a[href='/players?player_id=#{player.id}']", player.display_name)
    assert has_element?(view, "#portfolio-position-#{player.id}", player.display_name)
    assert has_element?(view, "#portfolio-position-#{player.id}", "3")
    assert has_element?(view, "#portfolio-position-#{player.id}", "1")
    assert has_element?(view, "#allocation-chart")
    assert has_element?(view, "#portfolio-history")
    assert has_element?(view, "#portfolio-history-range")

    assert has_element?(
             view,
             "#allocation-chart [role=alert]",
             "no está disponible temporalmente"
           )

    assert has_element?(
             view,
             "#portfolio-history [role=alert]",
             "no está disponible temporalmente"
           )

    assert has_element?(view, "#portfolio-tab-positions[aria-current=page]")
    assert has_element?(view, "#portfolio-panel-performance[hidden]")
    assert has_element?(view, "#portfolio-panel-details[hidden]")
    view |> element("#portfolio-tab-performance") |> render_click()
    refute has_element?(view, "#portfolio-panel-performance[hidden]")
    assert has_element?(view, "#portfolio-panel-positions[hidden]")
    view |> element("#portfolio-tab-details") |> render_click()
    refute has_element?(view, "#portfolio-panel-details[hidden]")

    today = Date.utc_today()

    view
    |> form("#portfolio-history-range",
      from: Date.to_iso8601(Date.add(today, -2)),
      to: Date.to_iso8601(today)
    )
    |> render_submit()

    assert has_element?(
             view,
             "#portfolio-history [role=alert]",
             "no está disponible temporalmente"
           )

    view
    |> form("#portfolio-history-range",
      from: Date.to_iso8601(today),
      to: Date.to_iso8601(Date.add(today, 1))
    )
    |> render_submit()

    assert has_element?(view, "#portfolio-range-invalid", "rango permitido")
    assert has_element?(view, "#portfolio-tab-details[aria-current=page]")
  end

  test "authenticated transaction history displays purchase details and paginates" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
    PurchasesCase.performance_quote!(f.player)
    PurchasesCase.fund(f.buyer, "100")

    for key <- ["history-one", "history-two"] do
      assert {:ok, _} =
               Market.purchase(PurchasesCase.actor(f.buyer), %{
                 player_id: f.player.id,
                 quantity: 1,
                 request_key: key
               })
    end

    {:ok, view, _html} = live(authenticated_conn(f.buyer), "/transactions?page_size=1")
    assert has_element?(view, "#transactions")
    assert has_element?(view, "#transaction-page-size")
    assert has_element?(view, "#transactions-next")
    assert has_element?(view, "#transactions tbody tr", f.player.display_name)
    assert has_element?(view, "#transactions tbody tr", "Compra")
    assert has_element?(view, "#transactions tbody tr", "Ver referencia")

    {:ok, first_page} =
      Market.transaction_history(PurchasesCase.actor(f.buyer), %{page_size: 1, cursor: nil})

    [first] = first_page.data
    assert has_element?(view, "#transaction-#{first.id}")
    refute has_element?(view, "#transaction-#{first.id}", first.quote_id)
    assert has_element?(view, "#transaction-#{first.id} td:nth-child(3)", "1")
    assert has_element?(view, "#transaction-#{first.id} td:nth-child(4)", "1")
    assert has_element?(view, "#transaction-#{first.id} td:nth-child(5)", "1")
    next_html = view |> element("#transactions-next") |> render()
    href = Regex.run(~r/href="([^"]+)"/, next_html) |> Enum.at(1) |> String.replace("&amp;", "&")
    {:ok, next_view, _html} = live(authenticated_conn(f.buyer), href)
    assert has_element?(next_view, "#transactions tbody tr", "Compra")

    {:ok, second_page} =
      Market.transaction_history(PurchasesCase.actor(f.buyer), %{
        page_size: 1,
        cursor: first_page.pagination.next_cursor
      })

    [second] = second_page.data
    refute first.id == second.id
    assert has_element?(next_view, "#transaction-#{second.id}")
    refute has_element?(next_view, "#transaction-#{first.id}")
    {:ok, owner, _} = live(authenticated_conn(f.owner), "/transactions")
    assert has_element?(owner, "#transactions-empty")
    refute has_element?(owner, "#transaction-#{first.id}")
    {:ok, mismatched, _} = live(authenticated_conn(f.owner), href)
    assert has_element?(mismatched, "#transactions [role=alert]", "no está disponible")
    refute has_element?(mismatched, "#transaction-#{second.id}")
  end

  test "initial issuer inventory is separate from an investor portfolio" do
    buyer = account("issuer-inventory-buyer@example.com")
    owner = account("issuer-inventory-owner@example.com")
    %{team: team} = FootballMarket.CatalogCase.insert_hierarchy!()
    {:ok, position} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    {:ok, player} = Catalog.create_player(FootballMarket.CatalogCase.player_attrs(team, position))

    Application.put_env(:football_market, :initial_issuance_recipients, [owner.id])
    assert {:ok, _} = Market.initialize_player(player.id)
    PurchasesCase.performance_quote!(player)
    PurchasesCase.fund(buyer, "100")

    assert {:ok, _} =
             Market.purchase(PurchasesCase.actor(buyer), %{
               player_id: player.id,
               quantity: 3,
               request_key: "issuer-inventory-ui"
             })

    {:ok, issuer_view, _} = live(authenticated_conn(owner), "/portfolio")
    assert has_element?(issuer_view, "#credit-balance", "Créditos disponibles: 3.00")
    assert has_element?(issuer_view, "#initial-issuer-inventory")

    assert has_element?(
             issuer_view,
             "#initial-issuer-inventory-#{player.id}",
             player.display_name
           )

    assert has_element?(issuer_view, "#initial-issuer-inventory-#{player.id}", "97")
    refute has_element?(issuer_view, "#portfolio-positions")
    assert has_element?(issuer_view, "#no-positions")

    assert has_element?(
             issuer_view,
             "#no-positions",
             "Todavía no tenés posiciones de operaciones"
           )

    {:ok, issuer_card, _} = live(authenticated_conn(owner), "/players?player_id=#{player.id}")
    assert has_element?(issuer_card, "#player-position-summary", "97 tokens")
    refute has_element?(issuer_card, "#player-position-summary", "Todavía no tenés tokens")
    refute has_element?(issuer_card, "#player-position-summary", "Valor estimado")
    refute has_element?(issuer_card, "#trade-form")

    {:ok, card} = Catalog.player_card(player.id)

    for unavailable <- [
          %{initial_recipient_unavailable: true},
          %{initial_recipient: true, issuer_inventory_unavailable: true},
          %{portfolio_unavailable: true}
        ] do
      html =
        render_component(
          &FootballMarketWeb.WorkspaceComponents.player_card/1,
          Map.merge(%{card: card, request_key: "unavailable-holdings"}, unavailable)
        )

      assert html =~ "Tus tenencias no están disponibles temporalmente"
      refute html =~ "Todavía no tenés tokens de este jugador"
    end

    {:ok, buyer_view, _} = live(authenticated_conn(buyer), "/portfolio")
    assert has_element?(buyer_view, "#credit-balance", "Créditos disponibles: 97.00")
    assert has_element?(buyer_view, "#portfolio-position-#{player.id}", "3")
    refute has_element?(buyer_view, "#initial-issuer-inventory")
    refute has_element?(buyer_view, "#initial-issuer-inventory-#{player.id}")

    {:ok, buyer_card, _} = live(authenticated_conn(buyer), "/players?player_id=#{player.id}")
    assert has_element?(buyer_card, "#player-position-summary", "3 tokens")
    assert has_element?(buyer_card, "#player-position-summary", "Valor estimado")

    assert {:ok, _} =
             Market.purchase(PurchasesCase.actor(buyer), %{
               player_id: player.id,
               quantity: 97,
               request_key: "issuer-inventory-exhausted"
             })

    send(issuer_card.pid, :portfolio_changed)
    assert has_element?(issuer_card, "#player-position-summary", "Todavía no tenés tokens")
    refute has_element?(issuer_card, "#player-position-summary", "97 tokens")
  end

  test "player card preserves search context and disables trades without a quote" do
    user = account("card@example.com")
    %{players: [player]} = FootballMarket.CatalogCase.insert_catalog!()
    {:ok, view, _} = live(authenticated_conn(user), "/players")
    view |> form("#player-catalog-search", player_search: player.display_name) |> render_change()
    assert has_element?(view, "a[href^='/players?player_id=#{player.id}']", "Ver ficha y operar")

    query = URI.encode_query(%{q: player.display_name})
    {:ok, card, _} = live(authenticated_conn(user), "/players?player_id=#{player.id}&#{query}")
    assert has_element?(card, "#player-card", player.team.name)

    assert has_element?(
             card,
             "#player-scraping-status",
             "Actualización automática no configurada para este jugador."
           )

    assert has_element?(card, "a[href^='/players?q=']", "Volver a resultados")
    refute has_element?(card, "#player-catalog-search")
    refute has_element?(card, "#trade-form")
    refute has_element?(card, "a[href^='/conditional-orders?player_id=']")

    assert has_element?(
             card,
             "#player-statistics-unavailable",
             "Todavía no hay estadísticas cargadas"
           )

    refute has_element?(card, "#player-statistics")
    assert has_element?(card, "#player-freshness")
    {:ok, missing, _} = live(authenticated_conn(user), "/players?player_id=invalid")
    assert has_element?(missing, "[role=alert]", "No se pudo cargar la ficha")

    {:ok, detail} = Catalog.player_card(player.id)

    unavailable =
      render_component(&FootballMarketWeb.WorkspaceComponents.player_card/1,
        card: detail,
        request_key: Ecto.UUID.generate(),
        quote_history_unavailable: true,
        dated_quote: :unavailable
      )

    assert unavailable =~ "El historial de cotizaciones no está disponible temporalmente"
    assert unavailable =~ "La consulta de cotización no está disponible temporalmente"
    refute unavailable =~ "No hay cotizaciones registradas"
    refute unavailable =~ "No hay cotización para esa fecha"
  end

  test "player details expose recorded statistics provenance and the exact selected dated quote" do
    f = FootballMarket.QuotesCase.fixture()
    day = Date.add(Date.utc_today(), -2)

    earlier =
      FootballMarket.QuotesCase.dated_quote(f, DateTime.new!(day, ~T[12:00:00.000000]), "1.25")

    later =
      FootballMarket.QuotesCase.dated_quote(
        f,
        DateTime.new!(Date.add(day, 1), ~T[12:00:00.000000]),
        "2.50"
      )

    {:ok, card} = Catalog.player_card(f.player.id)
    {:ok, view, _} = live(authenticated_conn(f.user), "/players?player_id=#{f.player.id}")
    assert has_element?(view, "#player-quote", "2.50")

    for value <- [
          later.id,
          later.configuration_version_id,
          later.mapping_id,
          later.calculation_id
        ] do
      refute has_element?(view, "#quote-provenance", value)
    end

    assert has_element?(view, "#quote-provenance", "Equilibrada · versión 1")
    assert has_element?(view, "#quote-provenance", "Rendimiento deportivo")

    statistics = view |> element("#player-statistics") |> render() |> LazyHTML.from_fragment()

    metrics = [
      {:minutes_played, "Minutos jugados", 123},
      {:goals, "Goles", 1},
      {:assists, "Asistencias", nil},
      {:shots_on_target, "Tiros al arco", nil},
      {:tackles, "Entradas", nil},
      {:interceptions, "Intercepciones", nil},
      {:saves, "Atajadas", nil},
      {:goals_conceded, "Goles recibidos en cancha", nil},
      {:yellow_cards, "Tarjetas amarillas", nil},
      {:red_cards, "Tarjetas rojas", nil}
    ]

    assert Enum.count(LazyHTML.query(statistics, "dd")) == 11
    assert has_element?(view, "#player-statistics dt", "Partidos registrados")

    assert statistics |> LazyHTML.query("div:first-child dd") |> LazyHTML.text() ==
             to_string(card.statistics.recorded_match_count)

    for {metric, label, value} <- metrics do
      selector = "[data-metric=#{metric}]"
      assert Map.fetch!(card.statistics, metric) == value
      assert statistics |> LazyHTML.query("#{selector} dt") |> LazyHTML.text() == label

      expected = if is_nil(value), do: "Desconocido", else: to_string(value)
      assert statistics |> LazyHTML.query("#{selector} dd") |> LazyHTML.text() == expected

      coverage = if is_nil(value), do: "Sin datos disponibles", else: "1 partidos con datos"
      assert statistics |> LazyHTML.query("#{selector} small") |> LazyHTML.text() == coverage
    end

    assert has_element?(view, "#player-statistics-coverage", "la cobertura puede ser parcial")

    refute has_element?(view, "#player-freshness", card.statistics.season_id)
    refute has_element?(view, "#player-freshness pre")
    assert has_element?(view, "#player-freshness", "cierre del mercado")
    refute has_element?(view, "#quote-history", earlier.id)
    refute has_element?(view, "#quote-history", later.id)
    assert_quote_details(view, "#quote-provenance", later)
    assert_quote_details(view, "#quote-history li", later, "2.50 créditos")
    assert_quote_details(view, "#quote-history li", earlier, "1.25 créditos")
    render_submit(view, "quote_date", %{"date" => Date.to_iso8601(day)})
    assert has_element?(view, "#quote-history [role=status]", "1.25 créditos")
    assert_quote_details(view, "#dated-quote-provenance", earlier)
    refute has_element?(view, "#dated-quote-provenance", earlier.id)
    refute has_element?(view, "#dated-quote-provenance", later.id)
    refute has_element?(view, "#quote-history [role=status]", "2.50 créditos")
    assert has_element?(view, "#quote-history [role=status]", "12:00:00 UTC")
    render_submit(view, "quote_date", %{"date" => Date.to_iso8601(Date.add(day, -1))})

    # Initial issuance may precede the selected dates, but must never select a later performance quote.
    refute has_element?(view, "#quote-history [role=status]", "2.50 créditos")
  end

  test "player detail blocks buying until a performance quote exists" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
    PurchasesCase.fund(f.buyer, "100")

    {:ok, view, _} = live(authenticated_conn(f.buyer), "/players?player_id=#{f.player.id}")

    assert has_element?(view, "#player-performance-quote-unavailable")
    assert has_element?(view, "#trade-actions button[name=side][value=buy][disabled]")

    assert {:error, %{kind: :quote_unavailable}} =
             Market.purchase(PurchasesCase.actor(f.buyer), %{
               player_id: f.player.id,
               quantity: 1,
               request_key: "purchase-before-performance-quote"
             })
  end

  test "buy and sell forms use immutable retry terms and immediately reload owner positions" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
    PurchasesCase.performance_quote!(f.player)
    PurchasesCase.fund(f.buyer, "100")
    PurchasesCase.fund(f.owner, "100")
    conn = authenticated_conn(f.buyer)
    {:ok, open_portfolio, _} = live(conn, "/portfolio")
    {:ok, view, _} = live(conn, "/players?player_id=#{f.player.id}")
    assert has_element?(view, "#player-quote", "Vigente desde")
    assert has_element?(view, "#quote-provenance")
    assert has_element?(view, "#quote-history")
    assert has_element?(view, "#player-freshness")
    assert has_element?(view, "#credit-balance", "Créditos disponibles:")
    assert has_element?(view, "#trade-actions button[name=side][value=buy]", "Comprar tokens")
    assert has_element?(view, "#trade-actions button[name=side][value=sell]", "Vender tokens")
    refute has_element?(view, "#trade-side")

    render_submit(view, "quote_date", %{"date" => "invalid-date"})
    assert has_element?(view, "#quote-history [role=alert]", "fecha válida")
    render_submit(view, "quote_date", %{"date" => Date.to_iso8601(Date.utc_today())})
    assert has_element?(view, "#quote-history [role=status]")

    key = trade_key(view)

    assert render_submit(view, "trade", %{side: "invalid", quantity: "1", request_key: key}) =~
             "Elegí comprar o vender"

    assert render_submit(view, "trade", %{side: "buy", quantity: "1.5", request_key: key}) =~
             "número entero"

    assert render_submit(view, "trade", %{side: "buy", quantity: "3", request_key: key}) =~
             "Operación confirmada"

    assert has_element?(view, "#trade-confirmation", "Cotización")

    {:ok, history} =
      Market.transaction_history(PurchasesCase.actor(f.buyer), %{page_size: 1, cursor: nil})

    [record] = history.data
    refute has_element?(view, "#trade-confirmation", record.id)
    refute has_element?(view, "#trade-confirmation", record.quote_id)
    refute has_element?(view, "#trade-confirmation", key)
    assert has_element?(view, "#trade-confirmation", "3.00 créditos")
    assert has_element?(view, "#trade-confirmation", "1.00 créditos")

    purchase = FootballMarket.Repo.get!(FootballMarket.Market.Purchase, record.id)

    confirmation =
      view
      |> element("#trade-confirmation")
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("dd")
      |> Enum.map(fn node -> node |> LazyHTML.text() |> String.trim() end)

    assert confirmation == [
             f.player.display_name,
             "Compra",
             "3",
             "1.00 créditos",
             "3.00 créditos",
             Calendar.strftime(purchase.completed_at, "%Y-%m-%d %H:%M:%S UTC"),
             Calendar.strftime(purchase.quote_effective_at, "%Y-%m-%d %H:%M:%S UTC"),
             "Equilibrada · versión #{purchase.rule_version}"
           ]

    assert has_element?(view, "#credit-balance", "Créditos disponibles: 97.00")
    assert has_element?(view, "#player-position-summary", "3 tokens")
    render_submit(view, "trade", %{side: "buy", quantity: "3", request_key: key})
    assert has_element?(view, "#player-position-summary", "3 tokens")

    assert render_submit(view, "trade", %{side: "sell", quantity: "1", request_key: key}) =~
             "otros datos"

    view |> element("#new-trade") |> render_click()

    render_submit(view, "trade", %{
      side: "sell",
      quantity: "1",
      request_key: trade_key(view)
    })

    assert has_element?(view, "#credit-balance", "Créditos disponibles: 98.00")
    assert has_element?(view, "#player-position-summary", "2 tokens")
    assert has_element?(open_portfolio, "#portfolio-position-#{f.player.id}", "2")
    {:ok, reconnected, _} = live(conn, "/portfolio")
    assert has_element?(reconnected, "#portfolio-position-#{f.player.id}", "2")
    other = account("other-positions@example.com")
    {:ok, other_view, _} = live(authenticated_conn(other), "/portfolio")
    assert has_element?(other_view, "#credit-balance", "Créditos disponibles: 0.00")
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

    assert has_element?(view, "#player-position-summary", "3 tokens")
    assert has_element?(reconnected, "#portfolio-position-#{f.player.id}", "3")
    refute has_element?(other_view, "#portfolio-position-#{f.player.id}")
  end

  defp assert_quote_details(view, selector, quote, text \\ nil) do
    actual =
      view
      |> element(selector, text)
      |> render()
      |> LazyHTML.from_fragment()
      |> LazyHTML.query("dd")
      |> Enum.map(fn node -> node |> LazyHTML.text() |> String.trim() end)

    assert actual == [
             Decimal.to_string(quote.unit_price, :normal) <> " créditos",
             Calendar.strftime(quote.effective_at, "%Y-%m-%d %H:%M:%S UTC"),
             "Equilibrada · versión #{quote.rule_version}",
             "Rendimiento deportivo registrado",
             Calendar.strftime(quote.inserted_at, "%Y-%m-%d %H:%M:%S UTC")
           ]
  end

  test "definitive buy and sale failures allow corrected quantities in the same session" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
    PurchasesCase.performance_quote!(f.player)
    PurchasesCase.fund(f.buyer, "3")
    PurchasesCase.fund(f.owner, "100")
    {:ok, view, _} = live(authenticated_conn(f.buyer), "/players?player_id=#{f.player.id}")
    original_key = trade_key(view)
    render_submit(view, "trade", %{side: "buy", quantity: "0", request_key: original_key})
    assert has_element?(view, "#trade-error")
    render_submit(view, "trade", %{side: "buy", quantity: "4", request_key: trade_key(view)})
    assert has_element?(view, "#trade-error", "créditos suficientes")
    refute trade_key(view) == original_key
    render_submit(view, "trade", %{side: "buy", quantity: "3", request_key: trade_key(view)})
    assert has_element?(view, "#player-position-summary", "3 tokens")
    view |> element("#new-trade") |> render_click()
    render_submit(view, "trade", %{side: "sell", quantity: "4", request_key: trade_key(view)})
    assert has_element?(view, "#trade-error")
    render_submit(view, "trade", %{side: "sell", quantity: "1", request_key: trade_key(view)})
    assert has_element?(view, "#player-position-summary", "2 tokens")
    view |> element("#new-trade") |> render_click()
    PurchasesCase.fund(f.buyer, "1000")
    render_submit(view, "trade", %{side: "buy", quantity: "101", request_key: trade_key(view)})
    assert has_element?(view, "#trade-error", "tokens disponibles")
    key = trade_key(view)
    render_submit(view, "trade", %{side: "buy", quantity: "1", request_key: key})
    render_submit(view, "trade", %{side: "buy", quantity: "1", request_key: key})
    assert has_element?(view, "#player-position-summary", "3 tokens")
    assert Repo.aggregate(FootballMarket.Market.Purchase, :count) == 2
    assert Repo.aggregate(FootballMarket.Market.Sale, :count) == 1
  end

  test "uncertain failures preserve the intent and request key until the same submission resolves" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
    PurchasesCase.fund(f.buyer, "100")
    key = Ecto.UUID.generate()

    socket = %Phoenix.LiveView.Socket{
      assigns: %{
        __changed__: %{},
        actor: %{account_id: f.buyer.id, session_id: Ecto.UUID.generate()},
        card: %{player: f.player},
        trade_key: key,
        trade_intent: nil,
        trade_complete: false
      }
    }

    {:ok, {:noreply, socket}} =
      Repo.transaction(fn ->
        FootballMarketWeb.WorkspaceLive.handle_event(
          "trade",
          %{"side" => "buy", "quantity" => "3", "request_key" => key},
          socket
        )
      end)

    assert socket.assigns.trade_key == key
    assert socket.assigns.trade_intent == {f.player.id, "buy", 3}

    assert {:noreply, ^socket} =
             FootballMarketWeb.WorkspaceLive.handle_event("new_trade", %{}, socket)

    {:noreply, changed} =
      FootballMarketWeb.WorkspaceLive.handle_event(
        "trade",
        %{"side" => "buy", "quantity" => "2", "request_key" => key},
        socket
      )

    assert changed.assigns.trade_error =~ "otros datos"
    assert changed.assigns.trade_key == key
    assert Repo.aggregate(FootballMarket.Market.Purchase, :count) == 0
  end

  test "ranking and card routes require browser authentication" do
    for path <- [
          "/portfolio",
          "/players?player_id=" <> Ecto.UUID.generate(),
          "/ranking",
          "/transactions"
        ] do
      conn = build_conn() |> get(path)
      assert redirected_to(conn, 303) =~ "/sign-in"
    end
  end

  test "ranking component preserves domain ordering and explicit states" do
    configuration = %{strategy_id: "balanced", formula_version: "1", id: Ecto.UUID.generate()}

    entries =
      for n <- [3, 1] do
        %{
          player_id: Integer.to_string(n),
          player_name: "Nombre real #{n}",
          quote_id: "quote-#{n}",
          effective_at: ~U[2026-11-02 12:00:00Z],
          unit_price: Decimal.new(n)
        }
      end

    html =
      render_component(&FootballMarketWeb.WorkspaceComponents.ranking_view/1,
        ranking: %{configuration: configuration, entries: entries}
      )

    text = html |> LazyHTML.from_fragment() |> LazyHTML.text() |> String.replace(~r/\s+/, " ")
    assert text =~ "Estrategia activa: Equilibrada"
    assert html =~ "Nombre real 3"
    refute html =~ configuration.id
    refute html =~ "quote-3"
    assert html =~ "2026-11-02 12:00:00 UTC"
    assert html =~ "Referencia de cotización"
    assert html =~ "class=\"ranking-reference\""
    assert [_, first, second] = Regex.run(~r/ranking-player-(3).*ranking-player-(1)/s, html)
    assert {first, second} == {"3", "1"}

    assert render_component(&FootballMarketWeb.WorkspaceComponents.ranking_view/1,
             ranking: %{configuration: configuration, entries: []}
           ) =~ "No hay cotizaciones válidas"

    assert render_component(&FootballMarketWeb.WorkspaceComponents.ranking_view/1,
             error: "Ranking is temporarily unavailable."
           ) =~ "temporarily unavailable"

    {:ok, view, _} = live(authenticated_conn(account("ranking-empty@example.com")), "/ranking")
    assert has_element?(view, "#ranking", "Ranking de estrategia activa")

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

  defp trade_key(view) do
    view
    |> element("#trade-form input[name=request_key]")
    |> render()
    |> then(&Regex.run(~r/value="([^"]+)"/, &1))
    |> List.last()
  end
end

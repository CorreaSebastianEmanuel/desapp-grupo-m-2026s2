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
  end

  test "authenticated transaction history displays purchase details and paginates" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
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
    assert has_element?(view, "#transaction-#{first.id}", first.quote_id)
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
    assert has_element?(buyer_view, "#no-initial-issuer-inventory")
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
        label: "Valor de mercado del portafolio"
      })

    assert html =~ "Sin datos"
    assert length(Regex.scan(~r/M[0-9.]+,[0-9.]+/, html)) == 2
    assert html =~ "Escala: 1 a 2 créditos."
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

    assert incomplete_allocation =~ "Sin datos"

    assert incomplete_allocation =~
             "La distribución estará disponible cuando todos tus jugadores tengan una cotización actual."

    realized =
      render_component(&FootballMarketWeb.WorkspaceComponents.history_chart/1, %{
        points: points,
        metric: :realized_profit_loss,
        label: "Ganancia/pérdida realizada"
      })

    assert realized =~ "<td>0</td>"
    refute realized =~ "<td>Sin datos</td>"
  end

  test "portfolio charts offer accessible empty allocation and history states" do
    html =
      render_component(&FootballMarketWeb.WorkspaceComponents.portfolio_charts/1, %{
        allocation: %{positions: [], totals: %{}, as_of: ~U[2026-10-30 12:00:00Z]},
        allocation_unavailable: false,
        history: %{points: [], from: ~D[2026-10-01], to: ~D[2026-10-30]},
        history_unavailable: false
      })

    assert html =~ "No hay posiciones para mostrar."
    assert html =~ "Todavía no hay movimientos."
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
    assert html =~ "Valor de mercado del portafolio por día"
    assert html =~ "Ganancia/pérdida realizada por día"
    assert html =~ "Ganancia/pérdida no realizada por día"
    assert html =~ "2026-10-30T12:00:00Z"

    unavailable =
      render_component(&FootballMarketWeb.WorkspaceComponents.portfolio_charts/1, %{
        allocation: nil,
        allocation_unavailable: true,
        history: nil,
        history_unavailable: true
      })

    assert unavailable =~ "La distribución no está disponible temporalmente"
    assert unavailable =~ "El historial del portafolio no está disponible temporalmente"
    refute unavailable =~ "Todavía no hay movimientos"
  end

  test "player card preserves search context and disables trades without a quote" do
    user = account("card@example.com")
    %{players: [player]} = FootballMarket.CatalogCase.insert_catalog!()
    {:ok, view, _} = live(authenticated_conn(user), "/players")
    view |> form("#player-catalog-search", player_search: player.display_name) |> render_submit()
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
          later.player_id,
          later.rule_id,
          later.configuration_version_id,
          later.mapping_id,
          later.calculation_id,
          to_string(later.performance_sequence)
        ] do
      assert has_element?(view, "#quote-provenance", value)
    end

    statistics = view |> element("#player-statistics") |> render() |> LazyHTML.from_fragment()

    expected_statistics =
      [
        card.statistics.recorded_match_count,
        card.statistics.minutes_played,
        card.statistics.goals,
        card.statistics.assists
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&to_string/1)

    assert Enum.map(LazyHTML.query(statistics, "dd"), &LazyHTML.text/1) == expected_statistics
    assert is_nil(card.statistics.assists)
    refute has_element?(view, "#player-statistics dt", "Asistencias")

    assert has_element?(view, "#player-freshness", card.statistics.season_id)
    assert has_element?(view, "#player-freshness", to_string(card.statistics.coverage))

    for value <- [
          card.statistics_status.scope.player_id,
          card.statistics_status.scope.season_id,
          card.statistics_status.scope.league_code,
          card.statistics_status.refresh.state,
          card.statistics_status.freshness,
          card.statistics_status.source_mode,
          to_string(card.statistics_status.ttl_seconds),
          card.statistics_status.valuation.state
        ] do
      assert has_element?(view, "#player-freshness pre", value)
    end

    assert has_element?(view, "#quote-history", earlier.id)
    assert has_element?(view, "#quote-history", later.id)
    assert_quote_details(view, "#quote-provenance", later)
    assert_quote_details(view, "#quote-history li", later, later.id)
    assert_quote_details(view, "#quote-history li", earlier, earlier.id)
    render_submit(view, "quote_date", %{"date" => Date.to_iso8601(day)})
    assert has_element?(view, "#quote-history [role=status]", "1.25 créditos")
    assert_quote_details(view, "#dated-quote-provenance", earlier)
    assert has_element?(view, "#dated-quote-provenance", earlier.id)
    refute has_element?(view, "#dated-quote-provenance", later.id)
    refute has_element?(view, "#quote-history [role=status]", "2.50 créditos")
    assert has_element?(view, "#quote-history [role=status]", "12:00:00 UTC")
    render_submit(view, "quote_date", %{"date" => Date.to_iso8601(Date.add(day, -1))})

    # Initial issuance may precede the selected dates, but must never select a later performance quote.
    refute has_element?(view, "#quote-history [role=status]", "2.50 créditos")
  end

  test "buy and sell forms use immutable retry terms and immediately reload owner positions" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
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
    assert has_element?(view, "#trade-confirmation", record.id)
    assert has_element?(view, "#trade-confirmation", record.quote_id)
    assert has_element?(view, "#trade-confirmation", key)
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
             purchase.id,
             purchase.player_id,
             purchase.buyer_id,
             purchase.recipient_id,
             key,
             "Compra",
             "3",
             "1.00 créditos",
             "3.00 créditos",
             Calendar.strftime(purchase.completed_at, "%Y-%m-%d %H:%M:%S UTC"),
             Calendar.strftime(purchase.quote_effective_at, "%Y-%m-%d %H:%M:%S UTC"),
             purchase.quote_id,
             "#{purchase.rule_id} · versión #{purchase.rule_version}",
             to_string(purchase.configuration_version_id),
             to_string(purchase.mapping_id),
             to_string(purchase.performance_sequence)
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
             quote.id,
             quote.player_id,
             "#{quote.rule_id} · versión #{quote.rule_version}",
             quote.configuration_version_id,
             quote.mapping_id,
             quote.calculation_id,
             to_string(quote.performance_sequence),
             Calendar.strftime(quote.inserted_at, "%Y-%m-%d %H:%M:%S UTC")
           ]
  end

  test "business failures remain safe and allow starting a corrected trade" do
    f = FootballMarket.MarketCase.fixture()
    assert {:ok, _} = Market.initialize_player(f.player.id)
    {:ok, view, _} = live(authenticated_conn(f.buyer), "/players?player_id=#{f.player.id}")

    render_submit(view, "trade", %{
      side: "buy",
      quantity: "1",
      request_key: trade_key(view)
    })

    assert has_element?(view, "#trade-error", "créditos suficientes")
    view |> element("#new-trade") |> render_click()

    render_submit(view, "trade", %{
      side: "sell",
      quantity: "1",
      request_key: trade_key(view)
    })

    assert has_element?(view, "#trade-error")
    refute has_element?(view, "#trade-notice")
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
          quote_id: "quote-#{n}",
          effective_at: ~U[2026-11-02 12:00:00Z],
          unit_price: Decimal.new(n)
        }
      end

    html =
      render_component(&FootballMarketWeb.WorkspaceComponents.ranking_view/1,
        ranking: %{configuration: configuration, entries: entries}
      )

    assert html =~ "Estrategia activa: balanced"
    assert html =~ "quote-3"
    assert html =~ "2026-11-02 12:00:00 UTC"
    assert html =~ "Referencia de cotización"
    assert html =~ "<details>"
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

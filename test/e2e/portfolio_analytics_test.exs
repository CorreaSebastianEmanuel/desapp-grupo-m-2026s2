defmodule FootballMarket.E2E.PortfolioAnalyticsTest do
  use ExUnit.Case, async: false
  import Phoenix.ConnTest, only: [build_conn: 0]
  require Phoenix.LiveViewTest
  @endpoint FootballMarketWeb.Endpoint
  @moduletag :e2e
  @tag timeout: 170_000
  alias FootballMarket.{Accounts, Market, MarketCase, PurchasesCase, SalesCase}

  test "real authenticated HTTP reports persisted trading value and flows without mutating state" do
    original = Application.fetch_env(:football_market, :initial_issuance_recipients)

    try do
      FootballMarket.E2E.Runtime.with_runtime!(fn base ->
        f = MarketCase.fixture()
        assert {:ok, _} = Market.initialize_player(f.player.id)
        PurchasesCase.fund(f.buyer, "100")
        PurchasesCase.fund(f.owner, "100")
        assert {:ok, _} = PurchasesCase.purchase(f, "analytics-runtime-buy", 3)
        assert {:ok, _} = SalesCase.sale(f, "analytics-runtime-sale", 1)
        {:ok, jwt} = Accounts.Authentication.issue(f.buyer.id)
        {:ok, owner_jwt} = Accounts.Authentication.issue(f.owner.id)
        before = {SalesCase.snapshot(), MarketCase.snapshot()}

        assert {401, _} = get(base, "/api/portfolio/history?from=invalid", nil)
        assert {200, %{"data" => allocation}} = get(base, "/api/portfolio/allocation", jwt)
        assert [position] = allocation["positions"]
        assert position["quantity"] == 2
        assert position["quote"]["unit_price"] == "1.00"
        assert Decimal.equal?(allocation["totals"]["market_value"], "2")
        assert Decimal.equal?(allocation["totals"]["purchase_expenditure"], "3")
        assert Decimal.equal?(allocation["totals"]["sale_proceeds"], "1")
        assert Decimal.equal?(allocation["totals"]["total_profit_loss"], "0")

        assert {200, %{"data" => %{"positions" => []}}} =
                 get(base, "/api/portfolio/allocation", owner_jwt)

        today = Date.to_iso8601(Date.utc_today())

        assert {200, %{"data" => %{"points" => [point]}}} =
                 get(base, "/api/portfolio/history?from=#{today}", jwt)

        assert point["partial"]
        assert Decimal.equal?(point["market_value"], "2")
        assert before == {SalesCase.snapshot(), MarketCase.snapshot()}
      end)
    after
      case original do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end
  end

  @tag timeout: 170_000
  test "real browser searches creates an executed order sells tokens and reads active ranking" do
    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)

    try do
      FootballMarket.E2E.Runtime.with_runtime!(fn base ->
        assert FootballMarket.E2E.Fixtures.market_browser!(base) == :ok
      end)
    after
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end
  end

  @tag timeout: 170_000
  test "portfolio tables preserve exact empty open closed and incomplete financial projections" do
    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)

    try do
      FootballMarket.E2E.Runtime.with_runtime!(fn _base ->
        f = MarketCase.fixture()
        assert {:ok, _} = Market.initialize_player(f.player.id)
        PurchasesCase.fund(f.buyer, "100")
        PurchasesCase.fund(f.owner, "100")
        conn = authenticated_conn(f.buyer)
        actor = PurchasesCase.actor(f.buyer)
        today = Date.utc_today()
        path = "/portfolio?from=#{today}&to=#{today}"

        empty = portfolio_html(conn, path)
        assert html_has?(empty, "#no-positions")
        assert html_has?(empty, "#allocation-empty")
        assert_allocation_totals(empty, actor)
        assert_history_values(empty, actor, today)
        refute html_has?(empty, "#portfolio-allocation-table")

        assert {:ok, _} = PurchasesCase.purchase(f, "table-buy", 3)
        assert {:ok, _} = SalesCase.sale(f, "table-partial-sale", 1)
        opened = portfolio_html(conn, path)
        assert_allocation_totals(opened, actor)
        assert_history_values(opened, actor, today)

        assert Enum.take(cells(opened, "#portfolio-allocation-table tbody td"), 7) ==
                 ["2", "1", "2", "2", "0", "0", "100%"]

        {:ok, quote} = FootballMarket.Quotes.latest(f.player.id)
        refute html_has?(opened, "#portfolio-allocation-table", quote.id)
        assert html_has?(opened, "#portfolio-allocation-table", f.player.display_name)

        {:ok, page} = Market.transaction_history(actor, %{page_size: 100, cursor: nil})

        snapshot = %{
          as_of: DateTime.utc_now(),
          range: %{from: today, to: today},
          transactions: page.data,
          quotes: [],
          players: %{f.player.id => f.player.display_name}
        }

        projection = FootballMarket.Market.Analytics.Projection
        allocation = projection.build(snapshot, :allocation)
        history = projection.build(snapshot, :history)

        incomplete =
          Phoenix.LiveViewTest.render_component(
            &FootballMarketWeb.WorkspaceComponents.portfolio_tables/1,
            allocation: allocation,
            portfolio_history: history
          )

        assert Enum.take(cells(incomplete, "#portfolio-allocation-totals dd"), 8) ==
                 financial_values(allocation.totals)

        assert Enum.slice(cells(incomplete, "#portfolio-history-table tbody td"), 1, 8) ==
                 financial_values(hd(history.points))

        assert Enum.take(cells(incomplete, "#portfolio-allocation-table tbody td"), 7) ==
                 ["2", "1", "2", "Sin datos", "0", "Sin datos", "Sin datos"]

        assert html_has?(incomplete, "#allocation-missing-quotes", f.player.id)
        assert html_has?(incomplete, "#portfolio-history-table tbody", "Incompleta")
        assert html_has?(incomplete, "#portfolio-history-table tbody", f.player.id)

        assert {:ok, _} = SalesCase.sale(f, "table-final-sale", 2)
        closed = portfolio_html(conn, path)
        assert html_has?(closed, "#no-positions")
        assert html_has?(closed, "#allocation-empty")
        refute html_has?(closed, "#portfolio-allocation-table")
        assert_allocation_totals(closed, actor)
        assert_history_values(closed, actor, today)

        assert Enum.take(cells(closed, "#portfolio-allocation-totals dd"), 4) ==
                 ["0", "0", "3", "3"]
      end)
    after
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end
  end

  defp assert_allocation_totals(view, actor) do
    {:ok, allocation} = Market.portfolio_allocation(actor)
    expected = financial_values(allocation.totals)
    assert Enum.take(cells(view, "#portfolio-allocation-totals dd"), 8) == expected
    completeness = if allocation.totals.valuation_complete, do: "Completa", else: "Incompleta"
    assert List.last(cells(view, "#portfolio-allocation-totals dd")) == completeness
  end

  defp assert_history_values(view, actor, today) do
    {:ok, %{points: [point]}} = Market.portfolio_history(actor, %{from: today, to: today})
    assert cells(view, "#portfolio-history-table tbody th") == [Date.to_iso8601(today)]

    assert Enum.slice(cells(view, "#portfolio-history-table tbody td"), 1, 8) ==
             financial_values(point)

    assert html_has?(view, "#portfolio-history-table tbody", "parcial")
  end

  defp financial_values(data) do
    Enum.map(
      ~w(market_value cost_basis purchase_expenditure sale_proceeds net_invested realized_profit_loss unrealized_profit_loss total_profit_loss)a,
      fn key ->
        case Map.fetch!(data, key) do
          nil -> "Sin datos"
          amount -> amount |> Decimal.normalize() |> Decimal.to_string(:normal)
        end
      end
    )
  end

  defp cells(view, selector) do
    view
    |> LazyHTML.from_fragment()
    |> LazyHTML.query(selector)
    |> Enum.map(fn node -> node |> LazyHTML.text() |> String.trim() end)
  end

  defp portfolio_html(conn, path) do
    conn |> Phoenix.ConnTest.get(path) |> Phoenix.ConnTest.html_response(200)
  end

  defp html_has?(html, selector, text \\ nil) do
    nodes = html |> LazyHTML.from_fragment() |> LazyHTML.query(selector)

    if text,
      do: Enum.any?(nodes, &String.contains?(LazyHTML.text(&1), text)),
      else: not Enum.empty?(nodes)
  end

  defp authenticated_conn(user) do
    {:ok, anonymous} = Accounts.BrowserSessions.create_anonymous()
    {:ok, handle} = Accounts.BrowserSessions.authenticate(anonymous, user.id)

    build_conn()
    |> Plug.Test.init_test_session(%{browser_handle: handle})
    |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})
  end

  defp get(base, path, jwt) do
    headers = if jwt, do: [{~c"authorization", String.to_charlist("Bearer " <> jwt)}], else: []

    assert {:ok, {{_, status, _}, _, body}} =
             :httpc.request(:get, {String.to_charlist(base <> path), headers}, [timeout: 5_000],
               body_format: :binary
             )

    {status, Jason.decode!(body)}
  end
end

defmodule FootballMarketWeb.WorkspaceNavigationTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint FootballMarketWeb.Endpoint
  test "both areas share identity and one active destination without invented finances" do
    user = account()
    {:ok, anon} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anon, user.id)

    for {path, heading, expectation} <- [
          {"/portfolio", "Portafolio", :empty_portfolio},
          {"/transactions", "Historial de operaciones", :empty_transactions},
          {"/conditional-orders", "Órdenes condicionales", :page}
        ] do
      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{browser_handle: handle})
        |> Plug.Conn.put_private(:live_view_connect_info, %{
          session: %{"browser_handle" => handle}
        })

      {:ok, view, html} = live(conn, path)
      assert html =~ user.email
      assert has_element?(view, ~s(a.skip-link[href="#workspace-main"]))
      assert has_element?(view, ~s(main#workspace-main[tabindex="-1"]))
      assert has_element?(view, ~s(nav a[href="/players"][data-phx-link="redirect"]))
      assert has_element?(view, "h1", heading)
      active_label = if path == "/transactions", do: "Operaciones", else: heading
      assert has_element?(view, "a[aria-current=page]", active_label)

      assert length(
               view
               |> element(~s(nav[aria-label="Espacio de trabajo"]))
               |> render()
               |> String.split("aria-current=\"page\"")
             ) ==
               2

      case expectation do
        :page ->
          assert has_element?(view, "#conditional-order-form")
          refute html =~ "not available yet"

        :empty_portfolio ->
          assert has_element?(view, "#no-positions")
          refute has_element?(view, "#portfolio-positions")
          assert has_element?(view, ~s(.empty-state a[href="/players"]), "Explorar jugadores")

        :empty_transactions ->
          assert has_element?(view, "#transactions-empty")
      end

      refute html =~ "Buy"
      refute html =~ handle
    end
  end
end

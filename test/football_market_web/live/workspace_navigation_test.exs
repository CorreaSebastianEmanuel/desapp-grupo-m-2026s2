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

    for {path, heading} <- [
          {"/portfolio", "Portfolio"},
          {"/conditional-orders", "Conditional orders"}
        ] do
      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{browser_handle: handle})
        |> Plug.Conn.put_private(:live_view_connect_info, %{
          session: %{"browser_handle" => handle}
        })

      {:ok, view, html} = live(conn, path)
      assert html =~ user.email
      assert has_element?(view, "h1", heading)
      assert has_element?(view, "a[aria-current=page]", heading)

      assert length(view |> element("nav") |> render() |> String.split("aria-current=\"page\"")) ==
               2

      assert html =~ "not available yet"
      refute html =~ "Buy"
      refute html =~ handle
    end
  end
end

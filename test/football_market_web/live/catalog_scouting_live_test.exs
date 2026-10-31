defmodule FootballMarketWeb.CatalogScoutingLiveTest do
  use FootballMarket.BrowserSessionCase

  @moduletag :integration

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint FootballMarketWeb.Endpoint

  test "a catalog miss reports that scouting is unavailable when no trusted scope is configured" do
    user = account("catalog-scouting@example.com")
    {:ok, view, _html} = live(authenticated_conn(user), "/players")

    view
    |> form("#player-catalog-search", player_search: "Messi")
    |> render_submit()

    assert has_element?(
             view,
             "#catalog-scout-status[role=status]",
             "trusted catalog sources are not configured"
           )

    assert has_element?(view, ".catalog-hint", "No players found")
  end

  defp authenticated_conn(user) do
    {:ok, anonymous} = FootballMarket.Accounts.BrowserSessions.create_anonymous()
    {:ok, handle} = FootballMarket.Accounts.BrowserSessions.authenticate(anonymous, user.id)

    build_conn()
    |> Plug.Test.init_test_session(%{browser_handle: handle})
    |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})
  end
end

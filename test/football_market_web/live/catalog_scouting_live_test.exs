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
             "no hay fuentes configuradas"
           )

    assert has_element?(view, ".catalog-hint", "No encontramos jugadores")
  end

  test "catalog browsing combines name and labeled filters and retains page state through detail navigation" do
    fixture = FootballMarket.CatalogFilterCase.build!()
    user = account("catalog-parity@example.com")

    query =
      URI.encode_query(%{
        q: "Tie",
        league_id: fixture.target.team.season.league.id,
        team_id: fixture.target.team.id,
        position_id: fixture.target.position.id,
        page_size: 1
      })

    {:ok, view, _html} = live(authenticated_conn(user), "/players?#{query}")

    assert has_element?(view, "#catalog-league", fixture.target.team.season.league.name)
    assert has_element?(view, "#catalog-team", fixture.target.team.name)
    assert has_element?(view, "#catalog-position", fixture.target.position.name)
    assert has_element?(view, "#catalog-next")
    assert has_element?(view, "#player-search-results tbody tr")

    send(
      view.pid,
      {:catalog_scout_changed, FootballMarket.Catalog.Scouting.normalize_identity("Tie")}
    )

    refute has_element?(view, "#player-search-results tbody tr:nth-child(2)")

    next_html = view |> element("#catalog-next") |> render()
    assert next_html =~ "cursor="
    assert next_html =~ "league_id="
    assert next_html =~ "team_id="
    assert next_html =~ "position_id="
    assert next_html =~ "q=Tie"
    assert next_html =~ "page_size=1"

    href = Regex.run(~r/href="([^"]+)"/, next_html) |> Enum.at(1) |> String.replace("&amp;", "&")
    next_params = href |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query()

    {:ok, next_view, _html} =
      live(authenticated_conn(user), "/players?" <> URI.encode_query(next_params))

    detail_link = render(element(next_view, "a[href^='/players?player_id=']"))
    assert detail_link =~ "cursor="
    assert detail_link =~ "league_id="
    assert detail_link =~ "team_id="
    assert detail_link =~ "position_id="
    assert detail_link =~ "q=Tie"

    {:ok, invalid_view, _html} = live(authenticated_conn(user), "/players?league_id=invalid")
    assert has_element?(invalid_view, "[role=alert]", "búsqueda no está disponible")
  end

  defp authenticated_conn(user) do
    {:ok, anonymous} = FootballMarket.Accounts.BrowserSessions.create_anonymous()
    {:ok, handle} = FootballMarket.Accounts.BrowserSessions.authenticate(anonymous, user.id)

    build_conn()
    |> Plug.Test.init_test_session(%{browser_handle: handle})
    |> Plug.Conn.put_private(:live_view_connect_info, %{session: %{"browser_handle" => handle}})
  end
end

defmodule FootballMarketWeb.HomeLiveTest do
  use FootballMarketWeb.LiveCase, async: false

  @moduletag :integration

  test "GET / renders the application marker and guest calls to action", %{conn: conn} do
    html = conn |> get(~p"/") |> html_response(200)

    assert html =~ "Football Player Market"
    assert html =~ ~s(href="/users/log-in")
    assert html =~ ~s(href="/users/register")
    refute html =~ "log-out-link"
  end

  test "the connected home page lists every supported league", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    for {code, name} <- FootballMarket.Catalog.supported_leagues() do
      assert render(view) =~ code
      assert render(view) =~ name
    end
  end

  test "a signed-in user sees their navigation instead of guest links", %{conn: conn} do
    %{conn: conn, user: user} = register_and_log_in_user(%{conn: conn})
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#current-user-email", user.email)
    assert has_element?(view, "#log-out-link")
    assert has_element?(view, ~s(a[href="/players"]), "Browse players")
    refute has_element?(view, ~s(a[href="/users/register"]))
  end
end

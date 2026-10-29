defmodule FootballMarketWeb.PageControllerTest do
  use FootballMarketWeb.ConnCase

  @moduletag :integration

  test "GET / returns the application foundation", %{conn: conn} do
    conn = get(conn, ~p"/")
    html = html_response(conn, 200)
    assert html =~ "Football Player Market"

    for path <- ["/sign-in", "/register", "/portfolio", "/conditional-orders", "/docs"] do
      assert html =~ ~s(href="#{path}")
    end

    assert html =~ "100"
    refute html =~ "Phoenix application foundation"
  end
end

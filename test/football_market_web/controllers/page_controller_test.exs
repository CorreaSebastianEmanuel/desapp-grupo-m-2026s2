defmodule FootballMarketWeb.PageControllerTest do
  use FootballMarketWeb.ConnCase

  @moduletag :integration

  test "GET / returns the application foundation", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Football Player Market"
  end
end

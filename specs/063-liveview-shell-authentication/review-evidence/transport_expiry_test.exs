defmodule Task046ReviewExpiryTest do
  use FootballMarket.BrowserSessionCase
  import Phoenix.ConnTest
  @endpoint FootballMarketWeb.Endpoint
  test "expired transport still provides the required session-ended notice" do
    controlled_clock!()
    user = account()
    {:ok, anonymous} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id)
    :persistent_term.put({FootballMarket.BrowserTestClock, :now}, DateTime.add(BrowserSessions.now(), 901, :second))
    # Control: an expired cookie still sent to the server produces the notice.
    retained = build_conn() |> Plug.Test.init_test_session(%{browser_handle: handle}) |> get("/portfolio")
    assert redirected_to(retained, 303) =~ "notice=ended"
    # A browser removes the Max-Age=900 cookie when its lifetime ends.
    removed = build_conn() |> get("/portfolio")
    assert redirected_to(removed, 303) =~ "notice=ended"
  end
end

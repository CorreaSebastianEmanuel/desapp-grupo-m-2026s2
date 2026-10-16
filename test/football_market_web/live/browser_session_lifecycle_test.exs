defmodule FootballMarketWeb.BrowserSessionLifecycleTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint FootballMarketWeb.Endpoint
  test "connected sessions terminate on revocation and clock expiry" do
    controlled_clock!()
    user = account()

    for mode <- [:logout, :expiry, :outage, :missed_notification, :deleted_account] do
      {:ok, anon} = BrowserSessions.create_anonymous()
      {:ok, handle} = BrowserSessions.authenticate(anon, user.id)

      conn =
        build_conn()
        |> Plug.Test.init_test_session(%{browser_handle: handle})
        |> Plug.Conn.put_private(:live_view_connect_info, %{
          session: %{"browser_handle" => handle}
        })

      {:ok, view, _} = live(conn, "/portfolio")

      {:ok, api_token} = FootballMarket.Accounts.Authentication.issue(user.id)

      case mode do
        :deleted_account ->
          import Ecto.Query

          Repo.delete_all(
            from(s in FootballMarket.Accounts.BrowserSession, where: s.user_id == ^user.id)
          )

          Repo.get!(FootballMarket.Accounts.User, user.id) |> Repo.delete!()

        :missed_notification ->
          import Ecto.Query

          Repo.update_all(
            from(s in FootballMarket.Accounts.BrowserSession,
              where: s.token_digest == ^:crypto.hash(:sha256, handle)
            ),
            set: [state: "revoked", revoked_at: BrowserSessions.now()]
          )

        :logout ->
          BrowserSessions.revoke(handle)

        :expiry ->
          :persistent_term.put(
            {FootballMarket.BrowserTestClock, :now},
            DateTime.add(BrowserSessions.now(), 900, :second)
          )

        :outage ->
          Application.put_env(:football_market, :browser_failure, :all)
      end

      assert_redirect(view, "/sign-in?notice=ended", 2000)
      assert {:ok, _} = FootballMarket.Accounts.validate_access_token(api_token)
      Application.delete_env(:football_market, :browser_failure)
    end
  end
end

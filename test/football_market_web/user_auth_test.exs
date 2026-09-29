defmodule FootballMarketWeb.UserAuthTest do
  use FootballMarketWeb.LiveCase, async: false

  @moduletag :integration

  import FootballMarket.AuthenticationHelpers, only: [put_fixed_authentication: 1]

  describe "POST /users/log-in" do
    test "valid credentials start a session and redirect to the catalog", %{conn: conn} do
      user = register_user!()

      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{"email" => user.email, "password" => user.password}
        })

      assert redirected_to(conn) == ~p"/players"
      assert is_binary(get_session(conn, :access_token))
      assert "user_sessions:" <> _ = get_session(conn, :live_socket_id)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Welcome back!"

      html = conn |> recycle() |> get(~p"/players") |> html_response(200)
      assert html =~ user.email
    end

    test "invalid credentials share one generic failure and keep the email", %{conn: conn} do
      user = register_user!()

      for email <- [user.email, "missing@example.test"] do
        conn =
          post(conn, ~p"/users/log-in", %{
            "user" => %{"email" => email, "password" => "wrong password!!"}
          })

        assert redirected_to(conn) == ~p"/users/log-in"
        assert get_session(conn, :access_token) == nil
        assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
        assert Phoenix.Flash.get(conn.assigns.flash, :email) == email
      end
    end

    test "malformed parameters fail without a session", %{conn: conn} do
      conn = post(conn, ~p"/users/log-in", %{"user" => %{"email" => ["x"]}})

      assert redirected_to(conn) == ~p"/users/log-in"
      assert get_session(conn, :access_token) == nil
    end

    test "returns to the protected page that required authentication", %{conn: conn} do
      user = register_user!()
      conn = get(conn, ~p"/account")
      assert redirected_to(conn) == ~p"/users/log-in"

      conn =
        conn
        |> recycle()
        |> post(~p"/users/log-in", %{
          "user" => %{"email" => user.email, "password" => user.password}
        })

      assert redirected_to(conn) == ~p"/account"
    end
  end

  describe "DELETE /users/log-out" do
    test "clears the session and disconnects its LiveViews", %{conn: conn} do
      user = register_user!()

      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{"email" => user.email, "password" => user.password}
        })

      live_socket_id = get_session(conn, :live_socket_id)
      FootballMarketWeb.Endpoint.subscribe(live_socket_id)

      conn = conn |> recycle() |> delete(~p"/users/log-out")

      assert redirected_to(conn) == ~p"/"
      assert get_session(conn, :access_token) == nil
      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}

      assert conn |> recycle() |> get(~p"/players") |> redirected_to() == ~p"/users/log-in"
    end
  end

  describe "route protection" do
    test "protected pages redirect guests to log in", %{conn: conn} do
      for path <- [~p"/players", ~p"/players/#{Ecto.UUID.generate()}", ~p"/account"] do
        conn = get(conn, path)
        assert redirected_to(conn) == ~p"/users/log-in"

        assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
                 "You must log in to access this page."
      end
    end

    test "guest-only pages redirect signed-in users", %{conn: conn} do
      %{conn: conn} = register_and_log_in_user(%{conn: conn})

      for path <- [~p"/users/log-in", ~p"/users/register"] do
        assert conn |> get(path) |> redirected_to() == ~p"/players"
      end
    end

    test "an expired session token is discarded and treated as signed out", %{conn: conn} do
      user = register_user!()
      issued_at = System.system_time(:second)
      put_fixed_authentication(issued_at)
      conn = log_in_user(conn, user)

      Application.put_env(:football_market, :authentication_test_time, issued_at + 900)
      conn = get(conn, ~p"/players")

      assert redirected_to(conn) == ~p"/users/log-in"
      assert get_session(conn, :access_token) == nil
    end

    test "a tampered session token is rejected", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        |> put_session(:access_token, "not-a-token")
        |> get(~p"/players")

      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "LiveView session expiry" do
    test "events after the token expires redirect to log in", %{conn: conn} do
      user = register_user!()
      issued_at = System.system_time(:second)
      put_fixed_authentication(issued_at)
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/account")

      Application.put_env(:football_market, :authentication_test_time, issued_at + 900)

      assert {:error, {:redirect, %{to: "/users/log-in"}}} = render_click(view, "issue-key")
      flash = assert_redirect(view, ~p"/users/log-in")

      assert flash["error"] == "Your session expired. Log in again."
      assert FootballMarket.Accounts.list_api_keys(user.id) == []
    end

    test "live patches after the token expires redirect to log in", %{conn: conn} do
      user = register_user!()
      issued_at = System.system_time(:second)
      put_fixed_authentication(issued_at)
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/players")

      Application.put_env(:football_market, :authentication_test_time, issued_at + 900)

      assert {:error, {:redirect, %{to: "/users/log-in"}}} =
               render_patch(view, ~p"/players?#{[league_id: Ecto.UUID.generate()]}")
    end
  end
end

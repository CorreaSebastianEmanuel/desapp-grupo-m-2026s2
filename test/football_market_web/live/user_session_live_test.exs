defmodule FootballMarketWeb.UserSessionLiveTest do
  use FootballMarketWeb.LiveCase, async: false

  @moduletag :integration

  alias FootballMarket.Accounts

  describe "log in page" do
    test "posts credentials to the session endpoint", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/users/log-in")

      assert has_element?(view, ~s(#login-form[action="/users/log-in"][method="post"]))
      assert has_element?(view, ~s(#login-form input[name="user[email]"][type="email"]))
      assert has_element?(view, ~s(#login-form input[name="user[password]"][type="password"]))
    end

    test "submitting the form signs the user in", %{conn: conn} do
      user = register_user!()
      {:ok, view, _html} = live(conn, ~p"/users/log-in")

      form =
        form(view, "#login-form", user: %{email: user.email, password: user.password})

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/players"
      assert is_binary(get_session(conn, :access_token))
    end

    test "prefills the email after a failed attempt", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log-in", %{
          "user" => %{"email" => "someone@example.test", "password" => "wrong password!!"}
        })

      {:ok, _view, html} = conn |> recycle() |> live(~p"/users/log-in")

      assert html =~ "Invalid email or password"
      assert html =~ ~s(value="someone@example.test")
    end
  end

  describe "registration page" do
    test "creates an account and continues to log in with the email prefilled", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/users/register")
      email = "new-user#{System.unique_integer([:positive])}@example.test"

      assert {:ok, login_view, html} =
               view
               |> form("#registration-form",
                 user: %{email: email, password: "a secure password"}
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/users/log-in")

      assert html =~ "Account created. Log in to continue."
      assert has_element?(login_view, ~s(input[name="user[email]"][value="#{email}"]))
      assert {:ok, %{email: ^email}} = Accounts.get_user_by_email(email)
    end

    test "shows validation errors without echoing the password", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/users/register")

      html =
        view
        |> form("#registration-form", user: %{email: "not-an-email", password: "short-secret"})
        |> render_submit()

      assert html =~ "has invalid format"
      refute html =~ "short-secret"
      assert Accounts.get_user_by_email("not-an-email") == {:error, :not_found}

      html =
        view
        |> form("#registration-form", user: %{email: "ok@example.test", password: "short"})
        |> render_submit()

      assert html =~ "should be at least 12 characters"
      refute html =~ ~s(value="short")
    end

    test "rejects an email that is already registered", %{conn: conn} do
      user = register_user!()
      {:ok, view, _html} = live(conn, ~p"/users/register")

      html =
        view
        |> form("#registration-form",
          user: %{email: String.upcase(user.email), password: "another secure password"}
        )
        |> render_submit()

      assert html =~ "has already been taken"
    end
  end
end

defmodule FootballMarketWeb.UserSessionController do
  @moduledoc """
  Writes and clears the browser session cookie, which a LiveView cannot do.
  It renders nothing: the login form is `FootballMarketWeb.UserLoginLive`.
  """
  use FootballMarketWeb, :controller

  alias FootballMarket.Accounts
  alias FootballMarketWeb.UserAuth

  @invalid_credentials "Invalid email or password"

  def create(conn, %{"user" => %{"email" => email, "password" => password}})
      when is_binary(email) and is_binary(password) do
    case Accounts.login(%{email: email, password: password}) do
      {:ok, %{access_token: token}} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> UserAuth.log_in_user(token)

      {:error, _reason} ->
        conn
        |> put_flash(:error, @invalid_credentials)
        |> put_flash(:email, String.slice(email, 0, 254))
        |> redirect(to: ~p"/users/log-in")
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, @invalid_credentials)
    |> redirect(to: ~p"/users/log-in")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end

defmodule FootballMarketWeb.LiveCase do
  @moduledoc """
  Test case for browser routes and LiveViews backed by the SQL sandbox.
  """
  use ExUnit.CaseTemplate

  alias FootballMarket.Accounts

  using do
    quote do
      @endpoint FootballMarketWeb.Endpoint

      use FootballMarketWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import FootballMarketWeb.LiveCase
    end
  end

  setup tags do
    FootballMarket.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def register_user!(attrs \\ %{}) do
    attrs =
      Map.merge(
        %{
          email: "user#{System.unique_integer([:positive])}@example.test",
          password: "a secure password"
        },
        attrs
      )

    {:ok, user} = Accounts.register_user(attrs)
    Map.put(user, :password, attrs.password)
  end

  def access_token!(user) do
    {:ok, %{access_token: token}} =
      Accounts.login(%{email: user.email, password: user.password})

    token
  end

  def log_in_user(conn, user) do
    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:access_token, access_token!(user))
  end

  def register_and_log_in_user(%{conn: conn}) do
    user = register_user!()
    %{conn: log_in_user(conn, user), user: user}
  end
end

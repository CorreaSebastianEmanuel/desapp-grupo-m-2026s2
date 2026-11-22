defmodule FootballMarketWeb.ConnCase do
  @moduledoc """
  Shared HTTP and LiveView test case with JWT, API key, and browser session helpers.
  """

  use ExUnit.CaseTemplate

  import Plug.Conn
  import Phoenix.ConnTest

  alias FootballMarket.Accounts
  alias FootballMarket.Accounts.BrowserSessions

  using do
    quote do
      @endpoint FootballMarketWeb.Endpoint

      use FootballMarketWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import FootballMarket.DataCase
      import FootballMarketWeb.ConnCase
    end
  end

  setup tags do
    FootballMarket.DataCase.__ex_unit__(:setup, tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def with_jwt(conn, user) do
    {:ok, %{access_token: token}} = Accounts.login(%{email: user.email, password: user.password})
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  def with_api_key(conn, user) do
    {:ok, %{secret: secret}} = Accounts.issue_api_key(user.id)
    put_req_header(conn, "x-api-key", secret)
  end

  def with_browser_session(conn, user) do
    {:ok, anon} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anon, user.id)
    init_test_session(conn, %{"browser_handle" => handle})
  end
end

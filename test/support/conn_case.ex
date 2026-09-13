defmodule FootballMarketWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  These tests rely on `Phoenix.ConnTest`. Database support remains
  intentionally inactive until TASK-002.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint FootballMarketWeb.Endpoint

      use FootballMarketWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import FootballMarketWeb.ConnCase
    end
  end

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end

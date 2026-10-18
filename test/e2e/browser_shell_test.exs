defmodule FootballMarket.E2E.BrowserShellTest do
  use ExUnit.Case, async: false
  @moduletag :e2e
  @tag timeout: 170_000

  test "real sign-in connected shell logout and expired authority" do
    FootballMarket.E2E.Runtime.with_runtime!(fn base ->
      credentials = FootballMarket.E2E.Fixtures.account!()
      assert FootballMarket.E2E.Fixtures.browser!(base, credentials) == :ok
    end)
  end
end

defmodule FootballMarket.E2E.BrowserReconnectTest do
  use ExUnit.Case, async: false

  @moduletag :e2e
  @tag timeout: 170_000

  test "real browser reconnect recovers a committed order purchase exactly once" do
    original = Application.fetch_env(:football_market, :initial_issuance_recipients)

    try do
      FootballMarket.E2E.Runtime.with_runtime!(fn base ->
        assert FootballMarket.E2E.Fixtures.market_reconnect_browser!(base) == :ok
      end)
    after
      case original do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end
  end
end

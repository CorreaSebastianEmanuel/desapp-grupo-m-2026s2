defmodule FootballMarket.E2E.CatalogSyncTest do
  use ExUnit.Case, async: false
  @moduletag :e2e
  @tag timeout: 170_000

  test "durable synchronization admission terminal state API replay and rejected input invariants" do
    FootballMarket.E2E.Runtime.with_runtime!(fn base ->
      assert FootballMarket.E2E.Fixtures.catalog!(base) == :ok
    end)
  end
end

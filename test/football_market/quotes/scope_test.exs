defmodule FootballMarket.Quotes.ScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  test "feature inventory stays explicitly bounded to quote calculation ownership" do
    paths =
      FootballMarket.WorkflowScope.paths("specs/026-quote-recalculation-and-immutable-history")

    assert "lib/football_market/quotes/" in paths

    assert "priv/repo/migrations/20261018000800_reconcile_quote_request_requested_mapping.exs" in paths
    assert "priv/repo/migrations/20261018000900_reconcile_legacy_quote_admission.exs" in paths

    refute "lib/football_market_web/" in paths
    refute "lib/football_market/providers/" in paths
  end
end

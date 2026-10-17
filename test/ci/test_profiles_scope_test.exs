defmodule FootballMarket.TestProfilesScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  test "E2E uses supported accounts fixture input worker and Endpoint without public test controls" do
    runtime = File.read!("test/support/e2e/runtime.ex")
    fixtures = File.read!("test/support/e2e/fixtures.ex")
    browser = File.read!("tools/openapi/e2e_browser.mjs")
    assert runtime =~ "testing: :disabled"
    assert runtime =~ "pool: DBConnection.ConnectionPool"
    assert fixtures =~ "Synchronization.request_catalog"
    assert fixtures =~ "Synchronization.get_run"
    assert fixtures =~ "Accounts.register_user"
    assert browser =~ "phx-connected"

    for forbidden <- [
          "/__test/",
          "drain_queue",
          "Workers.CatalogSync.perform",
          "football-data.org",
          "route.fulfill",
          "recordVideo",
          "storageState(",
          "screenshot(",
          "tracing.start"
        ] do
      refute runtime <> fixtures <> browser =~ forbidden
    end

    router = File.read!("lib/football_market_web/router.ex")
    refute router =~ "/__test/"
    refute browser =~ "/conditional-orders"
  end

  test "historical coverage scope remains unchanged and excludes E2E" do
    runner = File.read!("scripts/coverage_report.sh")
    refute runner =~ "test_profile.sh e2e"
    assert runner =~ "scripts/test_profile.sh unit"
    assert runner =~ "scripts/test_profile.sh integration"
    assert File.read!("mix.exs") =~ "summary: [threshold: 0]"
  end
end

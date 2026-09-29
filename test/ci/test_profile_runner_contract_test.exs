defmodule FootballMarket.TestProfileRunnerContractTest do
  use ExUnit.Case, async: true

  @moduletag :unit
  @root Path.expand("../..", __DIR__)

  test "runner selects exactly one profile, includes performance tests, and releases only safe receipts" do
    runner = File.read!(Path.join(@root, "scripts/test_profile.sh"))

    assert runner =~ "unit|integration"
    assert runner =~ "--include performance --only"
    assert runner =~ "FootballMarket.TestProfileAudit.audit!"
    assert runner =~ "umask 077"
    assert runner =~ "safe_failure"
    assert runner =~ "CP1_PROFILE_RECEIPT"
    assert runner =~ "CP1_PROFILE_SENTINEL_PATH"
    assert runner =~ "node-runtime"
    assert runner =~ "browser-prerequisite"
    assert runner =~ "playwright-core"
    assert runner =~ "chromium.launch"
    refute runner =~ "node_modules/playwright\")"
    assert runner =~ "safe_failure incomplete"
    assert runner =~ "Result: [1-9][0-9]* passed"
    assert runner =~ "safe_failure skipped"
    assert runner =~ "[ \"$test_status\" -eq 0 ] || safe_failure test-failure"
    refute runner =~ "cat \"$audit_output\""
    refute runner =~ "cat \"$test_output\""
    refute runner =~ "clean HEAD"
    refute runner =~ "|| true"
  end

  test "browser harness and ExUnit bridge use opaque receipts" do
    browser = File.read!(Path.join(@root, "tools/openapi/browser.mjs"))
    bridge = File.read!(Path.join(@root, "test/football_market_web/openapi_browser_test.exs"))

    assert browser =~ "CP1_BROWSER_RECEIPT status=complete"
    refute browser =~ "error.message"
    refute bridge =~ "IO.puts(output)"
    refute bridge =~ "assert status == 0, output"
  end
end

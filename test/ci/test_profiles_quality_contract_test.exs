defmodule FootballMarket.TestProfilesQualityContractTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  test "mandatory E2E job preserves existing CI and independent local profiles" do
    workflow = File.read!(".github/workflows/quality-baseline.yml")
    assert workflow =~ "name: End-to-end profile"
    assert workflow =~ "timeout-minutes:"
    assert workflow =~ "scripts/test_profile.sh e2e"
    assert workflow =~ "mix assets.build"
    assert workflow =~ "docker compose version"
    refute workflow =~ "continue-on-error"
    refute workflow =~ "paths-ignore:"
    assert File.read!(".github/workflows/sonarcloud.yml") =~ "SonarCloud analysis and CP1 gate"
  end

  test "baseline consumes independently reconciled component receipts" do
    script = File.read!("scripts/ci_unit_tests.sh")
    assert script =~ "scripts/test_profile.sh"
    assert script =~ "unit integration"
    assert script =~ "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL"
    refute script =~ "cat \"$output\""
    refute script =~ "mix test --warnings-as-errors"
  end
end

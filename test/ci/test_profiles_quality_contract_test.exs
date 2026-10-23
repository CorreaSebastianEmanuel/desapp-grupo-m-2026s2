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
    workflow = File.read!(".github/workflows/quality-baseline.yml")
    [baseline, _e2e] = String.split(workflow, "\n  end-to-end:", parts: 2)

    assert [_, after_prepare] =
             String.split(
               baseline,
               "- name: Prepare test database\n        run: MIX_ENV=test mix test.prepare",
               parts: 2
             )

    assert after_prepare =~ "- name: Unit tests"
    assert after_prepare =~ "run: scripts/ci_unit_tests.sh"
    [credo_step, _] = String.split(baseline, "- name: Credo and source inventory", parts: 2)
    refute credo_step =~ "name: Unit tests"
    assert after_prepare =~ "- name: Upload Credo evidence"
    assert after_prepare =~ "if: always()"
    assert after_prepare =~ "if-no-files-found: error"

    script = File.read!("scripts/ci_unit_tests.sh")
    assert script =~ "scripts/test_profile.sh"
    assert script =~ "unit integration"
    assert script =~ "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL"
    assert script =~ "PROFILE_DISCREPANCY id=[0-9a-f]{24}"
    assert script =~ "CP1_PROFILE_OUTCOME status=failed category="
    refute script =~ "cat \"$output\""
    refute script =~ "mix test --warnings-as-errors"
  end
end

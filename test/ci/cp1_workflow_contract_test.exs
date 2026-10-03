defmodule FootballMarket.CP1WorkflowContractTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  @root Path.expand("../..", __DIR__)
  @workflow Path.join(@root, ".github/workflows/cp1-acceptance.yml")

  setup_all do
    %{workflow: File.read!(@workflow)}
  end

  test "orchestrates the complete exact-toolchain local verification", %{workflow: workflow} do
    for command <- [
          "check_toolchain.sh",
          "mix format --check-formatted",
          "mix compile --warnings-as-errors",
          "scripts/ci_unit_tests.sh",
          "mix test.unit",
          "mix test.integration",
          "mix test.cp1_coverage",
          "cp1_acceptance_test.py",
          "cp1_demo_contract_test.exs",
          "cp1_demo.sh"
        ] do
      assert workflow =~ command
    end

    assert length(Regex.scan(~r/scripts\/cp1_demo\.sh/, workflow)) >= 2
  end

  test "binds hosted evidence and publication to the full triggering SHA", %{workflow: workflow} do
    for required <- [
          "github.sha",
          "refs/heads/main",
          "quality-baseline.yml",
          "sonarcloud.yml",
          "completed",
          "cp1-acceptance-${{ github.sha }}",
          "retention-days: 90",
          "if: always()",
          "GITHUB_STEP_SUMMARY"
        ] do
      assert workflow =~ required
    end

    collector = File.read!(Path.join(@root, "scripts/cp1_hosted_receipts.py"))
    assert collector =~ "range(40)"
    assert collector =~ "time.sleep(15)"
    assert collector =~ ~S|r.get("status") == "completed"|
  end

  test "publishes only sanitized records and receipts", %{workflow: workflow} do
    assert workflow =~ "scripts/cp1_acceptance.py"
    assert workflow =~ "--local-evidence tmp/local-receipts"
    assert workflow =~ "stage-local"
    assert workflow =~ "path: tmp/cp1-sanitized-local/"
    refute workflow =~ "set -x"
    refute workflow =~ "echo ${{ secrets"
  end
end

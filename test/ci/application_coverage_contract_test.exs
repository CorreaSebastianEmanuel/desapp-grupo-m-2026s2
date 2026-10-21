defmodule FootballMarket.ApplicationCoverageContractTest do
  use ExUnit.Case, async: false
  @moduletag :unit

  test "application output is opt-in and conflicts with historical CP1 output" do
    expression = "IO.puts(\"COVERAGE_OUTPUT=\" <> Mix.Project.config()[:test_coverage][:output])"

    isolated = [
      {"APPLICATION_COVERAGE_DIR", nil},
      {"CP1_PROFILE_COVERAGE", nil},
      {"CP1_COVERAGE_OUTPUT", nil}
    ]

    assert {default, 0} =
             System.cmd("mix", ["run", "--no-start", "-e", expression],
               env: isolated,
               stderr_to_stdout: true
             )

    assert default =~ "COVERAGE_OUTPUT=cover/cp1/staging"

    opts = [
      {"APPLICATION_COVERAGE_DIR", "/tmp/application-coverage-contract"}
      | List.keydelete(isolated, "APPLICATION_COVERAGE_DIR", 0)
    ]

    assert {custom, 0} =
             System.cmd("mix", ["run", "--no-start", "-e", expression],
               env: opts,
               stderr_to_stdout: true
             )

    assert custom =~ "COVERAGE_OUTPUT=/tmp/application-coverage-contract"

    {_, status} =
      System.cmd("mix", ["run", "--no-start", "-e", expression],
        env: [{"CP1_PROFILE_COVERAGE", "1"} | List.keydelete(opts, "CP1_PROFILE_COVERAGE", 0)],
        stderr_to_stdout: true
      )

    assert status != 0
  end

  test "test processes clear application collection options before recursive children" do
    helper = File.read!("test/test_helper.exs")
    assert helper =~ "System.delete_env(key)"

    for key <- [
          "APPLICATION_COVERAGE_DIR",
          "APPLICATION_COVERAGE_RUN_ID",
          "APPLICATION_COVERAGE_SNAPSHOT"
        ] do
      assert helper =~ key
      assert System.get_env(key) == nil
    end
  end
end

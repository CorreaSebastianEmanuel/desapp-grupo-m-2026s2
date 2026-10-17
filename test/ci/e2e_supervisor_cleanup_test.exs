defmodule FootballMarket.E2E.SupervisorCleanupTest do
  use ExUnit.Case, async: false
  @moduletag :integration

  @tag timeout: 100_000
  test "supervisor timeout removes owned schema and preserves unrelated persistence" do
    assert_probe("timeout")
  end

  @tag timeout: 100_000
  test "supervisor termination removes owned schema and preserves unrelated persistence" do
    assert_probe("terminate")
  end

  defp assert_probe(mode) do
    {output, status} =
      System.cmd("python3", ["test/support/e2e/supervisor_probe.py", mode],
        stderr_to_stdout: true
      )

    assert status == 0, output
    assert output == "E2E_SUPERVISOR status=complete mode=#{mode}\n"
  end
end

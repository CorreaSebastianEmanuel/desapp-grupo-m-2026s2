defmodule Task046IndependentB1QA do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  @tag timeout: 120_000
  test "independent B1 HTTP and Chromium both destinations" do
    account()
    controlled_clock!()
    {base, server, control} = start_runtime!()
    try do
      {output, status} = System.cmd("node", ["/tmp/task046_b1_qa.mjs", base], env: [{"WORKSPACE_EMAIL", "browser@example.com"}, {"WORKSPACE_PASSWORD", "correct-password-123"}, {"WORKSPACE_CONTROL", control}], stderr_to_stdout: true)
      assert status == 0, output
      assert output =~ "recovery PASS"
    after
      Supervisor.stop(server)
    end
  end
end

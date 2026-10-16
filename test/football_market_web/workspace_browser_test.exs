defmodule FootballMarketWeb.WorkspaceBrowserTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  @tag timeout: 120_000
  test "real Chromium exercises shell journeys and session lifecycle" do
    account()
    account("second@example.com")
    controlled_clock!()
    {_output, build_status} = System.cmd("mix", ["assets.build"], stderr_to_stdout: true)
    assert build_status == 0
    {base, server, control} = start_runtime!()

    try do
      {output, status} =
        System.cmd("node", ["tools/openapi/workspace_browser.mjs", base, "browser"],
          env: [
            {"WORKSPACE_EMAIL", "browser@example.com"},
            {"WORKSPACE_SECOND_EMAIL", "second@example.com"},
            {"WORKSPACE_PASSWORD", "correct-password-123"},
            {"WORKSPACE_CONTROL", control}
          ],
          stderr_to_stdout: true
        )

      assert {status, output} == {0, "WORKSPACE_RECEIPT mode=browser status=complete\n"}
    after
      Supervisor.stop(server)
    end
  end
end

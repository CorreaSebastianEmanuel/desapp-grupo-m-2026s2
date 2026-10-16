defmodule FootballMarketWeb.WorkspaceHTTPRuntimeTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  test "real listener asserts browser HTTP and API isolation contracts" do
    account()
    account("second@example.com")
    controlled_clock!()
    {base, server, control} = start_runtime!()

    try do
      {output, status} =
        System.cmd("node", ["tools/openapi/workspace_browser.mjs", base, "http"],
          env: [
            {"WORKSPACE_EMAIL", "browser@example.com"},
            {"WORKSPACE_SECOND_EMAIL", "second@example.com"},
            {"WORKSPACE_PASSWORD", "correct-password-123"},
            {"WORKSPACE_CONTROL", control}
          ],
          stderr_to_stdout: true
        )

      assert {status, output} == {0, "WORKSPACE_RECEIPT mode=http status=complete\n"}
    after
      Supervisor.stop(server)
    end
  end
end

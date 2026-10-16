defmodule Task046IndependentQA do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  @endpoint FootballMarketWeb.Endpoint
  @tag timeout: 120_000
  test "independent keyboard journey and measured lifecycle" do
    account()
    account("second@example.com")
    controlled_clock!()
    {base, server, control} = start_runtime!()
    try do
      {output, status} = System.cmd("node", ["/tmp/task046_qa_browser.mjs", base, "browser"], env: [{"WORKSPACE_EMAIL", "browser@example.com"}, {"WORKSPACE_SECOND_EMAIL", "second@example.com"}, {"WORKSPACE_PASSWORD", "correct-password-123"}, {"WORKSPACE_CONTROL", control}], stderr_to_stdout: true)
      IO.write(output)
      assert status == 0
      assert output =~ "WORKSPACE_RECEIPT mode=browser status=complete"
    after
      Supervisor.stop(server)
    end
  end
  test "API authority cannot authenticate browser and secret sentinels stay server side" do
    import Phoenix.ConnTest
    import Plug.Conn
    import ExUnit.CaptureLog
    user = account()
    {:ok, %{access_token: token}} = FootballMarket.Accounts.login(%{email: user.email, password: "correct-password-123"})
    {:ok, key} = FootballMarket.Accounts.issue_api_key(user.id)
    for {header, value} <- [{"authorization", "Bearer " <> token}, {"x-api-key", key.secret}] do
      conn = build_conn() |> put_req_header(header, value) |> get("/portfolio")
      assert conn.status == 303
      refute conn.resp_body =~ user.email
    end
    {:ok, anonymous} = BrowserSessions.create_anonymous()
    {:ok, handle} = BrowserSessions.authenticate(anonymous, user.id)
    sentinels = [handle, token, key.secret, "correct-password-123", FootballMarketWeb.Endpoint.config(:secret_key_base)]
    log = capture_log(fn ->
      conn = build_conn() |> Plug.Test.init_test_session(%{browser_handle: handle}) |> get("/portfolio")
      assert conn.status == 200
      [_, mount] = Regex.run(~r/data-phx-session="([^"]+)"/, conn.resp_body)
      assert {:ok, payload} = Phoenix.LiveView.Static.verify_token(FootballMarketWeb.Endpoint, mount)
      for secret <- sentinels do
        refute conn.resp_body =~ secret
        refute inspect(payload) =~ secret
      end
      assert BrowserSessions.revoke(handle) == :ok
      assert {:ok, _} = FootballMarket.Accounts.validate_access_token(token)
      # API credential lifecycles remain independent of browser revocation.
      api = build_conn() |> put_req_header("x-api-key", key.secret) |> get("/api/players")
      assert api.status == 200
    end)
    for secret <- sentinels, do: refute(log =~ secret)
    IO.puts("QA api_browser_separation_and_secret_sentinels=PASS")
  end

end

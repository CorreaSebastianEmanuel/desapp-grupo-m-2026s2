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

  @tag timeout: 100_000
  test "real browser observes bounded first load and late worker publication without reload" do
    f = FootballMarket.FreshnessCase.fixture()
    user = account("statistics-browser@example.com")
    {base, server, _control} = start_runtime!()
    ipc = Path.join(System.tmp_dir!(), "statistics-browser-" <> Ecto.UUID.generate())
    File.mkdir!(ipc)

    browser =
      Task.async(fn ->
        System.cmd("node", ["tools/openapi/player_statistics_browser.mjs", base, f.player.id],
          env: [
            {"STATISTICS_EMAIL", user.email},
            {"STATISTICS_PASSWORD", "correct-password-123"},
            {"STATISTICS_IPC", ipc}
          ],
          stderr_to_stdout: true
        )
      end)

    try do
      FootballMarket.E2E.Runtime.await!(
        fn ->
          if File.exists?(Path.join(ipc, "deadline-visible")), do: {:ok, :visible}, else: :pending
        end,
        40_000
      )

      assert Repo.aggregate(FootballMarket.Synchronization.Run, :count) == 1
      FootballMarket.FreshnessCase.perform!(f)

      FootballMarket.E2E.Runtime.await!(
        fn ->
          if File.exists?(Path.join(ipc, "stored-visible")), do: {:ok, :visible}, else: :pending
        end,
        20_000
      )

      check =
        FootballMarket.Statistics.Ingestion.ScopeCheck.find("synthetic-a", f.player.season_id)

      Repo.update!(
        Ecto.Changeset.change(check,
          last_checked_at: DateTime.add(DateTime.utc_now(), -86_401, :second)
        )
      )

      FootballMarket.Statistics.Freshness.refresh_now(f.player)
      FootballMarket.FreshnessCase.fail!(f, "invalid_response")
      File.write!(Path.join(ipc, "failure-ready"), "ready")
      assert {"PLAYER_STATISTICS_BROWSER status=complete\n", 0} = Task.await(browser, 40_000)
    after
      if Process.alive?(browser.pid), do: Task.shutdown(browser, :brutal_kill)
      Supervisor.stop(server)
      File.rm_rf!(ipc)
    end
  end
end

defmodule FootballMarketWeb.AdministrationBrowserTest do
  use FootballMarket.BrowserSessionCase
  @moduletag :integration
  @tag timeout: 120_000

  test "real Chromium navigates the shared responsive workspace and selects only two fixed formulas" do
    user = account()
    previous = Application.fetch_env(:football_market, :initial_issuance_recipients)

    on_exit(fn ->
      case previous do
        {:ok, value} -> Application.put_env(:football_market, :initial_issuance_recipients, value)
        :error -> Application.delete_env(:football_market, :initial_issuance_recipients)
      end
    end)

    Application.put_env(:football_market, :initial_issuance_recipients, [user.id])

    {_output, status} = System.cmd("mix", ["assets.build"], stderr_to_stdout: true)
    assert status == 0
    {base, server, _control} = start_runtime!()
    before_quotes = Repo.all(FootballMarket.Market.Quote)
    before_jobs = Repo.aggregate(Oban.Job, :count)

    try do
      {output, status} =
        System.cmd("node", ["tools/openapi/administration_browser.mjs", base],
          env: [
            {"ADMIN_EMAIL", user.email},
            {"ADMIN_SCREENSHOT_DIR", System.get_env("ADMIN_SCREENSHOT_DIR")}
          ],
          stderr_to_stdout: true
        )

      assert {status, output} == {0, "ADMINISTRATION_BROWSER status=complete\n"}

      assert {:ok, %{versions: versions, active_version_id: active}} =
               FootballMarket.Valuation.Configurations.list()

      assert length(versions) == 2
      assert Enum.find(versions, &(&1.id == active)).strategy_id == "position_aware"
      assert Repo.all(FootballMarket.Market.Quote) == before_quotes
      assert Repo.aggregate(Oban.Job, :count) == before_jobs
    after
      Supervisor.stop(server)
    end
  end
end

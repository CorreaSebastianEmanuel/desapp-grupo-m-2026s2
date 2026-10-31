defmodule FootballMarket.E2E.CatalogScoutingTest do
  use ExUnit.Case, async: false

  @moduletag :e2e
  @tag timeout: 170_000

  test "real browser search returns immediately and receives the imported catalog result" do
    FootballMarket.E2E.Runtime.with_runtime!(fn base ->
      credentials = FootballMarket.E2E.Fixtures.account!()
      FootballMarket.IngestionFixtures.positions!()
      gate = make_ref()

      source = FootballMarket.E2E.FixtureAdapter.source(self(), gate)

      Application.put_env(:football_market, FootballMarket.Synchronization,
        enabled: true,
        automatic: false,
        sources: %{"e2e-fixture" => source},
        scouting_scopes: [
          %{league_code: "PL", start_year: 2090, end_year: 2091, source_ref: "e2e-fixture"}
        ]
      )

      ipc = Path.join(System.tmp_dir!(), "catalog-scout-e2e-" <> Ecto.UUID.generate())
      File.mkdir!(ipc)
      File.chmod!(ipc, 0o700)

      browser =
        Task.async(fn ->
          {output, status} =
            System.cmd("node", ["tools/openapi/e2e_catalog_scouting.mjs", base],
              env: [
                {"E2E_EMAIL", credentials.email},
                {"E2E_PASSWORD", credentials.password},
                {"E2E_IPC", ipc}
              ],
              stderr_to_stdout: true
            )

          {status, output}
        end)

      try do
        receive do
          {^gate, worker, _backend} ->
            FootballMarket.E2E.Runtime.await!(fn ->
              if File.exists?(Path.join(ipc, "scouting-visible")),
                do: {:ok, :visible},
                else: :pending
            end)

            FootballMarket.E2E.FixtureAdapter.release(worker, gate)
        after
          30_000 -> flunk("catalog scout did not reach the configured provider")
        end

        assert {0, "E2E_CATALOG_SCOUT status=complete\n"} = Task.await(browser, 60_000)
      after
        if Process.alive?(browser.pid), do: Task.shutdown(browser, :brutal_kill)
        File.rm_rf!(ipc)
      end
    end)
  end
end

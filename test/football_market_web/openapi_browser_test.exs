defmodule FootballMarketWeb.OpenAPIBrowserTest do
  use FootballMarket.DataCase, async: false
  import Phoenix.ConnTest
  import Plug.Conn
  import FootballMarket.OpenAPICase
  @endpoint FootballMarketWeb.Endpoint

  test "interactive page uses only the selected credential and reports load errors" do
    %{jwt: jwt, api_key: key, player: player} = fixture!()

    expected_list =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> jwt)
      |> get("/api/players?page_size=25")
      |> json_response(200)

    expected_detail =
      build_conn()
      |> put_req_header("x-api-key", key)
      |> get("/api/players/#{player.id}")
      |> json_response(200)

    {base, server} = start_server!()

    try do
      {output, status} =
        System.cmd("node", ["tools/openapi/browser.mjs", base],
          env: [
            {"OPENAPI_TEST_JWT", jwt},
            {"OPENAPI_TEST_KEY", key},
            {"OPENAPI_TEST_PLAYER_ID", player.id},
            {"OPENAPI_EXPECTED_LIST", Jason.encode!(expected_list)},
            {"OPENAPI_EXPECTED_DETAIL", Jason.encode!(expected_detail)}
          ],
          stderr_to_stdout: true
        )

      assert status == 0, output
      assert output =~ "Browser discovery"
      IO.puts(output)
    after
      Supervisor.stop(server)
    end
  end
end

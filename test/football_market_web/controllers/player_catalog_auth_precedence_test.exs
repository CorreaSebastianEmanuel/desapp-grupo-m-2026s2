defmodule FootballMarketWeb.PlayerCatalogAuthPrecedenceTest do
  use FootballMarket.DataCase, async: false
  import Phoenix.ConnTest
  @endpoint FootballMarketWeb.Endpoint

  test "invalid authentication halts before validation and catalog queries" do
    FootballMarket.PlayerCatalogProbe.attach_query_probe(self())

    assert build_conn() |> get("/api/players?page_size=bad&cursor=bad") |> json_response(401) ==
             %{"error" => %{"code" => "unauthenticated"}}

    assert build_conn() |> get("/api/players/malformed") |> json_response(401) == %{
             "error" => %{"code" => "unauthenticated"}
           }

    refute_receive {:catalog_query, _}
  end
end

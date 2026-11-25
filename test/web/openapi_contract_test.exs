defmodule FootballMarketWeb.OpenApiContractTest do
  use FootballMarketWeb.ConnCase, async: false
  @moduletag :integration

  test "priv/static/openapi.json documents every active /api route and matches live responses" do
    spec = "priv/static/openapi.json" |> File.read!() |> Jason.decode!()
    assert spec["openapi"] =~ ~r/^3\./

    expected_paths = [
      "/api/players",
      "/api/players/{player_id}",
      "/api/players/{player_id}/quotes/current",
      "/api/players/{player_id}/quotes/history",
      "/api/players/{player_id}/quotes/at",
      "/api/ranking",
      "/api/purchases",
      "/api/sales",
      "/api/transactions",
      "/api/portfolio/allocation",
      "/api/portfolio/history",
      "/api/conditional-orders",
      "/api/conditional-orders/{id}",
      "/api/conditional-orders/{id}/cancel"
    ]

    for path <- expected_paths do
      assert Map.has_key?(spec["paths"], path), "Missing OpenAPI path: #{path}"
    end

    for {"/api/" <> _, methods} <- spec["paths"], {_method, operation} <- methods do
      assert operation["responses"]["429"] == %{"$ref" => "#/components/responses/RateLimited"}
    end

    assert get_in(spec, [
             "components",
             "responses",
             "RateLimited",
             "headers",
             "Retry-After",
             "schema"
           ]) == %{"type" => "integer", "minimum" => 1}

    # Verify /docs page renders Swagger UI and /openapi.json is served statically
    docs_conn = get(build_conn(), "/docs")
    assert docs_conn.status == 200
    assert docs_conn.resp_body =~ "/api-docs/docs.js"
    assert docs_conn.resp_body =~ "swagger-ui"
    assert get(build_conn(), "/openapi.json").status == 200
  end
end

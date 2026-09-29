defmodule FootballMarketWeb.RouterAuthenticationPolicyTest do
  use ExUnit.Case, async: true

  @moduletag :unit

  test "every production API route has exactly one named policy and public routes are allowlisted" do
    api_routes =
      FootballMarketWeb.Router
      |> Phoenix.Router.routes()
      |> Enum.filter(&(&1.path == "/api" or String.starts_with?(&1.path, "/api/")))

    public_allowlist = MapSet.new()

    Enum.each(api_routes, fn route ->
      policy = route.metadata[:authentication_policy]
      assert policy in [:api_public, :api_protected]

      if policy == :api_public do
        assert MapSet.member?(public_allowlist, {route.verb, route.path})
      end
    end)
  end

  test "production web handlers do not independently parse supported credential headers" do
    handler_files = Path.wildcard("lib/football_market_web/controllers/**/*.{ex,exs}")

    Enum.each(handler_files, fn path ->
      source = File.read!(path)
      refute source =~ "get_req_header"
      refute String.downcase(source) =~ "x-api-key"
      refute String.downcase(source) =~ "bearer "
    end)
  end
end

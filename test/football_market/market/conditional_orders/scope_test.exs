defmodule FootballMarket.Market.ConditionalOrders.ScopeTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.WorkflowScope

  test "conditional feature allowance is exact and excludes workers UI and unrelated trades" do
    feature = "specs/070-conditional-buy-orders"
    paths = WorkflowScope.paths(feature)
    assert "lib/football_market/market/conditional_order_store.ex" in paths
    assert length(paths) == length(Enum.uniq(paths))
    assert Enum.all?(paths, &File.regular?/1)

    for path <- [
          "lib/football_market/workers/order.ex",
          "lib/football_market_web/live/order.ex",
          "lib/football_market/funding.ex",
          "lib/football_market/market/sell.ex",
          "lib/football_market/market/unplanned.ex"
        ] do
      refute WorkflowScope.allows_path?(feature, path)
    end

    refute WorkflowScope.allows_path?(
             "specs/unknown",
             "lib/football_market/market/conditional_orders.ex"
           )

    for path <- Path.wildcard("lib/football_market/market/conditional*.ex") do
      source = File.read!(path)
      refute source =~ ~r/Oban|PubSub|Redix|:ets|Req\.|HTTPoison|FootballMarketWeb/
    end
  end

  test "web delegates persistence and domain input and projection stay pure" do
    web = File.read!("lib/football_market_web/controllers/conditional_order_controller.ex")
    refute web =~ ~r/Repo|Postgrex|Decimal|Ecto.Query/

    for name <- ~w(conditional_order_input conditional_order_projection) do
      source = File.read!("lib/football_market/market/#{name}.ex")
      refute source =~ ~r/Repo|Postgrex|DBConnection|Application|System|DateTime\.utc_now/
    end

    Code.ensure_loaded!(FootballMarket.Market.ConditionalOrders)
    assert function_exported?(FootballMarket.Market.ConditionalOrders, :evaluate, 1)
    refute function_exported?(FootballMarket.Market.ConditionalOrders, :evaluate, 2)
    routes = Phoenix.Router.routes(FootballMarketWeb.Router)
    assert Enum.count(routes, &String.starts_with?(&1.path, "/api/conditional-orders")) == 4
    refute Enum.any?(routes, &(&1.path =~ "evaluate"))
  end
end

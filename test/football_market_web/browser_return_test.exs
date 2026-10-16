defmodule FootballMarketWeb.BrowserReturnTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarketWeb.Plugs.BrowserAuth

  test "only exact known destinations are preserved" do
    for path <- ["/portfolio", "/conditional-orders"],
        do: assert(BrowserAuth.destination(path) == path)

    for path <- [
          nil,
          "https://evil.test",
          "//evil.test",
          "/%70ortfolio",
          "/portfolio?account=a",
          "/portfolio#x",
          "/other",
          ["/portfolio"]
        ],
        do: assert(BrowserAuth.destination(path) == "/portfolio")
  end
end

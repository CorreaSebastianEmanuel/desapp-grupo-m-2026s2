defmodule FootballMarket.CP1CoverageInventoryTest do
  use ExUnit.Case, async: true

  @moduletag :unit
  @root Path.expand("../..", __DIR__)

  test "canonical committed inventory controls the repository-owned denominator" do
    inventory = Path.join(@root, "config/cp1_coverage_inventory.exs")
    mixfile = File.read!(Path.join(@root, "mix.exs"))

    assert File.exists?(inventory)
    assert File.read!(inventory) =~ "FootballMarket.Accounts"
    assert File.read!(inventory) =~ "FootballMarket.Catalog"
    assert mixfile =~ "cp1_coverage_inventory.exs"
    assert mixfile =~ "ignore_modules"
    assert mixfile =~ "threshold: 0"
  end

  test "native collector excludes compiled test support modules" do
    ignored = Mix.Project.config()[:test_coverage][:ignore_modules]

    for module <- [
          FootballMarket.TestProfileAudit,
          FootballMarket.CP1CoveragePublisher,
          FootballMarket.DataCase,
          FootballMarketWeb.ConnCase,
          FootballMarketWeb.APIAuthenticationProbe.Router.Helpers,
          Inspect.FootballMarket.Accounts.ApiKey,
          Inspect.FootballMarket.Accounts.PasswordCredential
        ] do
      assert module in ignored
    end
  end
end

defmodule FootballMarket.ProfileIntegrationSentinelTest do
  use ExUnit.Case, async: true

  @moduletag :integration

  test "writes opaque completion evidence only for the selected integration profile" do
    if (path = System.get_env("CP1_PROFILE_SENTINEL_PATH")) &&
         System.get_env("CP1_PROFILE") == "integration" do
      File.write!(path, "integration\n")
    end

    assert true
  end
end

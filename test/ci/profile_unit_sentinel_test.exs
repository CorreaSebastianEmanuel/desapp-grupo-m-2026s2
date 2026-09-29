defmodule FootballMarket.ProfileUnitSentinelTest do
  use ExUnit.Case, async: true

  @moduletag :unit

  test "writes opaque completion evidence only for the selected unit profile" do
    if (path = System.get_env("CP1_PROFILE_SENTINEL_PATH")) &&
         System.get_env("CP1_PROFILE") == "unit" do
      File.write!(path, "unit\n")
    end

    assert true
  end
end

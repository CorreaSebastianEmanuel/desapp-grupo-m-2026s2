defmodule FootballMarket.ProfileUnitSentinelTest do
  use ExUnit.Case, async: true

  @moduletag :unit

  test "writes opaque completion evidence only for the selected unit profile" do
    case {System.get_env("CP1_PROFILE_SENTINEL_PATH"), System.get_env("CP1_PROFILE")} do
      {path, "unit"} when is_binary(path) -> File.write!(path, "unit\n")
      _ -> :ok
    end

    assert true
  end
end

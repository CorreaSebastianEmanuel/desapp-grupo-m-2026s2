defmodule FootballMarket.ProfileIntegrationSentinelTest do
  use ExUnit.Case, async: true

  @moduletag :integration

  test "writes opaque completion evidence only for the selected integration profile" do
    case {System.get_env("CP1_PROFILE_SENTINEL_PATH"), System.get_env("CP1_PROFILE")} do
      {path, "integration"} when is_binary(path) -> File.write!(path, "integration\n")
      _ -> :ok
    end

    assert true
  end
end

defmodule FootballMarket.Infrastructure.RedisTest do
  use ExUnit.Case, async: true
  alias FootballMarket.Infrastructure.Redis

  test "exposes only connectivity operations" do
    assert Code.ensure_loaded?(Redis)
    assert function_exported?(Redis, :start_link, 1)
    assert function_exported?(Redis, :ping, 1)
    refute function_exported?(Redis, :get, 2)
    refute function_exported?(Redis, :set, 3)
  end
end

defmodule FootballMarket.Infrastructure.ConfigurationTest do
  use FootballMarket.InfrastructureCase, async: true

  test "parses defaults and environment overrides" do
    assert %{hostname: "db", port: 5544, database: "sample"} =
             Configuration.postgres(
               %{"POSTGRES_HOST" => "db", "POSTGRES_PORT" => "5544", "POSTGRES_DB" => "sample"},
               :dev
             )

    assert %{host: "cache", port: 6380} =
             Configuration.redis(%{"REDIS_HOST" => "cache", "REDIS_PORT" => "6380"})
  end

  test "test database identity is fail closed" do
    assert :ok =
             Configuration.validate_test_database!("football_market_test", "football_market_dev")

    assert :ok =
             Configuration.validate_test_database!(
               "football_market_test7",
               "football_market_dev",
               "7"
             )

    assert_raise ArgumentError, ~r/unsafe test database identity/, fn ->
      Configuration.validate_test_database!("football_market_dev", "football_market_dev")
    end

    assert_raise ArgumentError, ~r/unsafe test database identity/, fn ->
      Configuration.validate_test_database!("another", "football_market_dev")
    end
  end

  test "targets and errors omit credentials" do
    config = Configuration.postgres(%{"POSTGRES_PASSWORD" => "top-secret"}, :dev)
    refute Configuration.safe_target(:postgresql, config) =~ "top-secret"

    refute Configuration.sanitize("password=top-secret ecto://u:top-secret@localhost/db", [
             "top-secret"
           ]) =~ "top-secret"
  end

  test "invalid ports fail by configuration category" do
    assert_raise ArgumentError, ~r/invalid PostgreSQL configuration/, fn ->
      Configuration.postgres(%{"POSTGRES_PORT" => "wrong"}, :dev)
    end
  end
end

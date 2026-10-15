defmodule Task028ReviewPrefixTest do
  use ExUnit.Case, async: false
  import FootballMarket.MarketCase
  alias FootballMarket.Repo

  test "issuance migration seeds its explicit prefix independently of search_path" do
    source = private_schema()
    target = "market_test_" <> String.replace(Ecto.UUID.generate(), "-", "")
    Repo.query!("CREATE SCHEMA #{target}")
    Repo.query!("CREATE TABLE #{target}.users(id uuid PRIMARY KEY)")
    Repo.query!("CREATE TABLE #{target}.players(id uuid PRIMARY KEY)")
    before = Repo.query!("SELECT id FROM #{source.schema}.market_initialization_locks").rows

    result =
      try do
        Ecto.Migrator.up(
          Repo,
          20261014000000,
          FootballMarket.Repo.Migrations.CreateInitialPlayerIssuance,
          prefix: target,
          log: false
        )
      rescue
        error in Postgrex.Error ->
          {:migration_error, error.postgres.code, error.postgres[:constraint]}
      end

    assert before == Repo.query!("SELECT id FROM #{source.schema}.market_initialization_locks").rows
    assert result == :ok,
           "explicit-prefix migration instead resolved seed through search_path: #{inspect(result)}"
    assert Repo.query!("SELECT id FROM #{target}.market_initialization_locks").rows == [[1]]
  end
end

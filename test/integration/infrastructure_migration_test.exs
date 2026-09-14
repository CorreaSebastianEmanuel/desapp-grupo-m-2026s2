defmodule FootballMarket.InfrastructureMigrationTest do
  use ExUnit.Case, async: true

  test "migration is infrastructure-only and reversible" do
    source = File.read!("priv/repo/migrations/20260913000000_create_infrastructure_probe.exs")
    assert source =~ "infrastructure_probe"
    assert source =~ "def down"
    refute source =~ ~r/users|players|quotes|transactions/
  end
end

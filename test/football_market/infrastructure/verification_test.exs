defmodule FootballMarket.Infrastructure.VerificationTest do
  use ExUnit.Case, async: true
  alias FootballMarket.Infrastructure.Verification

  test "renders both results and fails closed" do
    results = [
      %{dependency: :postgresql, target: "postgresql://db:5432/a", status: :ok},
      %{dependency: :redis, target: "redis://cache:6379", status: {:error, :unavailable}}
    ]

    assert Verification.exit_status(results) == 1
    output = Verification.render(results)
    assert output =~ "PostgreSQL: OK"
    assert output =~ "Redis: ERROR unavailable"
  end

  test "only two successes produce success" do
    assert Verification.exit_status([%{status: :ok}, %{status: :ok}]) == 0
  end
end

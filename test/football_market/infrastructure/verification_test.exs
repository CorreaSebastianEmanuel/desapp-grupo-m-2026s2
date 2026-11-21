defmodule FootballMarket.Infrastructure.VerificationTest do
  use ExUnit.Case, async: true

  @moduletag :unit
  alias FootballMarket.Infrastructure.Verification
  alias FootballMarket.Infrastructure.Health

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

  test "readiness keeps the application ready when only Redis is unavailable" do
    result =
      Health.readiness(%{
        postgresql: fn -> :ready end,
        redis: fn -> {:error, :offline} end,
        oban: fn -> :ready end
      })

    assert result == %{
             status: :ready,
             dependencies: %{postgresql: :ready, redis: :degraded, oban: :ready}
           }
  end

  test "readiness fails when PostgreSQL or Oban is unavailable" do
    for dependency <- [:postgresql, :oban] do
      probes = %{postgresql: fn -> :ready end, redis: fn -> :ready end, oban: fn -> :ready end}
      result = Health.readiness(Map.put(probes, dependency, fn -> :unavailable end))

      assert result.status == :unavailable
      assert result.dependencies[dependency] == :unavailable
    end
  end

  test "readiness fails closed on raised probe errors without exposing diagnostics" do
    assert Health.readiness(%{
             postgresql: fn -> raise "private diagnostic" end,
             redis: fn -> :ready end,
             oban: fn -> :ready end
           }) == %{
             status: :unavailable,
             dependencies: %{postgresql: :unavailable, redis: :ready, oban: :ready}
           }
  end
end

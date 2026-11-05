defmodule FootballMarket.Market.ConditionalOrders.ProjectionTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.{ConditionalOrder, ConditionalOrderStore}

  test "before equal and after expiry preserve every persisted status without side effects" do
    expiry = ~U[2026-10-27 12:00:00.000000Z]

    for status <- ~w(pending executed expired cancelled rejected),
        {delta, expected} <- [{-1, false}, {0, true}, {1, true}] do
      record = %ConditionalOrder{status: status, expires_at: expiry}
      result = ConditionalOrderStore.project(record, DateTime.add(expiry, delta, :microsecond))
      assert result.status == status
      assert result.expiry_reached == expected

      assert Map.drop(result, [:expiry_reached, :execution]) ==
               record |> Map.from_struct() |> Map.drop([:__meta__])

      assert result.execution == nil
    end
  end
end

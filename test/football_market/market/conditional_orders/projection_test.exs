defmodule FootballMarket.Market.ConditionalOrders.ProjectionTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.ConditionalOrderProjection, as: Projection

  test "before equal and after expiry preserve every persisted status without side effects" do
    expiry = ~U[2026-10-27 12:00:00.000000Z]

    for status <- ~w(pending executed expired cancelled rejected),
        {delta, expected} <- [{-1, false}, {0, true}, {1, true}] do
      record = %{status: status, expires_at: expiry}
      result = Projection.at(record, DateTime.add(expiry, delta, :microsecond))
      assert result.status == status
      assert result.expiry_reached == expected
      assert Map.delete(result, :expiry_reached) == record
    end
  end
end

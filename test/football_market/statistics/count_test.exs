defmodule FootballMarket.Statistics.CountTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Statistics.Count

  test "exact casts dumps and loads" do
    for n <- [0, 123, 999_999_999_999_999_999_999_999_999_999] do
      assert {:ok, ^n} = Count.cast(n)
      assert {:ok, d} = Count.dump(n)
      assert {:ok, ^n} = Count.load(d)
    end

    assert {:ok, nil} = Count.cast(nil)
    for value <- [-1, 1.0, "1", true, false], do: assert(Count.cast(value) == :error)

    for value <- [
          Decimal.new("NaN"),
          Decimal.new("Infinity"),
          Decimal.new("1.5"),
          Decimal.new("-1")
        ],
        do: assert(Count.load(value) == :error)
  end
end

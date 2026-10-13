defmodule FootballMarket.Valuation.NormalizationTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Valuation.DecimalMath, as: M

  test "exact ratios, saturation and half-away rounding independent of Decimal context" do
    for {n, r, want} <- [
          {0, 4, "0.000000"},
          {3, 4, "0.750000"},
          {4, 4, "1.000000"},
          {9, 4, "1.000000"},
          {1, 6, "0.166667"},
          {1, 128, "0.007813"},
          {1, Decimal.new("2.5"), "0.400000"},
          {Integer.pow(10, 100), 4, "1.000000"},
          {1, Decimal.new("2000000.0000000000000000000000001"), "0.000000"},
          {1, Decimal.new("1999999.9999999999999999999999999"), "0.000001"},
          {1, 2_000_000, "0.000001"}
        ] do
      Decimal.Context.with(%Decimal.Context{precision: 2}, fn ->
        assert M.normalize(n, r) == want
      end)
    end

    for {s, want} <- [
          {"1.2345674", "1.234567"},
          {"1.2345675", "1.234568"},
          {"-1.2345675", "-1.234568"},
          {"-0.0000004", "0.000000"}
        ] do
      assert M.round(Decimal.new(s)) == want
    end
  end

  test "exact signed cancellation beyond context precision" do
    Decimal.Context.with(%Decimal.Context{precision: 2}, fn ->
      terms = [
        {Decimal.new("1.000000"), Decimal.new(1, Integer.pow(10, 45) + 1_234_567, -7)},
        {Decimal.new("1.000000"), Decimal.new(-Integer.pow(10, 38))}
      ]

      assert M.round(M.weighted(terms)) == "0.123457"
    end)
  end
end

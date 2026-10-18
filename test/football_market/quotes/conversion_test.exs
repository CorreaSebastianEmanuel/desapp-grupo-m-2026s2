defmodule FootballMarket.Quotes.ConversionTest do
  use ExUnit.Case, async: true
  @moduletag :unit

  alias FootballMarket.Quotes.Conversion

  test "exact conversion rounds ties away and returns explicit no quote for zero cents" do
    assert {:ok, price} = Conversion.convert(Decimal.new("2"), Decimal.new("1.25"))
    assert Decimal.equal?(price, Decimal.new("2.50"))
    assert {:ok, rounded} = Conversion.convert(Decimal.new("1.005"), Decimal.new("1"))
    assert Decimal.equal?(rounded, Decimal.new("1.01"))

    assert {:no_quote, :nonpositive_converted_result} =
             Conversion.convert(Decimal.new("0.004"), Decimal.new("1"))

    assert {:no_quote, :nonpositive_score} =
             Conversion.convert(Decimal.new("-1"), Decimal.new("1"))
  end

  test "rejects nonpositive scale and does not depend on Decimal context" do
    assert {:error, :invalid_scale} = Conversion.convert(Decimal.new("2"), Decimal.new("0"))
    assert {:error, :invalid_scale} = Conversion.convert(Decimal.new("2"), Decimal.new("-1"))

    for invalid <- [Decimal.new("NaN"), Decimal.new("Infinity"), Decimal.new("-Infinity")] do
      assert {:error, :invalid_scale} = Conversion.convert(Decimal.new("2"), invalid)
    end

    assert {:error, :invalid_decimal} =
             Conversion.convert(Decimal.new("NaN"), Decimal.new("1"))

    assert {:error, :invalid_decimal} =
             Conversion.convert(Decimal.new("Infinity"), Decimal.new("1"))

    value =
      Decimal.Context.with(%Decimal.Context{precision: 1}, fn ->
        Conversion.convert(Decimal.new("1.005"), Decimal.new("1"))
      end)

    assert {:ok, rounded} = value
    assert Decimal.equal?(rounded, Decimal.new("1.01"))
  end

  test "is monotonic and handles exponent changes without binary floating point" do
    values = ["0.01", "0.1", "1", "1.005", "10", "1000000"]

    prices =
      Enum.map(values, fn value ->
        elem(Conversion.convert(Decimal.new(value), Decimal.new("1.25")), 1)
      end)

    assert Enum.chunk_every(prices, 2, 1, :discard)
           |> Enum.all?(fn [left, right] -> Decimal.compare(left, right) != :gt end)

    assert {:ok, tiny} = Conversion.convert(Decimal.new("1e-100"), Decimal.new("1e100"))
    assert Decimal.equal?(tiny, Decimal.new("1.00"))
  end
end

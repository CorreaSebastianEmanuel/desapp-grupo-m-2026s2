defmodule FootballMarket.Valuation.Balanced.ArithmeticTest do
  use FootballMarket.DataCase, async: false
  @moduletag :integration
  import FootballMarket.ValuationCase
  alias FootballMarket.Valuation
  alias FootballMarket.Valuation.{Balanced, Definition, DecimalMath}

  defp check(f, weights, references, expected) do
    d = %Definition{
      module: Balanced,
      strategy_id: "balanced",
      version: "1",
      config: %{weights: weights}
    }

    req = request(f, %{requirements: %{overall: Map.keys(weights)}, references: references})
    assert {:ok, prepared} = Valuation.prepare(req)
    assert {:ok, result} = Valuation.evaluate(req, d)
    assert result.score == expected
    assert {:ok, ^result} = Valuation.score(prepared, d)
    assert {:ok, ^result} = Valuation.replay(result.descriptor, d)
    result
  end

  test "rounded features, exact products, signed ties and canonical zero" do
    f = fixture()
    record(f, "fractions", %{goals: 1, assists: 1})

    assert check(f, %{goals: 3}, %{goals: 6}, "0.500001").prepared.scopes.overall.features.goals ==
             "0.166667"

    for {weight, expected} <- [{"0.000001", "0.000001"}, {"-0.000001", "-0.000001"}] do
      w = Decimal.new(weight)
      check(f, %{goals: w, assists: w}, %{goals: 2, assists: 2}, expected)
      check(f, %{goals: w}, %{goals: 2}, expected)
    end

    check(f, %{goals: Decimal.new("-0.0000004")}, %{goals: 1}, "0.000000")

    check(
      f,
      %{
        goals: 1_000_000_000_000_000_000_000_000_000_001,
        assists: -1_000_000_000_000_000_000_000_000_000_000
      },
      %{goals: 1, assists: 1},
      "1.000000"
    )
  end

  test "cancellation before alignment, disparate exponents and both signed residual ties" do
    f = fixture()
    record(f, "saturated", %{goals: 1, assists: 1, tackles: 1})
    original = Decimal.Context.get()
    on_exit(fn -> Decimal.Context.set(original) end)

    for {precision, rounding} <- [{1, :down}, {3, :ceiling}, {100, :half_even}],
        sign <- [1, -1],
        {residual, expected} <- [
          {499_999, "0.000000"},
          {500_000, "0.000001"},
          {500_001, "0.000001"}
        ] do
      Decimal.Context.set(%{original | precision: precision, rounding: rounding})
      expected = if sign < 0 and expected != "0.000000", do: "-" <> expected, else: expected

      for {a, b} <- [
            {%Decimal{sign: 1, coef: 1, exp: 1000}, %Decimal{sign: -1, coef: 10, exp: 999}},
            {%Decimal{sign: 1, coef: 100, exp: 998}, %Decimal{sign: -1, coef: 1, exp: 1000}}
          ] do
        weights = %{goals: a, assists: b, tackles: %Decimal{sign: sign, coef: residual, exp: -12}}
        check(f, weights, %{goals: 1, assists: 1, tackles: 1}, expected)
        terms = [{Decimal.new(1), a}, {Decimal.new(1), b}, {Decimal.new(1), weights.tackles}]

        for perm <- permutations(terms) do
          assert DecimalMath.round(DecimalMath.weighted(perm)) == expected
        end
      end
    end

    assert DecimalMath.weighted([
             {Decimal.new(1), Decimal.new("1E-1000")},
             {Decimal.new(1), Decimal.new("-1E-1000")}
           ]) == Decimal.new(0)

    assert DecimalMath.round(
             DecimalMath.weighted([
               {Decimal.new(1), Decimal.new("0.000000500001")},
               {Decimal.new(1), Decimal.new("-1E-1000")}
             ])
           ) == "0.000001"

    assert DecimalMath.round(
             DecimalMath.weighted([
               {Decimal.new(1), Decimal.new("0.0000005")},
               {Decimal.new(1), Decimal.new("-1E-1000")}
             ])
           ) == "0.000000"

    assert DecimalMath.round(
             DecimalMath.weighted([
               {Decimal.new(1), Decimal.new("-0.0000005")},
               {Decimal.new(1), Decimal.new("1E-1000")}
             ])
           ) == "0.000000"
  end

  test "zero factors never scale and accepted large counts have only feature saturation" do
    for exponent <- [-10_000, 10_000], sign <- [-1, 1] do
      wide = %Decimal{sign: sign, coef: 1, exp: exponent}
      zero = %Decimal{sign: sign, coef: 0, exp: exponent}

      assert DecimalMath.weighted([{Decimal.new(0), wide}, {wide, 0}, {zero, wide}]) ==
               Decimal.new(0)
    end

    f = fixture()
    count = Integer.pow(10, 40)
    record(f, "large", %{goals: count, assists: count})
    check(f, %{goals: 2, assists: 2}, %{goals: count * 2, assists: 1}, "3.000000")
  end

  defp permutations([]), do: [[]]
  defp permutations(xs), do: for(x <- xs, rest <- permutations(xs -- [x]), do: [x | rest])
end

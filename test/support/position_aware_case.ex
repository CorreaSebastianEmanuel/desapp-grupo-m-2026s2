defmodule FootballMarket.PositionAwareCase do
  @moduledoc "Explicit test rules and fixtures; independent integer-rational expectations."
  import ExUnit.Assertions
  alias FootballMarket.{Catalog, Valuation, ValuationCase}
  alias FootballMarket.Valuation.{Definition, PositionAware, Request}

  def groups, do: [:goalkeeper, :defender, :midfielder, :forward]
  def rules(metrics), do: Map.new(groups(), &{&1, metrics})

  def definition(weights),
    do: %Definition{
      module: PositionAware,
      strategy_id: "position_aware",
      version: "1",
      config: %{weights: weights}
    }

  def position_request(f, d, references, overrides \\ %{}) do
    requirements =
      Map.new(d.config.weights, fn {g, w} ->
        {g, Enum.filter(Request.metrics(), &Map.has_key?(w, &1))}
      end)

    ValuationCase.request(
      f,
      Map.merge(%{requirements: requirements, references: references}, overrides)
    )
  end

  def position do
    {:ok, p} = Catalog.create_position(FootballMarket.CatalogCase.position_attrs())
    p
  end

  def calculate(f, d, references, overrides \\ %{}) do
    req = position_request(f, d, references, overrides)
    assert {:ok, p} = Valuation.prepare(req)
    assert {:ok, result} = Valuation.evaluate(req, d)
    assert {:ok, ^result} = Valuation.score(p, d)
    assert {:ok, ^result} = Valuation.replay(result.descriptor, d)
    result
  end

  # Independent oracle: only integer fractions and quotient/remainder rounding.
  # Decimal structs are decoded as data; no production numeric helper is used.
  def ratio(n) when is_integer(n), do: {n, 1}

  def ratio(%Decimal{sign: sign, coef: c, exp: e}) when e >= 0,
    do: {sign * c * Integer.pow(10, e), 1}

  def ratio(%Decimal{sign: sign, coef: c, exp: e}),
    do: {sign * c, Integer.pow(10, -e)}

  def feature_units(count, reference) do
    {rn, rd} = ratio(reference)
    round_units(min(count * rd, rn) * 1_000_000, rn)
  end

  def oracle(weights, counts, references) do
    {n, d} =
      Enum.reduce(counts, {0, 1}, fn {g, metrics}, sum ->
        Enum.reduce(weights[g], sum, fn {metric, weight}, {n, d} ->
          feature = feature_units(Map.fetch!(metrics, metric), references[metric])
          {wn, wd} = ratio(weight)
          term_d = wd * 1_000_000
          total_n = n * term_d + feature * wn * d
          total_d = d * term_d
          gcd = Integer.gcd(abs(total_n), total_d)
          {div(total_n, gcd), div(total_d, gcd)}
        end)
      end)

    fixed(round_units(n * 1_000_000, d))
  end

  defp round_units(n, d) do
    units = div(abs(n), d) + if(2 * rem(abs(n), d) >= d, do: 1, else: 0)
    if n < 0, do: -units, else: units
  end

  def fixed(units) do
    sign = if units < 0, do: "-", else: ""

    sign <>
      Integer.to_string(div(abs(units), 1_000_000)) <>
      "." <>
      String.pad_leading(Integer.to_string(rem(abs(units), 1_000_000)), 6, "0")
  end

  def vectors do
    huge = Integer.pow(10, 30)

    named = [
      {[%{goals: Decimal.new("0.0000005"), assists: Decimal.new("-1E-1000")}, %{goals: 0}],
       %{goals: 1, assists: 1}},
      {[%{goals: Decimal.new("-0.0000005")}, %{goals: Decimal.new("1E-1000")}], %{goals: 1}},
      {[%{goals: Decimal.new("0.000000500001")}, %{goals: Decimal.new("-1E-1000")}], %{goals: 1}},
      {[%{goals: 3}, %{goals: 0}], %{goals: 6}},
      {[%{goals: 1}, %{goals: 0}], %{goals: 128}},
      {[%{goals: Decimal.new("-0.0000004")}, %{goals: 0}], %{goals: 1}},
      {[%{goals: huge + 1, assists: -huge}, %{goals: 0}], %{goals: 1, assists: 1}},
      {[%{goals: huge + 1}, %{goals: -huge}], %{goals: 1}}
    ]

    ties =
      for sign <- [-1, 1], mode <- [:within, :single, :cross, :residual, :cancel] do
        tie_vector(sign, mode)
      end

    exponents =
      for sign <- [-1, 1], residual <- [499_999, 500_000, 500_001], split <- [false, true] do
        a = %Decimal{sign: 1, coef: 1, exp: 1000}
        b = %Decimal{sign: -1, coef: 10, exp: 999}
        c = %Decimal{sign: sign, coef: residual, exp: -12}

        if split,
          do: {[%{goals: a, tackles: c}, %{goals: b}], %{goals: 1, tackles: 1}},
          else:
            {[%{goals: a, assists: b, tackles: c}, %{goals: 0}],
             %{goals: 1, assists: 1, tackles: 1}}
      end

    generated =
      for n <- 1..48 do
        {[
           %{
             goals: %Decimal{
               sign: if(rem(n, 2) == 0, do: 1, else: -1),
               coef: n * 17,
               exp: -rem(n, 8)
             },
             assists: n - 24
           },
           %{goals: %Decimal{sign: -1, coef: n * 13, exp: -rem(n, 5)}}
         ], %{goals: n + 1, assists: %Decimal{sign: 1, coef: n + 3, exp: -1}}}
      end

    Enum.map(named ++ ties ++ exponents ++ generated, fn {[defender, forward], refs} ->
      {rules(%{goals: 0}) |> Map.put(:defender, defender) |> Map.put(:forward, forward), refs}
    end)
  end

  defp tie_vector(sign, mode) do
    w = %Decimal{sign: sign, coef: 1, exp: -6}

    weights =
      case mode do
        :within -> [%{goals: w, assists: w}, %{goals: 0}]
        :single -> [%{goals: w}, %{goals: 0}]
        :cross -> [%{goals: w}, %{goals: w}]
        :residual -> [%{goals: %{w | coef: 2}}, %{goals: %{w | sign: -sign}}]
        :cancel -> [%{goals: w}, %{goals: %{w | sign: -sign}}]
      end

    {weights, if(mode == :within, do: %{goals: 2, assists: 2}, else: %{goals: 2})}
  end

  def permutations([]), do: [[]]
  def permutations(xs), do: for(x <- xs, rest <- permutations(xs -- [x]), do: [x | rest])

  def oracle_summary(vectors, counts) do
    expected = Enum.map(vectors, fn {weights, refs} -> oracle(weights, counts, refs) end)

    checksum =
      :crypto.hash(:sha256, :erlang.term_to_binary({vectors, expected}))
      |> Base.encode16(case: :lower)

    %{count: length(vectors), checksum: checksum}
  end
end

defmodule FootballMarket.Valuation.PositionAware.ReplayTest.CallbackProbe do
  @moduledoc false
  alias FootballMarket.Valuation.PositionAware
  defdelegate identity(), to: PositionAware
  defdelegate validate_config(config), to: PositionAware
  defdelegate requirements(config), to: PositionAware

  def score(view, config) do
    send(self(), :position_callback)
    PositionAware.score(view, config)
  end
end

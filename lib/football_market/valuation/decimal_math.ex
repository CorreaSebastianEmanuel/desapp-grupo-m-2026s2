defmodule FootballMarket.Valuation.DecimalMath do
  @moduledoc "Exact integer-rational arithmetic, independent of ambient Decimal context."
  def finite?(n) when is_integer(n), do: true

  def finite?(%Decimal{sign: s, coef: c, exp: e} = d),
    do: map_size(d) == 4 and s in [-1, 1] and is_integer(c) and c >= 0 and is_integer(e)

  def finite?(_), do: false

  def ratio(n) when is_integer(n), do: {n, 1}
  def ratio(%Decimal{sign: s, coef: c, exp: e}) when e >= 0, do: {s * c * Integer.pow(10, e), 1}
  def ratio(%Decimal{sign: s, coef: c, exp: e}), do: {s * c, Integer.pow(10, -e)}

  def positive?(n) do
    finite?(n) and elem(ratio(n), 0) > 0
  end

  def normalize(total, reference) do
    {n, d} = ratio(reference)
    if total * d >= n, do: "1.000000", else: fixed(rounded(total * d, n))
  end

  def round(decimal) do
    {n, d} = ratio(decimal)
    fixed(rounded(n, d))
  end

  defp rounded(n, d) do
    scaled = abs(n) * 1_000_000
    q = div(scaled, d)
    magnitude = if rem(scaled, d) * 2 >= d, do: q + 1, else: q
    if n < 0, do: -magnitude, else: magnitude
  end

  defp fixed(n) do
    sign = if n < 0, do: "-", else: ""

    sign <>
      Integer.to_string(div(abs(n), 1_000_000)) <>
      "." <> String.pad_leading(Integer.to_string(rem(abs(n), 1_000_000)), 6, "0")
  end

  def weighted(terms) do
    contributions =
      Enum.reduce(terms, %{}, fn {feature, weight}, acc ->
        {fc, fe} = coefficient(feature)
        {wc, we} = coefficient(weight)

        if fc == 0 or wc == 0 do
          acc
        else
          {c, e} = canonical(fc * wc, fe + we)
          Map.put(acc, e, Map.get(acc, e, 0) + c)
        end
      end)
      |> Enum.reject(fn {_, c} -> c == 0 end)

    case contributions do
      [] ->
        %Decimal{sign: 1, coef: 0, exp: 0}

      terms ->
        exponent = terms |> Enum.map(&elem(&1, 0)) |> Enum.min()
        sum = Enum.reduce(terms, 0, fn {e, c}, acc -> acc + c * Integer.pow(10, e - exponent) end)
        {c, e} = canonical(sum, exponent)
        %Decimal{sign: if(c < 0, do: -1, else: 1), coef: abs(c), exp: e}
    end
  end

  defp coefficient(n) when is_integer(n), do: {n, 0}
  defp coefficient(%Decimal{sign: s, coef: c, exp: e}), do: {s * c, e}
  defp canonical(0, _), do: {0, 0}

  defp canonical(c, e) do
    if rem(c, 10) == 0, do: canonical(div(c, 10), e + 1), else: {c, e}
  end
end

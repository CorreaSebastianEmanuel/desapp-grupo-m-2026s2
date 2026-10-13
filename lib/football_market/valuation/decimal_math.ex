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
    {n, d} =
      Enum.reduce(terms, {0, 1}, fn {feature, weight}, {an, ad} ->
        {fn_, fd} = ratio(feature)
        {wn, wd} = ratio(weight)
        {an * fd * wd + fn_ * wn * ad, ad * fd * wd}
      end)

    # All terms are finite decimals, hence the denominator is a power of ten.
    decimal(n, d, 0)
  end

  defp decimal(n, 1, e), do: %Decimal{sign: if(n < 0, do: -1, else: 1), coef: abs(n), exp: e}
  defp decimal(n, d, e), do: decimal(n, div(d, 10), e - 1)
end

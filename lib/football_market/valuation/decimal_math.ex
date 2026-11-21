defmodule FootballMarket.Valuation.DecimalMath do
  @moduledoc """
  Exact integer-rational arithmetic for valuation formulas.

  All calculations run over exact integer numerators/denominators rather than
  floating-point numbers or ambient `Decimal` context settings, ensuring every
  replay produces bit-for-bit identical 6-decimal scores.
  """

  def finite?(number) when is_integer(number), do: true

  def finite?(%Decimal{sign: sign, coef: coefficient, exp: exponent} = decimal) do
    map_size(decimal) == 4 and sign in [-1, 1] and is_integer(coefficient) and
      coefficient >= 0 and is_integer(exponent)
  end

  def finite?(_), do: false

  def ratio(number) when is_integer(number), do: {number, 1}

  def ratio(%Decimal{sign: sign, coef: coefficient, exp: exponent}) when exponent >= 0,
    do: {sign * coefficient * Integer.pow(10, exponent), 1}

  def ratio(%Decimal{sign: sign, coef: coefficient, exp: exponent}),
    do: {sign * coefficient, Integer.pow(10, -exponent)}

  def positive?(number), do: finite?(number) and elem(ratio(number), 0) > 0

  @doc "Normalizes `total / reference` capped at `1.000000` with 6-decimal half-away rounding."
  def normalize(total, reference) do
    {numerator, denominator} = ratio(reference)

    if total * denominator >= numerator,
      do: "1.000000",
      else: format_fixed(round_scaled(total * denominator, numerator))
  end

  @doc "Formats a finite Decimal or integer to 6 decimal places using half-away-from-zero rounding."
  def round(decimal) do
    {numerator, denominator} = ratio(decimal)
    format_fixed(round_scaled(numerator, denominator))
  end

  @doc "Computes an exact weighted sum `sum(feature * weight)` without floating-point drift."
  def weighted(terms) do
    grouped_by_exponent =
      terms
      |> Enum.reduce(%{}, fn {feature, weight}, acc ->
        {feature_coef, feature_exp} = signed_parts(feature)
        {weight_coef, weight_exp} = signed_parts(weight)

        if feature_coef == 0 or weight_coef == 0 do
          acc
        else
          {coef, exp} = canonical_parts(feature_coef * weight_coef, feature_exp + weight_exp)
          Map.put(acc, exp, Map.get(acc, exp, 0) + coef)
        end
      end)
      |> Enum.reject(fn {_exp, coef} -> coef == 0 end)

    case grouped_by_exponent do
      [] ->
        %Decimal{sign: 1, coef: 0, exp: 0}

      non_zero_terms ->
        min_exponent = non_zero_terms |> Enum.map(fn {exp, _coef} -> exp end) |> Enum.min()

        total_coef =
          Enum.reduce(non_zero_terms, 0, fn {exp, coef}, acc ->
            acc + coef * Integer.pow(10, exp - min_exponent)
          end)

        {coef, exp} = canonical_parts(total_coef, min_exponent)
        %Decimal{sign: if(coef < 0, do: -1, else: 1), coef: abs(coef), exp: exp}
    end
  end

  defp round_scaled(numerator, denominator) do
    scaled = abs(numerator) * 1_000_000
    quotient = div(scaled, denominator)
    magnitude = if rem(scaled, denominator) * 2 >= denominator, do: quotient + 1, else: quotient
    if numerator < 0, do: -magnitude, else: magnitude
  end

  defp format_fixed(scaled_value) do
    sign = if scaled_value < 0, do: "-", else: ""
    whole = Integer.to_string(div(abs(scaled_value), 1_000_000))
    fraction = String.pad_leading(Integer.to_string(rem(abs(scaled_value), 1_000_000)), 6, "0")
    sign <> whole <> "." <> fraction
  end

  defp signed_parts(number) when is_integer(number), do: {number, 0}
  defp signed_parts(%Decimal{sign: sign, coef: coef, exp: exp}), do: {sign * coef, exp}

  defp canonical_parts(0, _exponent), do: {0, 0}

  defp canonical_parts(coef, exp) when rem(coef, 10) == 0,
    do: canonical_parts(div(coef, 10), exp + 1)

  defp canonical_parts(coef, exp), do: {coef, exp}
end

defmodule FootballMarket.Quotes.Conversion do
  @moduledoc false

  @rounding "two-half-away-v1"

  def convert(%Decimal{} = score, %Decimal{} = scale) do
    with :ok <- positive_finite(scale), :ok <- finite(score) do
      product = multiply(score, scale)
      cents = round_cents(product)

      if cents > 0 do
        {:ok, %Decimal{sign: if(cents < 0, do: -1, else: 1), coef: abs(cents), exp: -2}}
      else
        {:no_quote,
         if(Decimal.compare(score, Decimal.new(0)) != :gt,
           do: :nonpositive_score,
           else: :nonpositive_converted_result
         )}
      end
    else
      {:error, _} = error -> error
    end
  end

  def convert(_, _), do: {:error, :invalid_decimal}
  def rounding_rule, do: @rounding

  defp positive_finite(%Decimal{coef: coef} = d) when is_integer(coef) do
    if Decimal.compare(d, Decimal.new(0)) == :gt, do: :ok, else: {:error, :invalid_scale}
  end

  defp positive_finite(_), do: {:error, :invalid_scale}

  defp finite(%Decimal{coef: coef}) when is_integer(coef), do: :ok
  defp finite(_), do: {:error, :invalid_decimal}

  defp multiply(a, b) do
    %Decimal{sign: a.sign * b.sign, coef: a.coef * b.coef, exp: a.exp + b.exp}
  end

  defp round_cents(%Decimal{sign: sign, coef: coef, exp: exp}) do
    n = coef * sign
    cent_exp = exp + 2

    cond do
      cent_exp >= 0 ->
        n * Integer.pow(10, cent_exp)

      true ->
        divisor = Integer.pow(10, -cent_exp)
        whole = div(abs(n), divisor)
        remainder = rem(abs(n), divisor)
        rounded = if remainder * 2 >= divisor, do: whole + 1, else: whole
        if n < 0, do: -rounded, else: rounded
    end
  end
end

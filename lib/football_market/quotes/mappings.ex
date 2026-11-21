defmodule FootballMarket.Quotes.Mappings do
  @moduledoc """
  Immutable score-to-price conversion mappings and exact cent-rounding arithmetic.

  Converts a player's 6-decimal valuation score into a 2-decimal market quote
  using `score * scale` with exact half-away-from-zero rounding (`two-half-away-v1`).
  """

  alias FootballMarket.Quotes.Mapping
  alias FootballMarket.Repo

  @rounding_rule "two-half-away-v1"

  # --- Mapping Persistence ---

  def save(name, version, %Decimal{} = scale) when is_binary(name) and is_binary(version) do
    with :ok <- valid_name(name),
         :ok <- valid_name(version),
         :ok <- positive_scale(scale) do
      %Mapping{}
      |> Mapping.changeset(%{
        id: Ecto.UUID.generate(),
        name: name,
        version: version,
        scale: scale,
        rounding_rule: @rounding_rule,
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:microsecond)
      })
      |> Repo.insert()
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def save(_, _, _), do: {:error, :invalid_mapping}

  def get(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         %Mapping{} = mapping <- Repo.get(Mapping, uuid) do
      {:ok, mapping}
    else
      _ -> {:error, :mapping_unavailable}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  # --- Exact Score-to-Price Conversion ---

  def rounding_rule, do: @rounding_rule

  def convert(%Decimal{} = score, %Decimal{} = scale) do
    with :ok <- require_positive_finite_scale(scale),
         :ok <- require_finite_score(score) do
      score |> multiply_exact(scale) |> round_to_cents() |> to_quote_result(score)
    end
  end

  def convert(_, _), do: {:error, :invalid_decimal}

  defp to_quote_result(cents, _score) when cents > 0,
    do: {:ok, %Decimal{sign: 1, coef: cents, exp: -2}}

  defp to_quote_result(_cents, score) do
    reason =
      if Decimal.compare(score, Decimal.new(0)) != :gt,
        do: :nonpositive_score,
        else: :nonpositive_converted_result

    {:no_quote, reason}
  end

  # --- Private Helpers ---

  defp valid_name(value),
    do: if(String.trim(value) != "", do: :ok, else: {:error, :invalid_mapping})

  defp positive_scale(%Decimal{} = value),
    do:
      if(Decimal.compare(value, Decimal.new(0)) == :gt, do: :ok, else: {:error, :invalid_mapping})

  defp require_positive_finite_scale(%Decimal{coef: coef} = decimal) when is_integer(coef) do
    if Decimal.compare(decimal, Decimal.new(0)) == :gt, do: :ok, else: {:error, :invalid_scale}
  end

  defp require_positive_finite_scale(_), do: {:error, :invalid_scale}

  defp require_finite_score(%Decimal{coef: coef}) when is_integer(coef), do: :ok
  defp require_finite_score(_), do: {:error, :invalid_decimal}

  defp multiply_exact(left, right) do
    %Decimal{
      sign: left.sign * right.sign,
      coef: left.coef * right.coef,
      exp: left.exp + right.exp
    }
  end

  defp round_to_cents(%Decimal{sign: sign, coef: coef, exp: exp}) do
    signed_coef = coef * sign
    cent_exp = exp + 2

    if cent_exp >= 0 do
      signed_coef * Integer.pow(10, cent_exp)
    else
      divisor = Integer.pow(10, -cent_exp)
      whole = div(abs(signed_coef), divisor)
      remainder = rem(abs(signed_coef), divisor)
      rounded = if remainder * 2 >= divisor, do: whole + 1, else: whole
      if signed_coef < 0, do: -rounded, else: rounded
    end
  end
end

defmodule FootballMarket.Quotes.Result do
  @moduledoc "Pure conversion of valuation scores and failures into retained quote outcomes."
  alias FootballMarket.Valuation
  alias FootballMarket.Quotes.Conversion

  def outcome(score, scale) do
    with {:ok, exact_score} <- exact_score(score) do
      case Conversion.convert(exact_score, scale) do
        {:ok, price} ->
          {:ok, %{status: "successful", reason: nil, price: price, score: exact_score}}

        {:no_quote, reason} ->
          {:ok,
           %{status: "no_quote", reason: Atom.to_string(reason), price: nil, score: exact_score}}

        error ->
          error
      end
    end
  end

  defp exact_score(%Decimal{} = score), do: {:ok, score}

  defp exact_score(score) when is_binary(score) do
    case Decimal.parse(score) do
      {%Decimal{} = decimal, ""} -> {:ok, decimal}
      _ -> {:error, :invalid_decimal}
    end
  end

  defp exact_score(_), do: {:error, :invalid_decimal}

  def safe_failure(%Valuation.Error{kind: :no_recorded_performances}),
    do: {:ok, "no_quote", "no_recorded_performances"}

  def safe_failure(%Valuation.Error{kind: :insufficient_data}),
    do: {:ok, "no_quote", "insufficient_data"}

  def safe_failure(%Valuation.Error{kind: :unsupported_strategy}),
    do: {:ok, "unsupported_strategy", "unsupported_strategy"}

  def safe_failure(%Valuation.Error{kind: kind})
      when kind in [:unavailable_replay, :inconsistent_replay],
      do: {:ok, "unreproducible", "original_unavailable"}

  def safe_failure(%Valuation.Error{}), do: {:ok, "validation_failed", "invalid_valuation_input"}
end

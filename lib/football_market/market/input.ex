defmodule FootballMarket.Market.Input do
  @moduledoc "Pure, assertion-only trusted setup validation."
  alias FootballMarket.Market.Error

  def validate(player, designation, assertions) do
    with {:ok, player} <- identifier(player),
         {:ok, recipient} <- designation(designation),
         :ok <- assertions(assertions, recipient) do
      {:ok, %{player_id: player, recipient_id: recipient}}
    end
  end

  def identifier(id) do
    case Ecto.UUID.cast(id) do
      {:ok, id} -> {:ok, id}
      _ -> Error.new(:invalid_input, :invalid_player)
    end
  end

  defp designation([id]) do
    case Ecto.UUID.cast(id) do
      {:ok, id} -> {:ok, id}
      _ -> Error.new(:invalid_designation, :invalid_recipient)
    end
  end

  defp designation(value) when value in [nil, []],
    do: Error.new(:invalid_designation, :missing_designation)

  defp designation(value) when is_list(value),
    do: Error.new(:invalid_designation, :ambiguous_designation)

  defp designation(_), do: Error.new(:invalid_designation, :invalid_recipient)

  defp assertions(attrs, recipient) when is_map(attrs) do
    cond do
      Enum.any?(Map.keys(attrs), &(&1 not in [:recipient_id, :quantity, :unit_price])) ->
        Error.new(:invalid_input, :unknown_assertion)

      Map.get(attrs, :recipient_id, recipient) != recipient ->
        Error.new(:invalid_input, :wrong_recipient)

      Map.get(attrs, :quantity, 100) !== 100 ->
        Error.new(:invalid_input, :wrong_quantity)

      not exact_one?(Map.get(attrs, :unit_price, 1)) ->
        Error.new(:invalid_input, :wrong_price)

      true ->
        :ok
    end
  end

  defp assertions(_, _), do: Error.new(:invalid_input, :invalid_assertions)

  def exact_one?(1), do: true

  def exact_one?(%Decimal{coef: coef} = d) when is_integer(coef),
    do: Decimal.equal?(d, Decimal.new(1))

  def exact_one?(_), do: false
end

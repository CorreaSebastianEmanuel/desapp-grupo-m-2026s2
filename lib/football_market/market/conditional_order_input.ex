defmodule FootballMarket.Market.ConditionalOrderInput do
  @moduledoc false
  alias FootballMarket.Accounts.AuthenticatedActor
  alias FootballMarket.Market.Error
  @keys [:player_id, :quantity, :maximum_unit_price, :expires_at]

  def validate(%AuthenticatedActor{account_id: owner}, terms) when is_map(terms) do
    with true <- Enum.sort(Map.keys(terms)) == Enum.sort(@keys),
         {:ok, owner} <- identifier(owner),
         {:ok, player} <- identifier(terms.player_id),
         quantity when is_integer(quantity) and quantity in 1..100 <- terms.quantity,
         {:ok, price} <- money(terms.maximum_unit_price),
         {:ok, expiry} <- expiry(terms.expires_at) do
      {:ok,
       %{
         owner_id: owner,
         player_id: player,
         quantity: quantity,
         maximum_unit_price: price,
         expires_at: expiry
       }}
    else
      _ -> Error.new(:invalid_request, :invalid_request)
    end
  end

  def validate(%AuthenticatedActor{}, _), do: Error.new(:invalid_request, :invalid_request)
  def validate(_, _), do: Error.new(:unauthenticated, :unauthenticated)

  def identifier(id) when is_binary(id) and byte_size(id) == 36, do: Ecto.UUID.cast(id)
  def identifier(_), do: :error

  defp money(%Decimal{sign: 1, coef: c} = value) when is_integer(c) and c > 0 do
    if Decimal.equal?(value, Decimal.round(value, 2)), do: {:ok, value}, else: :error
  end

  defp money(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, ""} -> money(decimal)
      _ -> :error
    end
  end

  defp money(_), do: :error

  defp expiry(%DateTime{utc_offset: 0, std_offset: 0} = value),
    do: {:ok, %{value | microsecond: {elem(value.microsecond, 0), 6}}}

  defp expiry(value) when is_binary(value) do
    if Regex.match?(~r/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d{1,6})?(?:Z|\+00:00)$/, value) do
      case DateTime.from_iso8601(value) do
        {:ok, time, 0} -> expiry(time)
        _ -> :error
      end
    else
      :error
    end
  end

  defp expiry(_), do: :error
end

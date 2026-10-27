defmodule FootballMarket.Market.ConditionalOrders.InputTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.ConditionalOrderInput, as: Input
  alias FootballMarket.ConditionalOrdersCase, as: C

  test "exact finite cents and whole quantities with immutable allowlist and UTC expiry" do
    f = %{player: %{id: Ecto.UUID.generate()}}
    user = %{id: Ecto.UUID.generate()}

    for quantity <- [1, 100], price <- ["0.01", "1.00", Decimal.new("99.99")] do
      assert {:ok, result} =
               Input.validate(
                 C.actor(user),
                 C.terms(f, %{quantity: quantity, maximum_unit_price: price})
               )

      assert result.quantity == quantity
      assert Decimal.equal?(result.maximum_unit_price, price)
    end

    for expiry <- ["2099-01-01T00:00:00Z", "2099-01-01T00:00:00.1+00:00"] do
      assert {:ok, parsed} = Input.validate(C.actor(user), C.terms(f, %{expires_at: expiry}))
      assert elem(parsed.expires_at.microsecond, 1) == 6
    end

    for quantity <- [0, -1, 101, 1.0, "1", nil],
        do: invalid(user, C.terms(f, %{quantity: quantity}))

    for price <- [0, 1.0, "0", "-1", "NaN", "Infinity", "0.001", nil, "1abc"],
        do: invalid(user, C.terms(f, %{maximum_unit_price: price}))

    for expiry <- [
          nil,
          "",
          "tomorrow",
          "2026-01-01T00:00:00+01:00",
          "2099-01-01T00:00:00.1234567Z"
        ],
        do: invalid(user, C.terms(f, %{expires_at: expiry}))

    for key <- [:owner_id, :status, :unit_price, :total, :purchase_id],
        do: invalid(user, Map.put(C.terms(f), key, user.id))

    for key <- Map.keys(C.terms(f)), do: invalid(user, Map.delete(C.terms(f), key))
    assert {:error, %{kind: :unauthenticated}} = Input.validate(nil, C.terms(f))
  end

  defp invalid(user, terms),
    do: assert({:error, %{kind: :invalid_request}} = Input.validate(C.actor(user), terms))
end

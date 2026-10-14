defmodule FootballMarket.Market.InputTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  alias FootballMarket.Market.{Input, Error}

  test "canonical inputs and assertions are exact; designation is singleton" do
    p = Ecto.UUID.generate()
    u = Ecto.UUID.generate()
    assert {:ok, %{player_id: ^p, recipient_id: ^u}} = Input.validate(p, [u], %{})

    for price <- [1, Decimal.new("1.000")] do
      assert {:ok, _} =
               Input.validate(p, [u], %{recipient_id: u, quantity: 100, unit_price: price})
    end

    for {designation, reason} <- [
          {nil, :missing_designation},
          {[], :missing_designation},
          {[u, u], :ambiguous_designation},
          {[u, p], :ambiguous_designation},
          {["bad"], :invalid_recipient}
        ] do
      assert {:error, %Error{kind: :invalid_designation, reason: ^reason}} =
               Input.validate(p, designation, %{})
    end
  end

  test "malformed IDs maps floats and unknown assertions fail deterministically" do
    p = Ecto.UUID.generate()
    u = Ecto.UUID.generate()

    for attrs <- [
          %{quantity: 99},
          %{quantity: 100.0},
          %{unit_price: 1.0},
          %{unit_price: Decimal.new("NaN")},
          %{unit_price: 2},
          %{recipient_id: p},
          %{effective_at: DateTime.utc_now()},
          %{"quantity" => 100},
          nil,
          []
        ] do
      assert {:error, %Error{kind: :invalid_input}} = Input.validate(p, [u], attrs)
    end

    for id <- [nil, 1, "bad"] do
      assert {:error, %Error{kind: :invalid_input}} = Input.validate(id, [u], %{})
    end

    assert Error.new(:invalid_input, :transaction_in_progress) ==
             {:error, %Error{kind: :invalid_input, reason: :transaction_in_progress}}

    assert Input.validate(p, [u], %{quantity: 5}) == Input.validate(p, [u], %{quantity: 5})
    refute File.read!("lib/football_market/market/input.ex") =~ "String.to_atom"
  end
end
